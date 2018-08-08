STATEMENT 의 정보를 조회하는 VIEW

VIEW 컬럼
  MEMBER_NAME     : 멤버 명
  STAT_BEGIN_TIME : STATEMENT 시작 시간
  USER_NAME       : 계정 명
  USER_ID         : 계정 ID
  USER_SERIAL     : 계정 SERIAL
  CHARSET         : 계정 언어셋
  PROGRAM         : 접속 프로그램
  USER_LOGIN_TIME : 계정이 데이터베이스에 접속한 시간
  SQL_TEXT        : STATEMENT SQL 구문
  
VIEW 사용법
gSQL> SELECT * FROM TECH_STATEMENT;

MEMBER_NAME STAT_BEGIN_TIME            USER_NAME USER_ID USER_SERIAL CHARSET PROGRAM USER_LOGIN_TIME            SQL_TEXT                    
----------- -------------------------- --------- ------- ----------- ------- ------- -------------------------- ----------------------------
G1N1        2018-08-08 16:38:08.427307 SYS             4           1 UTF8    gsql    2018-08-08 15:26:42.502763 SELECT * FROM TECH_STATEMENT