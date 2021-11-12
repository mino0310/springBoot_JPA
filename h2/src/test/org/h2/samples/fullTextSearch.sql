/*
 * Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */

// Example using the 'native' fulltext search implementation
CREATE ALIAS IF NOT EXISTS FT_INIT FOR "org.h2.fulltext.FullText.init";
CALL FT_INIT();
DROP TABLE IF EXISTS TEST;
CREATE TABLE TEST(ID INT PRIMARY KEY, NAME VARCHAR);
INSERT INTO TEST VALUES(1, 'Hello World');
CALL FT_CREATE_INDEX('PUBLIC', 'TEST', NULL);
SELECT * FROM FT_SEARCH('Hello', 0, 0);
SELECT * FROM FT_SEARCH('Hallo', 0, 0);
INSERT INTO TEST VALUES(2, 'Hallo Welt');
SELECT * FROM FT_SEARCH('Hello', 0, 0);
SELECT * FROM FT_SEARCH('Hallo', 0, 0);
CALL FT_REINDEX();
SELECT * FROM FT_SEARCH('Hello', 0, 0);
SELECT * FROM FT_SEARCH('Hallo', 0, 0);
INSERT INTO TEST VALUES(3, 'Hello World');
INSERT INTO TEST VALUES(4, 'Hello World');
INSERT INTO TEST VALUES(5, 'Hello World');
SELECT * FROM FT_SEARCH('World', 0, 0);
SELECT * FROM FT_SEARCH('World', 1, 0);
SELECT * FROM FT_SEARCH('World', 0, 2);
SELECT * FROM FT_SEARCH('World', 2, 1);
SELECT * FROM FT_SEARCH('1', 0, 0);
CALL FT_DROP_INDEX('PUBLIC', 'TEST');
SELECT * FROM FT_SEARCH('World', 2, 1);
CALL FT_DROP_ALL();

// Example using the 'Lucene' fulltext search implementation
CREATE ALIAS IF NOT EXISTS FTL_INIT FOR "org.h2.fulltext.FullTextLucene.init";
CALL FTL_INIT();
DROP TABLE IF EXISTS TEST;
CREATE TABLE TEST(ID INT PRIMARY KEY, NAME VARCHAR);
INSERT INTO TEST VALUES(1, 'Hello World');
CALL FTL_CREATE_INDEX('PUBLIC', 'TEST', NULL);
SELECT * FROM FTL_SEARCH('Hello', 0, 0);
SELECT * FROM FTL_SEARCH('Hallo', 0, 0);
INSERT INTO TEST VALUES(2, 'Hallo Welt');
SELECT * FROM FTL_SEARCH('Hello', 0, 0);
SELECT * FROM FTL_SEARCH('Hallo', 0, 0);
CALL FTL_REINDEX();
SELECT * FROM FTL_SEARCH('Hello', 0, 0);
SELECT * FROM FTL_SEARCH('Hallo', 0, 0);
INSERT INTO TEST VALUES(3, 'Hello World');
INSERT INTO TEST VALUES(4, 'Hello World');
INSERT INTO TEST VALUES(5, 'Hello World');
SELECT * FROM FTL_SEARCH('World', 0, 0);
SELECT * FROM FTL_SEARCH('World', 1, 0);
SELECT * FROM FTL_SEARCH('World', 0, 2);
SELECT * FROM FTL_SEARCH('World', 2, 1);
SELECT * FROM FTL_SEARCH('1', 0, 0);
CALL FTL_DROP_ALL();
SELECT * FROM FTL_SEARCH('World', 2, 1);
CALL FTL_DROP_ALL();
