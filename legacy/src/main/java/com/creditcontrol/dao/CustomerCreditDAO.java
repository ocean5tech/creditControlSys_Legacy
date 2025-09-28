package com.creditcontrol.dao;

import com.creditcontrol.model.CustomerCredit;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for CustomerCredit operations
 * Handles all database operations related to customer credit management
 */
public class CustomerCreditDAO {
    
    private DatabaseConnection dbConnection;
    
    public CustomerCreditDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }
    
    /**
     * Create a new customer credit record
     * @param customerCredit CustomerCredit object to insert
     * @return generated credit ID, or -1 if failed
     */
    public int createCustomerCredit(CustomerCredit customerCredit) {
        String sql = "INSERT INTO customer_credit (customer_id, credit_limit, available_credit, " +
                    "credit_rating, risk_score, credit_officer, approval_status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING credit_id";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            pstmt.setInt(1, customerCredit.getCustomerId());
            pstmt.setBigDecimal(2, customerCredit.getCreditLimit());
            pstmt.setBigDecimal(3, customerCredit.getAvailableCredit());
            pstmt.setString(4, customerCredit.getCreditRating());
            pstmt.setInt(5, customerCredit.getRiskScore());
            pstmt.setString(6, customerCredit.getCreditOfficer());
            pstmt.setString(7, customerCredit.getApprovalStatus());
            
            ResultSet rs = pstmt.executeQuery();
            
            int creditId = -1;
            if (rs.next()) {
                creditId = rs.getInt("credit_id");
                customerCredit.setCreditId(creditId);
                System.out.println("Customer credit created successfully with ID: " + creditId);
            }
            
            rs.close();
            pstmt.close();
            
            return creditId;
            
        } catch (SQLException e) {
            System.err.println("Error creating customer credit: " + e.getMessage());
            e.printStackTrace();
            return -1;
        }
    }
    
    /**
     * Get customer credit by customer ID
     * @param customerId Customer ID to search for
     * @return CustomerCredit object, or null if not found
     */
    public CustomerCredit getCustomerCreditByCustomerId(int customerId) {
        String sql = "SELECT * FROM customer_credit WHERE customer_id = ?";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);
            
            ResultSet rs = pstmt.executeQuery();
            
            CustomerCredit credit = null;
            if (rs.next()) {
                credit = mapResultSetToCustomerCredit(rs);
            }
            
            rs.close();
            pstmt.close();
            
            return credit;
            
        } catch (SQLException e) {
            System.err.println("Error getting customer credit by customer ID: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Update customer credit limit
     * @param customerId Customer ID
     * @param newCreditLimit New credit limit
     * @param creditOfficer Officer making the change
     * @return true if successful, false otherwise
     */
    public boolean updateCreditLimit(int customerId, BigDecimal newCreditLimit, String creditOfficer) {
        String sql = "UPDATE customer_credit SET credit_limit = ?, credit_officer = ?, " +
                    "updated_date = CURRENT_TIMESTAMP WHERE customer_id = ?";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            pstmt.setBigDecimal(1, newCreditLimit);
            pstmt.setString(2, creditOfficer);
            pstmt.setInt(3, customerId);
            
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                System.out.println("Credit limit updated successfully for customer ID: " + customerId);
                return true;
            } else {
                System.out.println("No credit record found for customer ID: " + customerId);
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("Error updating credit limit: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update customer risk score and rating
     * @param customerId Customer ID
     * @param riskScore New risk score (0-100)
     * @param creditRating New credit rating
     * @param creditOfficer Officer making the change
     * @return true if successful, false otherwise
     */
    public boolean updateRiskAssessment(int customerId, int riskScore, String creditRating, String creditOfficer) {
        String sql = "UPDATE customer_credit SET risk_score = ?, credit_rating = ?, " +
                    "credit_officer = ?, last_review_date = CURRENT_DATE, updated_date = CURRENT_TIMESTAMP " +
                    "WHERE customer_id = ?";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            pstmt.setInt(1, riskScore);
            pstmt.setString(2, creditRating);
            pstmt.setString(3, creditOfficer);
            pstmt.setInt(4, customerId);
            
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                System.out.println("Risk assessment updated successfully for customer ID: " + customerId);
                return true;
            } else {
                System.out.println("No credit record found for customer ID: " + customerId);
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("Error updating risk assessment: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get all customers with credit limits above a threshold
     * @param threshold Credit limit threshold
     * @return List of CustomerCredit objects
     */
    public List<CustomerCredit> getCustomersWithCreditAbove(BigDecimal threshold) {
        String sql = "SELECT * FROM customer_credit WHERE credit_limit > ? ORDER BY credit_limit DESC";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setBigDecimal(1, threshold);
            
            ResultSet rs = pstmt.executeQuery();
            
            List<CustomerCredit> credits = new ArrayList<>();
            while (rs.next()) {
                credits.add(mapResultSetToCustomerCredit(rs));
            }
            
            rs.close();
            pstmt.close();
            
            return credits;
            
        } catch (SQLException e) {
            System.err.println("Error getting customers with high credit: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    /**
     * Get customers by credit rating
     * @param creditRating Credit rating to search for
     * @return List of CustomerCredit objects
     */
    public List<CustomerCredit> getCustomersByRating(String creditRating) {
        String sql = "SELECT * FROM customer_credit WHERE credit_rating = ? ORDER BY credit_limit DESC";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, creditRating);
            
            ResultSet rs = pstmt.executeQuery();
            
            List<CustomerCredit> credits = new ArrayList<>();
            while (rs.next()) {
                credits.add(mapResultSetToCustomerCredit(rs));
            }
            
            rs.close();
            pstmt.close();
            
            return credits;
            
        } catch (SQLException e) {
            System.err.println("Error getting customers by rating: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    /**
     * Get customers requiring credit review (no review in last 365 days)
     * @return List of CustomerCredit objects
     */
    public List<CustomerCredit> getCustomersRequiringReview() {
        String sql = "SELECT * FROM customer_credit WHERE " +
                    "last_review_date IS NULL OR last_review_date < CURRENT_DATE - INTERVAL '365 days' " +
                    "ORDER BY last_review_date ASC NULLS FIRST";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            ResultSet rs = pstmt.executeQuery();
            
            List<CustomerCredit> credits = new ArrayList<>();
            while (rs.next()) {
                credits.add(mapResultSetToCustomerCredit(rs));
            }
            
            rs.close();
            pstmt.close();
            
            return credits;
            
        } catch (SQLException e) {
            System.err.println("Error getting customers requiring review: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    /**
     * Delete customer credit record
     * @param customerId Customer ID
     * @return true if successful, false otherwise
     */
    public boolean deleteCustomerCredit(int customerId) {
        String sql = "DELETE FROM customer_credit WHERE customer_id = ?";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, customerId);
            
            int rowsAffected = pstmt.executeUpdate();
            pstmt.close();
            
            if (rowsAffected > 0) {
                System.out.println("Customer credit deleted successfully for customer ID: " + customerId);
                return true;
            } else {
                System.out.println("No credit record found for customer ID: " + customerId);
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("Error deleting customer credit: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get total credit exposure (sum of all credit limits)
     * @return Total credit exposure
     */
    public BigDecimal getTotalCreditExposure() {
        String sql = "SELECT COALESCE(SUM(credit_limit), 0) as total FROM customer_credit";
        
        try {
            Connection conn = dbConnection.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql);
            
            ResultSet rs = pstmt.executeQuery();
            
            BigDecimal total = BigDecimal.ZERO;
            if (rs.next()) {
                total = rs.getBigDecimal("total");
            }
            
            rs.close();
            pstmt.close();
            
            return total != null ? total : BigDecimal.ZERO;
            
        } catch (SQLException e) {
            System.err.println("Error calculating total credit exposure: " + e.getMessage());
            e.printStackTrace();
            return BigDecimal.ZERO;
        }
    }
    
    /**
     * Map ResultSet to CustomerCredit object
     * @param rs ResultSet containing customer credit data
     * @return CustomerCredit object
     * @throws SQLException if database access error occurs
     */
    private CustomerCredit mapResultSetToCustomerCredit(ResultSet rs) throws SQLException {
        CustomerCredit credit = new CustomerCredit();
        
        credit.setCreditId(rs.getInt("credit_id"));
        credit.setCustomerId(rs.getInt("customer_id"));
        credit.setCreditLimit(rs.getBigDecimal("credit_limit"));
        credit.setAvailableCredit(rs.getBigDecimal("available_credit"));
        credit.setCreditRating(rs.getString("credit_rating"));
        credit.setRiskScore(rs.getInt("risk_score"));
        credit.setLastReviewDate(rs.getDate("last_review_date"));
        credit.setCreditOfficer(rs.getString("credit_officer"));
        credit.setApprovalStatus(rs.getString("approval_status"));
        credit.setCreatedDate(rs.getTimestamp("created_date"));
        credit.setUpdatedDate(rs.getTimestamp("updated_date"));
        
        return credit;
    }
}