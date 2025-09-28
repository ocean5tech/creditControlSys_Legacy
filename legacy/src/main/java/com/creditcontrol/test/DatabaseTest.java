package com.creditcontrol.test;

import com.creditcontrol.dao.DatabaseConnection;
import com.creditcontrol.dao.CustomerDAO;
import com.creditcontrol.model.Customer;
import java.util.List;

/**
 * Database connectivity test class
 */
public class DatabaseTest {
    
    public static void main(String[] args) {
        System.out.println("=== Database Connectivity Test ===");
        System.out.println("Date: " + new java.util.Date());
        
        try {
            // Test database connection
            System.out.println("\n1. Testing database connection...");
            DatabaseConnection dbConn = DatabaseConnection.getInstance();
            
            boolean connected = dbConn.testConnection();
            System.out.println("Database connection test: " + (connected ? "SUCCESS" : "FAILED"));
            
            if (connected) {
                boolean healthy = dbConn.performHealthCheck();
                System.out.println("Database health check: " + (healthy ? "PASSED" : "FAILED"));
                
                System.out.println("Connection pool status: " + dbConn.getConnectionPoolStatus());
            }
            
            // Test Customer DAO
            System.out.println("\n2. Testing Customer DAO...");
            CustomerDAO customerDAO = new CustomerDAO();
            
            int customerCount = customerDAO.getCustomerCount();
            System.out.println("Total active customers: " + customerCount);
            
            if (customerCount > 0) {
                System.out.println("\n3. Testing customer queries...");
                List<Customer> customers = customerDAO.getAllActiveCustomers();
                System.out.println("Retrieved " + customers.size() + " customers:");
                
                for (Customer customer : customers) {
                    System.out.println("  - " + customer.getDisplayName() + 
                                     " | Industry: " + customer.getIndustry());
                }
                
                // Test search functionality
                System.out.println("\n4. Testing search functionality...");
                List<Customer> searchResults = customerDAO.searchByCompanyName("ABC");
                System.out.println("Search for 'ABC' returned " + searchResults.size() + " results");
                
                for (Customer customer : searchResults) {
                    System.out.println("  - Found: " + customer.getDisplayName());
                }
            }
            
            System.out.println("\n=== Test Completed Successfully ===");
            
        } catch (Exception e) {
            System.err.println("Database test failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}