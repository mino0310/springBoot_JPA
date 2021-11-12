-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT
    NULL AND NULL, NULL AND FALSE, NULL AND TRUE,
    FALSE AND NULL, FALSE AND FALSE, FALSE AND TRUE,
    TRUE AND NULL, TRUE AND FALSE, TRUE AND TRUE;
> UNKNOWN FALSE UNKNOWN FALSE FALSE FALSE UNKNOWN FALSE TRUE
> ------- ----- ------- ----- ----- ----- ------- ----- ----
> null    FALSE null    FALSE FALSE FALSE null    FALSE TRUE
> rows: 1

SELECT
    NULL OR NULL, NULL OR FALSE, NULL OR TRUE,
    FALSE OR NULL, FALSE OR FALSE, FALSE OR TRUE,
    TRUE OR NULL, TRUE OR FALSE, TRUE OR TRUE;
> UNKNOWN UNKNOWN TRUE UNKNOWN FALSE TRUE TRUE TRUE TRUE
> ------- ------- ---- ------- ----- ---- ---- ---- ----
> null    null    TRUE null    FALSE TRUE TRUE TRUE TRUE
> rows: 1

SELECT NOT NULL, NOT FALSE, NOT TRUE;
> UNKNOWN TRUE FALSE
> ------- ---- -----
> null    TRUE FALSE
> rows: 1

SELECT 0 AND TRUE;
>> FALSE

SELECT TRUE AND 0;
>> FALSE

SELECT 1 OR FALSE;
>> TRUE

SELECT FALSE OR 1;
>> TRUE

SELECT NOT 0;
>> TRUE

SELECT NOT 1;
>> FALSE

CREATE TABLE TEST(B BOOLEAN, Z INT) AS VALUES (NULL, 0);
> ok

EXPLAIN SELECT NOT NOT B, NOT NOT Z FROM TEST;
>> SELECT "B", CAST("Z" AS BOOLEAN) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT TRUE AND B, B AND TRUE, TRUE AND Z, Z AND TRUE FROM TEST;
>> SELECT "B", "B", CAST("Z" AS BOOLEAN), CAST("Z" AS BOOLEAN) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT FALSE OR B, B OR FALSE, FALSE OR Z, Z OR FALSE FROM TEST;
>> SELECT "B", "B", CAST("Z" AS BOOLEAN), CAST("Z" AS BOOLEAN) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT, B INT);
> ok

EXPLAIN SELECT A FROM TEST WHERE (A, B) IS NOT DISTINCT FROM NULL;
>> SELECT "A" FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ WHERE ROW ("A", "B") IS NOT DISTINCT FROM NULL

EXPLAIN SELECT A FROM TEST WHERE (A, B) IS DISTINCT FROM NULL;
>> SELECT "A" FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ WHERE ROW ("A", "B") IS DISTINCT FROM NULL

EXPLAIN SELECT A IS DISTINCT FROM NULL, NULL IS DISTINCT FROM A FROM TEST;
>> SELECT ("A" IS NOT NULL), ("A" IS NOT NULL) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT A IS NOT DISTINCT FROM NULL, NULL IS NOT DISTINCT FROM A FROM TEST;
>> SELECT ("A" IS NULL), ("A" IS NULL) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A NULL);
> ok

SELECT 1 IN (SELECT A FROM TEST);
>> FALSE

INSERT INTO TEST VALUES NULL;
> update count: 1

SELECT 1 IN (SELECT A FROM TEST);
>> null

DROP TABLE TEST;
> ok

SELECT 1 IN (NULL);
>> null

SELECT 1 IN (SELECT NULL);
>> null

SELECT 1 IN (VALUES NULL);
>> null

SELECT 1 IN (TABLE(X NULL=()));
>> FALSE

SELECT (1, 1) IN (VALUES (1, NULL));
>> null

SELECT (1, 1) IN (VALUES (NULL, 1));
>> null

SELECT (1, 1) IN (TABLE(X INT=(), Y INT=()));
>> FALSE
