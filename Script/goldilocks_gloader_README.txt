gloader.sh
 * 데이터베이스 전체의 데이터를 내려받기 위한 스크립트
 * 데이터만 내려받기 때문에 모든 테이블 접근을 위해 유저는 시스템 계정으로 지정
 * 실행방법 sh gloader.sh
 * SYS 계정의 비밀번호가 변경된 경우 스크립트의 SYS 비밀번호 수정


쉘 수행시 생성되는 폴더
 * gloader_현재 쉘이 수행된 시간의 폴더가 생성된다. 이 폴더는 다음의 하위 폴더를 가진다.
 * sh         : import 와 export 시 수행되는 스크립트가 저장
 * control    : .ctl 파일이 저장
 * data       : .dat 파일이 저장
 * export_log : export 시 생성되는 log 파일이 저장
 * import_log : import 시 생성되는 log 파일이 저장
 * history    : 내려받은 SCHEMA 와 TABLE 이 저장

export 수행시
 * 반드시 gloader_${DATE}/sh 경로로 이동하여 수행
 * 실행방법 sh export.sh
 * 내려받은 데이터는 gloader_${DATE}/data/ 경로에 저장
 * 생성된 로그파일은  gloader_${DATE}/export_log 경로에 저장

import 수행시
 * 반드시 gloader_${DATE}/sh 경로로 이동하여 수행
 * 실행방법 sh import.sh
 * 데이터파일은 gloader_${DATE}/data/*.dat 를 읽음
 * 생성된 로그/배드 파일은 gloader_${DATE}/import_log 경로에 저장