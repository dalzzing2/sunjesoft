INDEX 의 사용량을 조회하는 VIEW

VIEW 컬럼
  OWNER            : 인덱스 소유자
  TAB_SCHEMA       : 테이블 스키마
  TAB_NAME         : 테이블 이름
  IDX_NAME         : 인덱스 이름
  LOC_USE_MBYTE    : Local 에서의 인덱스 사용량
  TBS_NAME         : 인덱스가 저장된 테이블스페이스 이름
  LOC_TBS_USE_PERC : 인덱스가 테이블스페이스를 사용하는 퍼센트
  CLU_USE_MBYTE    : Cluster 에서의 인덱스 사용량


VIEW 사용법
gSQL> SELECT * FROM TECH_INDEX;

OWNER TAB_SCHEMA TAB_NAME            IDX_NAME                              LOC_USE_MBYTE TBS_NAME     LOC_TBS_USE_PERC CLU_USE_MBYTE
----- ---------- ------------------- ------------------------------------- ------------- ------------ ---------------- -------------
TEST  PUBLIC     CYCLONE_SLAVE_STATE CYCLONE_SLAVE_STATE_PRIMARY_KEY_INDEX          0.50 MEM_TEMP_TBS             1.56          0.50
TEST  PUBLIC     PF_TEST             PF_TEST_PRIMARY_KEY_INDEX                      0.75 MEM_TEMP_TBS             2.34          0.75
TEST  PUBLIC     T1                  T1_PRIMARY_KEY_INDEX                           0.50 MEM_TEMP_TBS             1.56          0.50
TEST  PUBLIC     T2                  T2_PRIMARY_KEY_INDEX                           0.50 MEM_TEMP_TBS             1.56          0.50