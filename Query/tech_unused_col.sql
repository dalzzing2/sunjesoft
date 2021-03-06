--######################################################################################
-- View For Unused Column
--
-- OWNER        : Owner
-- SCHEMA_NAME  : Schema Name
-- TABLE_NAME   : Table Name
-- COLUMN_ID    : Column Identifier
-- IS_UNUSED    : Unused Status
--
--gSQL> SELECT * FROM TECH_UNUSED_COL;
--
--OWNER SCHEMA_NAME TABLE_NAME COLUMN_ID IS_UNUSED
------- ----------- ---------- --------- ---------
--TEST  PUBLIC      T1            102861 TRUE     
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_UNUSED_COL;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_UNUSED_COL
(
  OWNER,
  SCHEMA_NAME,
  TABLE_NAME,
  COLUMN_ID,
  IS_UNUSED
)
AS  
SELECT
  AU.AUTHORIZATION_NAME OWNER,
  SC.SCHEMA_NAME SCHEMA_NAME,
  WT.TABLE_NAME TABLE_NAME,
  WH.COLUMN_ID COLUMN_ID,
  WH.IS_UNUSED IS_UNUSED
FROM
  DICTIONARY_SCHEMA.WHOLE_COLUMNS@GLOBAL[IGNORE_INACTIVE_MEMBER] WH,
  DICTIONARY_SCHEMA.WHOLE_TABLES@GLOBAL[IGNORE_INACTIVE_MEMBER] WT,
  DEFINITION_SCHEMA.SCHEMATA@GLOBAL[IGNORE_INACTIVE_MEMBER] SC,
  AUTHORIZATIONS@GLOBAL[IGNORE_INACTIVE_MEMBER] AU
WHERE
  1 = 1 AND
  WH.IS_UNUSED = 'TRUE' AND
  WH.OWNER_ID = WT.OWNER_ID AND
  WH.SCHEMA_ID = WT.SCHEMA_ID AND
  WH.TABLE_ID = WT.TABLE_ID AND
  WH.OWNER_ID = AU.AUTH_ID AND
  WH.SCHEMA_ID = SC.SCHEMA_ID;
  
GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_UNUSED_COL TO PUBLIC;
