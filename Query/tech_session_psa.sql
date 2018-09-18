--######################################################################################
-- View For PSA
--
-- MEMBER_NAME      : Member Name
-- ID             : Session Identifier
-- SERIAL         : Session Serial
-- PROGRAM        : Program Name
-- TOTAL_PSA_MEGA : Maximum Available MegaByte Size
-- USED_PSA_MEGA  : Allocated MegaByte Size
-- USED_PSA_PERC  : Percentage Of Allocated Size
--
--gSQL> SELECT * FROM TECH_SESSION_PSA;
--
--MEMBER_NAME ID SERIAL PROGRAM TOTAL_PSA_MEGA USED_PSA_MEGA USED_PSA_PERC
------------- -- ------ ------- -------------- ------------- -------------
--STANDALONE  44      7 gsql    100.00         70.00         70.00              
--STANDALONE  45     31 gsql    100.00         10.00         10.00              
--STANDALONE  46     10 gsql    100.00         10.00         10.00              
--######################################################################################

DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_SESSION_PSA;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_SESSION_PSA
(
  MEMBER_NAME,
  ID,
  SERIAL,
  PROGRAM,
  TOTAL_PSA_MEGA,
  USED_PSA_MEGA,
  USED_PSA_PERC
)
AS
SELECT
  NVL(XKPS.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
  XS.ID ID,
  XS.SERIAL SERIAL,
  XS.PROGRAM PROGRAM,
  TO_CHAR(ROUND(XP.VALUE/1024/1024, 2), 'FM99999990.00') TOTAL_PSA_MEGA,
  TO_CHAR(ROUND(SUM(XKPS.VALUE)/1024/1024, 2), 'FM99999990.00') ALLOC_PSA_MEGA,
  TO_CHAR(ROUND(SUM(XKPS.VALUE)/XP.VALUE*100, 2), 'FM9999990.00') ALLOC_PERCENT
FROM
  X$KN_PROC_STAT XKPS,
  X$KN_PROC_ENV XKPE,
  X$PROPERTY XP,
  X$SESSION XS
WHERE
  1 = 1 AND
  NVL(XKPS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XKPE.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XKPS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XP.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XKPS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XKPE.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XP.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XKPE.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XP.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  XKPS.ID = XKPE.ID AND
  XKPE.OS_PROC_ID = XS.CLIENT_PROCESS AND
  XP.PROPERTY_NAME = 'PRIVATE_STATIC_AREA_SIZE' AND
  XS.TOP_LAYER != 12 AND
  XS.PROGRAM != 'cluster peer' AND
  XKPS.NAME LIKE '%TOTAL%'
GROUP BY XKPS.CLUSTER_MEMBER_NAME, XP.VALUE, XS.ID, XS.SERIAL, XS.PROGRAM
ORDER BY XKPS.CLUSTER_MEMBER_NAME, XS.ID;

GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_SESSION_PSA TO PUBLIC;