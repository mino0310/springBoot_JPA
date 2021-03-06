-- Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
-- and the EPL 1.0 (https://h2database.com/html/license.html).
-- Initial Developer: H2 Group
--

CREATE TABLE TEST(U UUID) AS (SELECT * FROM VALUES
    ('00000000-0000-0000-0000-000000000000'), ('00000000-0000-0000-9000-000000000000'),
    ('11111111-1111-1111-1111-111111111111'), ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'));
> ok

SELECT U FROM TEST ORDER BY U;
> U
> ------------------------------------
> aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
> 00000000-0000-0000-9000-000000000000
> 00000000-0000-0000-0000-000000000000
> 11111111-1111-1111-1111-111111111111
> rows (ordered): 4

SET UUID_COLLATION UNSIGNED;
> exception COLLATION_CHANGE_WITH_DATA_TABLE_1

DROP TABLE TEST;
> ok

SET UUID_COLLATION UNSIGNED;
> ok

CREATE TABLE TEST(U UUID) AS (SELECT * FROM VALUES
    ('00000000-0000-0000-0000-000000000000'), ('00000000-0000-0000-9000-000000000000'),
    ('11111111-1111-1111-1111-111111111111'), ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'));
> ok

SELECT U FROM TEST ORDER BY U;
> U
> ------------------------------------
> 00000000-0000-0000-0000-000000000000
> 00000000-0000-0000-9000-000000000000
> 11111111-1111-1111-1111-111111111111
> aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
> rows (ordered): 4

DROP TABLE TEST;
> ok

SET UUID_COLLATION SIGNED;
> ok
