package com.creditcontrol.form;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionMessage;
import javax.servlet.http.HttpServletRequest;

/**
 * ActionForm for Customer management functionality
 * Handles customer creation and editing operations
 */
public class CustomerForm extends ActionForm {
    
    private static final long serialVersionUID = 1L;
    
    // Customer identification
    private String customerId;
    private String customerCode;
    private String companyName;
    private String contactPerson;
    
    // Contact information
    private String phone;
    private String email;
    private String address;
    
    // Business information
    private String industry;
    private String registrationNumber;
    private String status;
    
    // Action parameters
    private String action = "display"; // display, edit, save, delete
    
    // Default constructor
    public CustomerForm() {
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
        customerCode = "";
        companyName = "";
        contactPerson = "";
        phone = "";
        email = "";
        address = "";
        industry = "";
        registrationNumber = "";
        status = "ACTIVE";
        action = "display";
    }
    
    /**
     * Validate form data
     */
    public ActionErrors validate(ActionMapping mapping, HttpServletRequest request) {
        ActionErrors errors = new ActionErrors();
        
        // Only validate for save operations
        if (!"save".equals(action)) {
            return errors;
        }
        
        // Customer code validation
        if (isEmpty(customerCode)) {
            errors.add("customerCode", 
                new ActionMessage("error.customercode.required"));
        } else {
            if (customerCode.length() < 3 || customerCode.length() > 20) {
                errors.add("customerCode", 
                    new ActionMessage("error.customercode.length"));
            }
            if (!customerCode.matches("^[A-Z0-9]+$")) {
                errors.add("customerCode", 
                    new ActionMessage("error.customercode.format"));
            }
        }
        
        // Company name validation
        if (isEmpty(companyName)) {
            errors.add("companyName", 
                new ActionMessage("error.companyname.required"));
        } else {
            if (companyName.length() < 2 || companyName.length() > 200) {
                errors.add("companyName", 
                    new ActionMessage("error.companyname.length"));
            }
        }
        
        // Email validation (if provided)
        if (!isEmpty(email)) {
            if (!isValidEmail(email)) {
                errors.add("email", 
                    new ActionMessage("error.email.format"));
            }
        }
        
        // Phone validation (if provided)
        if (!isEmpty(phone)) {
            if (phone.length() > 50) {
                errors.add("phone", 
                    new ActionMessage("error.phone.length"));
            }
        }
        
        // Industry validation
        if (!isEmpty(industry) && industry.length() > 50) {
            errors.add("industry", 
                new ActionMessage("error.industry.length"));
        }
        
        // Registration number validation
        if (!isEmpty(registrationNumber) && registrationNumber.length() > 50) {
            errors.add("registrationNumber", 
                new ActionMessage("error.registration.length"));
        }
        
        return errors;
    }
    
    // Utility methods
    private boolean isEmpty(String str) {
        return str == null || str.trim().length() == 0;
    }
    
    private boolean isValidEmail(String email) {
        if (email == null) return false;
        return email.contains("@") && email.contains(".") && 
               email.indexOf("@") > 0 && 
               email.indexOf("@") < email.lastIndexOf(".");
    }
    
    // Getters and Setters
    public String getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(String customerId) {
        this.customerId = customerId != null ? customerId.trim() : "";
    }
    
    public String getCustomerCode() {
        return customerCode;
    }
    
    public void setCustomerCode(String customerCode) {
        this.customerCode = customerCode != null ? customerCode.trim().toUpperCase() : "";
    }
    
    public String getCompanyName() {
        return companyName;
    }
    
    public void setCompanyName(String companyName) {
        this.companyName = companyName != null ? companyName.trim() : "";
    }
    
    public String getContactPerson() {
        return contactPerson;
    }
    
    public void setContactPerson(String contactPerson) {
        this.contactPerson = contactPerson != null ? contactPerson.trim() : "";
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone != null ? phone.trim() : "";
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email != null ? email.trim().toLowerCase() : "";
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address != null ? address.trim() : "";
    }
    
    public String getIndustry() {
        return industry;
    }
    
    public void setIndustry(String industry) {
        this.industry = industry != null ? industry.trim() : "";
    }
    
    public String getRegistrationNumber() {
        return registrationNumber;
    }
    
    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber != null ? registrationNumber.trim() : "";
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status != null ? status.trim() : "ACTIVE";
    }
    
    public String getAction() {
        return action;
    }
    
    public void setAction(String action) {
        this.action = action != null ? action.trim() : "display";
    }
    
    // Business methods
    
    /**
     * Check if this is a new customer (no ID assigned)
     */
    public boolean isNewCustomer() {
        return isEmpty(customerId) || "0".equals(customerId);
    }
    
    /**
     * Check if form is in edit mode
     */
    public boolean isEditMode() {
        return "edit".equals(action);
    }
    
    /**
     * Check if form is in save mode
     */
    public boolean isSaveMode() {
        return "save".equals(action);
    }
    
    /**
     * Get customer display name
     */
    public String getDisplayName() {
        if (!isEmpty(companyName) && !isEmpty(customerCode)) {
            return companyName + " (" + customerCode + ")";
        } else if (!isEmpty(companyName)) {
            return companyName;
        } else if (!isEmpty(customerCode)) {
            return customerCode;
        } else {
            return "New Customer";
        }
    }
    
    /**
     * Get formatted contact information
     */
    public String getContactInfo() {
        StringBuilder info = new StringBuilder();
        
        if (!isEmpty(contactPerson)) {
            info.append(contactPerson);
        }
        
        if (!isEmpty(phone)) {
            if (info.length() > 0) info.append(" | ");
            info.append("Phone: ").append(phone);
        }
        
        if (!isEmpty(email)) {
            if (info.length() > 0) info.append(" | ");
            info.append("Email: ").append(email);
        }
        
        return info.toString();
    }
    
    @Override
    public String toString() {
        return "CustomerForm{" +
               "customerId='" + customerId + '\'' +
               ", customerCode='" + customerCode + '\'' +
               ", companyName='" + companyName + '\'' +
               ", contactPerson='" + contactPerson + '\'' +
               ", email='" + email + '\'' +
               ", industry='" + industry + '\'' +
               ", status='" + status + '\'' +
               ", action='" + action + '\'' +
               '}';
    }
}