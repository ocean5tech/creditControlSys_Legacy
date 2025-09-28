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
import com.creditcontrol.form.CustomerForm;
import com.creditcontrol.model.Customer;
import com.creditcontrol.model.CustomerCredit;

/**
 * CustomerDetailsAction for Legacy Credit Control System
 * Handles customer details display, editing, and credit information
 */
public class CustomerDetailsAction extends Action {
    
    /**
     * Execute the customer details action
     */
    public ActionForward execute(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response)
            throws Exception {
        
        try {
            CustomerForm customerForm = (CustomerForm) form;
            CustomerDAO customerDAO = new CustomerDAO();
            CustomerCreditDAO creditDAO = new CustomerCreditDAO();
            
            // Get action parameter
            String action = request.getParameter("action");
            if (action == null) action = "display";
            
            String customerId = request.getParameter("customerId");
            
            switch (action) {
                case "display":
                    return displayCustomer(mapping, customerForm, request, customerDAO, creditDAO, customerId);
                    
                case "edit":
                    return editCustomer(mapping, customerForm, request, customerDAO, creditDAO, customerId);
                    
                case "save":
                    return saveCustomer(mapping, customerForm, request, customerDAO, customerId);
                    
                case "delete":
                    return deleteCustomer(mapping, request, customerDAO, customerId);
                    
                default:
                    return displayCustomer(mapping, customerForm, request, customerDAO, creditDAO, customerId);
            }
            
        } catch (Exception e) {
            System.err.println("Error in CustomerDetailsAction: " + e.getMessage());
            e.printStackTrace();
            
            ActionMessages errors = new ActionMessages();
            errors.add("detailsError", new ActionMessage("error.customer.details.failed"));
            request.setAttribute("errorMessages", errors);
            
            return mapping.findForward("error");
        }
    }
    
    /**
     * Display customer details
     */
    private ActionForward displayCustomer(ActionMapping mapping, CustomerForm customerForm,
                                        HttpServletRequest request, CustomerDAO customerDAO,
                                        CustomerCreditDAO creditDAO, String customerIdStr) {
        
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
            
            // Populate form with customer data
            populateFormFromCustomer(customerForm, customer);
            
            // Set request attributes
            request.setAttribute("customer", customer);
            request.setAttribute("customerCredit", credit);
            request.setAttribute("mode", "display");
            
            System.out.println("Displaying customer details for ID: " + customerId);
            
            return mapping.findForward("success");
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            return mapping.findForward("error");
        } catch (Exception e) {
            System.err.println("Error displaying customer: " + e.getMessage());
            request.setAttribute("errorMessage", "Error retrieving customer details");
            return mapping.findForward("error");
        }
    }
    
    /**
     * Edit customer details
     */
    private ActionForward editCustomer(ActionMapping mapping, CustomerForm customerForm,
                                     HttpServletRequest request, CustomerDAO customerDAO,
                                     CustomerCreditDAO creditDAO, String customerIdStr) {
        
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
            
            // Populate form with customer data for editing
            populateFormFromCustomer(customerForm, customer);
            customerForm.setAction("save");
            
            // Set request attributes
            request.setAttribute("customer", customer);
            request.setAttribute("customerCredit", credit);
            request.setAttribute("mode", "edit");
            
            // Get industry list for dropdown
            request.setAttribute("industries", customerDAO.getAllIndustries());
            
            System.out.println("Editing customer details for ID: " + customerId);
            
            return mapping.findForward("success");
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            return mapping.findForward("error");
        } catch (Exception e) {
            System.err.println("Error preparing customer edit: " + e.getMessage());
            request.setAttribute("errorMessage", "Error preparing customer for editing");
            return mapping.findForward("error");
        }
    }
    
    /**
     * Save customer changes
     */
    private ActionForward saveCustomer(ActionMapping mapping, CustomerForm customerForm,
                                     HttpServletRequest request, CustomerDAO customerDAO,
                                     String customerIdStr) {
        
        try {
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Customer ID is required");
                return mapping.findForward("error");
            }
            
            int customerId = Integer.parseInt(customerIdStr);
            
            // Create customer object from form data
            Customer customer = new Customer();
            populateCustomerFromForm(customer, customerForm);
            customer.setCustomerId(customerId);
            
            // Update customer in database
            boolean success = customerDAO.updateCustomer(customer);
            
            if (success) {
                request.setAttribute("successMessage", "Customer updated successfully");
                System.out.println("Customer updated successfully: " + customerId);
                
                // Redirect to display mode
                return displayCustomer(mapping, customerForm, request, customerDAO, 
                                     new CustomerCreditDAO(), customerIdStr);
            } else {
                request.setAttribute("errorMessage", "Failed to update customer");
                return mapping.findForward("error");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            return mapping.findForward("error");
        } catch (Exception e) {
            System.err.println("Error saving customer: " + e.getMessage());
            request.setAttribute("errorMessage", "Error saving customer changes");
            return mapping.findForward("error");
        }
    }
    
    /**
     * Delete (deactivate) customer
     */
    private ActionForward deleteCustomer(ActionMapping mapping, HttpServletRequest request,
                                       CustomerDAO customerDAO, String customerIdStr) {
        
        try {
            if (customerIdStr == null || customerIdStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Customer ID is required");
                return mapping.findForward("error");
            }
            
            int customerId = Integer.parseInt(customerIdStr);
            
            // Deactivate customer (soft delete)
            boolean success = customerDAO.deactivateCustomer(customerId);
            
            if (success) {
                request.setAttribute("successMessage", "Customer deactivated successfully");
                System.out.println("Customer deactivated successfully: " + customerId);
                return mapping.findForward("deleted");
            } else {
                request.setAttribute("errorMessage", "Failed to deactivate customer");
                return mapping.findForward("error");
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid customer ID format");
            return mapping.findForward("error");
        } catch (Exception e) {
            System.err.println("Error deleting customer: " + e.getMessage());
            request.setAttribute("errorMessage", "Error deactivating customer");
            return mapping.findForward("error");
        }
    }
    
    /**
     * Populate form from customer object
     */
    private void populateFormFromCustomer(CustomerForm form, Customer customer) {
        form.setCustomerId(String.valueOf(customer.getCustomerId()));
        form.setCustomerCode(customer.getCustomerCode());
        form.setCompanyName(customer.getCompanyName());
        form.setContactPerson(customer.getContactPerson());
        form.setPhone(customer.getPhone());
        form.setEmail(customer.getEmail());
        form.setAddress(customer.getAddress());
        form.setIndustry(customer.getIndustry());
        form.setRegistrationNumber(customer.getRegistrationNumber());
        form.setStatus(customer.getStatus());
    }
    
    /**
     * Populate customer object from form
     */
    private void populateCustomerFromForm(Customer customer, CustomerForm form) {
        customer.setCustomerCode(form.getCustomerCode());
        customer.setCompanyName(form.getCompanyName());
        customer.setContactPerson(form.getContactPerson());
        customer.setPhone(form.getPhone());
        customer.setEmail(form.getEmail());
        customer.setAddress(form.getAddress());
        customer.setIndustry(form.getIndustry());
        customer.setRegistrationNumber(form.getRegistrationNumber());
        customer.setStatus(form.getStatus());
    }
}