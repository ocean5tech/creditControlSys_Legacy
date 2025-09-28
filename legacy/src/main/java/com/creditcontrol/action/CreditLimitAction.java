package com.creditcontrol.action;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.creditcontrol.dao.CustomerDAO;
import com.creditcontrol.dao.CustomerCreditDAO;
import com.creditcontrol.model.Customer;
import com.creditcontrol.model.CustomerCredit;

import java.math.BigDecimal;
import java.util.List;

/**
 * CreditLimitAction for Legacy Credit Control System
 * Handles credit limit management and risk assessment operations
 */
public class CreditLimitAction extends Action {
    
    /**
     * Execute the credit limit management action
     */
    public ActionForward execute(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response)
            throws Exception {
        
        try {
            CustomerDAO customerDAO = new CustomerDAO();
            CustomerCreditDAO creditDAO = new CustomerCreditDAO();
            
            // Get action parameter
            String action = request.getParameter("action");
            if (action == null) action = "display";
            
            String customerId = request.getParameter("customerId");
            
            switch (action) {
                case "display":
                    return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerId);
                    
                case "updateLimit":
                    return updateCreditLimit(mapping, request, customerDAO, creditDAO, customerId);
                    
                case "updateRisk":
                    return updateRiskAssessment(mapping, request, customerDAO, creditDAO, customerId);
                    
                case "create":
                    return createCreditProfile(mapping, request, customerDAO, creditDAO, customerId);
                    
                case "dashboard":
                    return displayCreditDashboard(mapping, request, customerDAO, creditDAO);
                    
                default:
                    return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerId);
            }
            
        } catch (Exception e) {
            System.err.println("Error in CreditLimitAction: " + e.getMessage());
            e.printStackTrace();
            
            ActionMessages errors = new ActionMessages();
            errors.add("creditError", new ActionMessage("error.credit.operation.failed"));
            request.setAttribute("errorMessages", errors);
            
            return mapping.findForward("error");
        }
    }
    
    /**
     * Display credit information for a customer
     */
    private ActionForward displayCreditInfo(ActionMapping mapping, HttpServletRequest request,
                                          CustomerDAO customerDAO, CustomerCreditDAO creditDAO,
                                          String customerIdStr) {
        
        try {
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Customer ID is required");
                return mapping.findForward("error");
            }
            
            int customerId = Integer.parseInt(customerIdStr);
            
            // Get customer details
            Customer customer = customerDAO.findById(customerId);
            if (customer == null) {
                request.setAttribute("errorMessage", "Customer not found with ID: " + customerId);
                return mapping.findForward("error");
            }
            
            // Get customer credit information
            CustomerCredit credit = creditDAO.getCustomerCreditByCustomerId(customerId);
            
            // Set request attributes
            request.setAttribute("customer", customer);
            request.setAttribute("customerCredit", credit);
            request.setAttribute("mode", "display");
            
            // Add credit analysis data
            if (credit != null) {
                request.setAttribute("creditUtilization", credit.getCreditUtilization());
                request.setAttribute("creditStatus", credit.getCreditStatus());
                request.setAttribute("riskLevel", credit.getRiskLevel());
                request.setAttribute("limitIncreaseRecommended", credit.isLimitIncreaseRecommended());
            }
            
            System.out.println("Displaying credit info for customer ID: " + customerId);
            
            return mapping.findForward("success");
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            return mapping.findForward("error");
        } catch (Exception e) {
            System.err.println("Error displaying credit info: " + e.getMessage());
            request.setAttribute("errorMessage", "Error retrieving credit information");
            return mapping.findForward("error");
        }
    }
    
    /**
     * Update credit limit for a customer
     */
    private ActionForward updateCreditLimit(ActionMapping mapping, HttpServletRequest request,
                                          CustomerDAO customerDAO, CustomerCreditDAO creditDAO,
                                          String customerIdStr) {
        
        try {
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Customer ID is required");
                return mapping.findForward("error");
            }
            
            int customerId = Integer.parseInt(customerIdStr);
            
            String newLimitStr = request.getParameter("newCreditLimit");
            String creditOfficer = request.getParameter("creditOfficer");
            
            if (newLimitStr == null || newLimitStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "New credit limit is required");
                return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            }
            
            BigDecimal newLimit = new BigDecimal(newLimitStr);
            
            if (newLimit.compareTo(BigDecimal.ZERO) < 0) {
                request.setAttribute("errorMessage", "Credit limit cannot be negative");
                return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            }
            
            // Update credit limit
            boolean success = creditDAO.updateCreditLimit(customerId, newLimit, creditOfficer);
            
            if (success) {
                request.setAttribute("successMessage", 
                    "Credit limit updated successfully to " + String.format("$%,.2f", newLimit));
                System.out.println("Credit limit updated for customer " + customerId + " to " + newLimit);
            } else {
                request.setAttribute("errorMessage", "Failed to update credit limit");
            }
            
            // Redirect back to display
            return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format");
            return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
        } catch (Exception e) {
            System.err.println("Error updating credit limit: " + e.getMessage());
            request.setAttribute("errorMessage", "Error updating credit limit");
            return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
        }
    }
    
    /**
     * Update risk assessment for a customer
     */
    private ActionForward updateRiskAssessment(ActionMapping mapping, HttpServletRequest request,
                                             CustomerDAO customerDAO, CustomerCreditDAO creditDAO,
                                             String customerIdStr) {
        
        try {
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Customer ID is required");
                return mapping.findForward("error");
            }
            
            int customerId = Integer.parseInt(customerIdStr);
            
            String riskScoreStr = request.getParameter("riskScore");
            String creditRating = request.getParameter("creditRating");
            String creditOfficer = request.getParameter("creditOfficer");
            
            if (riskScoreStr == null || riskScoreStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Risk score is required");
                return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            }
            
            int riskScore = Integer.parseInt(riskScoreStr);
            
            if (riskScore < 0 || riskScore > 100) {
                request.setAttribute("errorMessage", "Risk score must be between 0 and 100");
                return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            }
            
            if (creditRating == null || creditRating.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Credit rating is required");
                return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            }
            
            // Update risk assessment
            boolean success = creditDAO.updateRiskAssessment(customerId, riskScore, 
                                                           creditRating, creditOfficer);
            
            if (success) {
                request.setAttribute("successMessage", 
                    "Risk assessment updated successfully (Score: " + riskScore + ", Rating: " + creditRating + ")");
                System.out.println("Risk assessment updated for customer " + customerId + 
                                 " - Score: " + riskScore + ", Rating: " + creditRating);
            } else {
                request.setAttribute("errorMessage", "Failed to update risk assessment");
            }
            
            // Redirect back to display
            return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format for risk score");
            return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
        } catch (Exception e) {
            System.err.println("Error updating risk assessment: " + e.getMessage());
            request.setAttribute("errorMessage", "Error updating risk assessment");
            return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
        }
    }
    
    /**
     * Create new credit profile for a customer
     */
    private ActionForward createCreditProfile(ActionMapping mapping, HttpServletRequest request,
                                            CustomerDAO customerDAO, CustomerCreditDAO creditDAO,
                                            String customerIdStr) {
        
        try {
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Customer ID is required");
                return mapping.findForward("error");
            }
            
            int customerId = Integer.parseInt(customerIdStr);
            
            // Check if customer exists
            Customer customer = customerDAO.findById(customerId);
            if (customer == null) {
                request.setAttribute("errorMessage", "Customer not found with ID: " + customerId);
                return mapping.findForward("error");
            }
            
            // Check if credit profile already exists
            CustomerCredit existingCredit = creditDAO.getCustomerCreditByCustomerId(customerId);
            if (existingCredit != null) {
                request.setAttribute("errorMessage", "Credit profile already exists for this customer");
                return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            }
            
            String initialLimitStr = request.getParameter("initialCreditLimit");
            String creditOfficer = request.getParameter("creditOfficer");
            
            BigDecimal initialLimit = BigDecimal.ZERO;
            if (initialLimitStr != null && !initialLimitStr.trim().isEmpty()) {
                initialLimit = new BigDecimal(initialLimitStr);
            }
            
            // Create new credit profile
            CustomerCredit newCredit = new CustomerCredit(customerId, initialLimit);
            newCredit.setCreditOfficer(creditOfficer);
            newCredit.setApprovalStatus("PENDING");
            
            int creditId = creditDAO.createCustomerCredit(newCredit);
            
            if (creditId > 0) {
                request.setAttribute("successMessage", "Credit profile created successfully");
                System.out.println("Credit profile created for customer " + customerId + 
                                 " with limit " + initialLimit);
            } else {
                request.setAttribute("errorMessage", "Failed to create credit profile");
            }
            
            // Redirect to display
            return displayCreditInfo(mapping, request, customerDAO, creditDAO, customerIdStr);
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid number format");
            return mapping.findForward("error");
        } catch (Exception e) {
            System.err.println("Error creating credit profile: " + e.getMessage());
            request.setAttribute("errorMessage", "Error creating credit profile");
            return mapping.findForward("error");
        }
    }
    
    /**
     * Display credit management dashboard
     */
    private ActionForward displayCreditDashboard(ActionMapping mapping, HttpServletRequest request,
                                                CustomerDAO customerDAO, CustomerCreditDAO creditDAO) {
        
        try {
            // Get high-value customers
            BigDecimal highLimitThreshold = new BigDecimal("100000"); // $100K+
            List<CustomerCredit> highValueCustomers = creditDAO.getCustomersWithCreditAbove(highLimitThreshold);
            
            // Get customers requiring review
            List<CustomerCredit> reviewRequired = creditDAO.getCustomersRequiringReview();
            
            // Get customers by rating categories
            List<CustomerCredit> highRiskCustomers = creditDAO.getCustomersByRating("D");
            List<CustomerCredit> excellentCustomers = creditDAO.getCustomersByRating("AAA");
            
            // Get total credit exposure
            BigDecimal totalExposure = creditDAO.getTotalCreditExposure();
            
            // Set dashboard attributes
            request.setAttribute("highValueCustomers", highValueCustomers);
            request.setAttribute("reviewRequired", reviewRequired);
            request.setAttribute("highRiskCustomers", highRiskCustomers);
            request.setAttribute("excellentCustomers", excellentCustomers);
            request.setAttribute("totalExposure", totalExposure);
            
            // Set summary statistics
            request.setAttribute("highValueCount", highValueCustomers.size());
            request.setAttribute("reviewRequiredCount", reviewRequired.size());
            request.setAttribute("highRiskCount", highRiskCustomers.size());
            request.setAttribute("excellentCount", excellentCustomers.size());
            
            System.out.println("Credit dashboard loaded:");
            System.out.println("  High-value customers: " + highValueCustomers.size());
            System.out.println("  Reviews required: " + reviewRequired.size());
            System.out.println("  Total exposure: $" + totalExposure);
            
            return mapping.findForward("dashboard");
            
        } catch (Exception e) {
            System.err.println("Error loading credit dashboard: " + e.getMessage());
            request.setAttribute("errorMessage", "Error loading credit dashboard");
            return mapping.findForward("error");
        }
    }
}