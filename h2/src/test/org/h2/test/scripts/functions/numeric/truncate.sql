-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

SELECT TRUNCATE(1.234, 2);
>> 1.23

SELECT (CURRENT_TIMESTAMP - CURRENT_TIME(6)) = TRUNCATE(CURRENT_TIMESTAMP);
>> TRUE

SELECT TRUNCATE(DATE '2011-03-05');
>> 2011-03-05 00:00:00

SELECT TRUNCATE(TIMESTAMP '2011-03-05 02:03:04');
>> 2011-03-05 00:00:00

SELECT TRUNCATE(TIMESTAMP WITH TIME ZONE '2011-03-05 02:03:04+07');
>> 2011-03-05 00:00:00+07

SELECT TRUNCATE(CURRENT_DATE, 1);
> exception INVALID_PARAMETER_COUNT_2

SELECT TRUNCATE(LOCALTIMESTAMP, 1);
> exception INVALID_PARAMETER_COUNT_2

SELECT TRUNCATE(CURRENT_TIMESTAMP, 1);
> exception INVALID_PARAMETER_COUNT_2

SELECT TRUNCATE('2011-03-05 02:03:04', 1);
> exception INVALID_PARAMETER_COUNT_2

SELECT TRUNCATE('bad');
> exception INVALID_DATETIME_CONSTANT_2

SELECT TRUNCATE(1, 2, 3);
> exception INVALID_PARAMETER_COUNT_2

select truncate(null, null) en, truncate(1.99, 0) e1, truncate(-10.9, 0) em10;
> EN   E1 EM10
> ---- -- ----
> null 1  -10
> rows: 1

select trunc(null, null) en, trunc(1.99, 0) e1, trunc(-10.9, 0) em10;
> EN   E1 EM10
> ---- -- ----
> null 1  -10
> rows: 1

select trunc(1.3);
>> 1

SELECT TRUNCATE(1.3) IS OF (NUMERIC);
>> TRUE

SELECT TRUNCATE(CAST(1.3 AS DOUBLE)) IS OF (DOUBLE);
>> TRUE

SELECT TRUNCATE(CAST(1.3 AS REAL)) IS OF (REAL);
>> TRUE

SELECT TRUNCATE(1.99, 0), TRUNCATE(1.99, 1), TRUNCATE(-1.99, 0), TRUNCATE(-1.99, 1);
> 1 1.9 -1 -1.9
> - --- -- ----
> 1 1.9 -1 -1.9
> rows: 1

SELECT TRUNCATE(1.99::DOUBLE, 0), TRUNCATE(1.99::DOUBLE, 1), TRUNCATE(-1.99::DOUBLE, 0), TRUNCATE(-1.99::DOUBLE, 1);
> 1.0 1.9 -1.0 -1.9
> --- --- ---- ----
> 1.0 1.9 -1.0 -1.9
> rows: 1

SELECT TRUNCATE(1.99::REAL, 0), TRUNCATE(1.99::REAL, 1), TRUNCATE(-1.99::REAL, 0), TRUNCATE(-1.99::REAL, 1);
> 1.0 1.9 -1.0 -1.9
> --- --- ---- ----
> 1.0 1.9 -1.0 -1.9
> rows: 1

SELECT TRUNCATE(V, S) FROM (VALUES (1.111, 1)) T(V, S);
>> 1.1
