-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT CAST(CURRENT_TIMESTAMP AS TIMESTAMP(9)) = LOCALTIMESTAMP;
>> TRUE

SELECT CAST(CURRENT_TIMESTAMP(0) AS TIMESTAMP(9)) = LOCALTIMESTAMP(0);
>> TRUE

SELECT CAST(CURRENT_TIMESTAMP(9) AS TIMESTAMP(9)) = LOCALTIMESTAMP(9);
>> TRUE

@reconnect off

SET AUTOCOMMIT OFF;
> ok

CREATE ALIAS SLEEP FOR "java.lang.Thread.sleep(long)";
> ok

CREATE TABLE TEST(I IDENTITY PRIMARY KEY, T TIMESTAMP(9) WITH TIME ZONE);
> ok

INSERT INTO TEST(T) VALUES (CURRENT_TIMESTAMP(9)), (CURRENT_TIMESTAMP(9));
> update count: 2

CALL SLEEP(10);
>> null

INSERT INTO TEST(T) VALUES (CURRENT_TIMESTAMP(9));
> update count: 1

CALL SLEEP(10);
>> null

COMMIT;
> ok

INSERT INTO TEST(T) VALUES (CURRENT_TIMESTAMP(9));
> update count: 1

CALL SLEEP(10);
>> null

COMMIT;
> ok

-- same statement
SELECT (SELECT T FROM TEST WHERE I = 1) = (SELECT T FROM TEST WHERE I = 2);
>> TRUE

-- same transaction
SELECT (SELECT T FROM TEST WHERE I = 2) = (SELECT T FROM TEST WHERE I = 3);
>> TRUE

-- another transaction
SELECT (SELECT T FROM TEST WHERE I = 3) = (SELECT T FROM TEST WHERE I = 4);
>> FALSE

SET MODE MySQL;
> ok

INSERT INTO TEST(T) VALUES (CURRENT_TIMESTAMP(9)), (CURRENT_TIMESTAMP(9));
> update count: 2

CALL SLEEP(10);
>> null

INSERT INTO TEST(T) VALUES (CURRENT_TIMESTAMP(9));
> update count: 1

CALL SLEEP(10);
>> null

COMMIT;
> ok

INSERT INTO TEST(T) VALUES (CURRENT_TIMESTAMP(9));
> update count: 1

COMMIT;
> ok

-- same statement
SELECT (SELECT T FROM TEST WHERE I = 5) = (SELECT T FROM TEST WHERE I = 6);
>> TRUE

-- same transaction
SELECT (SELECT T FROM TEST WHERE I = 6) = (SELECT T FROM TEST WHERE I = 7);
>> FALSE

-- another transaction
SELECT (SELECT T FROM TEST WHERE I = 7) = (SELECT T FROM TEST WHERE I = 8);
>> FALSE

SET MODE Regular;
> ok

DROP TABLE TEST;
> ok

DROP ALIAS SLEEP;
> ok

SET AUTOCOMMIT ON;
> ok

@reconnect on

SELECT GETDATE();
> exception FUNCTION_NOT_FOUND_1

SET MODE MSSQLServer;
> ok

SELECT LOCALTIMESTAMP = GETDATE();
>> TRUE

SET MODE Regular;
> ok
