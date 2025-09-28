package com.creditcontrol.dao;

import com.creditcontrol.model.Customer;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Customer operations
 * Handles all database operations related to customers
 */
public class CustomerDAO {
    
    private DatabaseConnection dbConnection;
    
    public CustomerDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }
    
    /**
     * Create a new customer record
     * @param customer Customer object to insert
     * @return generated customer ID, or -1 if failed
     */
    public int createCustomer(Customer customer) {
        String sql = "INSERT INTO customers (customer_code, company_name, contact_person, " +
                    "phone, email, address, industry, registration_number) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING customer_id";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, customer.getCustomerCode());
            pstmt.setString(2, customer.getCompanyName());
            pstmt.setString(3, customer.getContactPerson());
            pstmt.setString(4, customer.getPhone());
            pstmt.setString(5, customer.getEmail());
            pstmt.setString(6, customer.getAddress());
            pstmt.setString(7, customer.getIndustry());
            pstmt.setString(8, customer.getRegistrationNumber());
            
            ResultSet rs = pstmt.executeQuery();
            
            int customerId = -1;
            if (rs.next()) {
                customerId = rs.getInt("customer_id");
                customer.setCustomerId(customerId);
                System.out.println("Customer created successfully with ID: " + customerId);
            }
            
            rs.close();
            pstmt.close();
            
            return customerId;
            
        } catch (SQLException e) {
            System.err.println("Error creating customer: " + e.getMessage());
            return -1;
        }
    }
    
    /**
     * Find customer by customer code
     * @param customerCode unique customer code
     * @return Customer object or null if not found
     */
    public Customer findByCustomerCode(String customerCode) {
        String sql = "SELECT * FROM customers WHERE customer_code = ? AND status = 'ACTIVE'";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, customerCode);
            
            ResultSet rs = pstmt.executeQuery();
            
            Customer customer = null;
            if (rs.next()) {
                customer = mapResultSetToCustomer(rs);
            }
            
            rs.close();
            pstmt.close();
            
            return customer;
            
        } catch (SQLException e) {
            System.err.println("Error finding customer by code: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Find customer by ID
     * @param customerId customer primary key
     * @return Customer object or null if not found
     */
    public Customer findById(int customerId) {
        String sql = "SELECT * FROM customers WHERE customer_id = ?";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);
            
            ResultSet rs = pstmt.executeQuery();
            
            Customer customer = null;
            if (rs.next()) {
                customer = mapResultSetToCustomer(rs);
            }
            
            rs.close();
            pstmt.close();
            
            return customer;
            
        } catch (SQLException e) {
            System.err.println("Error finding customer by ID: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Search customers by company name (partial match)
     * @param companyName company name to search for
     * @return List of matching customers
     */
    public List<Customer> searchByCompanyName(String companyName) {
        String sql = "SELECT * FROM customers WHERE company_name ILIKE ? AND status = 'ACTIVE' " +
                    "ORDER BY company_name LIMIT 50";
        
        List<Customer> customers = new ArrayList<>();
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + companyName + "%");
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }
            
            rs.close();
            pstmt.close();
            
            System.out.println("Found " + customers.size() + " customers matching: " + companyName);
            
        } catch (SQLException e) {
            System.err.println("Error searching customers: " + e.getMessage());
        }
        
        return customers;
    }
    
    /**
     * Get all active customers
     * @return List of all active customers
     */
    public List<Customer> getAllActiveCustomers() {
        String sql = "SELECT * FROM customers WHERE status = 'ACTIVE' ORDER BY company_name";
        
        List<Customer> customers = new ArrayList<>();
        
        try {
            Connection conn = dbConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            
            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }
            
            rs.close();
            stmt.close();
            
        } catch (SQLException e) {
            System.err.println("Error getting all customers: " + e.getMessage());
        }
        
        return customers;
    }
    
    /**
     * Update customer information
     * @param customer Customer object with updated information
     * @return true if update successful
     */
    public boolean updateCustomer(Customer customer) {
        String sql = "UPDATE customers SET company_name = ?, contact_person = ?, " +
                    "phone = ?, email = ?, address = ?, industry = ?, " +
                    "registration_number = ?, updated_date = CURRENT_TIMESTAMP " +
                    "WHERE customer_id = ?";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            pstmt.setString(1, customer.getCompanyName());
            pstmt.setString(2, customer.getContactPerson());
            pstmt.setString(3, customer.getPhone());
            pstmt.setString(4, customer.getEmail());
            pstmt.setString(5, customer.getAddress());
            pstmt.setString(6, customer.getIndustry());
            pstmt.setString(7, customer.getRegistrationNumber());
            pstmt.setInt(8, customer.getCustomerId());
            
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            boolean success = rowsAffected > 0;
            if (success) {
                System.out.println("Customer updated successfully: " + customer.getCustomerCode());
            }
            
            return success;
            
        } catch (SQLException e) {
            System.err.println("Error updating customer: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get customer count for statistics
     * @return total number of active customers
     */
    public int getCustomerCount() {
        String sql = "SELECT COUNT(*) as total FROM customers WHERE status = 'ACTIVE'";
        
        try {
            Connection conn = dbConnection.getConnection();
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            
            int count = 0;
            if (rs.next()) {
                count = rs.getInt("total");
            }
            
            rs.close();
            stmt.close();
            
            return count;
            
        } catch (SQLException e) {
            System.err.println("Error getting customer count: " + e.getMessage());
            return 0;
        }
    }
    
    /**
     * Advanced customer search with multiple criteria
     * @param customerCode Customer code (exact match)
     * @param companyName Company name (partial match)
     * @param industry Industry (exact match)
     * @param status Status filter
     * @return List of matching customers
     */
    public List<Customer> advancedSearch(String customerCode, String companyName, String industry, String status) {
        StringBuilder sql = new StringBuilder("SELECT * FROM customers WHERE 1=1");
        List<String> params = new ArrayList<>();
        
        if (customerCode != null && !customerCode.trim().isEmpty()) {
            sql.append(" AND customer_code ILIKE ?");
            params.add("%" + customerCode.trim() + "%");
        }
        
        if (companyName != null && !companyName.trim().isEmpty()) {
            sql.append(" AND company_name ILIKE ?");
            params.add("%" + companyName.trim() + "%");
        }
        
        if (industry != null && !industry.trim().isEmpty()) {
            sql.append(" AND industry = ?");
            params.add(industry.trim());
        }
        
        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        } else {
            sql.append(" AND status = 'ACTIVE'");
        }
        
        sql.append(" ORDER BY company_name LIMIT 100");
        
        List<Customer> customers = new ArrayList<>();
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql.toString());
            
            for (int i = 0; i < params.size(); i++) {
                pstmt.setString(i + 1, params.get(i));
            }
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }
            
            rs.close();
            pstmt.close();
            
            System.out.println("Advanced search found " + customers.size() + " customers");
            
        } catch (SQLException e) {
            System.err.println("Error in advanced customer search: " + e.getMessage());
            e.printStackTrace();
        }
        
        return customers;
    }
    
    /**
     * Get customers by industry
     * @param industry Industry to search for
     * @return List of customers in that industry
     */
    public List<Customer> getCustomersByIndustry(String industry) {
        String sql = "SELECT * FROM customers WHERE industry = ? AND status = 'ACTIVE' " +
                    "ORDER BY company_name";
        
        List<Customer> customers = new ArrayList<>();
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, industry);
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                customers.add(mapResultSetToCustomer(rs));
            }
            
            rs.close();
            pstmt.close();
            
        } catch (SQLException e) {
            System.err.println("Error getting customers by industry: " + e.getMessage());
            e.printStackTrace();
        }
        
        return customers;
    }
    
    /**
     * Get all industries from customer database
     * @return List of distinct industries
     */
    public List<String> getAllIndustries() {
        String sql = "SELECT DISTINCT industry FROM customers WHERE industry IS NOT NULL " +
                    "AND industry != '' ORDER BY industry";
        
        List<String> industries = new ArrayList<>();
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                industries.add(rs.getString("industry"));
            }
            
            rs.close();
            pstmt.close();
            
        } catch (SQLException e) {
            System.err.println("Error getting all industries: " + e.getMessage());
            e.printStackTrace();
        }
        
        return industries;
    }
    
    
    /**
     * Deactivate customer (soft delete)
     * @param customerId Customer ID to deactivate
     * @return true if successful, false otherwise
     */
    public boolean deactivateCustomer(int customerId) {
        String sql = "UPDATE customers SET status = 'INACTIVE', updated_date = CURRENT_TIMESTAMP " +
                    "WHERE customer_id = ?";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);
            
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                System.out.println("Customer deactivated successfully: " + customerId);
                return true;
            } else {
                System.out.println("No customer found with ID: " + customerId);
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("Error deactivating customer: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Map ResultSet row to Customer object
     * @param rs ResultSet positioned at a row
     * @return Customer object
     */
    private Customer mapResultSetToCustomer(ResultSet rs) throws SQLException {
        Customer customer = new Customer();
        
        customer.setCustomerId(rs.getInt("customer_id"));
        customer.setCustomerCode(rs.getString("customer_code"));
        customer.setCompanyName(rs.getString("company_name"));
        customer.setContactPerson(rs.getString("contact_person"));
        customer.setPhone(rs.getString("phone"));
        customer.setEmail(rs.getString("email"));
        customer.setAddress(rs.getString("address"));
        customer.setIndustry(rs.getString("industry"));
        customer.setRegistrationNumber(rs.getString("registration_number"));
        customer.setStatus(rs.getString("status"));
        customer.setCreatedDate(rs.getTimestamp("created_date"));
        customer.setUpdatedDate(rs.getTimestamp("updated_date"));
        
        return customer;
    }
}