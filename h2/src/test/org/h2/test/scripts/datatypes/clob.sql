-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(C1 CLOB, C2 CHARACTER LARGE OBJECT, C3 TINYTEXT, C4 TEXT, C5 MEDIUMTEXT, C6 LONGTEXT, C7 NTEXT,
    C8 NCLOB);
> ok

SELECT COLUMN_NAME, DATA_TYPE, TYPE_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'TEST' ORDER BY ORDINAL_POSITION;
> COLUMN_NAME DATA_TYPE TYPE_NAME COLUMN_TYPE
> ----------- --------- --------- ----------------------
> C1          2005      CLOB      CLOB
> C2          2005      CLOB      CHARACTER LARGE OBJECT
> C3          2005      CLOB      TINYTEXT
> C4          2005      CLOB      TEXT
> C5          2005      CLOB      MEDIUMTEXT
> C6          2005      CLOB      LONGTEXT
> C7          2005      CLOB      NTEXT
> C8          2005      CLOB      NCLOB
> rows (ordered): 8

DROP TABLE TEST;
> ok

CREATE TABLE TEST(C0 CLOB(10), C1 CLOB(10K), C2 CLOB(10M CHARACTERS), C3 CLOB(10G OCTETS), C4 CLOB(10T), C5 CLOB(10P));
> ok

SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'TEST' ORDER BY ORDINAL_POSITION;
> COLUMN_NAME COLUMN_TYPE
> ----------- -----------------------
> C0          CLOB(10)
> C1          CLOB(10240)
> C2          CLOB(10485760)
> C3          CLOB(10737418240)
> C4          CLOB(10995116277760)
> C5          CLOB(11258999068426240)
> rows (ordered): 6

INSERT INTO TEST(C0) VALUES ('12345678901');
> exception VALUE_TOO_LONG_2

INSERT INTO TEST(C0) VALUES ('1234567890');
> update count: 1

SELECT C0 FROM TEST;
>> 1234567890

DROP TABLE TEST;
> ok

CREATE TABLE TEST(C CLOB(8192P));
> exception INVALID_VALUE_2
