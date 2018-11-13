#!/bin/sh
######################################################################################
# Createion 2018_03_28 18:16
# Made By SH
# Record All Tables that belongs to GOLDILOCKS
# sh goldilocks_table_count.sh
######################################################################################
FILE_PATH=$(readlink -f "$0")
FOLDER_PATH=$(dirname "${FILE_PATH}")
TODAY=$(date '+%Y%m%d')
FOLDER="${FOLDER_PATH}/${TODAY}"

#FOLDER=$(date '+%Y%m%d')
if [[ ! -d ${FOLDER} ]]
then
  mkdir ${FOLDER}
fi

DATE=$(date '+%Y%m%d_%H%M%S')
table_list_count_log_file="${DATE}.log"

##########################################################################################################
# Function
# 모든함수의 결과는 ORDER BY 절에 TABLE_SCHEMA, TABLE_NAME, GROUP_ID, MEMBER_ID, MEMBER_NAME 으로 출력순서를 보장한다.
##########################################################################################################
SCHEMA_NOT_IN="'DEFINITION_SCHEMA', 'FIXED_TABLE_SCHEMA', 'DICTIONARY_SCHEMA', 'INFORMATION_SCHEMA', 'PERFORMANCE_VIEW_SCHEMA', 'SESSION_SCHEMA'"

function Each_Group_Table_Count()
{
gsqlnet SYS gliese --as sysdba --no-prompt << EOF
\set linesize 1024
\set pagesize 10000
\set timing off
SELECT 'SELECT COUNT(*) AS "' || TABLE_SCHEMA || '.' || TABLE_NAME || '" FROM ' || TABLE_SCHEMA || '.' || TABLE_NAME || '@' || MEMBER_NAME ||';__EACH_GROUP_TABLE_COUNT_' AS EACH_GROUP_COUNT FROM DBA_ALL_TABLES@LOCAL, CLUSTER_MEMBER@LOCAL WHERE TABLE_SCHEMA NOT IN(${SCHEMA_NOT_IN}) ORDER BY TABLE_SCHEMA, TABLE_NAME, GROUP_ID, MEMBER_ID, MEMBER_NAME;
\quit
EOF
}
function Execute_Each_Group_Table_Count()
{
gsqlnet SYS gliese --as sysdba --no-prompt << EOF
\set linesize 1024
\set pagesize 10000
\set timing off
${each_group_table_query}
\quit
EOF
}

function All_Group_Table_Count()
{
gsqlnet SYS gliese --as sysdba --no-prompt << EOF
\set linesize 1024
\set pagesize 10000
\set timing off
SELECT 'SELECT COUNT(*) AS "' || TABLE_SCHEMA || '.' || TABLE_NAME || '" FROM ' || TABLE_SCHEMA  || '.' || TABLE_NAME || ';__ALL_GROUP_TABLE_COUNT_' AS ALL_GROUP_COUNT FROM ALL_TABLES WHERE TABLE_SCHEMA NOT IN (${SCHEMA_NOT_IN}) ORDER BY TABLE_SCHEMA, TABLE_NAME;
\quit
EOF
}
function Execute_All_Group_Table_Count()
{
gsqlnet SYS gliese --as sysdba --no-prompt << EOF
\set linesize 1024
\set pagesize 10000
\set timing off
${all_group_table_query}
\quit
EOF
}

function Table_List()
{
gsqlnet SYS gliese --as sysdba --no-prompt << EOF
\set linesize 1024
\set pagesize 10000
\set timing off
SELECT TABLE_SCHEMA || '.' || TABLE_NAME || '__TABLE_LIST_' AS TABLE_LIST FROM ALL_TABLES@LOCAL WHERE TABLE_SCHEMA NOT IN (${SCHEMA_NOT_IN}) ORDER BY TABLE_SCHEMA, TABLE_NAME;
\quit
EOF
}

function Each_Member_Name()
{
gsqlnet SYS gliese --as sysdba --no-prompt << EOF
\set linesize 1024
\set pagesize 10000
\set timing off
SELECT MEMBER_NAME || '__MEMBER_NAME_' AS MEMBER_NAME FROM CLUSTER_MEMBER@LOCAL ORDER BY GROUP_ID, MEMBER_ID, MEMBER_NAME;
\quit
EOF
}


