-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(ID BIGINT AUTO_INCREMENT PRIMARY KEY, A INT, B INT);
> ok

CREATE TRIGGER T1 BEFORE INSERT, UPDATE ON TEST FOR EACH ROW CALL "org.h2.test.scripts.Trigger1";
> ok

-- INSERT

SELECT * FROM OLD TABLE (INSERT INTO TEST(A, B) VALUES (100, 100));
> exception SYNTAX_ERROR_2

SELECT * FROM NEW TABLE (INSERT INTO TEST(A, B) VALUES (1, 2));
> ID A B
> -- - -
> 1  1 2
> rows: 1

SELECT * FROM FINAL TABLE (INSERT INTO TEST(A, B) VALUES (2, 3));
> ID A B
> -- - --
> 2  2 30
> rows: 1

-- INSERT from SELECT

SELECT * FROM NEW TABLE (INSERT INTO TEST(A, B) SELECT * FROM VALUES (3, 4), (4, 5));
> ID A B
> -- - -
> 3  3 4
> 4  4 5
> rows: 2

SELECT * FROM FINAL TABLE (INSERT INTO TEST(A, B) SELECT * FROM VALUES (5, 6), (6, 7));
> ID A B
> -- - --
> 5  5 60
> 6  6 70
> rows: 2

-- UPDATE

SELECT * FROM OLD TABLE (UPDATE TEST SET B = 3 WHERE ID = 1);
> ID A B
> -- - --
> 1  1 20
> rows: 1

SELECT * FROM NEW TABLE (UPDATE TEST SET B = 3 WHERE ID = 1);
> ID A B
> -- - -
> 1  1 3
> rows: 1

SELECT * FROM FINAL TABLE (UPDATE TEST SET B = 3 WHERE ID = 1);
> ID A B
> -- - --
> 1  1 30
> rows: 1

-- DELETE

SELECT * FROM OLD TABLE (DELETE FROM TEST WHERE ID = 1);
> ID A B
> -- - --
> 1  1 30
> rows: 1

SELECT * FROM OLD TABLE (DELETE FROM TEST WHERE ID = ?);
{
2
> ID A B
> -- - --
> 2  2 30
> rows: 1
100
> ID A B
> -- - -
> rows: 0
};
> update count: 0

SELECT * FROM NEW TABLE (DELETE FROM TEST);
> exception SYNTAX_ERROR_2

SELECT * FROM FINAL TABLE (DELETE FROM TEST);
> exception SYNTAX_ERROR_2

SELECT * FROM TEST TABLE (DELETE FROM TEST);
> exception SYNTAX_ERROR_2

-- MERGE INTO

SELECT * FROM OLD TABLE (MERGE INTO TEST KEY(ID) VALUES (3, 3, 5), (7, 7, 8));
> ID A B
> -- - --
> 3  3 40
> rows: 1

SELECT * FROM NEW TABLE (MERGE INTO TEST KEY(ID) VALUES (4, 4, 6), (8, 8, 9));
> ID A B
> -- - -
> 4  4 6
> 8  8 9
> rows: 2

SELECT * FROM FINAL TABLE (MERGE INTO TEST KEY(ID) VALUES (5, 5, 7), (9, 9, 10));
> ID A B
> -- - ---
> 5  5 70
> 9  9 100
> rows: 2

-- MERGE INTO from SELECT

SELECT * FROM OLD TABLE (MERGE INTO TEST KEY(ID) SELECT * FROM VALUES (3, 3, 6), (10, 10, 11));
> ID A B
> -- - --
> 3  3 50
> rows: 1

SELECT * FROM NEW TABLE (MERGE INTO TEST KEY(ID) SELECT * FROM VALUES (4, 4, 7), (11, 11, 12));
> ID A  B
> -- -- --
> 11 11 12
> 4  4  7
> rows: 2

SELECT * FROM FINAL TABLE (MERGE INTO TEST KEY(ID) SELECT * FROM VALUES (5, 5, 8), (12, 12, 13));
> ID A  B
> -- -- ---
> 12 12 130
> 5  5  80
> rows: 2

-- MERGE USING

