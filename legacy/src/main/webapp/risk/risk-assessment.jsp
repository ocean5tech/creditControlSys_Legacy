<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.sql.*, java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Risk Assessment Dashboard - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .dashboard-header { background: #e3f2fd; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #2196f3; }
        .risk-summary { background: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .risk-metrics { display: flex; flex-wrap: wrap; gap: 15px; margin: 20px 0; }
        .metric-card { flex: 1; min-width: 200px; background: white; border: 1px solid #ddd; padding: 15px; border-radius: 3px; text-align: center; }
        .metric-value { font-size: 24px; font-weight: bold; margin: 10px 0; }
        .metric-label { color: #666; font-size: 12px; }
        .risk-low { color: #28a745; }
        .risk-medium { color: #ffc107; }
        .risk-high { color: #fd7e14; }
        .risk-very-high { color: #dc3545; }
        .assessment-details { background: #f8f9fa; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .details-table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        .details-table th, .details-table td { padding: 8px; text-align: left; border-bottom: 1px solid #eee; }
        .details-table th { background: #f8f9fa; font-weight: bold; }
        .progress-bar { width: 100%; height: 20px; background: #e9ecef; border-radius: 10px; overflow: hidden; }
        .progress-fill { height: 100%; border-radius: 10px; transition: width 0.5s ease; }
        .chart-container { background: white; border: 1px solid #ddd; padding: 20px; margin: 15px 0; border-radius: 3px; }
        .action-buttons { margin: 20px 0; text-align: center; }
        .btn { display: inline-block; padding: 10px 20px; margin: 5px; text-decoration: none; border-radius: 3px; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-secondary { background: #6c757d; color: white; }
        .customers-table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        .customers-table th, .customers-table td { padding: 8px; border: 1px solid #ddd; text-align: left; }
        .customers-table th { background: #f8f9fa; }
        .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; margin: 15px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Risk Assessment Dashboard - Core Business Function 4</p>
    </div>
    
    <div id="main-content">
        <%
        String customerCode = request.getParameter("customerCode");
        if (customerCode == null || customerCode.isEmpty()) {
            customerCode = "CUST001";
        }
        
        // Real database connection and operations
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Map<String, Object>> customerRiskData = new ArrayList<>();
        String errorMessage = null;
        
        int totalLowRisk = 0, totalMediumRisk = 0, totalHighRisk = 0, totalVeryHighRisk = 0;
        
        try {
            // Database connection
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://35.77.54.203:5432/creditcontrol", "creditapp", "secure123");
            
            // Query all customers with their risk assessments
            String sql = "SELECT c.customer_code, c.company_name, c.industry, " +
                        "cc.credit_limit, cc.available_credit, cc.credit_rating, cc.risk_score " +
                        "FROM customers c " +
                        "LEFT JOIN customer_credit cc ON c.customer_id = cc.customer_id " +
                        "ORDER BY c.customer_code";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> custData = new HashMap<>();
                custData.put("customerCode", rs.getString("customer_code"));
                custData.put("companyName", rs.getString("company_name"));
                custData.put("creditRating", rs.getString("credit_rating"));
                custData.put("industry", rs.getString("industry"));
                custData.put("creditLimit", rs.getBigDecimal("credit_limit"));
                custData.put("availableCredit", rs.getBigDecimal("available_credit"));
                
                // Calculate outstanding balance
                BigDecimal creditLimit = rs.getBigDecimal("credit_limit");
                BigDecimal availableCredit = rs.getBigDecimal("available_credit");
                BigDecimal outstandingBalance = BigDecimal.ZERO;
                if (creditLimit != null && availableCredit != null) {
                    outstandingBalance = creditLimit.subtract(availableCredit);
                }
                custData.put("outstandingBalance", outstandingBalance);
                
                int riskScore = rs.getInt("risk_score");
                custData.put("riskScore", riskScore);
                
                // Determine risk level based on score
                String riskLevel;
                if (riskScore <= 30) {
                    riskLevel = "LOW";
                    totalLowRisk++;
                } else if (riskScore <= 50) {
                    riskLevel = "MEDIUM";
                    totalMediumRisk++;
                } else if (riskScore <= 70) {
                    riskLevel = "HIGH";
                    totalHighRisk++;
                } else {
                    riskLevel = "VERY_HIGH";
                    totalVeryHighRisk++;
                }
                custData.put("riskLevel", riskLevel);
                
                customerRiskData.add(custData);
            }
            
        } catch (Exception e) {
            errorMessage = "Database error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        
        // Find current selected customer's assessment results
        Map<String, Object> currentAssessment = null;
        for (Map<String, Object> assessment : customerRiskData) {
            if (customerCode.equals(assessment.get("customerCode"))) {
                currentAssessment = assessment;
                break;
            }
        }
        %>
        
        <% if (errorMessage != null) { %>
            <div class="error">
                <strong>Error:</strong> <%= errorMessage %>
            </div>
        <% } else { %>
        
        <!-- Dashboard Header -->
        <div class="dashboard-header">
            <h2>Risk Assessment Dashboard</h2>
            <% if (currentAssessment != null) { %>
                <p><strong>Current Analysis Customer:</strong> <%= currentAssessment.get("companyName") %> (<%= customerCode %>)</p>
            <% } else { %>
                <p><strong>Customer:</strong> <%= customerCode %> (Not Found)</p>
            <% } %>
        </div>
        
        <!-- Risk Metrics Overview -->
        <div class="risk-metrics">
            <div class="metric-card">
                <div class="metric-value risk-low"><%= totalLowRisk %></div>
                <div class="metric-label">Low Risk Customers</div>
            </div>
            <div class="metric-card">
                <div class="metric-value risk-medium"><%= totalMediumRisk %></div>
                <div class="metric-label">Medium Risk Customers</div>
            </div>
            <div class="metric-card">
                <div class="metric-value risk-high"><%= totalHighRisk %></div>
                <div class="metric-label">High Risk Customers</div>
            </div>
            <div class="metric-card">
                <div class="metric-value risk-very-high"><%= totalVeryHighRisk %></div>
                <div class="metric-label">Very High Risk Customers</div>
            </div>
        </div>
        
        <% if (currentAssessment != null) { %>
        <!-- Current Customer Risk Analysis -->
        <div class="risk-summary">
            <h3>Current Customer Risk Analysis</h3>
            <div class="assessment-details">
                <p><strong>Overall Risk Score:</strong> 
                    <span class="metric-value risk-<%= ((String)currentAssessment.get("riskLevel")).toLowerCase().replace("_", "-") %>">
                        <%= currentAssessment.get("riskScore") %>/100 (<%= currentAssessment.get("riskLevel") %>)
                    </span>
                </p>
                
                <div class="progress-bar">
                    <div class="progress-fill risk-<%= ((String)currentAssessment.get("riskLevel")).toLowerCase().replace("_", "-") %>" 
                         style="width: <%= currentAssessment.get("riskScore") %>%; background-color: 
                         <% String level = (String)currentAssessment.get("riskLevel");
                            if ("LOW".equals(level)) out.print("#28a745");
                            else if ("MEDIUM".equals(level)) out.print("#ffc107");
                            else if ("HIGH".equals(level)) out.print("#fd7e14");
                            else out.print("#dc3545");
                         %>;"></div>
                </div>
                
                <div style="margin-top: 20px;">
                    <h4>Risk Management Recommendation:</h4>
                    <% String riskLevel = (String)currentAssessment.get("riskLevel"); %>
                    <% if ("LOW".equals(riskLevel)) { %>
                        <p>Customer has excellent credit profile with stable payment patterns. Current credit utilization is well within acceptable limits. Recommended to maintain current credit policies.</p>
                    <% } else if ("MEDIUM".equals(riskLevel)) { %>
                        <p>Customer shows moderate risk factors. Regular monitoring is recommended. Consider periodic review of credit terms and payment history.</p>
                    <% } else if ("HIGH".equals(riskLevel)) { %>
                        <p>Customer exhibits higher risk characteristics. Enhanced monitoring required. Consider tightening credit terms or requiring additional security.</p>
                    <% } else { %>
                        <p>Customer poses very high risk. Immediate review required. Consider credit limit reduction or suspension of credit facilities.</p>
                    <% } %>
                </div>
            </div>
        </div>
        
        <!-- Detailed Risk Analysis -->
        <div class="assessment-details">
            <h3>Detailed Analysis</h3>
            <table class="details-table">
                <tr>
                    <th>Credit Status</th>
                    <td>Credit Rating <%= currentAssessment.get("creditRating") %></td>
                </tr>
                <tr>
                    <th>Credit Utilization</th>
                    <td>
                        <% 
                        BigDecimal creditLimit = (BigDecimal)currentAssessment.get("creditLimit");
                        BigDecimal outstandingBalance = (BigDecimal)currentAssessment.get("outstandingBalance");
                        double utilizationRate = 0;
                        if (creditLimit != null && creditLimit.compareTo(BigDecimal.ZERO) > 0) {
                            utilizationRate = outstandingBalance.divide(creditLimit, 4, BigDecimal.ROUND_HALF_UP).doubleValue() * 100;
                        }
                        %>
                        <%= String.format("%.1f", utilizationRate) %>% 
                        ($<%= String.format("%,.2f", outstandingBalance) %> of $<%= String.format("%,.2f", creditLimit) %>)
                    </td>
                </tr>
                <tr>
                    <th>Industry Risk</th>
                    <td><%= currentAssessment.get("industry") %> Industry</td>
                </tr>
                <tr>
                    <th>Credit Limit</th>
                    <td>$<%= String.format("%,.2f", creditLimit) %></td>
                </tr>
                <tr>
                    <th>Available Credit</th>
                    <td>$<%= String.format("%,.2f", (BigDecimal)currentAssessment.get("availableCredit")) %></td>
                </tr>
            </table>
        </div>
        <% } %>
        
        <!-- All Customers Risk Overview -->
        <div class="chart-container">
            <h3>All Customers Risk Overview</h3>
            <table class="customers-table">
                <thead>
                    <tr>
                        <th>Customer Code</th>
                        <th>Company Name</th>
                        <th>Credit Rating</th>
                        <th>Risk Score</th>
                        <th>Risk Level</th>
                        <th>Credit Limit</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> customer : customerRiskData) { %>
                    <tr>
                        <td><%= customer.get("customerCode") %></td>
                        <td><%= customer.get("companyName") %></td>
                        <td><%= customer.get("creditRating") %></td>
                        <td><%= customer.get("riskScore") %>/100</td>
                        <td><span class="risk-<%= ((String)customer.get("riskLevel")).toLowerCase().replace("_", "-") %>">
                            <%= customer.get("riskLevel") %>
                        </span></td>
                        <td>$<%= String.format("%,.2f", (BigDecimal)customer.get("creditLimit")) %></td>
                        <td>
                            <a href="risk-assessment.jsp?customerCode=<%= customer.get("customerCode") %>" class="btn btn-primary">View</a>
                            <a href="../customer/credit-limit-modify.jsp?customerCode=<%= customer.get("customerCode") %>" class="btn btn-warning">Adjust</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons">
            <a href="../customer-search-working.jsp" class="btn btn-secondary">Customer Search</a>
            <a href="../customer/customer-details.jsp?customerCode=<%= customerCode %>" class="btn btn-primary">Customer Details</a>
            <a href="../payment/payment-tracking.jsp?customerCode=<%= customerCode %>" class="btn btn-success">Payment Tracking</a>
        </div>
        
        <!-- System Information -->
        <div class="assessment-details">
            <p><strong>Risk Assessment Engine:</strong> Database-Integrated Risk Assessment v2.0</p>
            <p><strong>Assessment Time:</strong> <%= new java.util.Date() %></p>
            <p><strong>Assessed Customers:</strong> <%= customerRiskData.size() %></p>
            <p><strong>Database Status:</strong> Connected to PostgreSQL creditcontrol database</p>
        </div>
        
        <% } %>
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Risk Assessment Dashboard - Real Database Integration (PostgreSQL)</p>
    </div>
</body>
</html>