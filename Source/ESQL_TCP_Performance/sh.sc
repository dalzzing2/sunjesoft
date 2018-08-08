#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/time.h>

EXEC SQL INCLUDE SQLCA;

#define  PRINT_SQL_ERROR(aMsg)                                      \
    {                                                               \
        printf("\n");                                               \
        printf(aMsg);                                               \
        printf("\nSQLCODE : %d\nERROR MSG : %s\n",   \
               sqlca.sqlcode,                                       \
               sqlca.sqlerrm.sqlerrmc );                            \
    }

typedef struct thread
{
  char *dsn;
  char *uid;
  char *pwd;
  char mode;
  int  num;
  int  start;
  int  end;
  int  interval;
  //sql_contect *ctx;
}thread;

void    *MultiThread(void* threadInfo);
unsigned long testInsert(char* sat, int start, int end, int interval);
unsigned long testDelete(char* sat, int start, int end, int interval);
unsigned long testUpdate(char* sat, int start, int end, int interval);
unsigned long testSelect(char* sat, int start, int end, int interval);

/*
unsigned long testInsert(char* sat, int start, int end, int interval, sql_context ctx);
unsigned long testDelete(char* sat, int start, int end, int interval, sql_context ctx);
unsigned long testUpdate(char* sat, int start, int end, int interval, sql_context ctx);
unsigned long testSelect(char* sat, int start, int end, int interval, sql_context ctx);
*/
int total_tps = 0;

int main(int argc, char **argv)
{
    char  s[1024];
    FILE  *fp;
    char  conn[3][50];
    int i = 0;
    int session = 0;
    int record  = 0;
    char mode = NULL;
    //int interval;

    fp = fopen("sunje.conf", "r");
    while(!feof(fp))
    {
        fgets(s, 1024, fp);

        char *ptr = strchr(s, ':');
        if (ptr != NULL)
        {
            strcpy(conn[i], ptr + 1);
            conn[i][strlen(conn[i]) - 1] = '\0';
            //printf("conn[%d]=\"%s\"\n", i, conn[i]);
            i++;
        }
    }
    fclose(fp);


    session = atoi(argv[1]);
    record  = atoi(argv[2]);
    mode = argv[4][0];

    printf("=========================================\n");
    printf("DSN             = [%s]\n"
           "ID              = [%s]\n"
           "PW              = [%s]\n"
           "Commit Interval = [%d]\n"
           "\n"
           "Total Session   = %d\n"
           "Total Record    = %d\n"
           "Mode            = %c\n", conn[0], conn[1], conn[2], atoi(argv[3]), session, record, mode);
    printf("=========================================\n");

    int init = 1;
    int init_div = record / session ;
    int init_mod = record % session ;

    if (mode == 's')
    {
        init = record;
        init_div = 0;
    }

    thread     threadInfo[session];
    pthread_t  threadCount[session];
    //sql_contect ctx[session];
    //EXEC SQL ENABLE THREADS;

    i = 0;
    for ( i = 0 ; i < session ; i ++)
    {
        if( i != ( session - 1 ) )
        {
            threadInfo[i].dsn = conn[0];
            threadInfo[i].uid = conn[1];
            threadInfo[i].pwd = conn[2];
            threadInfo[i].interval = atoi(argv[3]);
            threadInfo[i].mode = mode;
            threadInfo[i].num  = i;
            threadInfo[i].start = init;
            threadInfo[i].end   = init + init_div - 1;
            //threadInfo[i].ctx = ctx[i];
        }else
        {
            threadInfo[i].dsn = conn[0];
            threadInfo[i].uid = conn[1];
            threadInfo[i].pwd = conn[2];
            threadInfo[i].interval = atoi(argv[3]);
            threadInfo[i].mode = mode;
            threadInfo[i].num  = i;
            threadInfo[i].start = init;
            threadInfo[i].end   = init + init_div + init_mod - 1;
            //threadInfo[i].ctx = ctx[i];
        }

/*
        printf("Thread Num  = [%d]\n"
               "Mode        = [%c]\n"
               "Start       = [%d]\n"
               "End         = [%d]\n"
               "Interval    = [%d]\n"
               "DSN         = [%s]\n\n"
               ,threadInfo[i].num, threadInfo[i].mode, threadInfo[i].start, threadInfo[i].end, threadInfo[i].interval, threadInfo[i].dsn);
*/

        pthread_create ( &threadCount[i], NULL, MultiThread, (void*)&threadInfo[i] );
        init = init + init_div;
    }

    for ( i = 0 ; i < session ; i ++)
    {
        pthread_join ( threadCount[i], NULL );
    }


    printf("\n");
    printf("Avg TPS = %d\n"
           "Tot TPS = %d\n", total_tps / session, total_tps);
    return 0;
}

