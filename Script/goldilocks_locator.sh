#!/bin/sh

info="[INFO]  "
fata="[FATAL] "
conn="gsqlnet SYS gliese --as sysdba --no-prompt"

odbc=${ODBCINI}

if [[ ${odbc} == "" ]]
then
  odbc=$HOME/.odbc.ini
else
  odbc=${ODBCINI}
fi
loca=$HOME/.locator.ini


function Logging
{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1 $2"
}

function check_file
{
  dat=$(date '+%Y%m%d_%H%M%S')
  Logging "${info}" "========================================================"
  Logging "${info}" "Step 1. Check .odbc.ini & .locator.ini"
  Logging "${info}" "========================================================"
  if [[ -f ${odbc} ]]
  then
    odbc2="${odbc}_${dat}_tmp"
    Logging "${info}" "'${odbc}' exists. ${odbc2} created."
    odbc=${odbc2}
    touch ${odbc}
    if [[ $? -ne 0 ]]
    then
      Logging "${fata}" "${odbc}' is not created."
      exit -1;
    fi
  else
    Logging "${info}" "'${odbc}' does not exist. ${odbc} created."
    touch ${odbc}
    if [[ $? -ne 0 ]]
    then
      Logging "${fata}" "'${odbc}' is not created."
      exit -1;
    fi
  fi

  if [[ -f ${loca} ]]
  then
    loca2="${loca}_${dat}_tmp"
    Logging "${info}" "'${loca}' exists. ${loca2} created."
    loca=${loca2}
    touch ${loca}
    if [[ $? -ne 0 ]]
    then
      Logging "${fata}" "${loca}' is not created."
      exit -1;
    fi
  else
    Logging "${info}" "'${loca}' does not exist. ${loca} created."
    touch ${loca}
    if [[ $? -ne 0 ]]
    then
      Logging "${fata}" "'${loca}' is not created."
      exit -1;
    fi
  fi
}

function check_odbc
{
  Logging "${info}" "========================================================"
  Logging "${info}" "Step 2. Setup GOLDILOCKS & LOCATOR on .odbc.ini"
  Logging "${info}" "========================================================"
  grep "^\[GOLDILOCKS\]" ${odbc} >> /dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
    Logging "${info}" "[GOLDILOCKS] exists in '${odbc}'"
  else
    Logging "${info}" "[GOLDILOCKS] does not exist in '${odbc}'"

    if [[ ${cl} == *"ERR-"* ]]
    then
      Logging "${fata}" "Can not Access Database"
      exit -1;
    fi
    ip=`echo ${cl} | awk '{print $2}'`
    po=`glsnr --status | grep Port | awk '{print $8}'`
    
    echo -e "  Input Value for [GOLDILOCKS]"
    echo -e "    Input server HOST IP (default : ${ip}) : \c"
    read host
    if [[ x"${host}" == x"" ]]
    then
      host=${ip}
    fi

    echo -e "    Input server LISTENER PORT (default : ${po})  : \c"
    read port
    if [[ x"${port}" == x"" ]]
    then
      port=${po}
    fi

    echo "[GOLDILOCKS]" >> ${odbc}
    echo "HOST = ${host}" >> ${odbc}
    echo "PORT = ${port}" >> ${odbc}
    if [[ $? -ne 0 ]]
    then
      Logging "${fata}" "[GOLDILOCKS] failed to write into '${odbc}'"
      exit -1;
    fi
    Logging "${info}" "[GOLDILOCKS] succeed to write into '${odbc}'"
  fi


  fline=1
  gline=0
  state=0
  lline=0
  
  while read line; do
    if [[ ${state} -eq 1 ]] && [[ x"${line}" == x"["* ]]
    then
      break;
    fi

    if [[ "${line}" == "[GOLDILOCKS]" ]]
    then
      gline=${fline}
      state=1
    fi

    if [[ ${state} -eq 1 ]] && [[ "${line}" == "LOCATOR_DSN"* ]]
    then
      lline=1
      #Logging "${info}" "[GOLDILOCKS] has LOCATOR_DSN value in '${odbc}'"
      break;
    fi

    fline=`expr ${fline} + 1`
  done < ${odbc}
  
  loc="LOCATOR"
  grep "\[${loc}\]" ${odbc} >> /dev/null 2>&1
  if [[ $? -eq 0 ]]
  then
    Logging "${fata}" "[LOCATOR] DSN exists in '${odbc}'"
    exit -1;
  fi

  if [[ ${lline} -ne 1 ]]
  then
    #Logging "${info}" "[GOLDILOCKS] has not LOCATOR_DSN value in '${odbc}'"

    sed -i '/\[GOLDILOCKS\]/a LOCATOR_DSN = '${loc}'' ${odbc}
    if [[ $? -ne 0 ]]
    then
      Logging "${fata}" "[GOLDILOCKS] failed to write LOCATOR_DSN in '${odbc}'"
      exit -1;
    fi
    Logging "${info}" "[GOLDILOCKS] succeed to write LOCATOR_DSN in '${odbc}'"
  fi
  
  echo "[${loc}]" >> ${odbc}
  echo "FILE=${loca}" >> ${odbc}
  if [[ $? -eq 0 ]]
  then
    Logging "${info}" "[${loc}] succeed to write into '${odbc}'"
  else
    Logging "${fata}" "[${loc}] failed to write into '${odbc}'"
    exit -1;
  fi
}