echo "==================================================================================================================================" | tee -a ${table_list_count_log_file}
echo "- 검사시간 ${DATE}" | tee -a ${table_list_count_log_file}
echo "==================================================================================================================================" | tee -a ${table_list_count_log_file}
# Execute Function
# 함수를 수행하여 쿼리결과값을 받아온다.
##########################################################################################################
echo "Database Table List Loading.."
table_list_query_result=`Table_List | grep "__TABLE_LIST_" | sed 's/__TABLE_LIST_/,/g' | sed 's/ //g'`
#echo ${table_list_query_result}
if [[ ${table_list_query_result} == "" ]]
then
  echo "  [ERROR] Table not exists" | tee -a ${table_list_count_log_file}
  exit 
fi

echo "Database Member Name Loading.."
each_member_name_query_result=`Each_Member_Name | grep "__MEMBER_NAME_" | sed 's/__MEMBER_NAME_/,/g' | sed 's/ //g'`
#echo ${each_member_name_query_result}
if [[ ${table_list_query_result} == "" ]]
then
  echo "  [ERROR] Database Member not exists" | tee -a ${table_list_count_log_file}
  exit 
fi

echo "Database Table Count Loading.."
all_group_table_query=`All_Group_Table_Count | grep "__ALL_GROUP_TABLE_COUNT_" | sed 's/__ALL_GROUP_TABLE_COUNT_//g'`
all_group_table_query_result=`Execute_All_Group_Table_Count | sed '/row selected./d'`
#echo ${all_group_table_query_result}

echo "Each Member Table Count Loading.."
each_group_table_query=`Each_Group_Table_Count | grep "__EACH_GROUP_TABLE_COUNT_" | sed 's/__EACH_GROUP_TABLE_COUNT_//g'`
each_group_table_query_result=`Execute_Each_Group_Table_Count | sed '/row selected./d'`
#echo ${each_group_table_query_result}


##########################################################################################################
# Pharsing
# 결과값을 구조체변수에 담는다.
##########################################################################################################
echo "Pharsing.."
while_table_list=0
while [[ ${table_list_query_result} != "" ]]
do
  table[$while_table_list]=`echo ${table_list_query_result} | cut -d',' -f1`
  table_list_query_result=${table_list_query_result#*,}
  while_table_list=`expr $while_table_list + 1`
done
#echo ${while_table_list}

while_member_count=0
while [[ ${each_member_name_query_result} != "" ]]
do
  member[$while_member_count]=`echo ${each_member_name_query_result} | cut -d',' -f1`
  each_member_name_query_result=${each_member_name_query_result#*,}
  while_member_count=`expr $while_member_count + 1`
done
#echo ${while_member_count}

while_all_group_table_count=0
while [[ ${while_all_group_table_count} -lt ${while_table_list} ]]
do
  all_group_table_count_location=`expr \( ${while_all_group_table_count} \* 3 \) + 3`
  all_group_count[$while_all_group_table_count]=`echo ${all_group_table_query_result} | awk '{print $'${all_group_table_count_location}'}'`
  while_all_group_table_count=`expr ${while_all_group_table_count} + 1`
done

while_each_group_table_count=0
while [[ ${while_each_group_table_count} -lt `expr ${while_member_count} \* ${while_table_list}` ]]
do
  each_group_table_count_location=`expr \( ${while_each_group_table_count} \* 3 \) + 3`
  each_group_count[$while_each_group_table_count]=`echo ${each_group_table_query_result} | awk '{print $'${each_group_table_count_location}'}'`
   
  while_each_group_table_count=`expr ${while_each_group_table_count} + 1`
done


##########################################################################################################
# Output
##########################################################################################################
output_member=0
printf "%30s" "TABLE_NAME" | tee -a ${table_list_count_log_file}
while [[ $output_member -lt $while_member_count ]]
do
  printf "%10s" ${member[$output_member]} | tee -a ${table_list_count_log_file}
  output_member=`expr ${output_member} + 1`
done
printf "%10s\n" "TOTAL" | tee -a ${table_list_count_log_file}

output_table_sum=0
output_each_table=0
output_each_table_count=0
while [[ ${output_table_sum} -lt $while_table_list ]]
do
  printf "%30s" ${table[$output_table_sum]} | tee -a ${table_list_count_log_file}

  while [[ ${output_each_table} -lt ${while_member_count} ]]
  do
    printf "%'10d" ${each_group_count[$output_each_table_count]} | tee -a ${table_list_count_log_file}
    output_each_table_count=`expr ${output_each_table_count} + 1`
    output_each_table=`expr $output_each_table + 1`
  done

  printf "%'10d\n" ${all_group_count[$output_table_sum]} | tee -a ${table_list_count_log_file}

  output_each_table=0
  output_table_sum=`expr $output_table_sum + 1`
done

mv ${table_list_count_log_file} ${FOLDER}