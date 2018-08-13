CLUSTER 의 정보를 조회하는 VIEW

VIEW 컬럼
  G_ID           : 그룹 ID
  M_ID           : 멤버 ID
  M_POS          : 멤버 POSITION
  NAME           : 멤버 명
  STATUS         : 클러스터 연결 상태
  G_COORD        : GLOBAL COORDINATOR
  D_COORD        : DOMAIN COORDINATOR
  GLOBAL_SCN     : GLOBAL SCN
  LOCAL_SCN      : LOCAL SCN
  AGABLE_SCN     : LOCAL AGER SCN
  AGABLE_SCN_GAP : LOCAL AGER SCN GAP
  IP             : LOCAL IP
  PORT           : LOCAL PORT
  
VIEW 사용법
gSQL> SELECT * FROM TECH_CLUSTER;

G_ID M_ID M_POS NAME STATUS G_COORD D_COORD GLOBAL_SCN LOCAL_SCN  AGABLE_SCN AGABLE_SCN_GAP IP            PORT
---- ---- ----- ---- ------ ------- ------- ---------- ---------- ---------- -------------- ------------ -----
   1    1     0 G1N1 ACTIVE FALSE   TRUE    748.0.316  748.0.330  748.0.330  0.0.0          192.168.0.50 10000
   2    2     1 G2N1 ACTIVE TRUE    TRUE    748.0.1253 748.0.1264 748.0.1264 0.0.0          192.168.0.50 20000