function check_loc_info
{
${conn} << EOF
set timing off
set linesize 1024
set pagesize 1024
SELECT 'DATA ' || HOST AS HOST FROM X\$CLUSTER_LOCATION@LOCAL WHERE MEMBER_NAME = CLUSTER_MEMBER_NAME;
EOF
}
function check_clu_info
{
${conn} << EOF
set timing off
set linesize 1024
set pagesize 1024
SELECT 'DATA ' || MEMBER_NAME || ' ' || HOST || ',' AS CLUST FROM X\$CLUSTER_LOCATION@LOCAL ORDER BY 1;
EOF
}

function check_loca
{
  Logging "${info}" "========================================================"
  Logging "${info}" "Step 3. Setup Member DSN on .odbc.ini & .locator.ini"
  Logging "${info}" "========================================================"
  if [[ ${clu} == *"ERR-"* ]]
  then
    Logging "${fata}" "Can not Access Database"
    exit -1;
  fi
  while [[ ${clu} != "" ]]
  do
    dbName=`echo ${clu} | cut -d',' -f1 | awk '{print $2}'`
    dbIP=`echo ${clu} | cut -d',' -f1 | awk '{print $3}'`

    grep ${dbName} ${odbc}
    if [[ $? -eq 0 ]]
    then
      Logging "${info}" "[${dbName}] exists in '${odbc}'"
    else
      echo "[${dbName}]" >> ${odbc}
      echo "HOST = ${dbIP}" >> ${odbc}
      echo "PORT = ${port}" >> ${odbc}
      if [[ $? -ne 0 ]]
      then
        Logging "${fata}" "[${dbName}] failed to write into '${odbc}'"
      else
        Logging "${info}" "[${dbName}] succeed to write into '${odbc}'"
      fi
    fi

    grep ${dbName} ${loca}
    if [[ $? -eq 0 ]]
    then
      Logging "${info}" "[${dbName}] exists in '${loca}'"
    else
      echo "[${dbName}]" >> ${loca}
      echo "HOST = ${dbIP}" >> ${loca}
      echo "PORT = ${port}" >> ${loca}
      if [[ $? -ne 0 ]]
      then
        Logging "${fata}" "[${dbName}] failed to write into '${loca}'"
      else
        Logging "${info}" "[${dbName}] succeed to write into '${loca}'"
      fi
    fi

    clu=${clu#*,}
  done
}

# main
#Logging "${info}" "START"
cl=`check_loc_info | grep "DATA"`
clu=`check_clu_info | grep "DATA"`
check_file
check_odbc
check_loca