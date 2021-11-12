-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(A INT, B INT, C INT);
> ok

INSERT INTO TEST VALUES (1, 1, 1), (1, 1, 2), (1, 1, 3), (1, 2, 1), (1, 2, 2), (1, 2, 3),
    (2, 1, 1), (2, 1, 2), (2, 1, 3), (2, 2, 1), (2, 2, 2), (2, 2, 3);
> update count: 12

SELECT * FROM TEST ORDER BY A, B;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> 1 2 2
> 1 2 3
> 2 1 1
> 2 1 2
> 2 1 3
> 2 2 1
> 2 2 2
> 2 2 3
> rows (partially ordered): 12

SELECT * FROM TEST ORDER BY A, B, C FETCH FIRST 4 ROWS ONLY;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> rows (ordered): 4

SELECT * FROM TEST ORDER BY A, B, C FETCH FIRST 4 ROWS WITH TIES;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> rows (ordered): 4

SELECT * FROM TEST ORDER BY A, B FETCH FIRST 4 ROWS WITH TIES;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> 1 2 2
> 1 2 3
> rows (partially ordered): 6

SELECT * FROM TEST ORDER BY A FETCH FIRST ROW WITH TIES;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> 1 2 2
> 1 2 3
> rows (partially ordered): 6

SELECT TOP (1) WITH TIES * FROM TEST ORDER BY A;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> 1 2 2
> 1 2 3
> rows (partially ordered): 6

SELECT TOP 1 PERCENT WITH TIES * FROM TEST ORDER BY A;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> 1 2 2
> 1 2 3
> rows (partially ordered): 6

SELECT TOP 51 PERCENT WITH TIES * FROM TEST ORDER BY A, B;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> 1 2 2
> 1 2 3
> 2 1 1
> 2 1 2
> 2 1 3
> rows (partially ordered): 9

SELECT * FROM TEST ORDER BY A, B OFFSET 3 ROWS FETCH NEXT 1 ROW WITH TIES;
> A B C
> - - -
> 1 2 1
> 1 2 2
> 1 2 3
> rows (partially ordered): 3

SELECT * FROM TEST FETCH NEXT ROWS ONLY;
> A B C
> - - -
> 1 1 1
> rows: 1

SELECT * FROM TEST FETCH FIRST 101 PERCENT ROWS ONLY;
> exception INVALID_VALUE_2

SELECT * FROM TEST FETCH FIRST -1 PERCENT ROWS ONLY;
> exception INVALID_VALUE_2

SELECT * FROM TEST FETCH FIRST 0 PERCENT ROWS ONLY;
> A B C
> - - -
> rows: 0

SELECT * FROM TEST FETCH FIRST 1 PERCENT ROWS ONLY;
> A B C
> - - -
> 1 1 1
> rows: 1

SELECT * FROM TEST FETCH FIRST 10 PERCENT ROWS ONLY;
> A B C
> - - -
> 1 1 1
> 1 1 2
> rows: 2

SELECT * FROM TEST OFFSET 2 ROWS FETCH NEXT 10 PERCENT ROWS ONLY;
> A B C
> - - -
> 1 1 3
> 1 2 1
> rows: 2

CREATE INDEX TEST_A_IDX ON TEST(A);
> ok

CREATE INDEX TEST_A_B_IDX ON TEST(A, B);
> ok

SELECT * FROM TEST ORDER BY A FETCH FIRST 1 ROW WITH TIES;
> A B C
> - - -
> 1 1 1
> 1 1 2
> 1 1 3
> 1 2 1
> 1 2 2
> 1 2 3
> rows (partially ordered): 6

SELECT * FROM TEST ORDER BY A, B OFFSET 3 ROWS FETCH NEXT 1 ROW WITH TIES;
> A B C
> - - -
> 1 2 1
> 1 2 2
> 1 2 3
> rows (partially ordered): 3

SELECT * FROM TEST FETCH FIRST 1 ROW WITH TIES;
> exception WITH_TIES_WITHOUT_ORDER_BY

(SELECT * FROM TEST) UNION (SELECT 1, 2, 4) ORDER BY A, B OFFSET 3 ROWS FETCH NEXT 1 ROW WITH TIES;
> A B C
> - - -
> 1 2 1
> 1 2 2
> 1 2 3
> 1 2 4
> rows (partially ordered): 4

