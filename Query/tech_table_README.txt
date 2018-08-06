TABLE 의 사용량을 조회하는 VIEW


VIEW 컬럼
  OWNER            : 테이블 소유자
  TAB_SCHEMA       : 테이블 스키마
  TAB_NAME         : 테이블 이름
  LOC_USE_MBYTE    : Local 에서의 테이블 사용량
  TBS_NAME         : 테이블이 저장된 테이블스페이스 이름
  LOC_TBS_USE_PERC : 테이블이 테이블스페이스를 사용하는 퍼센트
  CLU_USE_MBYTE    : Cluster 에서의 테이블 사용량


VIEW 사용법
gSQL> SELECT * FROM TECH_TABLE;

OWNER  TAB_SCHEMA TAB_NAME            LOC_USE_MBYTE TBS_NAME     LOC_TBS_USE_PERC CLU_USE_MBYTE
------ ---------- ------------------- ------------- ------------ ---------------- -------------
TEST   PUBLIC     TEST_02                      0.50 MEM_DATA_TBS             0.38          4.50