package com.creditcontrol.servlet;

import com.creditcontrol.dao.DatabaseConnection;
import com.creditcontrol.dao.CustomerDAO;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

/**
 * Health Check Servlet for Legacy Credit Control System
 * Provides system health information and database connectivity status
 */
public class HealthCheckServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        // Start HTML response
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head>");
        out.println("<title>Legacy Credit Control - System Health Check</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }");
        out.println(".health-container { background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }");
        out.println(".status-ok { color: #28a745; font-weight: bold; }");
        out.println(".status-error { color: #dc3545; font-weight: bold; }");
        out.println(".status-warning { color: #ffc107; font-weight: bold; }");
        out.println("table { width: 100%; border-collapse: collapse; margin-top: 20px; }");
        out.println("th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }");
        out.println("th { background-color: #003366; color: white; }");
        out.println(".info-section { margin-top: 30px; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        
        out.println("<div class='health-container'>");
        out.println("<h1>Legacy Credit Control System - Health Check</h1>");
        out.println("<p><strong>Timestamp:</strong> " + new Date() + "</p>");
        
        // Database connectivity test
        out.println("<div class='info-section'>");
        out.println("<h2>Database Connectivity</h2>");
        
        boolean dbHealthy = false;
        String dbStatus = "";
        String connectionPoolStatus = "";
        int customerCount = 0;
        
        try {
            DatabaseConnection dbConn = DatabaseConnection.getInstance();
            dbHealthy = dbConn.testConnection() && dbConn.performHealthCheck();
            connectionPoolStatus = dbConn.getConnectionPoolStatus();
            
            if (dbHealthy) {
                dbStatus = "<span class='status-ok'>✓ CONNECTED</span>";
                
                // Test customer DAO
                CustomerDAO customerDAO = new CustomerDAO();
                customerCount = customerDAO.getCustomerCount();
                
            } else {
                dbStatus = "<span class='status-error'>✗ CONNECTION FAILED</span>";
            }
            
        } catch (Exception e) {
            dbStatus = "<span class='status-error'>✗ ERROR: " + e.getMessage() + "</span>";
        }
        
        out.println("<table>");
        out.println("<tr><th>Component</th><th>Status</th><th>Details</th></tr>");
        out.println("<tr><td>Database Connection</td><td>" + dbStatus + "</td><td>PostgreSQL creditcontrol@localhost:5432</td></tr>");
        out.println("<tr><td>Connection Pool</td><td>" + 
                   (dbHealthy ? "<span class='status-ok'>HEALTHY</span>" : "<span class='status-error'>UNAVAILABLE</span>") + 
                   "</td><td>" + connectionPoolStatus + "</td></tr>");
        out.println("<tr><td>Customer Records</td><td>" + 
                   (customerCount > 0 ? "<span class='status-ok'>" + customerCount + " ACTIVE</span>" : "<span class='status-warning'>NO DATA</span>") + 
                   "</td><td>Active customers in database</td></tr>");
        out.println("</table>");
        out.println("</div>");
        
        // Application server info
        out.println("<div class='info-section'>");
        out.println("<h2>Application Server Information</h2>");
        out.println("<table>");
        out.println("<tr><th>Property</th><th>Value</th></tr>");
        out.println("<tr><td>Java Version</td><td>" + System.getProperty("java.version") + "</td></tr>");
        out.println("<tr><td>Java Vendor</td><td>" + System.getProperty("java.vendor") + "</td></tr>");
        out.println("<tr><td>Operating System</td><td>" + System.getProperty("os.name") + " " + System.getProperty("os.version") + "</td></tr>");
        out.println("<tr><td>Server Info</td><td>" + getServletContext().getServerInfo() + "</td></tr>");
        out.println("<tr><td>Servlet Context</td><td>" + getServletContext().getContextPath() + "</td></tr>");
        out.println("<tr><td>Available Memory</td><td>" + (Runtime.getRuntime().totalMemory() / (1024 * 1024)) + " MB</td></tr>");
        out.println("<tr><td>Free Memory</td><td>" + (Runtime.getRuntime().freeMemory() / (1024 * 1024)) + " MB</td></tr>");
        out.println("</table>");
        out.println("</div>");
        
        // Service endpoints
        out.println("<div class='info-section'>");
        out.println("<h2>Service Endpoints</h2>");
        out.println("<table>");
        out.println("<tr><th>Service</th><th>Port</th><th>URL</th></tr>");
        out.println("<tr><td>Main Application</td><td>4000</td><td><a href='http://35.77.54.203:4000/'>http://35.77.54.203:4000/</a></td></tr>");
        out.println("<tr><td>DB Monitor</td><td>4001</td><td><a href='http://35.77.54.203:4001/health'>http://35.77.54.203:4001/health</a></td></tr>");
        out.println("<tr><td>Batch Status</td><td>4002</td><td><a href='http://35.77.54.203:4002/health'>http://35.77.54.203:4002/health</a></td></tr>");
        out.println("</table>");
        out.println("</div>");
        
        // Overall system status
        out.println("<div class='info-section'>");
        out.println("<h2>Overall System Status</h2>");
        String overallStatus;
        if (dbHealthy && customerCount > 0) {
            overallStatus = "<span class='status-ok'>✓ ALL SYSTEMS OPERATIONAL</span>";
        } else if (dbHealthy) {
            overallStatus = "<span class='status-warning'>⚠ SYSTEM FUNCTIONAL - LIMITED DATA</span>";
        } else {
            overallStatus = "<span class='status-error'>✗ SYSTEM DEGRADED - DATABASE ISSUES</span>";
        }
        
        out.println("<h3>" + overallStatus + "</h3>");
        out.println("<p><em>Legacy Credit Control System - Phase 1 Implementation</em></p>");
        out.println("<p><em>Milestone 2: Database Schema and Models - Testing Phase</em></p>");
        out.println("</div>");
        
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
        
        out.close();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}