void *MultiThread(void* threadInfo)
{
    EXEC SQL BEGIN DECLARE SECTION;
    VARCHAR sUID[1024];
    VARCHAR sPWD[1024];
    //VARCHAR sAT[1024];
    VARCHAR sDSN[1024];
    //sql_context ctx;
    char    *sAT;
    EXEC SQL END DECLARE SECTION;

    thread* info = (thread*)threadInfo;


    char at[1024]="THREAD-";
    char nu[1024];
    char mode;
    int num;
    int start;
    int end;
    int interval;

    mode      = info->mode;
    num       = info->num;
    start     = info->start;
    end       = info->end;
    interval  = info->interval;
    //ctx       = info->ctx;

    sprintf(nu, "%d", num);
    strcat(at, nu);

    strcpy((char*)sUID.arr, info->uid);
    sUID.len = (short)strlen((char *)sUID.arr);

    strcpy((char*)sPWD.arr, info->pwd);
    sPWD.len = (short)strlen((char *)sPWD.arr);

    //strcpy((char*)sAT.arr, at);
    //sAT.len = (short)strlen((char *)sAT.arr);
    sAT = at;

    strcpy((char*)sDSN.arr, info->dsn);
    sDSN.len = (short)strlen((char *)sDSN.arr);

    //EXEC SQL AT :sAT CONTEXT ALLOCATE :ctx; // goldilocks not need for threads
    //EXEC SQL AT :sAT CONTEXT USE :ctx; // goldilocks not need for threads
    EXEC SQL AT :sAT CONNECT :sUID IDENTIFIED BY :sPWD USING :sDSN;
    if (sqlca.sqlcode != 0)
    {

        PRINT_SQL_ERROR("[ERROR] Connection Failure!");
        return NULL;
    }

    EXEC SQL AT :sAT AUTOCOMMIT OFF;   // ORACLE NOT SUPPORT

    if (sqlca.sqlcode != 0)
    {
        PRINT_SQL_ERROR("[ERROR] AutoCommif off Failure!");
        return NULL;
    }

    unsigned long tt = 0;
    switch(mode) {
        case 'i' :
            //printf("Insert Mode\n");
            //tt = testInsert(at, start, end, interval, ctx);
            tt = testInsert(at, start, end, interval);
            break;
        case 'u' :
            //printf("Update Mode\n");
            //tt = testUpdate(at, start, end, interval, ctx);
            tt = testUpdate(at, start, end, interval);
            break;
        case 'd' :
            //printf("Delete Mode\n");
            //tt = testDelete(at, start, end, interval, ctx);
            tt = testDelete(at, start, end, interval);
            break;
        case 's' :
            //printf("Select Mode\n");
            end = start;
            start = 1;
            //tt = testSelect(at, start, end, interval, ctx);
            tt = testSelect(at, start, end, interval);
            break;
        default :
            break;
     }

    printf("[%s] \n"
                   "Record   = %d     (%d ~ %d)\n"
           "Time     = %ld us (%ld s)\n"
           "TPS      = %d\n", at, end - start + 1, start, end, tt, tt / 1000000 , (int)( (end - start + 1) * (double)1000000 / tt ));

    //EXEC SQL AT :sAT DISCONNECT;   // ORACLE NOT SUPPORT
    //EXEC SQL AT :sAT USE :ctx; // goldilocks not need for threads
    EXEC SQL AT :sAT COMMIT RELEASE;
    total_tps = total_tps + (int)( (end - start + 1) * (double)1000000 / tt );
    return NULL;
}


//unsigned long testInsert(char* sat, int start, int end, int interval, sql_context ctx)
unsigned long testInsert(char* sat, int start, int end, int interval)
{
    struct timeval st, et;
    unsigned long dt;

    EXEC SQL BEGIN DECLARE SECTION;
        int sno;
        char *sAT;
    EXEC SQL END DECLARE SECTION;

    int commit_check = 0;
    sAT = sat;

    gettimeofday(&st, NULL);
    for ( sno = start ; sno <= end ; sno ++ )
    {
        EXEC SQL AT :sAT
          INSERT INTO ACCT_BALANCE VALUES (:sno, :sno, SYSDATE, SYSDATE, :sno, :sno, :sno, :sno, :sno, 'UPP', 'LOW', 'STT', SYSDATE, :sno, :sno, :sno, :sno, :sno, :sno, :sno );
        if (sqlca.sqlcode != 0)
        {
            PRINT_SQL_ERROR("[ERROR] Insert Failure!");
            return -1;
        }

        commit_check ++;
        if ( commit_check == interval )
        {
            EXEC SQL AT :sAT COMMIT;
            if (sqlca.sqlcode != 0)
            {
                PRINT_SQL_ERROR("[ERROR] Insert Commit Failure!");
                return -1;
            }
            commit_check = 0;
        }
    }
    EXEC SQL AT :sAT COMMIT;
    if (sqlca.sqlcode != 0)
    {
        PRINT_SQL_ERROR("[ERROR] Insert Commit Failure!");
        return -1;
    }
    gettimeofday(&et, NULL);

    dt = (( et.tv_sec - st.tv_sec ) * 1000000) + ( et.tv_usec - st.tv_usec );

    return dt;
}

