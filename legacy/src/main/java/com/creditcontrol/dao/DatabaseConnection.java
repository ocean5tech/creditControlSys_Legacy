package com.creditcontrol.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Database Connection Manager for Legacy Credit Control System
 * Provides PostgreSQL database connections with connection pooling simulation
 */
public class DatabaseConnection {
    
    private static final String DB_DRIVER = "org.postgresql.Driver";
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/creditcontrol";
    private static final String DB_USER = "creditapp";
    private static final String DB_PASSWORD = "secure123";
    
    private static DatabaseConnection instance;
    private static Connection connection;
    
    // Private constructor for singleton pattern
    private DatabaseConnection() {
        try {
            Class.forName(DB_DRIVER);
            initializeConnection();
        } catch (ClassNotFoundException e) {
            System.err.println("PostgreSQL JDBC Driver not found: " + e.getMessage());
            throw new RuntimeException("Database driver initialization failed", e);
        }
    }
    
    /**
     * Get singleton instance of DatabaseConnection
     */
    public static synchronized DatabaseConnection getInstance() {
        if (instance == null) {
            instance = new DatabaseConnection();
        }
        return instance;
    }
    
    /**
     * Initialize database connection with properties
     */
    private void initializeConnection() {
        try {
            Properties props = new Properties();
            props.setProperty("user", DB_USER);
            props.setProperty("password", DB_PASSWORD);
            props.setProperty("ssl", "false");
            props.setProperty("autoReconnect", "true");
            
            connection = DriverManager.getConnection(DB_URL, props);
            connection.setAutoCommit(true); // Legacy mode - auto commit
            
            System.out.println("Database connection established successfully");
            System.out.println("Connected to: " + connection.getMetaData().getURL());
            System.out.println("Database: " + connection.getMetaData().getDatabaseProductName() + 
                             " " + connection.getMetaData().getDatabaseProductVersion());
            
        } catch (SQLException e) {
            System.err.println("Failed to establish database connection: " + e.getMessage());
            throw new RuntimeException("Database connection failed", e);
        }
    }
    
    /**
     * Get database connection
     * @return active database connection
     */
    public Connection getConnection() {
        try {
            // Check if connection is still valid
            if (connection == null || connection.isClosed() || !connection.isValid(5)) {
                System.out.println("Reconnecting to database...");
                initializeConnection();
            }
        } catch (SQLException e) {
            System.err.println("Connection validation failed: " + e.getMessage());
            initializeConnection();
        }
        
        return connection;
    }
    
    /**
     * Test database connectivity
     * @return true if connection is successful
     */
    public boolean testConnection() {
        try {
            Connection conn = getConnection();
            java.sql.Statement stmt = conn.createStatement();
            java.sql.ResultSet rs = stmt.executeQuery("SELECT 1");
            
            boolean hasResult = rs.next();
            rs.close();
            stmt.close();
            
            System.out.println("Database connectivity test: " + (hasResult ? "SUCCESS" : "FAILED"));
            return hasResult;
            
        } catch (SQLException e) {
            System.err.println("Database connectivity test failed: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get database connection pool status (simulated)
     */
    public String getConnectionPoolStatus() {
        try {
            boolean isValid = connection != null && !connection.isClosed() && connection.isValid(2);
            return "Connection Pool Status: " + (isValid ? "HEALTHY" : "DISCONNECTED") +
                   " | Active Connections: 1" +
                   " | Database: creditcontrol@localhost:5432";
        } catch (SQLException e) {
            return "Connection Pool Status: ERROR - " + e.getMessage();
        }
    }
    
    /**
     * Close database connection
     */
    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("Database connection closed");
            }
        } catch (SQLException e) {
            System.err.println("Error closing database connection: " + e.getMessage());
        }
    }
    
    /**
     * Execute database health check
     */
    public boolean performHealthCheck() {
        try {
            Connection conn = getConnection();
            java.sql.Statement stmt = conn.createStatement();
            
            // Check system tables
            java.sql.ResultSet rs = stmt.executeQuery(
                "SELECT COUNT(*) as table_count FROM information_schema.tables " +
                "WHERE table_schema = 'public'"
            );
            
            rs.next();
            int tableCount = rs.getInt("table_count");
            
            rs.close();
            stmt.close();
            
            System.out.println("Health Check: Found " + tableCount + " tables in database");
            return tableCount >= 8; // We expect at least 8 tables
            
        } catch (SQLException e) {
            System.err.println("Database health check failed: " + e.getMessage());
            return false;
        }
    }
}