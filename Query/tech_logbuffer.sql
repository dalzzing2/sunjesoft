--######################################################################################
-- View For Log Buffer
--
-- MEMBER_NAME                : Member NAME
-- LOGBUF_TOT_MB              : Log Buffer Total MegaByte
-- LOGBUF_USE_MB              : Log Buffer Use MegaByte
-- LOGBUF_AVAI_MB             : Log Buffer Available MegaByte
-- LOGBUF_LSN_GAP             : Log Buffer Lsn Gap
-- FLUSH_COUNT                : Log Buffer Flush Count
-- WAIT_COUNT_BY_BUFFER_FULL  : Waited Session Count By Buffer Full
-- WAIT_COUNT_FOR_SYNC        : Waited Flush Count For Sync
-- BLOCKED_LOGGING_COUNT      : Blocked Logging Count
-- CURRENT_REDO               : Current Redo Log File
-- 
--gSQL> SELECT * FROM TECH_LOGBUFFER;
--
--MEMBER_NAME LOGBUF_TOT_MB LOGBUF_USE_MB LOGBUF_AVAI_MB LOGBUF_LSN_GAP FLUSH_COUNT WAIT_COUNT_BY_BUFFER_FULL WAIT_COUNT_FOR_SYNC BLOCKED_LOGGING_COUNT CURRENT_REDO                               
------------- ------------- ------------- -------------- -------------- ----------- ------------------------- ------------------- --------------------- -------------------------------------------
--G1N1                 1.00          0.00         1.00                0        2211                         0                   7                     0 /data/g1n1/goldilocks_data/wal/redo_2_0.log
--G2N1                 1.00          0.00         1.00                0        2621                        12                1157                     0 /data/g2n1/goldilocks_data/wal/redo_3_0.log
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_LOGBUFFER;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_LOGBUFFER
(
  MEMBER_NAME,
  LOGBUF_TOT_MB,
  LOGBUF_USE_MB,
  LOGBUF_AVAI_MB,
  LOGBUF_LSN_GAP,
  FLUSH_COUNT,
  WAIT_COUNT_BY_BUFFER_FULL,
  WAIT_COUNT_FOR_SYNC,
  BLOCKED_LOGGING_COUNT,
  CURRENT_REDO
)
AS
SELECT
  NVL(LB.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
  TO_CHAR(ROUND(NVL(LB.BUFFER_SIZE, 0) / 1024 / 1024, 2), '999999990.00') AS LOGBUF_TOT_MB,
  TO_CHAR(ROUND(NVL(LB.REAR_SBSN - LB.FRONT_SBSN, 0) * NVL(LS.BLOCK_SIZE, 0) / 1024 / 1024, 2), '999999990.00') AS LOGBUF_USE_MB,
  TO_CHAR(ROUND(NVL(LB.BUFFER_SIZE - ((LB.REAR_SBSN - LB.FRONT_SBSN) * LS.BLOCK_SIZE), 0) / 1024 / 1024, 2), '99999999.00') AS LOGBUF_AVAI_MB,
  (LB.REAR_LSN - LB.FRONT_LSN) AS LOGBUF_LSN_GAP,
  LS.FLUSH_COUNT AS FLUSH_COUNT,
  LS.WAIT_COUNT_BY_BUFFER_FULL AS WAIT_COUNT_BY_BUFFER_FULL,
  LS.WAIT_COUNT_FOR_SYNC AS WAIT_COUNT_FOR_SYNC,
  LS.BLOCKED_LOGGING_COUNT AS BLOCKED_LOGGING_COUNT,
  LM.NAME AS CURRENT_REDO
FROM
  X$LOG_BUFFER LB,
  X$LOG_STREAM LS,
  X$LOG_GROUP LG,
  X$LOG_MEMBER LM
WHERE
  1 = 1
  AND NVL(LB.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(LS.CLUSTER_MEMBER_NAME, 'STANDALONE')
  AND NVL(LB.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(LG.CLUSTER_MEMBER_NAME, 'STANDALONE')
  AND NVL(LB.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(LM.CLUSTER_MEMBER_NAME, 'STANDALONE')
  AND NVL(LS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(LG.CLUSTER_MEMBER_NAME, 'STANDALONE')
  AND NVL(LS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(LM.CLUSTER_MEMBER_NAME, 'STANDALONE')
  AND NVL(LG.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(LM.CLUSTER_MEMBER_NAME, 'STANDALONE')
  AND LS.FILE_SEQ_NO = LG.FILE_SEQ_NO
  AND LG.GROUP_ID = LM.GROUP_ID
ORDER BY 1
;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_LOGBUFFER TO PUBLIC;