(SELECT * FROM TEST) UNION (SELECT 1, 2, 4) ORDER BY A, B OFFSET 3 ROWS FETCH NEXT 50 PERCENT ROWS ONLY;
> A B C
> - - -
> 1 2 1
> 1 2 2
> 1 2 3
> 1 2 4
> 2 1 1
> 2 1 2
> 2 1 3
> rows (partially ordered): 7

(SELECT * FROM TEST) UNION (SELECT 1, 2, 4) ORDER BY A, B OFFSET 3 ROWS FETCH NEXT 40 PERCENT ROWS WITH TIES;
> A B C
> - - -
> 1 2 1
> 1 2 2
> 1 2 3
> 1 2 4
> 2 1 1
> 2 1 2
> 2 1 3
> rows (partially ordered): 7

(SELECT * FROM TEST) UNION (SELECT 1, 2, 4) FETCH NEXT 1 ROW WITH TIES;
> exception WITH_TIES_WITHOUT_ORDER_BY

EXPLAIN SELECT * FROM TEST ORDER BY A, B OFFSET 3 ROWS FETCH NEXT 1 ROW WITH TIES;
>> SELECT "PUBLIC"."TEST"."A", "PUBLIC"."TEST"."B", "PUBLIC"."TEST"."C" FROM "PUBLIC"."TEST" /* PUBLIC.TEST_A_B_IDX */ ORDER BY 1, 2 OFFSET 3 ROWS FETCH NEXT ROW WITH TIES /* index sorted */

EXPLAIN SELECT * FROM TEST ORDER BY A, B OFFSET 3 ROWS FETCH NEXT 1 PERCENT ROWS WITH TIES;
>> SELECT "PUBLIC"."TEST"."A", "PUBLIC"."TEST"."B", "PUBLIC"."TEST"."C" FROM "PUBLIC"."TEST" /* PUBLIC.TEST_A_B_IDX */ ORDER BY 1, 2 OFFSET 3 ROWS FETCH NEXT 1 PERCENT ROWS WITH TIES /* index sorted */

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A NUMERIC, B NUMERIC);
> ok

INSERT INTO TEST VALUES (0, 1), (0.0, 2), (0, 3), (1, 4);
> update count: 4

SELECT A, B FROM TEST ORDER BY A FETCH FIRST 1 ROW WITH TIES;
> A   B
> --- -
> 0   1
> 0   3
> 0.0 2
> rows (partially ordered): 3

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT, B INT);
> ok

INSERT INTO TEST VALUES (1, 1), (1, 2), (2, 1), (2, 2), (2, 3);
> update count: 5

SELECT A, COUNT(B) FROM TEST GROUP BY A ORDER BY A OFFSET 1;
> A COUNT(B)
> - --------
> 2 3
> rows (ordered): 1

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT PRIMARY KEY, VALUE VARCHAR) AS VALUES (1, 'A'), (2, 'B'), (3, 'C');
> ok

SELECT * FROM TEST ORDER BY ID DESC OFFSET 2 ROWS FETCH FIRST 2147483646 ROWS ONLY;
> ID VALUE
> -- -----
> 1  A
> rows (ordered): 1

SELECT * FROM TEST ORDER BY ID DESC OFFSET 2 ROWS FETCH FIRST 2147483647 ROWS ONLY;
> ID VALUE
> -- -----
> 1  A
> rows (ordered): 1

DROP TABLE TEST;
> ok

CREATE TABLE TEST1(A INT, B INT, C INT) AS SELECT 1, 2, 3;
> ok

CREATE TABLE TEST2(A INT, B INT, C INT) AS SELECT 4, 5, 6;
> ok

SELECT A, B FROM TEST1 UNION SELECT A, B FROM TEST2 ORDER BY 1.1;
> exception ORDER_BY_NOT_IN_RESULT

DROP TABLE TEST1;
> ok

DROP TABLE TEST2;
> ok

-- Disallowed mixed OFFSET/FETCH/LIMIT/TOP clauses
CREATE TABLE TEST (ID BIGINT);
> ok

SELECT TOP 1 ID FROM TEST OFFSET 1 ROW;
> exception SYNTAX_ERROR_1

SELECT TOP 1 ID FROM TEST FETCH NEXT ROW ONLY;
> exception SYNTAX_ERROR_1

SELECT TOP 1 ID FROM TEST LIMIT 1;
> exception SYNTAX_ERROR_1

SELECT ID FROM TEST OFFSET 1 ROW LIMIT 1;
> exception SYNTAX_ERROR_1