//unsigned long testDelete(char* sat, int start, int end, int interval, sql_context ctx)
unsigned long testDelete(char* sat, int start, int end, int interval)
{
    struct timeval st, et;
    unsigned long dt;

    EXEC SQL BEGIN DECLARE SECTION;
        int sno;
        char *sAT;
    EXEC SQL END DECLARE SECTION;

    int commit_check = 0;
    sAT = sat;

    gettimeofday(&st, NULL);
    for ( sno = start ; sno <= end ; sno ++ )
    {
        EXEC SQL AT :sAT
          DELETE FROM ACCT_BALANCE WHERE ACCT_BALANCE_ID = :sno;
        if(sqlca.sqlcode != 0)
        {
            PRINT_SQL_ERROR("[ERROR] Delete Execute Failure!");
            return -1;
        }
        commit_check ++;
        if ( commit_check == interval )
        {
            EXEC SQL AT :sAT COMMIT;
            if (sqlca.sqlcode != 0)
            {
                PRINT_SQL_ERROR("[ERROR] Delete Commit Failure!");
                return -1;
            }
            commit_check = 0;
        }
    }
    EXEC SQL AT :sAT COMMIT;
    if (sqlca.sqlcode != 0)
    {
        PRINT_SQL_ERROR("[ERROR] Delete Commit Failure!");
        return -1;
    }
    gettimeofday(&et, NULL);

    dt = (( et.tv_sec - st.tv_sec ) * 1000000) + ( et.tv_usec - st.tv_usec );

    return dt;
}

//unsigned long testUpdate(char* sat, int start, int end, int interval, sql_context ctx)
unsigned long testUpdate(char* sat, int start, int end, int interval)
{
    struct timeval st, et;
    unsigned long dt;

    EXEC SQL BEGIN DECLARE SECTION;
        int sno;
        char *sAT;
    EXEC SQL END DECLARE SECTION;

    int commit_check = 0;
    sAT = sat;

    gettimeofday(&st, NULL);
    for ( sno = start ; sno <= end ; sno ++ )
    {
        EXEC SQL AT :sAT
          UPDATE ACCT_BALANCE SET BALANCE_TYPE_ID = :sno + 1 WHERE ACCT_BALANCE_ID = :sno;
        if(sqlca.sqlcode != 0)
        {
            PRINT_SQL_ERROR("[ERROR] Update Execute Failure!");
            return -1;
        }
        commit_check ++;
        if ( commit_check == interval )
        {
            EXEC SQL AT :sAT COMMIT;
            if (sqlca.sqlcode != 0)
            {
                PRINT_SQL_ERROR("[ERROR] Update Commit Failure!");
                return -1;
            }
            commit_check = 0;
        }
    }
    EXEC SQL AT :sAT COMMIT;
    if (sqlca.sqlcode != 0)
    {
        PRINT_SQL_ERROR("[ERROR] Update Commit Failure!");
        return -1;
    }
    gettimeofday(&et, NULL);

    dt = (( et.tv_sec - st.tv_sec ) * 1000000) + ( et.tv_usec - st.tv_usec );

    return dt;
}

//unsigned long testSelect(char* sat, int start, int end, int interval, sql_context ctx)
unsigned long testSelect(char* sat, int start, int end, int interval)
{
    struct timeval st, et;
    unsigned long dt;

    EXEC SQL BEGIN DECLARE SECTION;
        int sno;
        int acct_balance_id;
        int balance_type_id;
        char *sAT;
    EXEC SQL END DECLARE SECTION;

    sAT = sat;

    gettimeofday(&st, NULL);
    for ( sno = start ; sno <= end ; sno ++ )
    {
        EXEC SQL AT :sAT
          SELECT ACCT_BALANCE_ID, BALANCE_TYPE_ID INTO :acct_balance_id, :balance_type_id FROM ACCT_BALANCE WHERE ACCT_BALANCE_ID = :sno;
        if(sqlca.sqlcode != 0)
        {
            PRINT_SQL_ERROR("[ERROR] Select Failure!");
            return -1;
        }
        //printf("%d, %d\n", acct_balance_id, balance_type_id);
    }
    gettimeofday(&et, NULL);

    dt = (( et.tv_sec - st.tv_sec ) * 1000000) + ( et.tv_usec - st.tv_usec );

    return dt;
}
