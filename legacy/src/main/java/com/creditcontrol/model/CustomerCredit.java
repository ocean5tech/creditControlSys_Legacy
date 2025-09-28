package com.creditcontrol.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * CustomerCredit Model Class for Legacy Credit Control System
 * Represents customer credit information and limits
 */
public class CustomerCredit {
    
    // Primary key
    private int creditId;
    
    // Foreign key reference
    private int customerId;
    
    // Credit information
    private BigDecimal creditLimit;
    private BigDecimal availableCredit;
    private String creditRating;
    private int riskScore;
    
    // Review information
    private Date lastReviewDate;
    private String creditOfficer;
    private String approvalStatus;
    
    // System fields
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // Default constructor
    public CustomerCredit() {
        this.creditLimit = BigDecimal.ZERO;
        this.availableCredit = BigDecimal.ZERO;
        this.creditRating = "C";
        this.riskScore = 50;
        this.approvalStatus = "PENDING";
    }
    
    // Constructor with essential fields
    public CustomerCredit(int customerId, BigDecimal creditLimit) {
        this();
        this.customerId = customerId;
        this.creditLimit = creditLimit;
        this.availableCredit = creditLimit; // Initially all credit is available
    }
    
    // Full constructor
    public CustomerCredit(int customerId, BigDecimal creditLimit, BigDecimal availableCredit,
                         String creditRating, int riskScore, String creditOfficer) {
        this(customerId, creditLimit);
        this.availableCredit = availableCredit;
        this.creditRating = creditRating;
        this.riskScore = riskScore;
        this.creditOfficer = creditOfficer;
    }
    
    // Getters and Setters
    public int getCreditId() {
        return creditId;
    }
    
    public void setCreditId(int creditId) {
        this.creditId = creditId;
    }
    
    public int getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    
    public BigDecimal getCreditLimit() {
        return creditLimit;
    }
    
    public void setCreditLimit(BigDecimal creditLimit) {
        this.creditLimit = creditLimit;
        // Update available credit when limit changes
        if (this.availableCredit.compareTo(creditLimit) > 0) {
            this.availableCredit = creditLimit;
        }
    }
    
    public BigDecimal getAvailableCredit() {
        return availableCredit;
    }
    
    public void setAvailableCredit(BigDecimal availableCredit) {
        this.availableCredit = availableCredit;
    }
    
    public String getCreditRating() {
        return creditRating;
    }
    
    public void setCreditRating(String creditRating) {
        this.creditRating = creditRating != null ? creditRating.toUpperCase() : "C";
    }
    
    public int getRiskScore() {
        return riskScore;
    }
    
    public void setRiskScore(int riskScore) {
        // Ensure risk score is within valid range (0-100)
        this.riskScore = Math.max(0, Math.min(100, riskScore));
    }
    
    public Date getLastReviewDate() {
        return lastReviewDate;
    }
    
    public void setLastReviewDate(Date lastReviewDate) {
        this.lastReviewDate = lastReviewDate;
    }
    
    public String getCreditOfficer() {
        return creditOfficer;
    }
    
    public void setCreditOfficer(String creditOfficer) {
        this.creditOfficer = creditOfficer;
    }
    
    public String getApprovalStatus() {
        return approvalStatus;
    }
    
    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus != null ? approvalStatus.toUpperCase() : "PENDING";
    }
    
    public Timestamp getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }
    
    public Timestamp getUpdatedDate() {
        return updatedDate;
    }
    
    public void setUpdatedDate(Timestamp updatedDate) {
        this.updatedDate = updatedDate;
    }
    
    // Business methods
    
    /**
     * Calculate credit utilization percentage
     */
    public double getCreditUtilization() {
        if (creditLimit.equals(BigDecimal.ZERO)) {
            return 0.0;
        }
        BigDecimal usedCredit = creditLimit.subtract(availableCredit);
        return usedCredit.divide(creditLimit, 4, BigDecimal.ROUND_HALF_UP).doubleValue() * 100;
    }
    
    /**
     * Get credit status based on utilization and rating
     */
    public String getCreditStatus() {
        double utilization = getCreditUtilization();
        
        if ("D".equals(creditRating)) {
            return "DEFAULT";
        } else if (utilization > 90) {
            return "CRITICAL";
        } else if (utilization > 75) {
            return "HIGH_USAGE";
        } else if (utilization > 50) {
            return "MODERATE";
        } else {
            return "GOOD";
        }
    }
    
    /**
     * Check if credit limit increase is recommended
     */
    public boolean isLimitIncreaseRecommended() {
        return getCreditUtilization() > 75 && 
               riskScore > 60 && 
               !"D".equals(creditRating) && 
               !"CCC".equals(creditRating);
    }
    
    /**
     * Get risk level based on risk score
     */
    public String getRiskLevel() {
        if (riskScore >= 80) return "LOW";
        else if (riskScore >= 60) return "MEDIUM";
        else if (riskScore >= 40) return "HIGH";
        else return "VERY_HIGH";
    }
    
    /**
     * Get formatted credit limit display
     */
    public String getFormattedCreditLimit() {
        return String.format("$%,.2f", creditLimit);
    }
    
    /**
     * Get formatted available credit display
     */
    public String getFormattedAvailableCredit() {
        return String.format("$%,.2f", availableCredit);
    }
    
    @Override
    public String toString() {
        return "CustomerCredit{" +
               "creditId=" + creditId +
               ", customerId=" + customerId +
               ", creditLimit=" + creditLimit +
               ", availableCredit=" + availableCredit +
               ", creditRating='" + creditRating + '\'' +
               ", riskScore=" + riskScore +
               ", approvalStatus='" + approvalStatus + '\'' +
               ", creditOfficer='" + creditOfficer + '\'' +
               '}';
    }
}