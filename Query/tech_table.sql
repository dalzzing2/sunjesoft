--######################################################################################
-- View For Table
--
-- OWNER            : Owner
-- TAB_SCHEMA       : Schema Name
-- TAB_NAME         : Table Name
-- LOC_USE_MBYTE    : MegaByte Used By Table In Local
-- TBS_NAME         : TableSpace Name stored Table
-- LOC_TBS_USE_PERC : Tablespace Percentage Used By Table
-- CLU_USE_MBYTE    : MegaByte Used By Table In Cluster
--
--gSQL> SELECT * FROM TECH_TABLE;
--
--OWNER  TAB_SCHEMA TAB_NAME            LOC_USE_MBYTE TBS_NAME     LOC_TBS_USE_PERC CLU_USE_MBYTE
-------- ---------- ------------------- ------------- ------------ ---------------- -------------
--TEST   PUBLIC     TEST_02                      0.50 MEM_DATA_TBS             0.38          4.50
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_TABLE;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_TABLE
(
  OWNER,
  TAB_SCHEMA,
  TAB_NAME,
  LOC_USE_MBYTE,
  TBS_NAME,
  LOC_TBS_USE_PERC,
  CLU_USE_MBYTE
)
AS
SELECT
  AATL.OWNER,
  AATL.TABLE_SCHEMA TABLE_SCHEMA,
  AATL.TABLE_NAME TABLE_NAME ,
  TO_CHAR(ROUND(NVL(AATL.BLOCKS, 0) * 8192 / 1024 / 1024, 2), '999999990.00') AS "USED MB",
  AATL.TABLESPACE_NAME                 AS "TABLESPACE_NAME",
  ( SELECT
      TO_CHAR((NVL(AATL.BLOCKS, 0) * 8192 ) / TOTAL * 100, '999999999990.00')
        FROM
          X$TABLESPACE@LOCAL,
          ( SELECT TABLESPACE_ID, SUM(SIZE) TOTAL FROM X$DATAFILE@LOCAL WHERE STATE != 'DROPPED' GROUP BY TABLESPACE_ID )
        WHERE
          ID = TABLESPACE_ID AND
          AATL.TABLESPACE_NAME = NAME )  AS "TABLESPACE_USAGE",
  TO_CHAR(ROUND(NVL(AAT.BLOCKS, 0) * 8192 / 1024 / 1024, 2), '999999990.00') AS "ALL USED MB"
FROM
  ALL_ALL_TABLES@LOCAL AATL,
  ALL_ALL_TABLES AAT
WHERE
  AATL.TABLE_SCHEMA = AAT.TABLE_SCHEMA AND
  AATL.TABLE_NAME = AAT.TABLE_NAME AND
  AATL.TABLE_SCHEMA NOT IN ('DICTIONARY_SCHEMA') AND
  AATL.OWNER != '_SYSTEM'
ORDER BY 1, 2, 5;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_TABLE TO PUBLIC;