SELECT * FROM OLD TABLE (MERGE INTO TEST USING
    (SELECT * FROM (VALUES (3, 3, 7), (10, 10, 12), (13, 13, 14)) S(ID, A, B)) S
    ON TEST.ID = S.ID
    WHEN MATCHED AND S.ID = 3 THEN UPDATE SET TEST.B = S.B
    WHEN MATCHED AND S.ID <> 3 THEN DELETE
    WHEN NOT MATCHED THEN INSERT VALUES (S.ID, S.A, S.B));
> ID A  B
> -- -- ---
> 10 10 110
> 3  3  60
> rows: 2

SELECT * FROM NEW TABLE (MERGE INTO TEST USING
    (SELECT * FROM (VALUES (4, 4, 8), (11, 11, 13), (14, 14, 15)) S(ID, A, B)) S
    ON TEST.ID = S.ID
    WHEN MATCHED AND S.ID = 4 THEN UPDATE SET TEST.B = S.B
    WHEN MATCHED AND S.ID <> 4 THEN DELETE
    WHEN NOT MATCHED THEN INSERT VALUES (S.ID, S.A, S.B));
> ID A  B
> -- -- --
> 14 14 15
> 4  4  8
> rows: 2

SELECT * FROM FINAL TABLE (MERGE INTO TEST USING
    (SELECT * FROM (VALUES (5, 5, 9), (12, 12, 15), (15, 15, 16)) S(ID, A, B)) S
    ON TEST.ID = S.ID
    WHEN MATCHED AND S.ID = 5 THEN UPDATE SET TEST.B = S.B
    WHEN MATCHED AND S.ID <> 5 THEN DELETE
    WHEN NOT MATCHED THEN INSERT VALUES (S.ID, S.A, S.B));
> ID A  B
> -- -- ---
> 15 15 160
> 5  5  90
> rows: 2

SELECT * FROM OLD TABLE (MERGE INTO TEST USING
    (SELECT * FROM (VALUES (3, 3, 8), (4, 4, 9)) S(ID, A, B)) S
    ON TEST.ID = S.ID
    WHEN MATCHED THEN UPDATE SET TEST.B = S.B DELETE WHERE TEST.B = 3);
> exception FEATURE_NOT_SUPPORTED_1

-- REPLACE

SELECT * FROM OLD TABLE (REPLACE INTO TEST VALUES (3, 3, 8), (16, 16, 17));
> exception SYNTAX_ERROR_2

SELECT * FROM NEW TABLE (REPLACE INTO TEST VALUES (4, 4, 9), (17, 17, 18));
> exception SYNTAX_ERROR_2

SELECT * FROM FINAL TABLE (REPLACE INTO TEST VALUES (5, 5, 10), (18, 18, 19));
> exception SYNTAX_ERROR_2

SET MODE MySQL;
> ok

SELECT * FROM OLD TABLE (REPLACE INTO TEST VALUES (3, 3, 8), (16, 16, 17));
> ID A B
> -- - --
> 3  3 70
> rows: 1

SELECT * FROM NEW TABLE (REPLACE INTO TEST VALUES (4, 4, 9), (17, 17, 18));
> ID A  B
> -- -- --
> 17 17 18
> 4  4  9
> rows: 2

SELECT * FROM FINAL TABLE (REPLACE INTO TEST VALUES (5, 5, 10), (18, 18, 19));
> ID A  B
> -- -- ---
> 18 18 190
> 5  5  100
> rows: 2

-- REPLACE from SELECT

SELECT * FROM OLD TABLE (REPLACE INTO TEST SELECT * FROM VALUES (3, 3, 9), (19, 19, 20));
> ID A B
> -- - --
> 3  3 80
> rows: 1

SELECT * FROM NEW TABLE (REPLACE INTO TEST SELECT * FROM VALUES (4, 4, 10), (20, 20, 21));
> ID A  B
> -- -- --
> 20 20 21
> 4  4  10
> rows: 2

SELECT * FROM FINAL TABLE (REPLACE INTO TEST SELECT * FROM VALUES (5, 5, 11), (21, 21, 22));
> ID A  B
> -- -- ---
> 21 21 220
> 5  5  110
> rows: 2

SET MODE Regular;
> ok

TRUNCATE TABLE TEST RESTART IDENTITY;
> ok

CREATE VIEW TEST_VIEW AS SELECT * FROM TEST;
> ok

