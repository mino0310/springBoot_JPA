-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(I NUMERIC(-1));
> exception INVALID_VALUE_2

CREATE TABLE TEST(I NUMERIC(-1, -1));
> exception INVALID_VALUE_2

CREATE TABLE TEST (N NUMERIC) AS VALUES (0), (0.0), (NULL);
> ok

SELECT * FROM TEST;
> N
> ----
> 0
> 0.0
> null
> rows: 3

SELECT DISTINCT * FROM TEST;
> N
> ----
> 0
> null
> rows: 2

DROP TABLE TEST;
> ok

CREATE TABLE TEST (N NUMERIC) AS VALUES (0), (0.0), (2), (NULL);
> ok

CREATE INDEX TEST_IDX ON TEST(N);
> ok

SELECT N FROM TEST WHERE N IN (0.000, 0.00, 1.0);
> N
> ---
> 0
> 0.0
> rows: 2

SELECT N FROM TEST WHERE N IN (SELECT DISTINCT ON(B) A FROM VALUES (0.000, 1), (0.00, 2), (1.0, 3) T(A, B));
> N
> ---
> 0
> 0.0
> rows: 2

DROP INDEX TEST_IDX;
> ok

CREATE UNIQUE INDEX TEST_IDX ON TEST(N);
> exception DUPLICATE_KEY_1

DROP TABLE TEST;
> ok

CREATE MEMORY TABLE TEST(N NUMERIC) AS VALUES (0), (0.0), (2), (NULL);
> ok

CREATE HASH INDEX TEST_IDX ON TEST(N);
> ok

SELECT N FROM TEST WHERE N = 0;
> N
> ---
> 0
> 0.0
> rows: 2

DROP INDEX TEST_IDX;
> ok

CREATE UNIQUE HASH INDEX TEST_IDX ON TEST(N);
> exception DUPLICATE_KEY_1

DELETE FROM TEST WHERE N = 0 LIMIT 1;
> update count: 1

CREATE UNIQUE HASH INDEX TEST_IDX ON TEST(N);
> ok

SELECT 1 FROM TEST WHERE N = 0;
>> 1

INSERT INTO TEST VALUES (NULL);
> update count: 1

SELECT N FROM TEST WHERE N IS NULL;
> N
> ----
> null
> null
> rows: 2

DELETE FROM TEST WHERE N IS NULL LIMIT 1;
> update count: 1

SELECT N FROM TEST WHERE N IS NULL;
>> null

DROP TABLE TEST;
> ok
