--######################################################################################
-- View For Sequence
--
-- MEMBER_NAME    : Cluster Member Name
-- OWNER          : Owner
-- SEQ_NAME       : Sequence Name
-- LOC_CURR_VALUE : Current Value In Local
-- LOC_NEXT_VALUE : Next Value In Local
-- GLO_NEXT_VALUE : Next Value In Cluster
-- INCREMENT      : Increment
-- MINVALUE       : Min Value
-- MAXVALUE       : Max Value
--
--gSQL> SELECT * FROM TECH_SEQUENCE;
--
--MEMBER_NAME OWNER SEQ_NAME LOC_CURR_VALUE LOC_NEXT_VALUE GLO_NEXT_VALUE INCREMENT MINVALUE            MAXVALUE
------------- ----- -------- -------------- -------------- -------------- --------- -------- -------------------
--G1N1        TEST  SEQ1                  4              5             21         1        1 9223372036854775807
--G1N1        TEST  SEQ2                  1              1              1         1        1 9223372036854775807
--G2N1        TEST  SEQ1                  1              1             21         1        1 9223372036854775807
--G2N1        TEST  SEQ2                  1              1              1         1        1 9223372036854775807
--######################################################################################


DROP VIEW IF EXISTS PERFORMANCE_VIEW_SCHEMA.TECH_SEQUENCE;

CREATE VIEW PERFORMANCE_VIEW_SCHEMA.TECH_SEQUENCE
(
  MEMBER_NAME,
  OWNER,
  SEQ_NAME,
  LOC_CURR_VALUE,
  LOC_NEXT_VALUE,
  GLO_NEXT_VALUE,
  INCREMENT,
  MINVALUE,
  MAXVALUE
)
AS
SELECT
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') MEMBER_NAME,
  AU.AUTHORIZATION_NAME OWNER,
  DSS.SEQUENCE_NAME SEQ_NAME,
  XS.LOCAL_CURR_VALUE LOC_CURR_VALUE,
  XS.LOCAL_NEXT_VALUE LOC_NEXT_VALUE,
  XS.GLOBAL_NEXT_VALUE GLO_NEXT_VALUE,
  XS.INCREMENT_BY INCREMENT,
  XS.MINVALUE MINVALUE,
  XS.MAXVALUE MAXVALUE
FROM
  AUTHORIZATIONS AU,
  X$SEQUENCE XS,
  DEFINITION_SCHEMA.SEQUENCES DSS
WHERE
  1 = 1 AND
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(AU.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(DSS.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  NVL(XS.CLUSTER_MEMBER_NAME, 'STANDALONE') = NVL(DSS.CLUSTER_MEMBER_NAME, 'STANDALONE') AND
  AU.AUTH_ID = OWNER_ID AND
  XS.PHYSICAL_ID = DSS.PHYSICAL_ID;
  
GRANT SELECT ON TABLE PERFORMANCE_VIEW_SCHEMA.TECH_SEQUENCE TO PUBLIC;