SELECT ID FROM TEST FETCH NEXT ROW ONLY LIMIT 1;
> exception SYNTAX_ERROR_1

DROP TABLE TEST;
> ok

-- ORDER BY with parameter
CREATE TABLE TEST(A INT, B INT);
> ok

INSERT INTO TEST VALUES (1, 1), (1, 2), (2, 1), (2, 2);
> update count: 4

SELECT * FROM TEST ORDER BY ?, ? FETCH FIRST ROW ONLY;
{
1, 2
> A B
> - -
> 1 1
> rows (ordered): 1
-1, 2
> A B
> - -
> 2 1
> rows (ordered): 1
1, -2
> A B
> - -
> 1 2
> rows (ordered): 1
-1, -2
> A B
> - -
> 2 2
> rows (ordered): 1
2, -1
> A B
> - -
> 2 1
> rows (ordered): 1
}
> update count: 0

DROP TABLE TEST;
> ok

CREATE TABLE TEST1(A INT, B INT, C INT) AS SELECT 1, 2, 3;
> ok

CREATE TABLE TEST2(A INT, D INT) AS SELECT 4, 5;
> ok

SELECT * FROM TEST1, TEST2;
> A B C A D
> - - - - -
> 1 2 3 4 5
> rows: 1

SELECT * EXCEPT (A) FROM TEST1;
> B C
> - -
> 2 3
> rows: 1

SELECT * EXCEPT (TEST1.A) FROM TEST1;
> B C
> - -
> 2 3
> rows: 1

SELECT * EXCEPT (PUBLIC.TEST1.A) FROM TEST1;
> B C
> - -
> 2 3
> rows: 1

SELECT * EXCEPT (SCRIPT.PUBLIC.TEST1.A) FROM TEST1;
> B C
> - -
> 2 3
> rows: 1

SELECT * EXCEPT (Z) FROM TEST1;
> exception COLUMN_NOT_FOUND_1

SELECT * EXCEPT (B, TEST1.B) FROM TEST1;
> exception DUPLICATE_COLUMN_NAME_1

SELECT * EXCEPT (A) FROM TEST1, TEST2;
> exception AMBIGUOUS_COLUMN_NAME_1

SELECT * EXCEPT (TEST1.A, B, TEST2.D) FROM TEST1, TEST2;
> C A
> - -
> 3 4
> rows: 1

SELECT TEST1.*, TEST2.* FROM TEST1, TEST2;
> A B C A D
> - - - - -
> 1 2 3 4 5
> rows: 1

SELECT TEST1.* EXCEPT (A), TEST2.* EXCEPT (A) FROM TEST1, TEST2;
> B C D
> - - -
> 2 3 5
> rows: 1

SELECT TEST1.* EXCEPT (A), TEST2.* EXCEPT (D) FROM TEST1, TEST2;
> B C A
> - - -
> 2 3 4
> rows: 1

SELECT * EXCEPT (T1.A, T2.D) FROM TEST1 T1, TEST2 T2;
> B C A
> - - -
> 2 3 4
> rows: 1

DROP TABLE TEST1, TEST2;
> ok

CREATE TABLE TEST(ID INT PRIMARY KEY, VALUE INT NOT NULL);
> ok

INSERT INTO TEST VALUES (1, 1), (2, 1), (3, 2);
> update count: 3

SELECT ID, VALUE FROM TEST FOR UPDATE;
> ID VALUE
> -- -----
> 1  1
> 2  1
> 3  2
> rows: 3

-- Check that NULL row is returned from SELECT FOR UPDATE
CREATE TABLE T1(A INT PRIMARY KEY) AS VALUES 1, 2;
> ok

CREATE TABLE T2(B INT PRIMARY KEY) AS VALUES 1;
> ok

SELECT * FROM T1 LEFT JOIN T2 ON A = B FOR UPDATE;
> A B
> - ----
> 1 1
> 2 null
> rows: 2

DROP TABLE T1, T2;
> ok

SELECT DISTINCT VALUE FROM TEST FOR UPDATE;
> exception FOR_UPDATE_IS_NOT_ALLOWED_IN_DISTINCT_OR_GROUPED_SELECT

SELECT DISTINCT ON(VALUE) ID, VALUE FROM TEST FOR UPDATE;
> exception FOR_UPDATE_IS_NOT_ALLOWED_IN_DISTINCT_OR_GROUPED_SELECT

