package com.creditcontrol.form;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import javax.servlet.http.HttpServletRequest;

/**
 * ActionForm for Customer Search functionality
 * Handles customer search criteria and validation
 */
public class CustomerSearchForm extends ActionForm {
    
    private static final long serialVersionUID = 1L;
    
    // Search criteria fields
    private String customerCode;
    private String companyName;
    private String industry;
    private String creditRating;
    private String status = "ACTIVE";
    
    // Search parameters
    private String searchType = "name"; // name, code, industry
    private int maxResults = 50;
    
    // Default constructor
    public CustomerSearchForm() {
        reset();
    }
    
    /**
     * Reset form fields to default values
     */
    public void reset(ActionMapping mapping, HttpServletRequest request) {
        reset();
    }
    
    private void reset() {
        customerCode = "";
        companyName = "";
        industry = "";
        creditRating = "";
        status = "ACTIVE";
        searchType = "name";
        maxResults = 50;
    }
    
    /**
     * Validate form data
     */
    public ActionErrors validate(ActionMapping mapping, HttpServletRequest request) {
        ActionErrors errors = new ActionErrors();
        
        // At least one search criteria must be provided
        if (isEmpty(customerCode) && isEmpty(companyName) && isEmpty(industry)) {
            errors.add("searchCriteria", 
                new ActionMessage("error.search.criteria.required"));
        }
        
        // Customer code validation
        if (!isEmpty(customerCode)) {
            if (customerCode.length() < 3) {
                errors.add("customerCode", 
                    new ActionMessage("error.customercode.minlength"));
            }
            if (customerCode.length() > 20) {
                errors.add("customerCode", 
                    new ActionMessage("error.customercode.maxlength"));
            }
        }
        
        // Company name validation
        if (!isEmpty(companyName)) {
            if (companyName.length() < 2) {
                errors.add("companyName", 
                    new ActionMessage("error.companyname.minlength"));
            }
            if (companyName.length() > 200) {
                errors.add("companyName", 
                    new ActionMessage("error.companyname.maxlength"));
            }
        }
        
        // Max results validation
        if (maxResults < 1) {
            errors.add("maxResults", 
                new ActionMessage("error.maxresults.minimum"));
        }
        if (maxResults > 500) {
            errors.add("maxResults", 
                new ActionMessage("error.maxresults.maximum"));
        }
        
        return errors;
    }
    
    // Utility method to check if string is empty
    private boolean isEmpty(String str) {
        return str == null || str.trim().length() == 0;
    }
    
    // Getters and Setters
    public String getCustomerCode() {
        return customerCode;
    }
    
    public void setCustomerCode(String customerCode) {
        this.customerCode = customerCode != null ? customerCode.trim() : "";
    }
    
    public String getCompanyName() {
        return companyName;
    }
    
    public void setCompanyName(String companyName) {
        this.companyName = companyName != null ? companyName.trim() : "";
    }
    
    public String getIndustry() {
        return industry;
    }
    
    public void setIndustry(String industry) {
        this.industry = industry != null ? industry.trim() : "";
    }
    
    public String getCreditRating() {
        return creditRating;
    }
    
    public void setCreditRating(String creditRating) {
        this.creditRating = creditRating != null ? creditRating.trim() : "";
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status != null ? status.trim() : "ACTIVE";
    }
    
    public String getSearchType() {
        return searchType;
    }
    
    public void setSearchType(String searchType) {
        this.searchType = searchType != null ? searchType.trim() : "name";
    }
    
    public int getMaxResults() {
        return maxResults;
    }
    
    public void setMaxResults(int maxResults) {
        this.maxResults = maxResults;
    }
    
    // Business methods
    
    /**
     * Check if this is a specific customer code search
     */
    public boolean isCustomerCodeSearch() {
        return "code".equals(searchType) || !isEmpty(customerCode);
    }
    
    /**
     * Check if this is a company name search
     */
    public boolean isCompanyNameSearch() {
        return "name".equals(searchType) || (!isEmpty(companyName) && isEmpty(customerCode));
    }
    
    /**
     * Check if this is an industry-based search
     */
    public boolean isIndustrySearch() {
        return "industry".equals(searchType) || 
               (!isEmpty(industry) && isEmpty(customerCode) && isEmpty(companyName));
    }
    
    /**
     * Get search summary for display
     */
    public String getSearchSummary() {
        StringBuilder summary = new StringBuilder();
        
        if (!isEmpty(customerCode)) {
            summary.append("Customer Code: ").append(customerCode);
        }
        
        if (!isEmpty(companyName)) {
            if (summary.length() > 0) summary.append(", ");
            summary.append("Company: ").append(companyName);
        }
        
        if (!isEmpty(industry)) {
            if (summary.length() > 0) summary.append(", ");
            summary.append("Industry: ").append(industry);
        }
        
        if (!isEmpty(creditRating)) {
            if (summary.length() > 0) summary.append(", ");
            summary.append("Rating: ").append(creditRating);
        }
        
        return summary.toString();
    }
    
    @Override
    public String toString() {
        return "CustomerSearchForm{" +
               "customerCode='" + customerCode + '\'' +
               ", companyName='" + companyName + '\'' +
               ", industry='" + industry + '\'' +
               ", creditRating='" + creditRating + '\'' +
               ", status='" + status + '\'' +
               ", searchType='" + searchType + '\'' +
               ", maxResults=" + maxResults +
               '}';
    }
}