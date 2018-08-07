#!/bin/sh
file_path=$(readlink -f "$0")
folder_path=$(dirname "${file_path}")
today=$(date '+%Y%m%d_%H%M%S')
backup_folder="${folder_path}/${today}"
info="[INFORMATION]"
fatal="[FATAL]      "

help() {
    echo ""
    echo "Usage"
    echo "  $ sh goldilocks_backup.sh user_name password"
    echo "  $ sh goldilocks_backup.sh [OPTIONS] user_name password"
    echo ""
    echo "arguments:"
    echo "    user_name   user name"
    echo "    password    password"
    echo ""
    echo "options:"
    echo "    -h         Print Help Messages"
    echo "    -m [i|h|c] Set Backup Mode               (Default : h) [ ONLINE : Incremental (i), Full (h) ][ OFFLINE : Full (c) ]"
    echo "    -p PATH    Set Absolute Destination Path (Default : current path)"
    exit 0
}

while getopts "m:p:h" opt
do
    case $opt in
        m) mode=$OPTARG
          ;;
        p) path=$OPTARG
          ;;
        h) help ;;
        ?) help ;;
    esac
done

if [[ "${mode}" == "" ]]
then
  mode="h"
fi

if [[ "${path}" == "" ]]
then
  path=${folder_path}
fi

shift $(( $OPTIND - 1))
user_id=$1
user_pw=$2

function Chk_argu
{
if [[ "${user_id}" == "" ]]
then
  Logging "${fatal}" "UserID is invalid."
  help
  exit 0
fi

if [[ "${user_pw}" == "" ]]
then
  Logging "${fatal}" "UserPW is invalid."
  help
  exit 0
fi

if [[ ! -d "${path}" ]]
then
  Logging "${fatal}" "Path is invalid."
  help
  exit 0
fi

if [[ "${mode}" == "h" ]] || [[ "${mode}" == "i" ]] || [[ "${mode}" == "c" ]]
then
  Logging "${info}" "GOLDILOCKS BACKUP START"
else
  Logging "${fatal}" "Mode is invalid."
  help
  exit 0
fi

session="gsql ${user_id} ${user_pw} --no-prompt"

Logging "${info}" "START TIME  = ${today}"
Logging "${info}" "BACKUP MODE = ${mode}"
Logging "${info}" "BACKUP PATH = ${path}"
Logging "${info}" "USER ID     = ${user_id}"
#Logging "${info}" "USER PW     = ${user_pw}"
}

function Logging
{
  echo "[$(date '+%Y%m%d_%H%M%S')] $1 $2" | tee -a goldilocks_backup.log
}

function Chk_Session
{
$session << EOF
quit
EOF
}

function Chk_Grant_before_backup
{
# Alter Database 권한
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
SELECT '@grant_success' AS CHK FROM DBA_DB_PRIVS WHERE GRANTEE=(SELECT USER FROM DUAL) AND PRIVILEGE = 'ALTER DATABASE';
quit
EOF
}

function Chk_DBName
{
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
SELECT '@' || NVL(CLUSTER_MEMBER_NAME, 'STANDALONE') AS CHK FROM DUAL;
quit
EOF
}

function Chk_DBFile_before_backup
{
# V$DB_FILE
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
SELECT '@' || FILE_NAME AS CHK FROM V\$DB_FILE;
quit
EOF
}

function Chk_BeginBackup
{
if [[ "${db_name}" == "STANDALONE" ]]
then
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
ALTER DATABASE BEGIN BACKUP;
quit
EOF
else
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
ALTER DATABASE BEGIN BACKUP AT ${db_name};
quit
EOF
fi
}

function Chk_EndBackup
{
if [[ "${db_name}" == "STANDALONE" ]]
then
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
ALTER DATABASE END BACKUP;
quit
EOF
else
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
ALTER DATABASE END BACKUP AT ${db_name};
quit
EOF
fi
}

function Chk_EndBackup2
{
  while true;
  do
    db_ebackup=`Chk_EndBackup`
    db_ebackup=`echo ${db_ebackup} | sed 's/\n//g'`
    if [[ "${db_ebackup}" == *"Database altered."* ]] || [[ "${db_ebackup}" == *"ERR-HY000(14080): cannot end backup; database is not in backup"* ]]
    then
     Logging "${info}" "ALTER DATABASE END BACKUP AT ${db_name}"
     Logging "${info}" "${db_ebackup}"
     break;
    else
     Logging "${info}" "ALTER DATABASE END BACKUP AT ${db_name}"
     Logging "${fatal}" "${db_ebackup}"
     sleep 1
    fi
  done
}

