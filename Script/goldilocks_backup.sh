##################################################################
# goldilocks_backup.sh
# 증분백업과 온라인핫백업을 수행한다.
##################################################################
#!/bin/sh

today=$(date '+%Y%m%d_%H%M%S')
file_path=$(readlink -f "$0")
folder_path=$(dirname "${file_path}")
backup_folder="${folder_path}/${today}"
info="[INFORMATION]"
fatal="[FATAL]      "
log="goldilocks_backup.log"

##################################################################
# Opt
##################################################################

help() {
    echo ""
    echo "Usage"
    echo "  $ sh goldilocks_backup.sh user_name password"
    echo "  $ sh goldilocks_backup.sh [OPTIONS] user_name password"
    echo ""
    echo "arguments:"
    echo "    user_name  user name"
    echo "    password   password"
    echo ""
    echo "options:"
    echo "    -h         Print Help Messages"
    echo "    -m [i|h]   Set Backup Mode                    (Default : h)  [ ONLINE : Incremental (i), Full (h) ]"
    echo "    -l LEVEL   Set Level of Incremental Backup    (Default : 0)"
    echo "    -p PATH    Set Absolute Destination Path      (Default : current path)"
    exit 0
}

while getopts "m:p:l:h" opt
do
    case $opt in
        m) mode=$OPTARG
          ;;
        p) path=$OPTARG
          ;;
        l) level=$OPTARG
          ;;
        h) help
           exit 0 ;;
        ?) help
           exit 0 ;;
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

if [[ "${level}" == "" ]]
then
  level=0
fi

shift $(( $OPTIND -1 ))
user_id=$1
user_pw=$2


##################################################################
# function
##################################################################
function Chk_argu
{
if [[ "${user_id}" == "" ]] || [[ "${user_pw}" == "" ]]
then
  help
  exit 0;
fi

if [[ "${mode}" == "h" ]] || [[ "${mode}" == "i" ]] || [[ "${mode}" == "c" ]]
then
  echo "" >> ${log}
  Logging "${info}" "[ GOLDILOCKS BACKUP START ]"
else
  Logging "${fatal}" "Mode is invalid."
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  help
  exit 0
fi

if [[ "${user_id}" == "" ]]
then
  Logging "${fatal}" "UserID is invalid."
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  help
  exit 0
fi

if [[ "${user_pw}" == "" ]]
then
  Logging "${fatal}" "UserPW is invalid."
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  help
  exit 0
fi

if [[ ! -d "${path}" ]]
then
  Logging "${fatal}" "Path is invalid."
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  help
  exit 0
fi
session="gsqlnet ${user_id} ${user_pw} --no-prompt"

Logging "${info}" "START TIME  = ${today}"
Logging "${info}" "BACKUP MODE = ${mode}"
  if [[ ${mode} == "i" ]]
  then
    Logging "${info}" "BACKUP LEVEL = ${level}"
  fi
Logging "${info}" "BACKUP PATH = ${path}"
Logging "${info}" "USER ID     = ${user_id}"
#Logging "${info}" "USER PW     = ${user_pw}"
}

function Logging
{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1 $2" | tee -a ${log}
  #echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1 $2" >> ${log}
}

function Chk_err
{
if [[ ${1} == *"ERR-"* ]]
then
  Logging "${fatal}" "${1}"
  Chk_EndBackup2
  Logging "${fatal}" "Backup Failure."
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  exit 0
fi
}

