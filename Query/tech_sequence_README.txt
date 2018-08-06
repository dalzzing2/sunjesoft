SEQUENCE 의 현재값과 다음값을 조회하는 VIEW

VIEW 컬럼
  MEMBER_NAME    : 클러스터 멤버 명
  OWNER          : 시퀀스 소유자
  SEQ_NAME       : 시퀀스 명
  LOC_CURR_VALUE : LOCAL 에서의 현재 시퀀스 값
  LOC_NEXT_VALUE : LOCAL 에서의 다음 시퀀스 값
  GLO_NEXT_VALUE : GLOBAL 에서의 다음 시퀀스 값
  INCREMENT      : 증가량
  MINVALUE       : 시퀀스의 최소값
  MAXVALUE       : 시퀀스의 최대값

VIEW 사용법
gSQL> SELECT * FROM TECH_SEQUENCE;

MEMBER_NAME OWNER SEQ_NAME LOC_CURR_VALUE LOC_NEXT_VALUE GLO_NEXT_VALUE INCREMENT MINVALUE            MAXVALUE
----------- ----- -------- -------------- -------------- -------------- --------- -------- -------------------
G1N1        TEST  SEQ1                  4              5             21         1        1 9223372036854775807
G1N1        TEST  SEQ2                  1              1              1         1        1 9223372036854775807
G2N1        TEST  SEQ1                  1              1             21         1        1 9223372036854775807
G2N1        TEST  SEQ2                  1              1              1         1        1 9223372036854775807