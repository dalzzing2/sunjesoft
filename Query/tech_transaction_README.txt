TRANSACTION 의 정보를 조회하는 VIEW

VIEW 컬럼
  MEMBER_NAME     : 멤버 명
  USER_NAME       : 계정 명
  USER_ID         : 계정 ID
  USER_SERIAL     : 계정 SERIAL
  CHARSET         : 계정 언어셋
  PROGRAM         : 접속 프로그램
  USER_LOGIN_TIME : 계정이 데이터베이스에 접속한 시간
  TRANSACTION_ID  : 트랜잭션 ID
  TRAN_BEGIN_TIME : 트랜잭션 시작 시간
  

VIEW 사용법  
gSQL> SELECT * FROM TECH_TRANSACTION;

MEMBER_NAME USER_NAME USER_ID USER_SERIAL CHARSET PROGRAM USER_LOGIN_TIME            TRANSACTION_ID TRAN_BEGIN_TIME           
----------- --------- ------- ----------- ------- ------- -------------------------- -------------- --------------------------
G1N1        SYS             4           1 UTF8    gsql    2018-08-08 15:26:42.502763       33292292 2018-08-08 15:55:23.107324