# goldilocks_user_obj.sh
#   사용자가 소유한 객체 생성 구문을 출력하는 스크립트
# 
# 제약사항
# 1. 버전 2.3 혹은 3.1 에서 사용 가능하다.
# 2. 리스너가 구동되어 있어야 한다.
# 3. SYS 계정의 비밀번호가 변경된 경우 스크립트의 CONN 변수값을 수정한다.
# 
# 사용법
# $ sh goldilocks_user_obj.sh USER_NAME
# 
# 도출물
# ddl_object_TEST_${DATA}
#   /func_proc             : 프로시저 및 함수 관련 생성 구문
#   /sequence              : 시퀀스 생성 구문
#   /synonym               : 시노님 생성 구문
#   /table_index           : 테이블 및 인덱스 생성 구문
#   /view                  : 뷰 생성 구문
#   obj_list.txt           : 사용자가 소유한 객체 리스트
#   obj_list.log           : 사용자가 소유한 객체 리스트의 생성 구문 파일 생성 성공 및 실패 체크
# 
#!/bin/sh

CONN='gsqlnet SYS gliese --as sysdba --no-prompt'
USR=$1
if [[ ${USR} == "" ]]
then
  USR='TEST'
fi

NOT_IN_SCHEMA_NAME="('DEFINITION_SCHEMA', 'FIXED_TABLE_SCHEMA', 'DICTIONARY_SCHEMA', 'INFORMATION_SCHEMA', 'PERFORMANCE_VIEW_SCHEMA')"
NOT_IN_OBJECT_NAME="('CYCLONE_SLAVE_STATE', 'CYCLONE_MONITOR_INFO', 'CYCLONEM_SLAVE_META')"
NOT_IN_OBJECT_TYPE="('INDEX')"

tod=$(date '+%Y%m%d_%H%M%S')
DAT="ddl_object_${USR}_${tod}"

function chk_acc(){
$CONN << EOF
EOF
}

function find_object(){
$CONN << EOF
\set timing off
\set linesize 10000
\set pagesize 10000
-- ddl_table 에 INDEX 가 포함되므로 INDEX TYPE 은 제거한다
SELECT '@' || OBJECT_TYPE || '@' || SCHEMA_NAME || '.' || OBJECT_NAME AS OBJEC
  FROM ALL_OBJECTS
  WHERE OWNER=UPPER('${USR}')
        AND SCHEMA_NAME NOT IN ${NOT_IN_SCHEMA_NAME}
        AND OBJECT_NAME NOT IN ${NOT_IN_OBJECT_NAME}
        AND OBJECT_TYPE NOT IN ${NOT_IN_OBJECT_TYPE}
  ORDER BY OBJECT_TYPE;
EOF
}

function makeddl_object(){
$CONN << EOF
\set timing off
\set linesize 1024
\set pagesize 1024
\set ddlsize 100000
${1} ${2}
EOF
}

# Main
mkdir $DAT
mkdir $DAT/table_index
mkdir $DAT/view
mkdir $DAT/func_proc
mkdir $DAT/synonym
mkdir $DAT/sequence

chk=`chk_acc | grep '^ERR-'`
if [[ ${chk} == *"ERR-"* ]]
then
  echo "${chk}"
  exit -1;
fi

obj=`find_object | grep -e '^@' -e '^ERR-'`
echo "${obj}" > ${DAT}/obj_list.txt

while [[ "${obj}" != "" ]]
do
  obj_type=`echo ${obj} | cut -d'@' -f2 | sed 's/ //g'`
  obj_type2=`echo ${obj} | cut -d'@' -f3 | sed 's/ //g'`
  #echo ${obj_type}
  #echo ${obj_type2}
  if [[ ${obj_type} == ${obj_type2} ]]
  then
    break;
  else
    if [[ ${obj_type} == "TABLE" ]]
    then
      makeddl_object "\\ddl_table" ${obj_type2} > ${DAT}/table_index/${obj_type2}.sql
      grep "ERR-" ${DAT}/table_index/${obj_type2}.sql
      if [[ $? -ne 0 ]]
      then
        echo "[TABLE&INDEX] ${obj_type2} success" | tee -a ${DAT}/obj_list.log
        sed -i '/^SET SESSION/d' ${DAT}/table_index/${obj_type2}.sql
      else
        echo "[TABLE&INDEX] ${obj_type2} failure" | tee -a ${DAT}/obj_list.log
      fi

    elif [[ ${obj_type} == "VIEW" ]]
    then
      makeddl_object "\\ddl_view" ${obj_type2} > ${DAT}/view/${obj_type2}.sql
      grep "ERR-" ${DAT}/view/${obj_type2}.sql
      if [[ $? -ne 0 ]]
      then
        echo "[VIEW] ${obj_type2} success" | tee -a ${DAT}/obj_list.log
        sed -i '/^SET SESSION/d' ${DAT}/view/${obj_type2}.sql
      else
        echo "[VIEW] ${obj_type2} failure" | tee -a ${DAT}/obj_list.log
      fi

    elif [[ ${obj_type} == "FUNCTION" ]] || [[ ${obj_type} == "PROCEDURE" ]]
    then
      makeddl_object "\\ddl_procedure" ${obj_type2} > ${DAT}/func_proc/${obj_type2}.sql
      grep "ERR-" ${DAT}/func_proc/${obj_type2}.sql
      if [[ $? -ne 0 ]]
      then
        echo "[FUNC&PROC] ${obj_type2} success" | tee -a ${DAT}/obj_list.log
        sed -i '/^SET SESSION/d' ${DAT}/func_proc/${obj_type2}.sql
      else
        echo "[FUNC&PROC] ${obj_type2} failure" | tee -a ${DAT}/obj_list.log
      fi

    elif [[ ${obj_type} == "SYNONYM" ]]
    then
      makeddl_object "\\ddl_synonym" ${obj_type2} > ${DAT}/synonym/${obj_type2}.sql
      grep "ERR-" ${DAT}/synonym/${obj_type2}.sql
      if [[ $? -ne 0 ]]
      then
        echo "[SYNONYM] ${obj_type2} success" | tee -a ${DAT}/obj_list.log
        sed -i '/^SET SESSION/d' ${DAT}/synonym/${obj_type2}.sql
      else
        echo "[SYNONYM] ${obj_type2} failure" | tee -a ${DAT}/obj_list.log
      fi

    elif [[ ${obj_type} == "SEQUENCE" ]]
    then
      makeddl_object "\\ddl_sequence" ${obj_type2} > ${DAT}/sequence/${obj_type2}.sql
      grep "ERR-" ${DAT}/sequence/${obj_type2}.sql
      if [[ $? -ne 0 ]]
      then
        echo "[SEQUENCE] ${obj_type2} success" | tee -a ${DAT}/obj_list.log
        sed -i '/^SET SESSION/d' ${DAT}/sequence/${obj_type2}.sql
      else
        echo "[SEQUENCE] ${obj_type2} failure" | tee -a ${DAT}/obj_list.log
      fi
    else
      echo "[ERROR] ${obj_type} ${obj_type2} NOT Support Object Type"
    fi
  fi
  obj=${obj#*@}
  obj=${obj#*@}
done