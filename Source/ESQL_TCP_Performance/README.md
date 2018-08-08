####################################################
# 파일 
####################################################
ORACLE
  Makefile.oracle  : Oracle Makefile ( oracle env 가 등록되어 있지 않은 경우 오류 )
  oracle.conf      : Oracle Connection Information
  sh.pc            : Oracle MultiThread ESQL Source


ALTIBASE
  Makefile.altibase : Altibase Makefile ( altibase env 가 등록되어 있지 않은 경우 오류 )
  alti.conf         : Altibase Connection Information
  sh.sc             : Altibase MulthThread ESQL Source


GOLDILOCKS
  Makefile.goldilocks : Goldilocks Makefile ( goldilocks env 가 등록되어 있지 않은 경우 오류 )
  goldi.conf          : Goldilocks Connection Information
  sh.gc               : Goldilocks MulthThread ESQL Source

####################################################
# 사전에 밴더의 환경이 등록되어 있어야 한다.
####################################################

####################################################
# 실행방법
####################################################
1. Make -f Makefile.<vendor> sh 를 수행한다.
2. 컴파일이 수행되었으면 <vendor>.conf 를 sunje.conf 로 변경한다.
3. acct_balance.sql 을 수행하여 테이블을 생성한다.
3. sh 를 수행한다.

####################################################
# sh 수행방법
####################################################
1. sh <session> <record> <commit_interval> <mode>
 session : 세션 수
 record  : 레코드 수
 commit_interval : 커밋 주기 ( select 모드에서는 무시 )
 mode : Select / Insert / Update / Delete ( s / i / u / d )

ex)
세션 10 개가 1000 건을 1건당 Commit 으로 Insert 한다. ( 세션 1 개당 100 건 Insert )
  sh 10 1000 1 i
세션 10 개가 1000 건을 2건당 Commit 으로 Insert 한다. ( 세션 1 개당 100 건 Update )
  sh 10 1000 2 u
세션 20 개가 2000 건을 Select 한다. ( 세션 1 개당 2000 건 Select )
  sh 20 2000 1 s

####################################################
# sh 수행결과
####################################################
$ sh 2 100 1 i
=========================================
DSN             = [dsn=GOLDILOCKS]
ID              = [TEST]
PW              = [test]
Commit Interval = [1]

Total Session   = 2
Total Record    = 100
Mode            = i
=========================================
[THREAD-0] 
Record   = 50     (1 ~ 50)
Time     = 20302 us (0 s)
TPS      = 2462
[THREAD-1] 
Record   = 50     (51 ~ 100)
Time     = 25142 us (0 s)
TPS      = 1988

Avg TPS = 2225
Tot TPS = 4450
