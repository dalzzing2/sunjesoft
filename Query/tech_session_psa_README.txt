접속한 세션의 PSA 영역을 조회하는 VIEW

VIEW 컬럼
  MEMBER_NAME           : 클러스터 멤버 명
  ID                    : 세션 ID
  SERIAL                : 세션 SERIAL
  PROGRAM               : 접속한 프로그램 명
  TOTAL_PSA_MEGA        : 최대 사용할 수 있는 크기 ( 단위 MB )
  USED_PSA_MEGA         : 현재 할당된 크기 ( 단위 MB )
  USED_PSA_PERCENTAGE   : 현재 할당된 크기의 퍼센트 

VIEW 사용법
gSQL> SELECT * FROM TECH_SESSION_PSA;

MEMBER_NAME ID SERIAL PROGRAM TOTAL_PSA_MEGA USED_PSA_MEGA USED_PSA_PERCENTAGE
----------- -- ------ ------- -------------- ------------- -------------------
STANDALONE  44      7 gsql    100.00         70.00         70.00              
STANDALONE  45     31 gsql    100.00         10.00         10.00              
STANDALONE  46     10 gsql    100.00         10.00         10.00              