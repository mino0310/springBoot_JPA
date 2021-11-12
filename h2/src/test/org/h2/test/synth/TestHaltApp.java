/*
 * Copyright 2004-2019 H2 Group. Multiple-Licensed under the MPL 2.0,
 * and the EPL 1.0 (https://h2database.com/html/license.html).
 * Initial Developer: H2 Group
 */
package org.h2.test.synth;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import org.h2.test.utils.SelfDestructor;

/**
 * The application code for the {@link TestHalt} application.
 */
public class TestHaltApp extends TestHalt {

    private int rowCount;

    /**
     * This method is called when executing this application from the command
     * line.
     *
     * @param args the command line parameters
     */
    public static void main(String... args) throws Exception {
        SelfDestructor.startCountdown(60);
        TestHaltApp app = new TestHaltApp();
        if (args.length == 0) {
            app.controllerTest();
        } else {
            app.operations = Integer.parseInt(args[0]);
            app.flags = Integer.parseInt(args[1]);
            app.value = Integer.parseInt(args[2]);
            app.processRunRandom();
        }
    }

    @Override
    protected void execute(Statement stat, String sql) throws SQLException {
        traceOperation("execute: " + sql);
        super.execute(stat, sql);
    }

    /**
     * Initialize the database.
     */
    @Override
    protected void controllerInit() throws SQLException {
        Statement stat = conn.createStatement();
        // stat.execute("CREATE TABLE TEST(ID IDENTITY, NAME VARCHAR(255))");
        for (int i = 0; i < 20; i++) {
            execute(stat, "DROP TABLE IF EXISTS TEST" + i);
            execute(stat, "CREATE TABLE TEST" + i +
                    "(ID INT PRIMARY KEY, NAME VARCHAR(255))");
        }
        for (int i = 0; i < 20; i += 2) {
            execute(stat, "DROP TABLE TEST" + i);
        }
        execute(stat, "DROP TABLE IF EXISTS TEST");
        execute(stat, "CREATE TABLE TEST" +
                "(ID BIGINT GENERATED BY DEFAULT AS IDENTITY, " +
                "NAME VARCHAR(255), DATA CLOB)");
    }

    /**
     * Wait after the application has been started.
     */
    @Override
    protected void controllerWaitAfterAppStart() throws Exception {
        int sleep = 10 + random.nextInt(300);
        if ((flags & FLAG_NO_DELAY) == 0) {
            sleep += 1000;
        }
        Thread.sleep(sleep);
    }

    /**
     * This method is called after a simulated crash. The method should check if
     * the data is transactionally consistent and throw an exception if not.
     *
     * @throws SQLException  if the data is not consistent.
     */
    @Override
    protected void controllerCheckAfterCrash() throws SQLException {
        Statement stat = conn.createStatement();
        ResultSet rs = stat.executeQuery("SELECT COUNT(*) FROM TEST");
        rs.next();
        int count = rs.getInt(1);
        System.out.println("count: " + count);
        if (count % 2 != 0) {
            traceOperation("row count: " + count);
            throw new SQLException("Unexpected odd row count: " + count);
        }
    }

    /**
     * Initialize the application.
     */
    @Override
    protected void processAppStart() throws SQLException {
        Statement stat = conn.createStatement();
        if ((flags & FLAG_NO_DELAY) != 0) {
            execute(stat, "SET WRITE_DELAY 0");
            execute(stat, "SET MAX_LOG_SIZE 1");
        }
        ResultSet rs = stat.executeQuery("SELECT COUNT(*) FROM TEST");
        rs.next();
        rowCount = rs.getInt(1);
        traceOperation("rows: " + rowCount, null);
    }

    /**
     * Run the application code.
     */
    @Override
    protected void processAppRun() throws SQLException {
        conn.setAutoCommit(false);
        traceOperation("setAutoCommit false");
        int rows = 10000 + value;
        PreparedStatement prepInsert = conn.prepareStatement(
                "INSERT INTO TEST(NAME, DATA) VALUES('Hello World', ?)");
        PreparedStatement prepUpdate = conn.prepareStatement(
                "UPDATE TEST SET NAME = 'Hallo Welt', DATA = ? WHERE ID = ?");
        for (int i = 0; i < rows; i++) {
            Statement stat = conn.createStatement();
            if ((operations & OP_INSERT) != 0) {
                if ((flags & FLAG_LOBS) != 0) {
                    String s = getRandomString(random.nextInt(200));
                    prepInsert.setString(1, s);
                    traceOperation("insert " + s);
                    prepInsert.execute();
                } else {
                    execute(stat, "INSERT INTO TEST(NAME) " +
                            "VALUES('Hello World')");
                }
                ResultSet rs = stat.getGeneratedKeys();
                rs.next();
                int key = rs.getInt(1);
                traceOperation("inserted key: " + key);
                rowCount++;
            }
            if ((operations & OP_UPDATE) != 0) {
                if ((flags & FLAG_LOBS) != 0) {
                    String s = getRandomString(random.nextInt(200));
                    prepUpdate.setString(1, s);
                    int x = random.nextInt(rowCount + 1);
                    prepUpdate.setInt(2, x);
                    traceOperation("update " + s + " " + x);
                    prepUpdate.execute();
                } else {
                    int x = random.nextInt(rowCount + 1);
                    execute(stat, "UPDATE TEST SET VALUE = 'Hallo Welt' " +
                            "WHERE ID = " + x);
                }
            }
            if ((operations & OP_DELETE) != 0) {
                int x = random.nextInt(rowCount + 1);
                traceOperation("deleting " + x);
                int uc = stat.executeUpdate("DELETE FROM TEST " +
                        "WHERE ID = " + x);
                traceOperation("updated: " + uc);
                rowCount -= uc;
            }
            traceOperation("rowCount " + rowCount);
            traceOperation("rows now: " + rowCount, null);
            if (rowCount % 2 == 0) {
                traceOperation("commit " + rowCount);
                conn.commit();
                traceOperation("committed: " + rowCount, null);
            }
            if ((flags & FLAG_NO_DELAY) != 0) {
                if (random.nextInt(10) == 0 && (rowCount % 2 == 0)) {
                    execute(stat, "CHECKPOINT");
                }
            }
        }
        traceOperation("rollback");
        conn.rollback();
    }

}
