-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

-- EXEC and EXECUTE in MSSQLServer mode

CREATE ALIAS MY_NO_ARG AS 'int f() { return 1; }';
> ok

CREATE ALIAS MY_SQRT FOR "java.lang.Math.sqrt";
> ok

CREATE ALIAS MY_REMAINDER FOR "java.lang.Math.IEEEremainder";
> ok

EXEC MY_SQRT 4;
> exception SYNTAX_ERROR_2

-- PostgreSQL-style EXECUTE doesn't work with MSSQLServer-style arguments
EXECUTE MY_SQRT 4;
> exception FUNCTION_ALIAS_NOT_FOUND_1

SET MODE MSSQLServer;
> ok

-- PostgreSQL-style PREPARE is not available in MSSQLServer mode
PREPARE TEST AS SELECT 1;
> exception SYNTAX_ERROR_1

-- PostgreSQL-style DEALLOCATE is not available in MSSQLServer mode
DEALLOCATE TEST;
> exception SYNTAX_ERROR_2

EXEC MY_NO_ARG;
>> 1

EXEC MY_SQRT 4;
>> 2.0

EXEC MY_REMAINDER 4, 3;
>> 1.0

EXECUTE MY_SQRT 4;
>> 2.0

EXEC PUBLIC.MY_SQRT 4;
>> 2.0

EXEC SCRIPT.PUBLIC.MY_SQRT 4;
>> 2.0

EXEC UNKNOWN_PROCEDURE;
> exception FUNCTION_NOT_FOUND_1

EXEC UNKNOWN_SCHEMA.MY_SQRT 4;
> exception SCHEMA_NOT_FOUND_1

EXEC UNKNOWN_DATABASE.PUBLIC.MY_SQRT 4;
> exception DATABASE_NOT_FOUND_1

SET MODE Regular;
> ok

DROP ALIAS MY_NO_ARG;
> ok

DROP ALIAS MY_SQRT;
> ok

DROP ALIAS MY_REMAINDER;
> ok

-- UPDATE TOP (n) in MSSQLServer mode

CREATE TABLE TEST(A INT, B INT) AS VALUES (1, 2), (3, 4), (5, 6);
> ok

UPDATE TOP (1) TEST SET B = 10;
> exception TABLE_OR_VIEW_NOT_FOUND_1

SET MODE MSSQLServer;
> ok

UPDATE TOP (1) TEST SET B = 10;
> update count: 1

SELECT COUNT(*) FILTER (WHERE B = 10) N, COUNT(*) FILTER (WHERE B <> 10) O FROM TEST;
> N O
> - -
> 1 2
> rows: 1

UPDATE TEST SET B = 10 WHERE B <> 10;
> update count: 2

UPDATE TOP (1) TEST SET B = 10 LIMIT 1;
> exception SYNTAX_ERROR_1

SET MODE Regular;
> ok

DROP TABLE TEST;
> ok

SET MODE MySQL;
> ok

CREATE TABLE A (A INT PRIMARY KEY, X INT);
> ok

ALTER TABLE A ADD INDEX A_IDX(X);
> ok

-- MariaDB compatibility
ALTER TABLE A DROP INDEX A_IDX_1;
> exception CONSTRAINT_NOT_FOUND_1

ALTER TABLE A DROP INDEX IF EXISTS A_IDX_1;
> ok

ALTER TABLE A DROP INDEX IF EXISTS A_IDX;
> ok

ALTER TABLE A DROP INDEX A_IDX;
> exception CONSTRAINT_NOT_FOUND_1

CREATE TABLE B (B INT PRIMARY KEY, A INT);
> ok

ALTER TABLE B ADD CONSTRAINT B_FK FOREIGN KEY (A) REFERENCES A(A);
> ok

ALTER TABLE B DROP FOREIGN KEY B_FK_1;
> exception CONSTRAINT_NOT_FOUND_1

-- MariaDB compatibility
ALTER TABLE B DROP FOREIGN KEY IF EXISTS B_FK_1;
> ok

ALTER TABLE B DROP FOREIGN KEY IF EXISTS B_FK;
> ok

ALTER TABLE B DROP FOREIGN KEY B_FK;
> exception CONSTRAINT_NOT_FOUND_1

DROP TABLE A, B;
> ok

SET MODE Regular;
> ok