SELECT SUM(VALUE) FROM TEST FOR UPDATE;
> exception FOR_UPDATE_IS_NOT_ALLOWED_IN_DISTINCT_OR_GROUPED_SELECT

SELECT ID FROM TEST GROUP BY VALUE FOR UPDATE;
> exception FOR_UPDATE_IS_NOT_ALLOWED_IN_DISTINCT_OR_GROUPED_SELECT

SELECT 1 FROM TEST HAVING TRUE FOR UPDATE;
> exception FOR_UPDATE_IS_NOT_ALLOWED_IN_DISTINCT_OR_GROUPED_SELECT

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT PRIMARY KEY, V INT) AS SELECT X, X + 1 FROM SYSTEM_RANGE(1, 3);
> ok

SELECT ID FROM TEST WHERE ID != ALL (SELECT ID FROM TEST WHERE ID IN(1, 3));
> ID
> --
> 2
> rows: 1

SELECT (1, 3) > ANY (SELECT ID, V FROM TEST);
>> TRUE

SELECT (1, 2) > ANY (SELECT ID, V FROM TEST);
>> FALSE

SELECT (2, 3) = ANY (SELECT ID, V FROM TEST);
>> TRUE

SELECT (3, 4) > ALL (SELECT ID, V FROM TEST);
>> FALSE

DROP TABLE TEST;
> ok

SELECT 1 = ALL (SELECT * FROM VALUES (NULL), (1), (2), (NULL) ORDER BY 1);
>> FALSE

CREATE TABLE TEST(G INT, V INT);
> ok

INSERT INTO TEST VALUES (10, 1), (11, 2), (20, 4);
> update count: 3

SELECT G / 10 G1, G / 10 G2, SUM(T.V) S FROM TEST T GROUP BY G / 10, G / 10;
> G1 G2 S
> -- -- -
> 1  1  3
> 2  2  4
> rows: 2

SELECT G / 10 G1, G / 10 G2, SUM(T.V) S FROM TEST T GROUP BY G2;
> G1 G2 S
> -- -- -
> 1  1  3
> 2  2  4
> rows: 2

DROP TABLE TEST;
> ok

@reconnect off

CALL RAND(0);
>> 0.730967787376657

SELECT RAND(), RAND() + 1, RAND() + 1, RAND() GROUP BY RAND() + 1;
> RAND()             RAND() + 1         RAND() + 1         RAND()
> ------------------ ------------------ ------------------ ------------------
> 0.6374174253501083 1.2405364156714858 1.2405364156714858 0.5504370051176339
> rows: 1

SELECT RAND() A, RAND() + 1 B, RAND() + 1 C, RAND() D, RAND() + 2 E, RAND() + 3 F GROUP BY B, C, E, F;
> A                  B                  C                  D                  E                  F
> ------------------ ------------------ ------------------ ------------------ ------------------ ------------------
> 0.8791825178724801 1.3332183994766498 1.3332183994766498 0.9412491794821144 2.3851891847407183 3.9848415401998087
> rows: 1

@reconnect on

CREATE TABLE TEST (A INT, B INT, C INT);
> ok

INSERT INTO TEST VALUES (11, 12, 13), (21, 22, 23), (31, 32, 33);
> update count: 3

SELECT * FROM TEST WHERE (A, B) IN (VALUES (11, 12), (21, 22), (41, 42));
> A  B  C
> -- -- --
> 11 12 13
> 21 22 23
> rows: 2

SELECT * FROM TEST WHERE (A, B) = (VALUES (11, 12));
> A  B  C
> -- -- --
> 11 12 13
> rows: 1

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A BIGINT, B INT) AS VALUES (1::BIGINT, 2);
> ok

SELECT * FROM TEST WHERE (A, B) IN ((1, 2), (3, 4));
> A B
> - -
> 1 2
> rows: 1

UPDATE TEST SET A = 1000000000000;
> update count: 1

SELECT * FROM TEST WHERE (A, B) IN ((1, 2), (3, 4));
> A B
> - -
> rows: 0

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A BIGINT, B INT) AS VALUES (1, 2);
> ok

SELECT * FROM TEST WHERE (A, B) IN ((1::BIGINT, 2), (3, 4));
> A B
> - -
> 1 2
> rows: 1

SELECT * FROM TEST WHERE (A, B) IN ((1000000000000, 2), (3, 4));
> A B
> - -
> rows: 0

