<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.util.*" %>
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
        .recommendation { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; margin: 15px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Risk Assessment Dashboard - Core Business Function 4</p>
    </div>
    
    <div id="main-content">
        <%
        // Get customer parameters
        String customerCode = request.getParameter("customerCode");
        if (customerCode == null || customerCode.isEmpty()) {
            customerCode = "CUST001";
        }
        
        // Mock multiple customer risk assessment data - POC Implementation
        List<Map<String, Object>> customerRiskData = new ArrayList<>();
        
        // Customer 1 data
        Map<String, Object> cust1 = new HashMap<>();
        cust1.put("customerCode", "CUST001");
        cust1.put("companyName", "ABC Manufacturing Ltd");
        cust1.put("creditRating", "A");
        cust1.put("industry", "Manufacturing");
        cust1.put("creditLimit", new BigDecimal("200000"));
        cust1.put("outstandingBalance", new BigDecimal("45000"));
        cust1.put("riskScore", 35);
        cust1.put("riskLevel", "LOW");
        customerRiskData.add(cust1);
        
        // Customer 2 data
        Map<String, Object> cust2 = new HashMap<>();
        cust2.put("customerCode", "CUST002");
        cust2.put("companyName", "XYZ Trading Corp");
        cust2.put("creditRating", "BBB");
        cust2.put("industry", "Trading");
        cust2.put("creditLimit", new BigDecimal("100000"));
        cust2.put("outstandingBalance", new BigDecimal("75000"));
        cust2.put("riskScore", 72);
        cust2.put("riskLevel", "HIGH");
        customerRiskData.add(cust2);
        
        // Customer 3 data
        Map<String, Object> cust3 = new HashMap<>();
        cust3.put("customerCode", "CUST003");
        cust3.put("companyName", "Global Logistics Inc");
        cust3.put("creditRating", "AA");
        cust3.put("industry", "Logistics");
        cust3.put("creditLimit", new BigDecimal("500000"));
        cust3.put("outstandingBalance", new BigDecimal("125000"));
        cust3.put("riskScore", 25);
        cust3.put("riskLevel", "LOW");
        customerRiskData.add(cust3);
        
        // Simplified risk statistics - POC implementation
        List<Map<String, Object>> riskAssessments = customerRiskData;
        int totalLowRisk = 0, totalMediumRisk = 0, totalHighRisk = 0, totalVeryHighRisk = 0;
        
        for (Map<String, Object> custData : customerRiskData) {
            // Count risk level distribution
            String riskLevel = (String)custData.get("riskLevel");
            if ("LOW".equals(riskLevel)) totalLowRisk++;
            else if ("MEDIUM".equals(riskLevel)) totalMediumRisk++;
            else if ("HIGH".equals(riskLevel)) totalHighRisk++;
            else if ("VERY_HIGH".equals(riskLevel)) totalVeryHighRisk++;
        }
        
        // Find current selected customer's assessment results
        Map<String, Object> currentAssessment = null;
        for (Map<String, Object> assessment : riskAssessments) {
            if (customerCode.equals(assessment.get("customerCode"))) {
                currentAssessment = assessment;
                break;
            }
        }
        
        if (currentAssessment == null) {
            currentAssessment = riskAssessments.get(0); // Default to first one
        }
        
        // Current customer's risk information (simplified version)
        int currentRiskScore = (Integer)currentAssessment.get("riskScore");
        String currentRiskLevel = (String)currentAssessment.get("riskLevel");
        %>
        
        <!-- Dashboard Header -->
        <div class="dashboard-header">
            <h2>Risk Assessment Dashboard</h2>
            <p>Current Analysis Customer: <strong><%= currentAssessment.get("companyName") %> (<%= customerCode %>)</strong></p>
        </div>
        
        <!-- Risk Indicators Overview -->
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
        
        <!-- Current Customer Risk Details -->
        <div class="risk-summary">
            <h3>Current Customer Risk Analysis</h3>
            
            <div class="assessment-details">
                <h4>Comprehensive Risk Score: 
                    <span class="risk-<%= currentRiskLevel.toLowerCase().replace("_", "-") %>">
                        <%= currentRiskScore %>/100 (<%= currentRiskLevel %>)
                    </span>
                </h4>
                
                <div class="progress-bar" style="margin: 15px 0;">
                    <div class="progress-fill" style="width: <%= currentRiskScore %>%; background: 
                        <% if ("LOW".equals(currentRiskLevel)) { %>
                               #28a745
                        <% } else if ("MEDIUM".equals(currentRiskLevel)) { %>
                               #ffc107
                        <% } else if ("HIGH".equals(currentRiskLevel)) { %>
                               #fd7e14
                        <% } else { %>
                               #dc3545
                        <% } %>;">
                    </div>
                </div>
            </div>
            
            <!-- Risk Assessment Recommendations -->
            <div class="recommendation">
                <h4>Risk Management Recommendations:</h4>
                <% if ("LOW".equals(currentRiskLevel)) { %>
                    <p>Customer credit status is good, risk is controllable. Recommend maintaining current credit policy.</p>
                <% } else if ("HIGH".equals(currentRiskLevel)) { %>
                    <p>Customer risk is high, recommend strengthening monitoring and considering credit policy adjustments.</p>
                <% } else { %>
                    <p>Customer risk is at medium level, recommend regular review of credit status.</p>
                <% } %>
                
                <h4>Detailed Analysis:</h4>
                <ul>
                    <li><strong>Credit Status:</strong> Credit Rating <%= currentAssessment.get("creditRating") %></li>
                    <li><strong>Balance Status:</strong> Current Utilization Rate <%= String.format("%.1f", ((BigDecimal)currentAssessment.get("outstandingBalance")).divide((BigDecimal)currentAssessment.get("creditLimit"), 3, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"))) %>%</li>
                    <li><strong>Industry Risk:</strong> <%= currentAssessment.get("industry") %> Industry</li>
                </ul>
            </div>
        </div>
        
        <!-- All Customers Risk Overview -->
        <div class="chart-container">
            <h3>All Customers Risk Overview</h3>
            <table class="details-table">
                <thead>
                    <tr>
                        <th>Customer Code</th>
                        <th>Company Name</th>
                        <th>Credit Rating</th>
                        <th>Risk Score</th>
                        <th>Risk Level</th>
                        <th>Suggested Limit</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> assessment : riskAssessments) { 
                       String code = (String)assessment.get("customerCode");
                       boolean isCurrent = code.equals(customerCode);
                       int assessmentRiskScore = (Integer)assessment.get("riskScore");
                       String assessmentRiskLevel = (String)assessment.get("riskLevel");
                    %>
                    <tr style="<%= isCurrent ? "background: #e3f2fd;" : "" %>">
                        <td><%= code %></td>
                        <td><%= assessment.get("companyName") %></td>
                        <td><%= assessment.get("creditRating") %></td>
                        <td><span class="risk-<%= assessmentRiskLevel.toLowerCase().replace("_", "-") %>"><%= assessmentRiskScore %>/100</span></td>
                        <td><span class="risk-<%= assessmentRiskLevel.toLowerCase().replace("_", "-") %>"><%= assessmentRiskLevel %></span></td>
                        <td>¥200,000</td>
                        <td>
                            <a href="risk-assessment.jsp?customerCode=<%= code %>" class="btn btn-primary" style="padding: 3px 8px; font-size: 12px;">View</a>
                            <a href="../customer/credit-limit-modify.jsp?customerCode=<%= code %>" class="btn btn-warning" style="padding: 3px 8px; font-size: 12px;">Adjust</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Action Buttons -->
        <div class="action-buttons">
            <a href="../customer/customer-details.jsp?customerCode=<%= customerCode %>" class="btn btn-primary">View Customer Details</a>
            <a href="../customer/credit-limit-modify.jsp?customerCode=<%= customerCode %>" class="btn btn-warning">Modify Credit Limit</a>
            <a href="../customer-search-working.jsp" class="btn btn-secondary">Back to Search</a>
        </div>
        
        <!-- System Information -->
        <div class="assessment-details">
            <p><strong>Risk Assessment Engine:</strong> POC Risk Assessment v1.0</p>
            <p><strong>Assessment Time:</strong> <%= new java.util.Date() %></p>
            <p><strong>Assessed Customers:</strong> <%= riskAssessments.size() %></p>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
</body>
</html>