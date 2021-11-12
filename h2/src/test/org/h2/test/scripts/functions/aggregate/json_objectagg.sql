-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(ID INT PRIMARY KEY, N VARCHAR, J JSON) AS VALUES
    (1, 'Ten', '10' FORMAT JSON),
    (2, 'Null', NULL),
    (3, 'False', 'false' FORMAT JSON);
> ok

SELECT JSON_OBJECTAGG(KEY N VALUE J) FROM TEST;
>> {"Ten":10,"Null":null,"False":false}

SELECT JSON_OBJECTAGG(N VALUE J) FROM TEST;
>> {"Ten":10,"Null":null,"False":false}

SELECT JSON_OBJECTAGG(N: J) FROM TEST;
>> {"Ten":10,"Null":null,"False":false}

SELECT JSON_OBJECTAGG(N: J ABSENT ON NULL) FROM TEST;
>> {"Ten":10,"False":false}

SELECT JSON_OBJECTAGG(N: J) FILTER (WHERE FALSE) FROM TEST;
>> null

SELECT JSON_OBJECTAGG(NULL: J) FROM TEST;
> exception INVALID_VALUE_2

INSERT INTO TEST VALUES (4, 'Ten', '-10' FORMAT JSON);
> update count: 1

SELECT JSON_OBJECTAGG(N: J) FROM TEST;
>> {"Ten":10,"Null":null,"False":false,"Ten":-10}

SELECT JSON_OBJECTAGG(N: J WITHOUT UNIQUE KEYS) FROM TEST;
>> {"Ten":10,"Null":null,"False":false,"Ten":-10}

SELECT JSON_OBJECTAGG(N: J WITH UNIQUE KEYS) FROM TEST;
> exception INVALID_VALUE_2

EXPLAIN SELECT JSON_OBJECTAGG(N: J) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J") FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J NULL ON NULL) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J") FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J ABSENT ON NULL) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J" ABSENT ON NULL) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J WITH UNIQUE KEYS) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J" WITH UNIQUE KEYS) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J NULL ON NULL WITH UNIQUE KEYS) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J" WITH UNIQUE KEYS) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J ABSENT ON NULL WITH UNIQUE KEYS) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J" ABSENT ON NULL WITH UNIQUE KEYS) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J WITHOUT UNIQUE KEYS) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J") FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J NULL ON NULL WITHOUT UNIQUE KEYS) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J") FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_OBJECTAGG(N: J ABSENT ON NULL WITHOUT UNIQUE KEYS) FROM TEST;
>> SELECT JSON_OBJECTAGG("N": "J" ABSENT ON NULL) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

DROP TABLE TEST;
> ok
