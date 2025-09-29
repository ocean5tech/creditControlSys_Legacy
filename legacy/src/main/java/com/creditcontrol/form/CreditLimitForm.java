package com.creditcontrol.form;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import javax.servlet.http.HttpServletRequest;

import java.math.BigDecimal;

/**
 * ActionForm for Credit Limit Management functionality
 * Handles credit limit updates and risk assessment operations
 */
public class CreditLimitForm extends ActionForm {
    
    private static final long serialVersionUID = 1L;
    
    // Customer and credit identification
    private String customerId;
    private String creditId;
    
    // Credit limit fields
    private String currentCreditLimit;
    private String newCreditLimit;
    private String availableCredit;
    
    // Risk assessment fields
    private String riskScore;
    private String creditRating;
    private String previousRating;
    
    // Review information
    private String creditOfficer;
    private String approvalStatus;
    private String lastReviewDate;
    private String reviewComments;
    
    // Action parameters
    private String action = "display"; // display, updateLimit, updateRisk, approve
    
    // Default constructor
    public CreditLimitForm() {
        reset();
    }
    
    /**
     * Reset form fields to default values
     */
    public void reset(ActionMapping mapping, HttpServletRequest request) {
        reset();
    }
    
    private void reset() {
        customerId = "";
        creditId = "";
        currentCreditLimit = "";
        newCreditLimit = "";
        availableCredit = "";
        riskScore = "";
        creditRating = "";
        previousRating = "";
        creditOfficer = "";
        approvalStatus = "";
        lastReviewDate = "";
        reviewComments = "";
        action = "display";
    }
    
    /**
     * Validate form data
     */
    public ActionErrors validate(ActionMapping mapping, HttpServletRequest request) {
        ActionErrors errors = new ActionErrors();
        
        // Only validate for specific operations
        if ("updateLimit".equals(action)) {
            validateCreditLimit(errors);
        } else if ("updateRisk".equals(action)) {
            validateRiskAssessment(errors);
        }
        
        return errors;
    }
    
    /**
     * Validate credit limit update
     */
    private void validateCreditLimit(ActionErrors errors) {
        // New credit limit validation
        if (isEmpty(newCreditLimit)) {
            errors.add("newCreditLimit", 
                new ActionMessage("error.creditlimit.required"));
        } else {
            try {
                BigDecimal limit = new BigDecimal(newCreditLimit);
                if (limit.compareTo(BigDecimal.ZERO) < 0) {
                    errors.add("newCreditLimit", 
                        new ActionMessage("error.creditlimit.negative"));
                }
                if (limit.compareTo(new BigDecimal("10000000")) > 0) { // $10M max - TODO: move to database
                    errors.add("newCreditLimit", 
                        new ActionMessage("error.creditlimit.toolarge"));
                }
            } catch (NumberFormatException e) {
                errors.add("newCreditLimit", 
                    new ActionMessage("error.creditlimit.format"));
            }
        }
        
        // Credit officer validation
        if (isEmpty(creditOfficer)) {
            errors.add("creditOfficer", 
                new ActionMessage("error.creditofficer.required"));
        } else {
            if (creditOfficer.length() < 2 || creditOfficer.length() > 100) {
                errors.add("creditOfficer", 
                    new ActionMessage("error.creditofficer.length"));
            }
        }
    }
    
    /**
     * Validate risk assessment update
     */
    private void validateRiskAssessment(ActionErrors errors) {
        // Risk score validation
        if (isEmpty(riskScore)) {
            errors.add("riskScore", 
                new ActionMessage("error.riskscore.required"));
        } else {
            try {
                int score = Integer.parseInt(riskScore);
                if (score < 0 || score > 100) {
                    errors.add("riskScore", 
                        new ActionMessage("error.riskscore.range"));
                }
            } catch (NumberFormatException e) {
                errors.add("riskScore", 
                    new ActionMessage("error.riskscore.format"));
            }
        }
        
        // Credit rating validation
        if (isEmpty(creditRating)) {
            errors.add("creditRating", 
                new ActionMessage("error.creditrating.required"));
        } else {
            if (!isValidCreditRating(creditRating)) {
                errors.add("creditRating", 
                    new ActionMessage("error.creditrating.invalid"));
            }
        }
        
        // Credit officer validation
        if (isEmpty(creditOfficer)) {
            errors.add("creditOfficer", 
                new ActionMessage("error.creditofficer.required"));
        }
    }
    
    // Utility methods
    private boolean isEmpty(String str) {
        return str == null || str.trim().length() == 0;
    }
    
    private boolean isValidCreditRating(String rating) {
        if (rating == null) return false;
        String[] validRatings = {"AAA", "AA", "A", "BBB", "BB", "B", "CCC", "CC", "C", "D"};
        for (String valid : validRatings) {
            if (valid.equals(rating.toUpperCase())) {
                return true;
            }
        }
        return false;
    }
    
    // Getters and Setters
    public String getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(String customerId) {
        this.customerId = customerId != null ? customerId.trim() : "";
    }
    
    public String getCreditId() {
        return creditId;
    }
    
