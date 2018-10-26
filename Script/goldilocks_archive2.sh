############################################################################
# goldilocks_backup.sh 스크립트와 연관있는 스크립트
# 마지막 백업성공한 폴더의 리두로그 시퀀스 - 리두로그 그룹수 이전의 아카이브로그를 지운다
############################################################################

#!/bin/sh

today=$(date '+%Y%m%d')
info="[INFORMATION]"
fatal="[FATAL]      "

log="goldilocks_archive2.log"
backup_log="${PWD}/goldilocks_backup.log"

last2=`ls -alt ${PWD} | grep $(date '+%Y') | sort -r | head -1 | awk '{print $9}'`
last="${PWD}/${last2}"

############################################################################
# Opt
############################################################################

help() {
  echo ""
  echo "Usage"
  echo "    $ sh goldilocks_archive.sh user_name password"
  echo "    $ sh goldilocks_archive.sh [OPTIONS] user_name password"
  echo ""
  echo "arguments:"
  echo "    user_name  user name"
  echo "    password   password"
  echo ""
  echo "options:"
  echo "    -h         Print Help Messages"
  echo "    -p         Set Absolute Archive Log Path   (Default : ${GOLDILOCKS_DATA}/archive_log)"
  echo "    -q         Set Absolute BackUp Folder Path (Default : ${last})"
  echo "    -w         Set Absolute Backup Log File    (Default : ${backup_log})"
  exit 0
}

while getopts "p:q:w:h" opt
do
  case $opt in
    p) pa=$OPTARG
      ;;
    q) qa=$OPTARG
      ;;
    w) wa=$OPTARG
      ;;
    h) help
      exit 0 ;;
    ?) help
      exit 0 ;; 
  esac
done

if [[ "${pa}" == "" ]]
then
  pa="${GOLDILOCKS_DATA}/archive_log"
fi
if [[ "${qa}" == "" ]]
then
  qa="${last}"
fi
if [[ "${wa}" == "" ]]
then
  wa="${backup_log}"
fi

shift $(( $OPTIND -1 ))
id=$1
pw=$2

############################################################################
# function
############################################################################
function Logging
{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1 $2" | tee -a ${log}
}

function Chk_argu
{
if [[ "${id}" == "" ]]
then
  help
  exit 0;
fi

echo "" >> ${log}
Logging "${info}" "[ ARCHIVE LOG DELETE START ]"

if [[ "${last2}" == "" ]]
then
  Logging "${fatal}" "Cannot Find Last Backup Folder"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
if [[ ! -d "${pa}" ]]
then
  Logging "${fatal}" "Path is invalid."
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
if [[ ! -d "${qa}" ]]
then
  Logging "${fatal}" "Backup Path is invalid."
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
if [[ ! -f "${wa}" ]]
then
  Logging "${fatal}" "Backup Log File is invalid."
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
if [[ "${pw}" == "" ]]
then
  Logging "${fatal}" "Password is invalid."
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi

se="gsqlnet ${id} ${pw} --no-prompt"

Logging "${info}" "START TIME          = $(date '+%Y-%m-%d %H:%M:%S')"
Logging "${info}" "USER ID             = ${id}"
Logging "${info}" "ARCH PATH           = ${pa}"
Logging "${info}" "LAST BACKUP FOLDER  = ${qa}"
Logging "${info}" "BACKUP LOG FILE     = ${wa}"
}

function Group_Count
{
$se << EOF
set linesize 1024
set pagesize 1024
set timing off
SELECT '@' || COUNT(*) AS QUERY FROM X\$LOG_GROUP@LOCAL;
quit
EOF
}
function Archive_Prefix
{
$se << EOF
set linesize 1024
set pagesize 1024
set timing off
SELECT '@' || ARCHIVELOG_FILE AS QUERY FROM X\$ARCHIVELOG@LOCAL;
quit
EOF
}

############################################################################
# main
############################################################################
Chk_argu

# 리두로그 그룹 개수를 체크해야겠지
gc=`Group_Count | grep -e "^@" -e "ERR-"`
if [[ "${gc}" == *"ERR-"* ]]
then
  Logging "${fatal}" "${gc}"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
else
  gc=`echo ${gc} | cut -d '@' -f2`
  Logging "${info}" "LOG GROUP COUNT     = ${gc}"
fi
ap=`Archive_Prefix | grep -e "^@" -e "ERR-"`
if [[ "${ap}" == *"ERR-"* ]]
then
  Logging "${fatal}" "${ap}"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
else
  ap=`echo ${ap} | cut -d '@' -f2`
  Logging "${info}" "ARCH NAME PREFIX    = ${ap}"
fi


# 정상적으로 백업받은 마지막 폴더의 log 의 파일 시퀀스를 찾아야함 - 대체 어떻게?

