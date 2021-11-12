-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT JSON_ARRAY(10, TRUE, 'str', NULL, '[1,2,3]' FORMAT JSON);
>> [10,true,"str",[1,2,3]]

SELECT JSON_ARRAY(10, TRUE, 'str', NULL, '[1,2,3]' FORMAT JSON ABSENT ON NULL);
>> [10,true,"str",[1,2,3]]

SELECT JSON_ARRAY(10, TRUE, 'str', NULL, '[1,2,3]' FORMAT JSON NULL ON NULL);
>> [10,true,"str",null,[1,2,3]]

SELECT JSON_ARRAY(NULL ABSENT ON NULL);
>> []

SELECT JSON_ARRAY(NULL NULL ON NULL);
>> [null]

CREATE TABLE TEST(ID INT, V VARCHAR);
> ok

EXPLAIN SELECT JSON_ARRAY(V) FROM TEST;
>> SELECT JSON_ARRAY("V") FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_ARRAY(V NULL ON NULL) FROM TEST;
>> SELECT JSON_ARRAY("V" NULL ON NULL) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_ARRAY(V ABSENT ON NULL) FROM TEST;
>> SELECT JSON_ARRAY("V") FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

EXPLAIN SELECT JSON_ARRAY(V FORMAT JSON ABSENT ON NULL) FROM TEST;
>> SELECT JSON_ARRAY("V" FORMAT JSON) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */

INSERT INTO TEST VALUES (1, 'null'), (2, '1'), (3, null);
> update count: 3

SELECT JSON_ARRAY((SELECT V FROM TEST ORDER BY ID));
>> ["null","1"]

SELECT JSON_ARRAY((SELECT V FROM TEST ORDER BY ID) ABSENT ON NULL);
>> ["null","1"]

SELECT JSON_ARRAY((SELECT V FROM TEST ORDER BY ID) NULL ON NULL);
>> ["null","1",null]

SELECT JSON_ARRAY((SELECT V FROM TEST ORDER BY ID) FORMAT JSON);
>> [null,1,null]

DROP TABLE TEST;
> ok
