TABLESPACE 의 사용량을 조회하는 VIEW

VIEW 컬럼
  CLUSTER_NAME      : 클러스터명 ( STANDALONE 인 경우 STANDALONE )
  TABLESPACE_NAME   : 테이블스페이스명
  TOTAL_MEGABYTE    : 테이블스페이스에 잡힌 총 크기
  USED_MEGABYTE     : 테이블스페이스 사용된 공간
  FREE_MEGABYTE     : 테이블스페이스에 남은 공간
  FREE_PERCENTAGE   : 남은 공간을 퍼센트로 계산


VIEW 사용법
GSQL> SELECT * FROM TECH_TABLESPACE;

CLUSTER_NAME TABLESPACE_NAME TOTAL_MEGABYTE USED_MEGABYTE FREE_MEGABYTE FREE_PERCENTAGE
------------ --------------- -------------- ------------- ------------- ---------------
STANDALONE   DICTIONARY_TBS          256.00         80.31        175.68           68.62
STANDALONE   MEM_DATA_TBS             32.00          8.25         23.75           74.21
STANDALONE   MEM_TEMP_TBS             32.00          2.50         29.50           92.18
STANDALONE   MEM_UNDO_TBS             32.00         16.00         16.00           50.00