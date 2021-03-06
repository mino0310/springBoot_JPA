-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(A INT, B INT);
> ok

INSERT INTO TEST VALUES (1, 2);
> update count: 1

UPDATE TEST SET (A, B) = (3, 4);
> update count: 1

SELECT * FROM TEST;
> A B
> - -
> 3 4
> rows: 1

UPDATE TEST SET (B) = 5;
> update count: 1

SELECT B FROM TEST;
>> 5

UPDATE TEST SET (B) = ROW (6);
> update count: 1

SELECT B FROM TEST;
>> 6

UPDATE TEST SET (B) = (7);
> update count: 1

SELECT B FROM TEST;
>> 7

UPDATE TEST SET (B) = (2, 3);
> exception COLUMN_COUNT_DOES_NOT_MATCH

UPDATE TEST SET (A, B) = ARRAY[3, 4];
> exception COLUMN_COUNT_DOES_NOT_MATCH

EXPLAIN UPDATE TEST SET (A) = ROW(3), B = 4;
>> UPDATE "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ SET "A" = 3, "B" = 4

EXPLAIN UPDATE TEST SET A = 3, (B) = 4;
>> UPDATE "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ SET "A" = 3, "B" = 4

UPDATE TEST SET (A, B) = (1, 2), (B, A) = (2, 1);
> exception DUPLICATE_COLUMN_NAME_1

UPDATE TEST SET (A) = A * 3;
> update count: 1

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT) AS VALUES 100;
> ok

SELECT _ROWID_ FROM TEST;
>> 1

-- _ROWID_ modifications are ignored
UPDATE TEST SET _ROWID_ = 2 WHERE ID = 100;
> update count: 1

UPDATE TEST SET TEST._ROWID_ = 3 WHERE ID = 100;
> update count: 1

UPDATE TEST SET PUBLIC.TEST._ROWID_ = 4 WHERE ID = 100;
> update count: 1

UPDATE TEST SET SCRIPT.PUBLIC.TEST._ROWID_ = 5 WHERE ID = 100;
> update count: 1

SELECT _ROWID_ FROM TEST;
>> 1

DROP TABLE TEST;
> ok
