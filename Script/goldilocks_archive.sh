############################################################################
# goldilocks_archive.sh
# 입력받은 날짜 이전의 아카이브 로그를 삭제한다.
############################################################################

#!/bin/sh

today=$(date '+%Y%m%d')
info="[INFORMATION]"
fatal="[FATAL]      "
log="goldilocks_archive.log"

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
  echo "    -d         Set DATE                       (Default : ${today})"
  echo "    -p         Set Absolute Archive Log Path  (Default : ${GOLDILOCKS_DATA}/archive_log)"
  exit 0
}

while getopts "d:p:h" opt
do
  case $opt in
    d) da=$OPTARG
      ;;
    p) pa=$OPTARG
      ;;
    h) help
      exit 0 ;;
    ?) help
      exit 0 ;; 
  esac
done

if [[ "${da}" == "" ]]
then
  da=${today}
fi
if [[ "${pa}" == "" ]]
then
  pa="${GOLDILOCKS_DATA}/archive_log"
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

if [[ ! -d "${pa}" ]]
then
  Logging "${fatal}" "Path is invalid."
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
if ! [[ "${da}" =~ ^[0-9]+$ ]]
then
  Logging "${fatal}" "Date format is not number"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
fi
if [[ $(expr ${da} / 10000000) -lt 1 ]] || [[ $(expr ${da} / 10000000) -gt 9 ]]
then
  Logging "${fatal}" "Date format is invalid. Format is YYYYMMDD"
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

Logging "${info}" "START TIME   = $(date '+%Y-%m-%d %H:%M:%S')"
Logging "${info}" "ARCH PATH    = ${pa}"
Logging "${info}" "DELETE DATE  = ${da}"
Logging "${info}" "USER ID      = ${id}"
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
  Logging "${info}" "GROUP COUNT  = ${gc}"
fi
ap=`Archive_Prefix | grep -e "^@" -e "ERR-"`
if [[ "${ap}" == *"ERR-"* ]]
then
  Logging "${fatal}" "${ap}"
  Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
  exit 0;
else
  ap=`echo ${ap} | cut -d '@' -f2`
  Logging "${info}" "PREFIX       = ${ap}"
fi

ar_cnt=`ls -lt ${pa} | grep ${ap} | wc -l`
old_days=`echo $(( ( $(date -d "${today}" "+%s") - $(date -d "${da}" "+%s") ) / 86400))`
Logging "${info}" "find mtime   = ${old_days}"

# 아카이브가 리두로그 그룹 개수보다 적으면 날짜에 상관없이 지우면 안되고
if [[ ${ar_cnt} -le ${gc} ]]
then
  Logging "${info}" "Count of Archive Files is Log Group Count or Less"
  Logging "${info}" "[ ARCHIVE LOG DELETE END ]"
else
# 아카이브가 리두로그 그룹 개수보다 많으면 날짜 이전의 리두로그는 지우고
  while true;
  do
    ar_cnt=`ls -lt ${pa} | grep ${ap} | wc -l`
    # 아카이브 파일과 리두로그 그룹갯수가 동일할 때까지 지우는 작업을 수행
    if [[ ${ar_cnt} -eq ${gc} ]]
    then
      Logging "${info}" "Count of Archive Files is identical with Log Group Count"
      Logging "${info}" "[ ARCHIVE LOG DELETE END ]"
      break;
    else
      old_file=`ls -lt ${pa}/${ap}* | tail -1 | awk '{print $9}'`
      # 위험성 방지 1 : 아카이브 파일 Prefix 가 ${ap} 가 아니면 바로 중단, 파일명의 Prefix 가 archive 가 아니면 바로 중단
      if [[ ${old_file##*/} != "${ap}"* ]] || [[ ${old_file##*/} != *"archive"* ]]
      then
        Logging "${fatal}" "File Prefix is not ${ap}"
        Logging "${fatal}" "[ ARCHIVE LOG DELETE END ]"
        exit 0;
      fi

      if [[ ${old_days} -eq 0 ]]
      then
        old_file=`find ${old_file} -mtime ${old_days} -type f`
      fi
      if [[ ${old_days} -gt 0 ]]
      then
        old_days=`expr ${old_days} - 1`
        old_file=`find ${old_file} -mtime +${old_days} -type f`
      fi

      # 위험성 방지 2 : find 에서 해당 시간에 걸러진 파일명의 Prefix 가 ${ap} 가 아니면 바로 중단, 폴더경로가 ${pa} 가 아니면 바로 중단, find 로 안찾아 지는 경우
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