function Chk_Grant
{
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

function Chk_BeginBackup
{
if [[ ${db_name} == "STANDALONE" ]]
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

function Chk_Incremental_Backup
{
if [[ "${db_name}" == "STANDALONE" ]]
then
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
ALTER DATABASE BACKUP INCREMENTAL LEVEL ${level};
quit
EOF
else
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
ALTER DATABASE BACKUP INCREMENTAL LEVEL ${level} AT ${db_name};
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
    if [[ ${db_name} == "STANDALONE" ]]
    then
      Logging "${info}" "ALTER DATABASE END BACKUP"
      Logging "${info}" "${db_ebackup}"
    else
      Logging "${info}" "ALTER DATABASE END BACKUP AT ${db_name}"
      Logging "${info}" "${db_ebackup}"
    fi
    break;
  else
    if [[ ${db_name} == "STANDALONE" ]]
    then
      Logging "${info}" "ALTER DATABASE END BACKUP"
      Logging "${fatal}" "${db_ebackup}"
    else
      Logging "${info}" "ALTER DATABASE END BACKUP AT ${db_name}"
      Logging "${fatal}" "${db_ebackup}"
    fi
    sleep 1
  fi
done
}

function Chk_Hot_DBFile
{
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
SELECT '@' || FILE_NAME AS CHK FROM V\$DB_FILE WHERE FILE_TYPE NOT IN ('Redo Log File')
UNION ALL SELECT '@' || FILE_NAME AS CHK FROM V\$LOGFILE WHERE GROUP_STATE = 'CURRENT'
UNION ALL SELECT '@' || PROPERTY_VALUE AS CHK FROM V\$PROPERTY WHERE PROPERTY_NAME = 'LOCATION_FILE'
UNION ALL SELECT DISTINCT '@' || CONCAT(SUBSTR(FILE_NAME, 1, INSTR(FILE_NAME, '/', -1)), 'commit.log') AS CHK FROM V\$DB_FILE WHERE FILE_TYPE ='Redo Log File';
quit
EOF
}

function Chk_Inc_DBFile
{
$session << EOF
set linesize 1024
set pagesize 10000
set timing off
SELECT '@' || FILE_NAME AS CHK FROM V\$DB_FILE WHERE FILE_TYPE IN ('Config File', 'Trace Log File')
UNION ALL SELECT '@' || VP.PROPERTY_VALUE || '/' || VI.BACKUP_NAME AS CHK FROM V\$PROPERTY VP, V\$INCREMENTAL_BACKUP VI WHERE VP.PROPERTY_NAME = 'BACKUP_DIR_1'
UNION ALL SELECT '@' || FILE_NAME AS CHK FROM V\$LOGFILE WHERE GROUP_STATE = 'CURRENT'
UNION ALL SELECT '@' || PROPERTY_VALUE AS CHK FROM V\$PROPERTY WHERE PROPERTY_NAME = 'LOCATION_FILE'
UNION ALL SELECT DISTINCT '@' || CONCAT(SUBSTR(FILE_NAME, 1, INSTR(FILE_NAME, '/', -1)), 'commit.log') AS CHK FROM V$\DB_FILE WHERE FILE_TYPE ='Redo Log File' ;
EOF
}

function Copy
{
backup_space=`df -k ${path} | tail -1 | awk '{print $4*1024}'`
Logging "${info}" "Physical Free Size is ${backup_space} Bytes"
#Logging "${info}" "${path} is available size ${backup_space} Bytes"

i=0
j=0
each_file_sumsize=0

while [[ "${db_file}" != "" ]]
do
  db_file=${db_file#*@}
  each_file[$i]=`echo ${db_file} | cut -d'@' -f1 | sed 's/ //g'`


  if [[ -f "${each_file[$i]}" ]]
  then
    if [[ ! -r "${each_file[$i]}" ]]
    then
      echo "${each_file[$i]} Not Readable"
    fi
    each_file_size=`ls -al ${each_file[$i]} | awk '{print $5}'`
    each_file_sumsize=`expr ${each_file_sumsize} + ${each_file_size}`
    Logging "${info}" "${each_file[$i]} size is ${each_file_size} Bytes"
  fi

  if [[ "${each_file_sumsize}" -ge "${backup_space}" ]]
  then
    Logging "${fatal}" "Backup Size is greater than ${each_file_sumsize} Bytes. It requires more Available Bytes on disk"
    Chk_EndBackup2
    Logging "${fatal}" "Backup Failure."
    Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
    exit 0;
  fi

  if [[ "${db_file}" == ${each_file[$i]} ]]
  then
    break;
  fi
  i=`expr $i + 1`
  j=`expr $j + 1`
done

to_file="${path}/${today}"
mkdir -p ${to_file}

while [[ $i -ge 0 ]]
do
  from_file=`echo "${each_file[$i]}" | sed 's/\/\//\//g'`

  if [[ ! -d "${to_file}" ]]
  then
    Logging "${fatal}" "Directory Not Exists"
    Chk_EndBackup2
    Logging "${fatal}" "Backup Failure."
    Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
    exit 0;
  fi

  if [[ -f "${from_file}" ]]
  then
    mkdir -p ${to_file}${from_file%/*}
    if [[ ${from_file##*.} == "inc" ]]
    then
      mv ${from_file} ${to_file}${from_file}
    else
      cp ${from_file} ${to_file}${from_file}
    fi
    if [[ $? -eq 0 ]]
    then
      Logging "${info}" "From ${from_file} To ${to_file}${from_file}"
    else
      Logging "${fatal}" "Copy Failure"
      Logging "${fatal}" "From ${from_file} To ${to_file}${from_file}"
      Chk_EndBackup2
      Logging "${fatal}" "Backup Failure."
      Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
      exit 0;
    fi
  fi
  i=`expr $i - 1`
done

while [[ $j -ge 0 ]]
do
  if [[ -f ${each_file[$j]} ]]
  then
    if [[ ! -f "${to_file}${each_file[$j]}" ]]
    then
      Logging "${fatal}" "${to_file}${each_file[$j]} Not Exists"
      Chk_EndBackup2
      Logging "${fatal}" "Backup Failure."
      Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
      exit 0;
    fi
  fi
  j=`expr $j - 1`
done
}


##################################################################
# main
##################################################################
# Argument 체크
Chk_argu

# 백업 프로세스가 실행중인지 체크
pline=`ps -ef | grep "goldilocks_backup.sh" | grep -v "grep" | grep -v "$$" | wc -l`
if [[ $pline -ne 0 ]]
then
  Logging "${fatal}" "Goldilocks Backup Script is Already Started"
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  exit 0;
fi


# BACKUP 권한 체크
db_grant=`Chk_Grant | grep -e "^@" -e "ERR-"`
if [[ "${db_grant}" == *"ERR-"* ]]
then
  Logging "${fatal}" "${db_grant}"
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  exit 0
fi

# DBName 체크
db_name=`Chk_DBName | grep -e "^@" -e "ERR-" | cut -d '@' -f2`
if [[ "${db_name}" == *"ERR-"* ]]
then
  Logging "${fatal}" "${db_name}"
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  exit 0
else
  Logging "${info}" "DB NAME     = ${db_name}"
fi

# 백업모드 ON
db_sbackup=`Chk_BeginBackup`
db_sbackup=`echo ${db_sbackup} | sed 's/\n//g'`
if [[ ${db_sbackup} == *"ERR-"* ]]
then
  if [[ ${db_name} == "STANDALONE" ]]
  then
    Logging "${info}" "ALTER DATABASE BEGIN BACKUP"
    Logging "${fatal}" "${db_sbackup}"
  else
    Logging "${info}" "ALTER DATABASE BEGIN BACKUP AT ${db_name}"
    Logging "${fatal}" "${db_sbackup}"
  fi
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  exit 0
else
  if [[ ${db_name} == "STANDALONE" ]]
  then
    Logging "${info}" "ALTER DATABASE BEGIN BACKUP"
    Logging "${info}" "${db_sbackup}"
  else
    Logging "${info}" "ALTER DATABASE BEGIN BACKUP AT ${db_name}"
    Logging "${info}" "${db_sbackup}"
  fi
fi

# 백업
if [[ "${mode}" == "h" ]]
then
  # Hot Backup DB File 체크
  db_file=`Chk_Hot_DBFile | grep -e "^@" -e "ERR-" | sed 's/ //g'`
  Chk_err ${db_file}

  Copy
elif [[ "${mode}" == "i" ]]
then
  inc_end=`Chk_Incremental_Backup | grep -e "Database altered." -e "ERR-"`
  Chk_err ${inc_end}

  db_file=`Chk_Inc_DBFile | grep -e "^@" -e "ERR-" | sed 's/ //g'`
  Chk_err ${db_file0}

  Copy
elif [[ "${mode}" == "c" ]]
then
  Logging "${fatal}" "Not Yet Support Mode"
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  exit 0
else
  Logging "${fatal}" "Mode is invalid."
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
  help
  exit 0
fi

# 백업모드 OFF
Chk_EndBackup2

if [[ "${db_ebackup}" == *"Database altered."* ]]
then
  Logging "${info}" "Backup Success."
  Logging "${info}" "[ GOLDILOCKS BACKUP END ]"
else
  Logging "${fatal}" "Backup Failure."
  Logging "${fatal}" "[ GOLDILOCKS BACKUP END ]"
fi
