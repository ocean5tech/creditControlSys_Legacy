<%-- Customer Details Page --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.sql.*, java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Customer Credit Details - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .customer-header { background: #f8f9fa; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #007bff; }
        .details-section { background: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .details-table { width: 100%; border-collapse: collapse; }
        .details-table th, .details-table td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; }
        .details-table th { background: #f8f9fa; font-weight: bold; width: 30%; }
        .risk-indicator { padding: 5px 10px; border-radius: 3px; color: white; font-weight: bold; }
        .risk-low { background: #28a745; }
        .risk-medium { background: #ffc107; color: #000; }
        .risk-high { background: #fd7e14; }
        .risk-very-high { background: #dc3545; }
        .credit-rating { font-size: 18px; font-weight: bold; padding: 5px 10px; border-radius: 3px; }
        .rating-aaa, .rating-aa { background: #d4edda; color: #155724; }
        .rating-a, .rating-bbb { background: #fff3cd; color: #856404; }
        .rating-bb, .rating-b { background: #f8d7da; color: #721c24; }
        .rating-c { background: #f5c6cb; color: #721c24; }
        .action-buttons { margin: 20px 0; }
        .action-buttons a { display: inline-block; padding: 10px 15px; margin: 5px; text-decoration: none; border-radius: 3px; }
        .btn-primary { background: #007bff; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-success { background: #28a745; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; margin: 15px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Customer Credit Details - Core Business Function</p>
    </div>
    
    <div id="main-content">
        <%
        String customerCode = request.getParameter("customerCode");
        if (customerCode == null || customerCode.trim().isEmpty()) {
            customerCode = "CUST001";
        }
        
        // Database connection to fetch real customer data
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        String companyName = "";
        String contactPerson = "";
        String industry = "";
        String phone = "";
        String email = "";
        String status = "";
        String creditRating = "";
        BigDecimal creditLimit = BigDecimal.ZERO;
        BigDecimal availableCredit = BigDecimal.ZERO;
        int riskScore = 0;
        String riskLevel = "";
        String errorMessage = null;
        BigDecimal outstandingBalance = BigDecimal.ZERO;
        
        try {
            // Database connection
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://172.31.19.10:5432/creditcontrol", "creditapp", "secure123");
            
            // Query customer and credit information
            String sql = "SELECT c.customer_id, c.customer_code, c.company_name, c.contact_person, c.phone, c.email, c.industry, c.status, " +
                        "cc.credit_limit, cc.available_credit, cc.credit_rating, cc.risk_score " +
                        "FROM customers c " +
                        "LEFT JOIN customer_credit cc ON c.customer_id = cc.customer_id " +
                        "WHERE c.customer_code = ?";
            
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, customerCode);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                companyName = rs.getString("company_name");
                contactPerson = rs.getString("contact_person");
                industry = rs.getString("industry");
                phone = rs.getString("phone");
                email = rs.getString("email");
                status = rs.getString("status");
                creditRating = rs.getString("credit_rating");
                creditLimit = rs.getBigDecimal("credit_limit");
                availableCredit = rs.getBigDecimal("available_credit");
                riskScore = rs.getInt("risk_score");
                
                // Calculate outstanding balance
                if (creditLimit != null && availableCredit != null) {
                    outstandingBalance = creditLimit.subtract(availableCredit);
                }
                
                // Determine risk level based on score
                if (riskScore <= 30) {
                    riskLevel = "LOW";
                } else if (riskScore <= 50) {
                    riskLevel = "MEDIUM";
                } else if (riskScore <= 70) {
                    riskLevel = "HIGH";
                } else {
                    riskLevel = "VERY_HIGH";
                }
            } else {
                errorMessage = "Customer not found: " + customerCode;
            }
            
        } catch (Exception e) {
            errorMessage = "Database error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        %>
        
        <% if (errorMessage != null) { %>
            <div class="error">
                <strong>Error:</strong> <%= errorMessage %>
                <p><a href="../customer-search-working.jsp">Return to Customer Search</a></p>
            </div>
        <% } else { %>
        
        <div class="customer-header">
            <h2><%= companyName %> (<%= customerCode %>)</h2>
            <p><strong>Credit Rating:</strong> <span class="credit-rating rating-<%= creditRating != null ? creditRating.toLowerCase() : "" %>"><%= creditRating %></span></p>
            <p><strong>Risk Level:</strong> 
                <span class="risk-indicator risk-<%= riskLevel.toLowerCase().replace("_", "-") %>">
                    <%= riskLevel %> (<%= riskScore %>/100)
                </span>
            </p>
        </div>
        
        <div class="details-section">
            <h3>Basic Information</h3>
            <table class="details-table">
                <tr><th>Customer Code</th><td><%= customerCode %></td></tr>
                <tr><th>Company Name</th><td><%= companyName %></td></tr>
                <tr><th>Contact Person</th><td><%= contactPerson %></td></tr>
                <tr><th>Industry</th><td><%= industry %></td></tr>
                <tr><th>Phone</th><td><%= phone %></td></tr>
                <tr><th>Email</th><td><%= email %></td></tr>
                <tr><th>Status</th><td><%= status %></td></tr>
            </table>
        </div>
        
        <div class="details-section">
            <h3>Credit Information</h3>
            <table class="details-table">
                <tr><th>Credit Limit</th><td>$<%= creditLimit != null ? String.format("%,.2f", creditLimit) : "0.00" %></td></tr>
                <tr><th>Outstanding Balance</th><td>$<%= String.format("%,.2f", outstandingBalance) %></td></tr>
                <tr><th>Available Credit</th><td>$<%= availableCredit != null ? String.format("%,.2f", availableCredit) : "0.00" %></td></tr>
                <tr><th>Credit Rating</th><td><%= creditRating %></td></tr>
                <tr><th>Risk Score</th><td><%= riskScore %>/100</td></tr>
            </table>
        </div>
        
        <div class="details-section">
            <h3>Risk Assessment</h3>
            <% if ("LOW".equals(riskLevel)) { %>
                <p>Customer has excellent credit history with stable payment patterns. Current credit utilization is well within acceptable limits. Recommended to maintain current credit policies.</p>
            <% } else if ("MEDIUM".equals(riskLevel)) { %>
                <p>Customer shows moderate risk factors. Regular monitoring is recommended. Consider periodic review of credit terms and payment history.</p>
            <% } else if ("HIGH".equals(riskLevel)) { %>
                <p>Customer exhibits higher risk characteristics. Enhanced monitoring required. Consider tightening credit terms or requiring additional security.</p>
            <% } else { %>
                <p>Customer poses very high risk. Immediate review required. Consider credit limit reduction or suspension of credit facilities.</p>
            <% } %>
        </div>
        
        <div class="action-buttons">
            <a href="credit-limit-modify.jsp?customerCode=<%= customerCode %>" class="btn-warning">Modify Credit Limit</a>
            <a href="../risk/risk-assessment.jsp?customerCode=<%= customerCode %>" class="btn-primary">Risk Assessment</a>
            <a href="../payment/payment-tracking.jsp?customerCode=<%= customerCode %>" class="btn-success">Payment Tracking</a>
            <a href="../customer-search-working.jsp" class="btn-secondary">Back to Search</a>
        </div>
        
        <% } %>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Customer Details - Real Database Integration (PostgreSQL)</p>
    </div>
</body>
</html>