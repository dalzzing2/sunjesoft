--######################################################################################
-- View For Index
--
-- OWNER            : Owner
-- TAB_SCHEMA       : Schema Name
-- TAB_NAME         : Table Name
-- IDX_NAME         : Index Name
-- LOC_USE_MBYTE    : MegaByte Used By Index In Local
-- TBS_NAME         : TableSpace Name stored Index
-- LOC_TBS_USE_PERC : Tablespace Percentage Used By Index
-- CLU_USE_MBYTE    : MegaByte Used By Index In Cluster
--
--gSQL> SELECT * FROM TECH_INDEX;
--
--OWNER TAB_SCHEMA TAB_NAME IDX_NAME                  LOC_USE_MBYTE TBS_NAME     LOC_TBS_USE_PERC CLU_USE_MBYTE
------- ---------- -------- ------------------------- ------------- ------------ ---------------- -------------
--TEST  PUBLIC     PF_TEST  PF_TEST_PRIMARY_KEY_INDEX          1.00 MEM_TEMP_TBS             1.56          5.00
--TEST  PUBLIC     PF_TEST  [GLOBAL INDEX]                     1.75 MEM_TEMP_TBS             2.73          7.25
--TEST  PUBLIC     T1       T1_PRIMARY_KEY_INDEX               0.50 MEM_TEMP_TBS             0.78          3.00
--TEST  PUBLIC     T1       [GLOBAL INDEX]                     0.50 MEM_TEMP_TBS             0.78          3.00
--TEST  PUBLIC     T2       T2_PRIMARY_KEY_INDEX               0.50 MEM_TEMP_TBS             0.78          3.00
--TEST  PUBLIC     T2       [GLOBAL INDEX]                     0.50 MEM_TEMP_TBS             0.78          3.00
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_INDEX;

DECLARE
  CHK_CLUSTER BOOLEAN;
BEGIN
  SELECT IS_CLUSTER INTO CHK_CLUSTER FROM CATALOG_NAME@LOCAL;
  
  IF CHK_CLUSTER = 'FALSE' THEN
  EXECUTE IMMEDIATE '
  DROP VIEW IF EXISTS DICTIONARY_SCHEMA.ALL_GLOBAL_SECONDARY_INDEXES';
  
  EXECUTE IMMEDIATE '
  CREATE VIEW DICTIONARY_SCHEMA.ALL_GLOBAL_SECONDARY_INDEXES
  (
    TABLE_OWNER,
	TABLE_SCHEMA,
	TABLE_NAME,
	BLOCKS,
	TABLESPACE_NAME
  )
  AS
  SELECT
    NULL,
	NULL,
	NULL,
	NULL,
	NULL
  FROM
    DUAL';

  END IF;
END;
/
   
CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_INDEX
(
  OWNER,
  TAB_SCHEMA,
  TAB_NAME,
  IDX_NAME,
  LOC_USE_MBYTE,
  TBS_NAME,
  LOC_TBS_USE_PERC,
  CLU_USE_MBYTE
)
AS
SELECT
  AIL.OWNER OWNER,
  AIL.TABLE_SCHEMA TABLE_SCHEMA,
  AIL.TABLE_NAME TABLE_NAME,
  AIL.INDEX_NAME INDEX_NAME,
  TO_CHAR(ROUND(NVL(AIL.BLOCKS, 0) * 8192 / 1024 / 1024, 2), '999999990.00') AS "USED MB",
  AIL.TABLESPACE_NAME                 AS "TABLESPACE_NAME",
  ( SELECT
      TO_CHAR((NVL(AIL.BLOCKS, 0) * 8192 ) / TOTAL * 100, '999999999990.00')
        FROM
          X$TABLESPACE@LOCAL[IGNORE_INACTIVE_MEMBER],
          ( SELECT TABLESPACE_ID, SUM(SIZE) TOTAL FROM X$DATAFILE@LOCAL[IGNORE_INACTIVE_MEMBER] WHERE STATE != 'DROPPED' GROUP BY TABLESPACE_ID )
        WHERE
          ID = TABLESPACE_ID AND
          AIL.TABLESPACE_NAME = NAME )  AS "TABLESPACE_USAGE",
  TO_CHAR(ROUND(NVL(AI.BLOCKS, 0) * 8192 / 1024 / 1024, 2), '999999990.00') AS "ALL USED MB"
FROM
  ALL_INDEXES@LOCAL[IGNORE_INACTIVE_MEMBER] AIL,
  ALL_INDEXES@GLOBAL[IGNORE_INACTIVE_MEMBER] AI
WHERE
  AIL.TABLE_SCHEMA = AI.TABLE_SCHEMA AND
  AIL.TABLE_NAME = AI.TABLE_NAME AND
  AIL.INDEX_NAME = AIL.INDEX_NAME AND
  AIL.OWNER != '_SYSTEM'
UNION ALL
SELECT
  GIL.TABLE_OWNER OWNER,
  GIL.TABLE_SCHEMA TABLE_SCHEMA,
  GIL.TABLE_NAME TABLE_NAME,
  '[GLOBAL INDEX]',
  TO_CHAR(ROUND(NVL(GIL.BLOCKS, 0) * 8192 / 1024 / 1024, 2), '999999990.00') AS "USED MB",
  GIL.TABLESPACE_NAME AS "TABLESPACE_NAME",
  ( SELECT
      TO_CHAR((NVL(GIL.BLOCKS, 0) * 8192 ) / TOTAL * 100, '999999999990.00')
        FROM
          X$TABLESPACE@LOCAL[IGNORE_INACTIVE_MEMBER],
          ( SELECT TABLESPACE_ID, SUM(SIZE) TOTAL FROM X$DATAFILE@LOCAL[IGNORE_INACTIVE_MEMBER] WHERE STATE != 'DROPPED' GROUP BY TABLESPACE_ID )
        WHERE
          ID = TABLESPACE_ID AND
          GIL.TABLESPACE_NAME = NAME )  AS "TABLESPACE_USAGE",
  TO_CHAR(ROUND(NVL(GI.BLOCKS, 0) * 8192 / 1024 / 1024, 2), '999999990.00') AS "ALL USED MB"
FROM
  ALL_GLOBAL_SECONDARY_INDEXES@LOCAL[IGNORE_INACTIVE_MEMBER] GIL,
  ALL_GLOBAL_SECONDARY_INDEXES@GLOBAL[IGNORE_INACTIVE_MEMBER] GI
WHERE
  GIL.TABLE_SCHEMA = GI.TABLE_SCHEMA AND
  GIL.TABLE_NAME = GI.TABLE_NAME AND
  GIL.TABLE_SCHEMA != 'DICTIONARY_SCHEMA'
ORDER BY 1, 3, 6  
;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_INDEX TO PUBLIC;