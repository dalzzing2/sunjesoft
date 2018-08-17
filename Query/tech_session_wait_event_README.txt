현재 연결중인 각 세션이 WAIT EVENT 별로 대기시간을 기록한 VIEW

VIEW 컬럼
  MEMBER_NAME    : 멤버 명
  ID             : 세션 ID
  SERIAL         : 세션 SERIAL
  PROGRAM        : 접속한 프로그램 명
  WAIT_ID        : WAIT Identifier
  WAIT_NAME      : WAIT 명
  WAIT_DESC      : WAIT 설명
  TOTAL_WAITS    : WAIT EVENT 대기 횟수
  TOTAL_TIMEOUTS : WAIT EVENT 타임아웃 횟수
  TIME_WAITED    : WAIT EVENT 를 위한 대기 타임의 총 량 ( 마이크로 세컨드 )
  AVERAGE_WAIT   : TIME_WAITED / TOTAL_WAITS ( 마이크로 세컨드 )
  MAX_WAIT       : 세션에서 EVENT 별로 WAIT 한 최대 시간 ( 마이크로 세컨드 )
  CLASS_NAME     : CLASS 명
  CLASS_DESC     : CLASS 설명

VIEW 사용법
gSQL> SELECT * FROM TECH_SESSION_WAIT_EVENT@LOCAL;

MEMBER_NAME ID SERIAL PROGRAM WAIT_ID WAIT_NAME                          WAIT_DESC                                            TOTAL_WAITS TOTAL_TIMEOUT TIME_WAITED AVERAGE_WAIT MAX_WAIT CLASS_NAME  CLASS_DESC                                        
----------- -- ------ ------- ------- ---------------------------------- ---------------------------------------------------- ----------- ------------- ----------- ------------ -------- ----------- --------------------------------------------------
G1N1        53    745 gsql         10 ENQUEUE: CLUSTER REQUEST           Waiting for enqueue cluster request.                         260             0        1334            5      282 OTHER       Waits which should not typically occur on a system
G1N1        53    745 gsql         11 ENQUEUE: CLUSTER BROADCAST REQUEST Waiting for enqueue cluster broadcast request.                48             0         224            4        9 OTHER       Waits which should not typically occur on a system
G1N1        53    745 gsql         12 DEQUEUE: CLUSTER RESPONSE          Waiting for dequeue cluster request.                         401           401      253041          631    24407 OTHER       Waits which should not typically occur on a system
G1N1        53    745 gsql         34 WAIT ENABLE LOGGING                Waiting for a logging available.                            3438             0         210            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         38 LATCH: LOG BUFFER                  Waiting for the log buffer latch.                           3437             0         331            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         40 LATCH: ENV MGR                     Waiting for the environment manager latch.                    41             0           3            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         42 LATCH: PCH                         Waiting for the page control Header latch.                 12847             0        1407            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         45 LATCH: ALLOC TRANS                 Waiting for the allocate transaction latch.                    3             0           1            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         46 LATCH: UNDO SEGMENT                Waiting for the undo segment latch.                            3             0           1            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         48 LATCH: DICT HASH ELEMENT AGING     Waiting for the dictionary hash element aging latch.         504             0          79            0        3 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         51 LATCH: TRACE LOG                   Waiting for the trace log latch.                              24             0           8            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         54 LATCH: SQL HANDLE                  Waiting for the SQL Handle latch.                             57             0          53            0        2 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         56 LATCH: PLAN CLOCK                  Waiting for the plan clock latch.                              7             0           0            0        0 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         59 LATCH: DYNAMIC MEM                 Waiting for the dynamic memory latch.                       4738             0         622            0        3 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         60 LATCH: PROPERTY                    Waiting for the property latch.                              231             0          15            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         70 LATCH: RECORD HASH                 Waiting for the record hash latch.                           362             0         142            0        9 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         72 LATCH: SEQUENCE                    Waiting for the sequence latch.                              140             0           7            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         73 LATCH: LOG STREAM                  Waiting for the log stream latch.                              2             0           0            0        0 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         74 LATCH: BUILD AGABLE SCN            Waiting for the build agable SCN latch.                        1             0           0            0        0 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         75 LATCH: TRANSACTION TABLE           Waiting for the transaction table latch.                       5             0           1            0        1 CONCURRENCY Waits for internal database resources             
G1N1        53    745 gsql         79 LATCH: SEQUENCE GLOBALY            Waiting for the sequence global latch Y.                     140             0          23            0        1 CONCURRENCY Waits for internal database resources             