last_folder=${last##*/}
if [[ ${last_folder} == "" ]]
then
  Logging "${fatal}" "Can Not find Last Backup Folder"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
# goldilocks_backup.log 파일에서 START TIME = ${last_folder} 의 라인을 찾는다.
# 해당 라인부터 가장 처음에 나오는 [ GOLDILOCKS BACKUP END ] 의 앞이 [FATAL] 이면 스크립트를 종료한다.
# 해당 라인부터 가장 처음에 나오는 [ GOLDILOCKS BACKUP END ] 의 앞이 [INFORMATION] 이면 다음 단계를 수행한다.
# 만약 백업로그의 프로세스 2개가 동시에 수행되서 로그순서가 깨졌다면? -> 보장안함
line=`grep -n "START TIME  = ${last_folder}" ${wa} | cut -d':' -f1`
if [[ ${line} == "" ]]
then
  Logging "${fatal}" "This ${last_folder} content is not in the ${wa}"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
sinfo=`sed -n "1,${line}!p" ${wa} | grep "\[ GOLDILOCKS BACKUP END \]" | head -1`
if [[ ${sinfo} == *"FATAL"* ]]
then
  Logging "${fatal}" "Last Backup Folder Status is failed"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
elif [[ ${sinfo} == *"INFORMATION"* ]]
then
  last_redo=`find ${last} -name 'redo*.log'`
  if [[ ! -f ${last_redo} ]]
  then
    Logging "${fatal}" "Can Not Find Last Redo Log File"
    Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
    exit 0;
  fi
  if [[ ${last_redo} == "" ]]
  then
    Logging "${fatal}" "Redo Log File of Last Backup Folder does not exist"
    Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
    exit 0;
  else
    Logging "${info}" "LAST REDO FILE      = ${last_redo}"
  fi
else
  Logging "${fatal}" "Can Not Find FATAL OR INFORMATION"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi

# find 로 리두 로그 파일을 찾은 뒤 해당 내용을 덤프해서 파일 시퀀스를 얻어온다.
file_sequence=`gdump LOG ${last_redo} -h | grep FILE_SEQUENCE | cut -d':' -f2 | sed 's/ //g'`
if [[ ${file_sequence} == "" ]]
then
  Logging "${fatal}" "Can not get FILESEQUENCE from Last Redo Log File"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
else
  Logging "${info}" "LAST REDO FILE SEQ  = ${file_sequence}"
fi
if [[ ! -n ${file_sequence} ]]
then
  Logging "${fatal}" "FILESEQUENCE is not number."
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi

need_arch=`expr ${file_sequence} - ${gc}`
Logging "${info}" "You should have at least the ${need_arch}th archive log."


# 마지막 아카이브의 시퀀스가 need_arch 보다 작으면 지우면 안됨
curr_arch=`ls -lt ${pa}/${ap}* | tail -1 | awk '{print $9}' | rev | cut -d'/' -f1 | cut -d'.' -f2 | cut -d'_' -f1 | rev`
Logging "${info}" "The Oldest File in the Archive folder is ${curr_arch}th."

# curr_arch 이 need_arch 보다 작은것들을 지운다
if [[ ${curr_arch} -gt ${need_arch} ]]
then
  Logging "${info}" "The Oldest Archive File Sequence is greater than expected"
  Logging "${info}" "[ ARCHIVE LOG DELETE END ]"
else
  while true;
  do
    old_file=`ls -lt ${pa}/${ap}* | tail -1 | awk '{print $9}'`
    curr_arch=`echo ${old_file} | rev | cut -d'/' -f1 | cut -d'.' -f2 | cut -d'_' -f1 | rev`
    if [[ ${curr_arch} -eq ${need_arch} ]]
    then
      Logging "${info}" "The Oldest Archive File Sequence is the same as expected."
      Logging "${info}" "[ ARCHIVE LOG DELETE END ]"
      break;
    else
      # 위험성 방지 1 : 아카이브 파일 Prefix 가 ${ap} 가 아니면 바로 중단, 파일명의 Prefix 가 archive 가 아니면 바로 중단
      if [[ ${old_file##*/} != "${ap}"* ]] || [[ ${old_file##*/} != *"archive"* ]]
      then
        Logging "${fatal}" "File Prefix is not ${ap}"
        Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
        exit 0;
      fi

      if [[ ${old_file} == "" ]]
      then
        Logging "${fatal}" "Old File is not exists"
        Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
        exit 0;
      fi
      if [[ ${old_file%/*} != "${pa}" ]]
      then
        Logging "${fatal}" "${old_file}"
        Logging "${fatal}" "Folder Name is not ${pa}"
        Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
        exit 0;
      fi
      if [[ ${old_file##*/} != "${ap}"* ]]
      then
        Logging "${fatal}" "${old_file}"
        Logging "${fatal}" "File Prefix is not ${ap}"
        Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
        exit 0;
      else
        # 또한 한번씩 지울때마다 백업폴더가 있는지를 확인한다. 이때는 백업폴더와 리두로그 파일로 체크한다.
        if [[ ! -f ${last_redo} ]]
        then
          Logging "${fatal}" "Can Not Find Last Redo Log File"
          Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
          exit 0;
        fi
        if [[ ! -d ${qa} ]]
        then
          Logging "${fatal}" "Can Not Find Last Backup Folder"
          Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
          exit 0;
        fi
        rm ${old_file}
        if [[ $? -eq 0 ]]
        then
          Logging "${info}" "Remove ${old_file}"
        else
          Logging "${fatal}" "Not Matched"
          Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
          exit 0;
        fi
      fi
    fi
  done
fi