    public void setCreditId(String creditId) {
        this.creditId = creditId != null ? creditId.trim() : "";
    }
    
    public String getCurrentCreditLimit() {
        return currentCreditLimit;
    }
    
    public void setCurrentCreditLimit(String currentCreditLimit) {
        this.currentCreditLimit = currentCreditLimit != null ? currentCreditLimit.trim() : "";
    }
    
    public String getNewCreditLimit() {
        return newCreditLimit;
    }
    
    public void setNewCreditLimit(String newCreditLimit) {
        this.newCreditLimit = newCreditLimit != null ? newCreditLimit.trim() : "";
    }
    
    public String getAvailableCredit() {
        return availableCredit;
    }
    
    public void setAvailableCredit(String availableCredit) {
        this.availableCredit = availableCredit != null ? availableCredit.trim() : "";
    }
    
    public String getRiskScore() {
        return riskScore;
    }
    
    public void setRiskScore(String riskScore) {
        this.riskScore = riskScore != null ? riskScore.trim() : "";
    }
    
    public String getCreditRating() {
        return creditRating;
    }
    
    public void setCreditRating(String creditRating) {
        this.creditRating = creditRating != null ? creditRating.trim().toUpperCase() : "";
    }
    
    public String getPreviousRating() {
        return previousRating;
    }
    
    public void setPreviousRating(String previousRating) {
        this.previousRating = previousRating != null ? previousRating.trim() : "";
    }
    
    public String getCreditOfficer() {
        return creditOfficer;
    }
    
    public void setCreditOfficer(String creditOfficer) {
        this.creditOfficer = creditOfficer != null ? creditOfficer.trim() : "";
    }
    
    public String getApprovalStatus() {
        return approvalStatus;
    }
    
    public void setApprovalStatus(String approvalStatus) {
        this.approvalStatus = approvalStatus != null ? approvalStatus.trim() : "";
    }
    
    public String getLastReviewDate() {
        return lastReviewDate;
    }
    
    public void setLastReviewDate(String lastReviewDate) {
        this.lastReviewDate = lastReviewDate != null ? lastReviewDate.trim() : "";
    }
    
    public String getReviewComments() {
        return reviewComments;
    }
    
    public void setReviewComments(String reviewComments) {
        this.reviewComments = reviewComments != null ? reviewComments.trim() : "";
    }
    
    public String getAction() {
        return action;
    }
    
    public void setAction(String action) {
        this.action = action != null ? action.trim() : "display";
    }
    
    // Business methods
    
    /**
     * Check if this is a credit limit update operation
     */
    public boolean isCreditLimitUpdate() {
        return "updateLimit".equals(action);
    }
    
    /**
     * Check if this is a risk assessment update
     */
    public boolean isRiskAssessmentUpdate() {
        return "updateRisk".equals(action);
    }
    
    /**
     * Get formatted current credit limit
     */
    public String getFormattedCurrentLimit() {
        if (isEmpty(currentCreditLimit)) return "$0.00";
        try {
            BigDecimal amount = new BigDecimal(currentCreditLimit);
            return String.format("$%,.2f", amount);
        } catch (NumberFormatException e) {
            return currentCreditLimit;
        }
    }
    
    /**
     * Get formatted new credit limit
     */
    public String getFormattedNewLimit() {
        if (isEmpty(newCreditLimit)) return "$0.00";
        try {
            BigDecimal amount = new BigDecimal(newCreditLimit);
            return String.format("$%,.2f", amount);
        } catch (NumberFormatException e) {
            return newCreditLimit;
        }
    }
    
    /**
     * Calculate limit change percentage
     */
    public String getLimitChangePercentage() {
        if (isEmpty(currentCreditLimit) || isEmpty(newCreditLimit)) return "N/A";
        try {
            BigDecimal current = new BigDecimal(currentCreditLimit);
            BigDecimal newLimit = new BigDecimal(newCreditLimit);
            
            if (current.equals(BigDecimal.ZERO)) return "N/A";
            
            BigDecimal change = newLimit.subtract(current);
            BigDecimal percentage = change.divide(current, 4, BigDecimal.ROUND_HALF_UP)
                                         .multiply(new BigDecimal(100));
            
            return String.format("%+.1f%%", percentage);
        } catch (Exception e) {
            return "N/A";
        }
    }
    
    /**
     * Get risk level description
     */
    public String getRiskLevelDescription() {
        if (isEmpty(riskScore)) return "Unknown";
        try {
            int score = Integer.parseInt(riskScore);
            if (score >= 80) return "LOW RISK";
            else if (score >= 60) return "MEDIUM RISK";
            else if (score >= 40) return "HIGH RISK";
            else return "VERY HIGH RISK";
        } catch (NumberFormatException e) {
            return "Invalid";
        }
    }
    
    @Override
    public String toString() {
        return "CreditLimitForm{" +
               "customerId='" + customerId + '\'' +
               ", newCreditLimit='" + newCreditLimit + '\'' +
               ", riskScore='" + riskScore + '\'' +
               ", creditRating='" + creditRating + '\'' +
               ", creditOfficer='" + creditOfficer + '\'' +
               ", action='" + action + '\'' +
               '}';
    }
}