-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(B INT);
> ok

ALTER TABLE TEST ADD C INT;
> ok

ALTER TABLE TEST ADD COLUMN D INT;
> ok

ALTER TABLE TEST ADD IF NOT EXISTS B INT;
> ok

ALTER TABLE TEST ADD IF NOT EXISTS E INT;
> ok

ALTER TABLE IF EXISTS TEST2 ADD COLUMN B INT;
> ok

ALTER TABLE TEST ADD B1 INT AFTER B;
> ok

ALTER TABLE TEST ADD B2 INT BEFORE C;
> ok

ALTER TABLE TEST ADD (C1 INT, C2 INT) AFTER C;
> ok

ALTER TABLE TEST ADD (C3 INT, C4 INT) BEFORE D;
> ok

ALTER TABLE TEST ADD A2 INT FIRST;
> ok

ALTER TABLE TEST ADD (A INT, A1 INT) FIRST;
> ok

SELECT * FROM TEST;
> A A1 A2 B B1 B2 C C1 C2 C3 C4 D E
> - -- -- - -- -- - -- -- -- -- - -
> rows: 0

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT NOT NULL, B INT);
> ok

-- column B may be null
ALTER TABLE TEST ADD (CONSTRAINT PK_B PRIMARY KEY (B));
> exception COLUMN_MUST_NOT_BE_NULLABLE_1

ALTER TABLE TEST ADD (CONSTRAINT PK_A PRIMARY KEY (A));
> ok

ALTER TABLE TEST ADD (C INT AUTO_INCREMENT UNIQUE, CONSTRAINT U_B UNIQUE (B), D INT UNIQUE);
> ok

INSERT INTO TEST(A, B, D) VALUES (11, 12, 14);
> update count: 1

SELECT * FROM TEST;
> A  B  C D
> -- -- - --
> 11 12 1 14
> rows: 1

INSERT INTO TEST VALUES (11, 20, 30, 40);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 12, 30, 40);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 20, 1, 40);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 20, 30, 14);
> exception DUPLICATE_KEY_1

INSERT INTO TEST VALUES (10, 20, 30, 40);
> update count: 1

DROP TABLE TEST;
> ok

CREATE TABLE TEST();
> ok

ALTER TABLE TEST ADD A INT CONSTRAINT PK_1 PRIMARY KEY;
> ok

SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS;
> CONSTRAINT_NAME CONSTRAINT_TYPE
> --------------- ---------------
> PK_1            PRIMARY KEY
> rows: 1

DROP TABLE TEST;
> ok
