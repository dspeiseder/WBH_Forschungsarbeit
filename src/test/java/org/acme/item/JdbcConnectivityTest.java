package org.acme.item;

import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class JdbcConnectivityTest {

    private static final String JDBC_URL = "jdbc:postgresql://localhost:5432/itemsdb";
    private static final String USER = "quarkus";
    private static final String PASSWORD = "quarkus";

    @Test
    void shouldFetchSeededItemOverJdbc() throws SQLException {
        Assumptions.assumeTrue(databaseAvailable(), "Requires running Postgres from docker-compose");

        try (Connection connection = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
             PreparedStatement statement = connection.prepareStatement("SELECT name FROM items WHERE id = 1")) {
            try (ResultSet resultSet = statement.executeQuery()) {
                assertTrue(resultSet.next(), "Item with id 1 should exist");
                assertEquals("Sample Item 1", resultSet.getString("name"));
            }
        }
    }

    private boolean databaseAvailable() {
        try (Connection ignored = DriverManager.getConnection(JDBC_URL, USER, PASSWORD)) {
            return true;
        } catch (SQLException e) {
            return false;
        }
    }
}
