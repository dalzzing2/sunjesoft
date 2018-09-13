goldilocks_locator.sh 알고리즘

1. 환경변수 ODBCINI 의 값이 있는지 확인
 - 설정되어 있지 않은 경우 $HOME 경로에 .odbc.ini 파일 생성
 - 설정되어 있는 경우 설정된 경로에 .odbc.ini 파일 생성
2. 홈디렉토리에 .locator.ini 파일이 있는지 확인
3. 1단계, 2단계의 파일생성시 이미 파일이 존재하는 경우 `date`_goldilocks 의 스냇샵 파일을 생성
4. .odbc.ini 파일에 GOLDILOCKS DSN 작성
 - 입력값 서버 아이피, 리스너 포트
 - 쓰기 실패하는 경우 프로그램 종료
5. 데이터베이스에 접속하여 클러스터 정보를 가지고 옴
6. .odbc.ini 와 .locator.ini 파일에 해당 정보를 기록
 - 쓰기 실패하는 경우 프로그램 종료
 
 
goldilocks_locator.sh 제약사항

1. 클러스터 데이터베이스 경우에만 사용 가능하다.
2. SYS 계정의 비밀번호가 변경된 경우 파일을 수정해야 한다.
3. 입력한 포트는 모든 데이터베이스에서 동일하다고 가정한다.
   따라서 만약 각 멤버의 리스너 포터가 동일하지 않다면 생성된 파일을 수정해야 한다.
   

goldilocks_locator.sh 사용법

$ sh goldilocks_locator.sh