DROP TABLE TEST;
> ok

CREATE TABLE TEST(I) AS VALUES 1, 2, 3;
> ok

SELECT COUNT(*) C FROM TEST HAVING C < 1;
> C
> -
> rows: 0

SELECT COUNT(*) C FROM TEST QUALIFY C < 1;
> C
> -
> rows: 0

DROP TABLE TEST;
> ok

SELECT A, ROW_NUMBER() OVER (ORDER BY B) R
FROM (VALUES (1, 2), (2, 1), (3, 3)) T(A, B);
> A R
> - -
> 1 2
> 2 1
> 3 3
> rows: 3

SELECT X, A, ROW_NUMBER() OVER (ORDER BY B) R
FROM (SELECT 1 X), (VALUES (1, 2), (2, 1), (3, 3)) T(A, B);
> X A R
> - - -
> 1 1 2
> 1 2 1
> 1 3 3
> rows: 3

SELECT A, SUM(S) OVER (ORDER BY S) FROM
    (SELECT A, SUM(B) FROM (VALUES (1, 2), (1, 3), (3, 5), (3, 10)) V(A, B) GROUP BY A) S(A, S);
> A SUM(S) OVER (ORDER BY S)
> - ------------------------
> 1 5
> 3 20
> rows: 2

SELECT A, SUM(A) OVER W SUM FROM (VALUES 1, 2) T(A) WINDOW W AS (ORDER BY A);
> A SUM
> - ---
> 1 1
> 2 3
> rows: 2

SELECT A, B, C FROM (SELECT A, B, C FROM (VALUES (1, 2, 3)) V(A, B, C));
> A B C
> - - -
> 1 2 3
> rows: 1

SELECT * FROM (SELECT * FROM (VALUES (1, 2, 3)) V(A, B, C));
> A B C
> - - -
> 1 2 3
> rows: 1

SELECT * FROM
    (SELECT X * X, Y FROM
        (SELECT A + 5, B FROM
            (VALUES (1, 2)) V(A, B)
        ) T(X, Y)
    );
> X * X Y
> ----- -
> 36    2
> rows: 1

CREATE TABLE TEST("_ROWID_" INT) AS VALUES 2;
> ok

SELECT _ROWID_ S1, TEST._ROWID_ S2, PUBLIC.TEST._ROWID_ S3, SCRIPT.PUBLIC.TEST._ROWID_ S4,
    "_ROWID_" U1, TEST."_ROWID_" U2, PUBLIC.TEST."_ROWID_" U3, SCRIPT.PUBLIC.TEST."_ROWID_" U4
    FROM TEST;
> S1 S2 S3 S4 U1 U2 U3 U4
> -- -- -- -- -- -- -- --
> 1  1  1  1  2  2  2  2
> rows: 1

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID BIGINT PRIMARY KEY);
> ok

SELECT X.ID FROM TEST X JOIN TEST Y ON Y.ID IN (SELECT 1);
> ID
> --
> rows: 0

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT, B INT) AS VALUES (1, 10), (2, 20), (4, 40);
> ok

SELECT T1.A, T2.ARR FROM TEST T1 JOIN (
    SELECT A, ARRAY_AGG(B) OVER (ORDER BY B ROWS BETWEEN 1 FOLLOWING AND 2 FOLLOWING) ARR FROM TEST
) T2 ON T1.A = T2.A;
> A ARR
> - --------
> 1 [20, 40]
> 2 [40]
> 4 null
> rows: 3

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT PRIMARY KEY, V INT UNIQUE);
> ok

EXPLAIN SELECT * FROM TEST ORDER BY ID FOR UPDATE;
>> SELECT "PUBLIC"."TEST"."ID", "PUBLIC"."TEST"."V" FROM "PUBLIC"."TEST" /* PUBLIC.PRIMARY_KEY_2 */ ORDER BY 1 FOR UPDATE /* index sorted */

EXPLAIN SELECT * FROM TEST ORDER BY V;
>> SELECT "PUBLIC"."TEST"."ID", "PUBLIC"."TEST"."V" FROM "PUBLIC"."TEST" /* PUBLIC.CONSTRAINT_INDEX_2 */ ORDER BY 2 /* index sorted */

