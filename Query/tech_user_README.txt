USER 의 정보를 조회하는 VIEW

VIEW 컬럼
  MEMBER_NAME     : 멤버 명
  USER_NAME       : 사용자 계정 명
  LOCK_STATUS     : 사용자 계정 잠금 상태
  TABLESPACE_TYPE : 테이블스페이스 타입
  TABLESPACE_NAME : 테이블스페이스 명
  
VIEW 사용 법
gSQL> SELECT * FROM TECH_USER;

MEMBER_NAME USER_NAME LOCK_STATUS TABLESPACE_TYPE TABLESPACE_NAME
----------- --------- ----------- --------------- ---------------
STANDALONE  SYS       OPEN        DATA            MEM_DATA_TBS   
STANDALONE  SYS       OPEN        TEMPORARY       MEM_TEMP_TBS   
STANDALONE  TEST      OPEN        DATA            MEM_DATA_TBS   
STANDALONE  TEST      OPEN        TEMPORARY       MEM_TEMP_TBS   