function Chk_Space_before_backup
{
# DB Size vs FileSystem Size

backup_space=`echo ${path} | df -k | tail -1 | awk '{print $4*1024}'`
Logging "${info}" "${path} is available size ${backup_space} Bytes"

i=0
each_file_sumsize=0
while [[ "${db_file}" != "" ]]
do
  db_file=${db_file#*@}
  each_file[$i]=`echo ${db_file} | cut -d'@' -f1 | sed 's/ //g'`

  if [[ -f "${each_file[$i]}" ]]
  then
    each_file_size=`ls -al ${each_file[$i]} | awk '{print $5}'`
    each_file_sumsize=`expr ${each_file_sumsize} + ${each_file_size}`
    Logging "${info}" "${each_file[$i]} size is ${each_file_size} Bytes"
  else
    Logging "${info}" "${each_file[$i]} does not exist"
  fi

  if [[ "${each_file_sumsize}" -ge "${backup_space}" ]]
  then
    Logging "${fatal}" "Backup Size is greater than ${each_file_sumsize} Bytes. It requires more Available Bytes on disk"
    Chk_EndBackup2
    Logging "${fatal}" "Backup Failure."
    exit 0;
  fi

  if [[ "${db_file}" == "${each_file[$i]}" ]]
  then
    break;
  fi
  i=`expr $i + 1`
done

state=0
while [[ $i -ge 0 ]]
do
  location_file="location.ctl"
  from_file=`echo "${each_file[$i]}" | sed 's/\/\//\//g'`
  to_file=`echo "${path}/${today}/${from_file%/*}" | sed 's/\/\//\//g'`

  if [[ ! -d "${to_file}" ]]
  then
    mkdir -p ${to_file}
  fi

  location_file=${from_file%/*}/${location_file}

  if [[ -f "${location_file}" ]] && [[ $state -eq 0 ]]
  then
    cp ${location_file} ${to_file}
    if [[ $? -eq 0 ]]
    then
      Logging "${info}" "From ${location_file} To ${to_file}/${location_file##*/}"
      state=1
    else
      Logging "${fatal}" "From ${location_file} To ${to_file}/${location_file##*/}"
      Chk_EndBackup2
      Logging "${fatal}" "Backup Failure."
      exit 0;
    fi
  fi


  if [[ -f "${from_file}" ]]
  then
    cp ${from_file} ${to_file}
    if [[ $? -eq 0 ]]
    then
      Logging "${info}" "From ${from_file} To ${to_file}/${from_file##*/}"
    else
      Logging "${fatal}" "From ${from_file} To ${to_file}/${from_file##*/}"
      Chk_EndBackup2
      Logging "${fatal}" "Backup Failure."
      exit 0;
    fi
  fi

  i=`expr $i - 1`
done
}


# main
pline=`ps -ef | grep "goldilocks_backup.sh" | grep -v "grep" | grep -v "$$" | wc -l`
if [[ $pline -ne 0 ]]
then
  Logging "${fatal}" "Goldilocks Backup Script is Already Started"
  exit 0;
fi

if [[ "${mode}" == "h" ]]
then
  Chk_argu
  db_session=`Chk_Session | grep "ERR-"`
  if [[ "${db_session}" != "" ]]
  then
    Logging "${fatal}" "${db_session}"
    exit 0
  fi

  db_grant=`Chk_Grant_before_backup | grep "^@"`
  if [[ "${db_grant}" == "" ]]
  then
    Logging "${fatal}" "ERR-42000(16210): lacks privilege (ALTER DATABASE ON DATABASE)"
    exit 0
  fi

  db_name=`Chk_DBName | grep "^@" | sed 's/ //g' | cut -d '@' -f2`
  if [[ "${db_name}" != "" ]]
  then
    Logging "${info}" "DB NAME     = ${db_name}"
  else
    Logging "${fatal}" "DB NAME     = ${db_name}"
    exit 0
  fi

  db_sbackup=`Chk_BeginBackup`
  db_sbackup=`echo ${db_sbackup} | sed 's/\n//g'`
  if [[ ${db_sbackup} == *"ERR-"* ]]
  then
    Logging "${info}" "ALTER DATABASE BEGIN BACKUP AT ${db_name}"
    Logging "${fatal}" "${db_sbackup}"
    exit 0
  else
    Logging "${info}" "ALTER DATABASE BEGIN BACKUP AT ${db_name}"
    Logging "${info}" "${db_sbackup}"
  fi

  db_file=`Chk_DBFile_before_backup | grep "^@" | sed 's/ //g'`
  if [[ ${db_file} == *"ERR-"* ]]
  then
    Logging "${fatal}" "${db_file}"
    Chk_EndBackup2
    Logging "${fatal}" "Backup Failure."
    exit 0
  fi

  Chk_Space_before_backup

  Chk_EndBackup2
  if [[ "${db_ebackup}" == *"Database altered."* ]]
  then
    Logging "${info}" "Backup Success."
  else
    Logging "${fatal}" "Backup Failure."
  fi
elif [[ "${mode}" == "i" ]]
then
  Logging "${fatal}" "Not Yet Support Mode"
  exit 0
elif [[ "${mode}" == "c" ]]
then
  Logging "${fatal}" "Not Yet Support Mode"
  exit 0
else
  Logging "${fatal}" "Mode is invalid."
  help
  exit 0
fi