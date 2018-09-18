#!/bin/sh

searchdir=.
for entry in $searchdir/tech_*.sql
do
  echo "gsqlnet SYS gliese --as sysdba -i ${entry}"
  gsqlnet SYS gliese --as sysdba -i ${entry} >> ${entry}.log

  grep "ERR-" ${entry}.log

  if [[ $? -eq 1 ]]
  then
    echo "  Success"
    rm ${entry}.log
  else
    echo "  Failure"
    echo "  Check ${entry}.log"
    exit -1
  fi
done