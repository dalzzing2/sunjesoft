UNUSED 된 컬럼의 정보를 조회하는 VIEW

VIEW 컬럼
  USER_NAME      : 사용자 명
  SCHEMA_NAME    : 스키마 명
  TABLE_NAME     : 테이블 명
  COLUMN_ID      : 컬럼 ID
  IS_UNUSED      : UNUSED 값

VIEW 사용법
gSQL> SELECT * FROM TECH_UNUSED_COL;

USER_NAME SCHEMA_NAME TABLE_NAME COLUMN_ID IS_UNUSED
--------- ----------- ---------- --------- ---------
TEST      PUBLIC      T1            102861 TRUE     

1 row selected.
