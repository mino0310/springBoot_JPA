-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT 1 IS OF (INT);
>> TRUE

SELECT 1 IS NOT OF (INT);
>> FALSE

SELECT NULL IS OF (INT);
>> null

SELECT NULL IS NOT OF (INT);
>> null

SELECT 1 IS OF (INT, BIGINT);
>> TRUE

SELECT 1 IS NOT OF (INT, BIGINT);
>> FALSE

SELECT TRUE IS OF (VARCHAR, TIME);
>> FALSE

SELECT TRUE IS NOT OF (VARCHAR, TIME);
>> TRUE

CREATE TABLE TEST(A INT NOT NULL, B INT);
> ok

EXPLAIN SELECT
    'Test' IS OF (VARCHAR), 'Test' IS NOT OF (VARCHAR),
    10 IS OF (VARCHAR), 10 IS NOT OF (VARCHAR),
    NULL IS OF (VARCHAR), NULL IS NOT OF (VARCHAR);
>> SELECT TRUE, FALSE, FALSE, TRUE, UNKNOWN, UNKNOWN

EXPLAIN SELECT A IS OF (INT), A IS OF (BIGINT), A IS NOT OF (INT), NOT A IS OF (BIGINT) FROM TEST;
>> SELECT ("A" IS OF (INTEGER), ("A" IS OF (BIGINT), ("A" IS NOT OF (INTEGER), ("A" IS NOT OF (BIGINT) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT B IS OF (INT), B IS OF (BIGINT),  B IS NOT OF (INT), NOT B IS OF (BIGINT) FROM TEST;
>> SELECT ("B" IS OF (INTEGER), ("B" IS OF (BIGINT), ("B" IS NOT OF (INTEGER), ("B" IS NOT OF (BIGINT) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */
