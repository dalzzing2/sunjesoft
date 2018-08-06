DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_INDEX;

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
          X$TABLESPACE@LOCAL,
          ( SELECT TABLESPACE_ID, SUM(SIZE) TOTAL FROM X$DATAFILE@LOCAL WHERE STATE != 'DROPPED' GROUP BY TABLESPACE_ID )
        WHERE
          ID = TABLESPACE_ID AND
          AIL.TABLESPACE_NAME = NAME )  AS "TABLESPACE_USAGE",
  TO_CHAR(ROUND(NVL(AI.BLOCKS, 0) * 8192 / 1024 / 1024, 2), '999999990.00') AS "ALL USED MB"
FROM
  ALL_INDEXES@LOCAL AIL,
  ALL_INDEXES AI
WHERE
  AIL.TABLE_SCHEMA = AI.TABLE_SCHEMA AND
  AIL.TABLE_NAME = AI.TABLE_NAME AND
  AIL.INDEX_NAME = AI.INDEX_NAME AND
  AIL.OWNER != '_SYSTEM'
ORDER BY 1, 3, 6  
;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_INDEX TO PUBLIC;