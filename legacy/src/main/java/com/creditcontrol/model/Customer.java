package com.creditcontrol.model;

import java.sql.Timestamp;

/**
 * Customer Model Class for Legacy Credit Control System
 * Represents a customer entity in the database
 */
public class Customer {
    
    // Primary key
    private int customerId;
    
    // Customer identification
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
    
    // System fields
    private String status;
    private Timestamp createdDate;
    private Timestamp updatedDate;
    
    // Default constructor
    public Customer() {
        this.status = "ACTIVE";
    }
    
    // Constructor with essential fields
    public Customer(String customerCode, String companyName) {
        this();
        this.customerCode = customerCode;
        this.companyName = companyName;
    }
    
    // Full constructor
    public Customer(String customerCode, String companyName, String contactPerson, 
                   String phone, String email, String address, String industry, 
                   String registrationNumber) {
        this(customerCode, companyName);
        this.contactPerson = contactPerson;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.industry = industry;
        this.registrationNumber = registrationNumber;
    }
    
    // Getters and Setters
    public int getCustomerId() {
        return customerId;
    }
    
    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
    
    public String getCustomerCode() {
        return customerCode;
    }
    
    public void setCustomerCode(String customerCode) {
        this.customerCode = customerCode;
    }
    
    public String getCompanyName() {
        return companyName;
    }
    
    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }
    
    public String getContactPerson() {
        return contactPerson;
    }
    
    public void setContactPerson(String contactPerson) {
        this.contactPerson = contactPerson;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getIndustry() {
        return industry;
    }
    
    public void setIndustry(String industry) {
        this.industry = industry;
    }
    
    public String getRegistrationNumber() {
        return registrationNumber;
    }
    
    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
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
     * Check if customer is active
     * @return true if customer status is ACTIVE
     */
    public boolean isActive() {
        return "ACTIVE".equals(this.status);
    }
    
    /**
     * Get display name for customer
     * @return company name with customer code
     */
    public String getDisplayName() {
        return this.companyName + " (" + this.customerCode + ")";
    }
    
    /**
     * Validate customer data
     * @return true if customer has minimum required data
     */
    public boolean isValid() {
        return this.customerCode != null && !this.customerCode.trim().isEmpty() &&
               this.companyName != null && !this.companyName.trim().isEmpty();
    }
    
    /**
     * Get formatted contact information
     * @return formatted contact string
     */
    public String getContactInfo() {
        StringBuilder sb = new StringBuilder();
        
        if (contactPerson != null && !contactPerson.trim().isEmpty()) {
            sb.append("Contact: ").append(contactPerson);
        }
        
        if (phone != null && !phone.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(" | ");
            sb.append("Phone: ").append(phone);
        }
        
        if (email != null && !email.trim().isEmpty()) {
            if (sb.length() > 0) sb.append(" | ");
            sb.append("Email: ").append(email);
        }
        
        return sb.toString();
    }
    
    // toString method for debugging
    @Override
    public String toString() {
        return "Customer{" +
                "customerId=" + customerId +
                ", customerCode='" + customerCode + '\'' +
                ", companyName='" + companyName + '\'' +
                ", contactPerson='" + contactPerson + '\'' +
                ", phone='" + phone + '\'' +
                ", email='" + email + '\'' +
                ", industry='" + industry + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
    
    // equals and hashCode for proper object comparison
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        
        Customer customer = (Customer) obj;
        return customerId == customer.customerId &&
               (customerCode != null ? customerCode.equals(customer.customerCode) : 
                customer.customerCode == null);
    }
    
    @Override
    public int hashCode() {
        int result = customerId;
        result = 31 * result + (customerCode != null ? customerCode.hashCode() : 0);
        return result;
    }
}