package com.optum.cmc;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.SQLException;

public class DBConnectionTest {

    public static void main(String[] args) {
        String url = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String password = System.getenv("DB_PASSWORD");
        String query = System.getenv("DB_TEST_QUERY");

        if (url == null || user == null || password == null || query == null) {
            System.out.println("One or more required environment variables (DB_URL, DB_USER, DB_PASSWORD) are missing.");
            return;
        }

        Connection connection = null;
        Statement statement = null;
        ResultSet resultSet = null;

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            connection = DriverManager.getConnection(url, user, password);
            System.out.println("Connected to the database.");

            statement = connection.createStatement();
            resultSet = statement.executeQuery(query);
            System.out.println("Executed Query.");

            while (resultSet.next()) {
                System.out.println(resultSet.getString(1) + " | " + resultSet.getString(2));
            }
            System.out.println("Fetched Result.");
        } catch (ClassNotFoundException e) {
            System.out.println("SQL Server JDBC Driver not found.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.out.println("Database error.");
            e.printStackTrace();
        } finally {
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    System.out.println("Error closing resultset");
                }
            }
            if (statement != null) {
                try {
                    statement.close();
                } catch (SQLException e) {
                    System.out.println("Error closing resultset");
                }
            }
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    System.out.println("Error closing resultset");
                }
            }
        }
    }
}
