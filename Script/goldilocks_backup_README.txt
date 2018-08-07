goldilocks_backup.sh 알고리즘

1. goldilocks_backup.sh 프로세스가 구동중인지 확인
 프로세스가 구동중인 경우 [FATAL] 로그 후 종료
2. 옵션 확인
 옵션 부적절한 경우 [FATAL] 로그 후 종료
3. DB 계정 권한 확인
 BEGIN, END 권한이 없는 경우 [FATAL] 로그 후 종료
4. STANDALONE 혹은 CLUSTER 인지 확인
 둘다 아닌(디비가 안떠있거나?) 경우 [FATAL] 로그 후 종료
6. BEGIN BACKUP
 실패할 경우 [FATAL] 로그 후 종료
7. 백업할 파일들을 저장 및, 크기가 디스크 여유공간보다 큰지 확인
 큰 경우 [FATAL] 로그 후 종료
8. 백업할 파일을 복사
 복사 실패시 [FATAL] 로그 후 종료
9. END BACKUP
 실패할 경우 [FATAL] 로그 후 종료



goldilocks_backup.sh 사용법

$ sh goldilocks_backup.sh -h

Usage
  $ sh goldilocks_backup.sh user_name password
  $ sh goldilocks_backup.sh [OPTIONS] user_name password

arguments:
    user_name   user name
    password    password

options:
    -h         Print Help Messages
    -m [i|h|c] Set Backup Mode               (Default : h) [ ONLINE : Incremental (i), Full (h) ][ OFFLINE : Full (c) ]
    -p PATH    Set Absolute Destination Path (Default : current path)
	
-m 옵션이 부여되지 않을 시 온라인 핫 백업
-p 옵션이 부여되지 않을 시 현재 경로


1] $ sh goldilocks_backup.sh SYS gliese
2] $ sh goldilocks_backup.sh -m h -p /home/sh/Appliance/Source/Script SYS gliese



goldilocks_backup.sh 결과

현재시간으로 폴더가 생성된 후, 백업된 파일이 저장된다.
goldilocks_backup.log 에 작업내용이 기록된다.



