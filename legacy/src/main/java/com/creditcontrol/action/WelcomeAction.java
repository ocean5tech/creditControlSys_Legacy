package com.creditcontrol.action;

import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.creditcontrol.dao.CustomerDAO;
import com.creditcontrol.dao.DatabaseConnection;

/**
 * Welcome Action for Legacy Credit Control System
 * Displays system status and basic metrics on the welcome page
 */
public class WelcomeAction extends Action {
    
    /**
     * Execute the action
     */
    public ActionForward execute(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response)
            throws Exception {
        
        try {
            // Get system information for display
            DatabaseConnection dbConn = DatabaseConnection.getInstance();
            CustomerDAO customerDAO = new CustomerDAO();
            
            // Test database connectivity
            boolean dbHealthy = dbConn.testConnection();
            String connectionStatus = dbConn.getConnectionPoolStatus();
            
            // Get basic statistics
            int totalCustomers = 0;
            if (dbHealthy) {
                totalCustomers = customerDAO.getCustomerCount();
            }
            
            // Set request attributes for JSP display
            request.setAttribute("systemName", "Legacy Credit Control System");
            request.setAttribute("systemVersion", "1.0 (Phase 1 - Legacy Implementation)");
            request.setAttribute("buildDate", new java.util.Date());
            request.setAttribute("databaseHealthy", dbHealthy);
            request.setAttribute("connectionStatus", connectionStatus);
            request.setAttribute("totalCustomers", totalCustomers);
            request.setAttribute("serverInfo", getServlet().getServletContext().getServerInfo());
            request.setAttribute("javaVersion", System.getProperty("java.version"));
            
            // System status summary
            String systemStatus;
            if (dbHealthy && totalCustomers > 0) {
                systemStatus = "ALL SYSTEMS OPERATIONAL";
            } else if (dbHealthy) {
                systemStatus = "SYSTEM FUNCTIONAL - LIMITED DATA";
            } else {
                systemStatus = "SYSTEM DEGRADED - DATABASE ISSUES";
            }
            request.setAttribute("systemStatus", systemStatus);
            
            // Navigation menu items
            String[] menuItems = {
                "Customer Search|/customerSearch.do",
                "Customer Management|/customer/customer-search.jsp",
                "Credit Dashboard|/creditLimit.do?action=dashboard",
                "Credit Management|/creditLimit.do",
                "Risk Assessment|/riskDashboard.do", 
                "Payment Tracking|/paymentTracking.do",
                "Collections Management|/collections.do"
            };
            request.setAttribute("menuItems", menuItems);
            
            // Recent activity (placeholder for now)
            String[] recentActivity = {
                "System startup completed successfully",
                "Database connection established", 
                "Customer data loaded (" + totalCustomers + " active customers)",
                "Application ready for operations"
            };
            request.setAttribute("recentActivity", recentActivity);
            
            System.out.println("WelcomeAction executed successfully");
            System.out.println("Database Status: " + (dbHealthy ? "Connected" : "Disconnected"));
            System.out.println("Total Customers: " + totalCustomers);
            
            return mapping.findForward("success");
            
        } catch (Exception e) {
            System.err.println("Error in WelcomeAction: " + e.getMessage());
            e.printStackTrace();
            
            // Set error information
            request.setAttribute("errorMessage", "System initialization error: " + e.getMessage());
            request.setAttribute("systemStatus", "SYSTEM ERROR");
            request.setAttribute("databaseHealthy", false);
            request.setAttribute("totalCustomers", 0);
            
            // Still forward to success page to show error status
            return mapping.findForward("success");
        }
    }
}