EXPLAIN SELECT * FROM TEST ORDER BY V FOR UPDATE;
#+mvStore#>> SELECT "PUBLIC"."TEST"."ID", "PUBLIC"."TEST"."V" FROM "PUBLIC"."TEST" /* PUBLIC.CONSTRAINT_INDEX_2 */ ORDER BY 2 FOR UPDATE
#-mvStore#>> SELECT "PUBLIC"."TEST"."ID", "PUBLIC"."TEST"."V" FROM "PUBLIC"."TEST" /* PUBLIC.CONSTRAINT_INDEX_2 */ ORDER BY 2 FOR UPDATE /* index sorted */

DROP TABLE TEST;
> ok

-- The next tests should be at the of this file

SET MAX_MEMORY_ROWS = 1;
> ok

CREATE TABLE TEST(I INT) AS SELECT * FROM SYSTEM_RANGE(1, 10);
> ok

SELECT COUNT(*) FROM (SELECT I, SUM(I) S, COUNT(I) C FROM TEST GROUP BY I HAVING S + C <= 9 ORDER BY I);
>> 8

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT, B INT);
> ok

EXPLAIN SELECT * FROM TEST WHERE A = 1 AND B = 1 OR A = 2 AND B = 2;
>> SELECT "PUBLIC"."TEST"."A", "PUBLIC"."TEST"."B" FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ WHERE (("A" = 1) AND ("B" = 1)) OR (("A" = 2) AND ("B" = 2))

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT, B INT) AS VALUES (1, 2), (1, 3), (5, 5);
> ok

SELECT (SELECT A, B FROM TEST ORDER BY A + B FETCH FIRST ROW ONLY);
>> ROW (1, 2)

SELECT * FROM TEST UNION ALL SELECT * FROM TEST OFFSET 2 ROWS;
> A B
> - -
> 1 2
> 1 3
> 5 5
> 5 5
> rows: 4

SELECT (1, 2) IN (SELECT * FROM TEST UNION ALL SELECT * FROM TEST OFFSET 2 ROWS);
>> TRUE

SELECT * FROM TEST UNION ALL SELECT * FROM TEST ORDER BY A DESC, B DESC OFFSET 2 ROWS;
> A B
> - -
> 1 3
> 1 3
> 1 2
> 1 2
> rows (ordered): 4

SELECT (1, 2) IN (SELECT * FROM TEST UNION ALL SELECT * FROM TEST ORDER BY A DESC, B DESC OFFSET 2 ROWS);
>> TRUE

SELECT (1, 2) IN (SELECT * FROM TEST UNION ALL SELECT * FROM TEST ORDER BY A DESC, B DESC OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY);
>> FALSE

DROP TABLE TEST;
> ok

CREATE TABLE TEST(ID INT, NAME VARCHAR, DATA VARCHAR);
> ok

-- This ORDER BY condition is currently forbidden
SELECT DISTINCT DATA FROM TEST ORDER BY (CASE WHEN EXISTS(SELECT * FROM TEST T WHERE T.NAME = 'A') THEN 1 ELSE 2 END);
> exception ORDER_BY_NOT_IN_RESULT

SELECT DISTINCT DATA FROM TEST X ORDER BY (CASE WHEN EXISTS(SELECT * FROM TEST T WHERE T.ID = X.ID + 1) THEN 1 ELSE 2 END);
> exception ORDER_BY_NOT_IN_RESULT

DROP TABLE TEST;
> ok

-- Additional GROUP BY tests

CREATE TABLE TEST(A INT, B INT, C INT) AS (VALUES
    (NULL, NULL, NULL), (NULL, NULL, 1), (NULL, NULL, 2),
    (NULL, 1, NULL), (NULL, 1, 1), (NULL, 1, 2),
    (NULL, 2, NULL), (NULL, 2, 1), (NULL, 2, 2),
    (1, NULL, NULL), (1, NULL, 1), (1, NULL, 2),
    (1, 1, NULL), (1, 1, 1), (1, 1, 2),
    (1, 2, NULL), (1, 2, 1), (1, 2, 2),
    (2, NULL, NULL), (2, NULL, 1), (2, NULL, 2),
    (2, 1, NULL), (2, 1, 1), (2, 1, 2),
    (2, 2, NULL), (2, 2, 1), (2, 2, 2));
> ok

SELECT SUM(A), B, C FROM TEST GROUP BY B, C;
> SUM(A) B    C
> ------ ---- ----
> 3      1    1
> 3      1    2
> 3      1    null
> 3      2    1
> 3      2    2
> 3      2    null
> 3      null 1
> 3      null 2
> 3      null null
> rows: 9