CREATE TRIGGER T2 INSTEAD OF INSERT, UPDATE, DELETE ON TEST_VIEW FOR EACH ROW CALL "org.h2.test.scripts.Trigger2";
> ok

-- INSERT

SELECT * FROM NEW TABLE (INSERT INTO TEST_VIEW(A, B) VALUES (1, 2));
> ID   A B
> ---- - -
> null 1 2
> rows: 1

SELECT * FROM FINAL TABLE (INSERT INTO TEST_VIEW(A, B) VALUES (2, 3));
> exception FEATURE_NOT_SUPPORTED_1

INSERT INTO TEST_VIEW(A, B) VALUES (2, 3);
> update count: 1

-- INSERT from SELECT

SELECT * FROM NEW TABLE (INSERT INTO TEST_VIEW(A, B) SELECT * FROM VALUES (3, 4), (4, 5));
> ID   A B
> ---- - -
> null 3 4
> null 4 5
> rows: 2

SELECT * FROM FINAL TABLE (INSERT INTO TEST_VIEW(A, B) SELECT * FROM VALUES (5, 6), (6, 7));
> exception FEATURE_NOT_SUPPORTED_1

INSERT INTO TEST_VIEW(A, B) SELECT * FROM VALUES (5, 6), (6, 7);
> update count: 2

-- UPDATE

SELECT * FROM OLD TABLE (UPDATE TEST_VIEW SET B = 3 WHERE ID = 1);
> ID A B
> -- - --
> 1  1 20
> rows: 1

SELECT * FROM NEW TABLE (UPDATE TEST_VIEW SET B = 3 WHERE ID = 1);
> ID A B
> -- - -
> 1  1 3
> rows: 1

SELECT * FROM FINAL TABLE (UPDATE TEST_VIEW SET B = 3 WHERE ID = 1);
> exception FEATURE_NOT_SUPPORTED_1

UPDATE TEST_VIEW SET B = 3 WHERE ID = 1;
> update count: 1

-- DELETE

SELECT * FROM OLD TABLE (DELETE FROM TEST_VIEW WHERE ID = 1);
> ID A B
> -- - --
> 1  1 30
> rows: 1

SELECT * FROM OLD TABLE (DELETE FROM TEST_VIEW WHERE ID = ?);
{
2
> ID A B
> -- - --
> 2  2 30
> rows: 1
100
> ID A B
> -- - -
> rows: 0
};
> update count: 0

-- MERGE INTO

SELECT * FROM OLD TABLE (MERGE INTO TEST_VIEW KEY(ID) VALUES (3, 3, 5), (7, 7, 8));
> ID A B
> -- - --
> 3  3 40
> rows: 1

SELECT * FROM NEW TABLE (MERGE INTO TEST_VIEW KEY(ID) VALUES (4, 4, 6), (8, 8, 9));
> ID A B
> -- - -
> 4  4 6
> 8  8 9
> rows: 2

SELECT * FROM FINAL TABLE (MERGE INTO TEST_VIEW KEY(ID) VALUES (5, 5, 7), (9, 9, 10));
> exception FEATURE_NOT_SUPPORTED_1

MERGE INTO TEST_VIEW KEY(ID) VALUES (5, 5, 7), (9, 9, 10);
> update count: 2

-- MERGE INTO from SELECT

SELECT * FROM OLD TABLE (MERGE INTO TEST_VIEW KEY(ID) SELECT * FROM VALUES (3, 3, 6), (10, 10, 11));
> ID A B
> -- - --
> 3  3 50
> rows: 1

SELECT * FROM NEW TABLE (MERGE INTO TEST_VIEW KEY(ID) SELECT * FROM VALUES (4, 4, 7), (11, 11, 12));
> ID A  B
> -- -- --
> 11 11 12
> 4  4  7
> rows: 2

SELECT * FROM FINAL TABLE (MERGE INTO TEST_VIEW KEY(ID) SELECT * FROM VALUES (5, 5, 8), (12, 12, 13));
> exception FEATURE_NOT_SUPPORTED_1

MERGE INTO TEST_VIEW KEY(ID) SELECT * FROM VALUES (5, 5, 8), (12, 12, 13);
> update count: 2

-- MERGE USING does not work with views

DROP TABLE TEST CASCADE;
> ok
