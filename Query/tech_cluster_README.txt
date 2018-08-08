CLUSTER 의 정보를 조회하는 VIEW

VIEW 컬럼
  G_ID       : 그룹 ID
  M_ID       : 멤버 ID
  M_POS      : 멤버 POSITION
  NAME       : 멤버 명
  STATUS     : 클러스터 연결 상태
  G_COORD    : GLOBAL COORDINATOR
  D_COORD    : DOMAIN COORDINATOR
  LOCAL_SCN  : 멤버 SCN
  AGABLE_SCN : 멤버 AGER SCN
  IP         : 멤버 IP
  PORT       : 멤버 PORT
  
VIEW 사용법
gSQL> SELECT * FROM TECH_CLUSTER;

G_ID M_ID M_POS NAME STATUS G_COORD D_COORD LOCAL_SCN AGABLE_SCN IP            PORT
---- ---- ----- ---- ------ ------- ------- --------- ---------- ------------ -----
   1    1     0 G1N1 ACTIVE TRUE    TRUE    592.0.19  592.0.19   192.168.0.50 10000
   2    2     1 G2N1 ACTIVE FALSE   TRUE    592.0.0   592.0.0    192.168.0.50 20000