EXPLAIN SELECT SUM(A), B, C FROM TEST GROUP BY B, C;
>> SELECT SUM("A"), "B", "C" FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ GROUP BY "B", "C"

SELECT SUM(A), B, C FROM TEST GROUP BY (B), C, ();
> SUM(A) B    C
> ------ ---- ----
> 3      1    1
> 3      1    2
> 3      1    null
> 3      2    1
> 3      2    2
> 3      2    null
> 3      null 1
> 3      null 2
> 3      null null
> rows: 9

EXPLAIN SELECT SUM(A), B, C FROM TEST GROUP BY (B), C, ();
>> SELECT SUM("A"), "B", "C" FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ GROUP BY "B", "C"

SELECT SUM(A), B, C FROM TEST GROUP BY (B, C);
> SUM(A) B    C
> ------ ---- ----
> 3      1    1
> 3      1    2
> 3      1    null
> 3      2    1
> 3      2    2
> 3      2    null
> 3      null 1
> 3      null 2
> 3      null null
> rows: 9

EXPLAIN SELECT SUM(A), B, C FROM TEST GROUP BY (B, C);
>> SELECT SUM("A"), "B", "C" FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ GROUP BY "B", "C"

SELECT COUNT(*) FROM TEST;
>> 27

EXPLAIN SELECT COUNT(*) FROM TEST;
>> SELECT COUNT(*) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ /* direct lookup */

SELECT COUNT(*) FROM TEST GROUP BY ();
>> 27

EXPLAIN SELECT COUNT(*) FROM TEST GROUP BY ();
>> SELECT COUNT(*) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ /* direct lookup */

SELECT COUNT(*) FROM TEST WHERE FALSE;
>> 0

EXPLAIN SELECT COUNT(*) FROM TEST WHERE FALSE;
>> SELECT COUNT(*) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan: FALSE */ WHERE FALSE

SELECT COUNT(*) FROM TEST WHERE FALSE GROUP BY ();
>> 0

EXPLAIN SELECT COUNT(*) FROM TEST WHERE FALSE GROUP BY ();
>> SELECT COUNT(*) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan: FALSE */ WHERE FALSE

SELECT COUNT(*) FROM TEST WHERE FALSE GROUP BY (), ();
>> 0

EXPLAIN SELECT COUNT(*) FROM TEST WHERE FALSE GROUP BY (), ();
>> SELECT COUNT(*) FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan: FALSE */ WHERE FALSE

SELECT 1 FROM TEST GROUP BY ();
>> 1

EXPLAIN SELECT 1 FROM TEST GROUP BY ();
>> SELECT 1 FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ GROUP BY () /* direct lookup */

EXPLAIN SELECT FALSE AND MAX(A) > 0 FROM TEST;
>> SELECT FALSE FROM "PUBLIC"."TEST" /* PUBLIC.TEST.tableScan */ GROUP BY () /* direct lookup */

DROP TABLE TEST;
> ok

CREATE TABLE TEST(A INT PRIMARY KEY) AS (VALUES 1, 2, 3);
> ok

SELECT A AS A1, A AS A2 FROM TEST GROUP BY A;
> A1 A2
> -- --
> 1  1
> 2  2
> 3  3
> rows: 3

DROP TABLE TEST;
> ok

-- Tests for SELECT without columns

EXPLAIN SELECT *;
>> SELECT

SELECT;
>
>
>
> rows: 1

SELECT FROM DUAL;
>
>
>
> rows: 1

SELECT * FROM DUAL JOIN (SELECT * FROM DUAL) ON 1 = 1;
>
>
>
> rows: 1

EXPLAIN SELECT * FROM DUAL JOIN (SELECT * FROM DUAL) ON 1 = 1;
>> SELECT FROM DUAL /* dual index */ INNER JOIN ( SELECT ) "_51" /* SELECT */ ON 1=1 WHERE TRUE

SELECT WHERE FALSE;
>
>
> rows: 0

SELECT GROUP BY ();
>
>
>
> rows: 1

SELECT HAVING FALSE;
>
>
> rows: 0

SELECT QUALIFY FALSE;
>
>
> rows: 0

SELECT ORDER BY (SELECT 1);
>
>
>
> rows (ordered): 1

SELECT OFFSET 0 ROWS;
>
>
>
> rows: 1

SELECT FETCH FIRST 0 ROWS ONLY;
>
>
> rows: 0
