<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Credit Dashboard - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .dashboard-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 20px 0; }
        .dashboard-card { background: white; padding: 20px; border-radius: 5px; border-left: 4px solid #0066cc; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .dashboard-card h3 { margin-top: 0; color: #0066cc; }
        .stat-number { font-size: 32px; font-weight: bold; color: #0066cc; }
        .stat-label { color: #666; font-size: 14px; }
        .summary-stats { background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .stats-row { display: flex; justify-content: space-around; flex-wrap: wrap; }
        .stat-item { text-align: center; margin: 10px; }
        .customer-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .customer-table th, .customer-table td { border: 1px solid #ddd; padding: 8px; text-align: left; font-size: 12px; }
        .customer-table th { background: #0066cc; color: white; }
        .customer-table tr:nth-child(even) { background: #f2f2f2; }
        .customer-table a { color: #0066cc; text-decoration: none; }
        .customer-table a:hover { text-decoration: underline; }
        .risk-high { color: #dc3545; font-weight: bold; }
        .risk-excellent { color: #28a745; font-weight: bold; }
        .alert { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .alert-danger { background: #f8d7da; border-color: #f5c6cb; color: #721c24; }
        .no-data { font-style: italic; color: #666; text-align: center; padding: 20px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Credit Risk Management Dashboard</p>
    </div>
    
    <div id="main-content">
        
        <!-- Summary Statistics -->
        <div class="summary-stats">
            <h2>Credit Portfolio Summary</h2>
            <div class="stats-row">
                <div class="stat-item">
                    <div class="stat-number"><bean:write name="totalExposure" format="$###,###,##0.00"/></div>
                    <div class="stat-label">Total Credit Exposure</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><bean:write name="highValueCount"/></div>
                    <div class="stat-label">High-Value Customers ($100K+)</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><bean:write name="reviewRequiredCount"/></div>
                    <div class="stat-label">Reviews Required</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><bean:write name="highRiskCount"/></div>
                    <div class="stat-label">High Risk Customers</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><bean:write name="excellentCount"/></div>
                    <div class="stat-label">Excellent Customers</div>
                </div>
            </div>
        </div>
        
        <!-- Dashboard Cards -->
        <div class="dashboard-grid">
            
            <!-- High Risk Customers -->
            <div class="dashboard-card">
                <h3>⚠️ High Risk Customers</h3>
                
                <logic:present name="highRiskCustomers">
                    <logic:notEmpty name="highRiskCustomers">
                        <div class="alert alert-danger">
                            <strong>Attention Required:</strong> <bean:write name="highRiskCount"/> customers with 'D' rating require immediate review.
                        </div>
                        
                        <table class="customer-table">
                            <thead>
                                <tr>
                                    <th>Customer ID</th>
                                    <th>Credit Limit</th>
                                    <th>Risk Score</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <logic:iterate name="highRiskCustomers" id="credit" indexId="index">
                                    <logic:lessThan name="index" value="10">
                                        <tr>
                                            <td><bean:write name="credit" property="customerId"/></td>
                                            <td><bean:write name="credit" property="formattedCreditLimit"/></td>
                                            <td class="risk-high"><bean:write name="credit" property="riskScore"/></td>
                                            <td>
                                                <a href="../creditLimit.do?action=display&customerId=<bean:write name="credit" property="customerId"/>">Review</a>
                                            </td>
                                        </tr>
                                    </logic:lessThan>
                                </logic:iterate>
                            </tbody>
                        </table>
                        
                        <logic:greaterThan name="highRiskCount" value="10">
                            <p><em>Showing first 10 of <bean:write name="highRiskCount"/> high-risk customers.</em></p>
                        </logic:greaterThan>
                    </logic:notEmpty>
                    <logic:empty name="highRiskCustomers">
                        <div class="no-data">✅ No high-risk customers found</div>
                    </logic:empty>
                </logic:present>
            </div>
            
            <!-- Reviews Required -->
            <div class="dashboard-card">
                <h3>📋 Reviews Required</h3>
                
                <logic:present name="reviewRequired">
                    <logic:notEmpty name="reviewRequired">
                        <div class="alert">
                            <strong>Review Schedule:</strong> <bean:write name="reviewRequiredCount"/> customers need credit review (annual requirement).
                        </div>
                        
                        <table class="customer-table">
                            <thead>
                                <tr>
                                    <th>Customer ID</th>
                                    <th>Credit Limit</th>
                                    <th>Last Review</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <logic:iterate name="reviewRequired" id="credit" indexId="index">
                                    <logic:lessThan name="index" value="8">
                                        <tr>
                                            <td><bean:write name="credit" property="customerId"/></td>
                                            <td><bean:write name="credit" property="formattedCreditLimit"/></td>
                                            <td>
                                                <logic:present name="credit" property="lastReviewDate">
                                                    <bean:write name="credit" property="lastReviewDate"/>
                                                </logic:present>
                                                <logic:notPresent name="credit" property="lastReviewDate">
                                                    <em>Never</em>
                                                </logic:notPresent>
                                            </td>
                                            <td>
                                                <a href="../creditLimit.do?action=display&customerId=<bean:write name="credit" property="customerId"/>">Review</a>
                                            </td>
                                        </tr>
                                    </logic:lessThan>
                                </logic:iterate>
                            </tbody>
                        </table>
                        
                        <logic:greaterThan name="reviewRequiredCount" value="8">
                            <p><em>Showing first 8 of <bean:write name="reviewRequiredCount"/> customers requiring review.</em></p>
                        </logic:greaterThan>
                    </logic:notEmpty>
                    <logic:empty name="reviewRequired">
                        <div class="no-data">✅ All customer reviews are up to date</div>
                    </logic:empty>
                </logic:present>
            </div>
            
            <!-- High Value Customers -->
            <div class="dashboard-card">
                <h3>💎 High-Value Customers</h3>
                
                <logic:present name="highValueCustomers">
                    <logic:notEmpty name="highValueCustomers">
                        <p><strong><bean:write name="highValueCount"/> customers</strong> with credit limits over $100,000</p>
                        
                        <table class="customer-table">
                            <thead>
                                <tr>
                                    <th>Customer ID</th>
                                    <th>Credit Limit</th>
                                    <th>Rating</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <logic:iterate name="highValueCustomers" id="credit" indexId="index">
                                    <logic:lessThan name="index" value="8">
                                        <tr>
                                            <td><bean:write name="credit" property="customerId"/></td>
                                            <td><strong><bean:write name="credit" property="formattedCreditLimit"/></strong></td>
                                            <td><bean:write name="credit" property="creditRating"/></td>
                                            <td>
                                                <a href="../creditLimit.do?action=display&customerId=<bean:write name="credit" property="customerId"/>">Manage</a>
                                            </td>
                                        </tr>
                                    </logic:lessThan>
                                </logic:iterate>
                            </tbody>
                        </table>
                        
                        <logic:greaterThan name="highValueCount" value="8">
                            <p><em>Showing top 8 of <bean:write name="highValueCount"/> high-value customers.</em></p>
                        </logic:greaterThan>
                    </logic:notEmpty>
                    <logic:empty name="highValueCustomers">
                        <div class="no-data">No customers with limits over $100,000</div>
                    </logic:empty>
                </logic:present>
            </div>
            
            <!-- Excellent Customers -->
            <div class="dashboard-card">
                <h3>⭐ Excellent Customers</h3>
                
                <logic:present name="excellentCustomers">
                    <logic:notEmpty name="excellentCustomers">
                        <p><strong><bean:write name="excellentCount"/> customers</strong> with AAA credit rating</p>
                        
                        <table class="customer-table">
                            <thead>
                                <tr>
                                    <th>Customer ID</th>
                                    <th>Credit Limit</th>
                                    <th>Risk Score</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <logic:iterate name="excellentCustomers" id="credit" indexId="index">
                                    <logic:lessThan name="index" value="8">
                                        <tr>
                                            <td><bean:write name="credit" property="customerId"/></td>
                                            <td><bean:write name="credit" property="formattedCreditLimit"/></td>
                                            <td class="risk-excellent"><bean:write name="credit" property="riskScore"/></td>
                                            <td>
                                                <a href="../creditLimit.do?action=display&customerId=<bean:write name="credit" property="customerId"/>">View</a>
                                            </td>
                                        </tr>
                                    </logic:lessThan>
                                </logic:iterate>
                            </tbody>
                        </table>
                        
                        <logic:greaterThan name="excellentCount" value="8">
                            <p><em>Showing first 8 of <bean:write name="excellentCount"/> excellent customers.</em></p>
                        </logic:greaterThan>
                    </logic:notEmpty>
                    <logic:empty name="excellentCustomers">
                        <div class="no-data">No customers currently rated AAA</div>
                    </logic:empty>
                </logic:present>
            </div>
            
        </div>
        
        <!-- Quick Actions -->
        <div class="summary-stats">
            <h3>Quick Actions</h3>
            <p>
                <a href="../customerSearch.do" style="background: #0066cc; color: white; padding: 10px 15px; text-decoration: none; border-radius: 3px; margin-right: 10px;">Search Customers</a>
                <a href="../creditLimit.do?action=dashboard" style="background: #28a745; color: white; padding: 10px 15px; text-decoration: none; border-radius: 3px; margin-right: 10px;">Refresh Dashboard</a>
                <a href="../welcome.do" style="background: #6c757d; color: white; padding: 10px 15px; text-decoration: none; border-radius: 3px;">Main Dashboard</a>
            </p>
        </div>
        
        <!-- Navigation -->
        <div class="navigation-section">
            <h3>Navigation</h3>
            <p>
                <a href="../welcome.do">Main Dashboard</a> |
                <a href="../customerSearch.do">Customer Search</a> |
                <a href="../creditLimit.do?action=dashboard">Credit Dashboard</a>
            </p>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Credit Risk Dashboard - Milestone 4 Implementation</p>
    </div>
    
    <script>
        // Auto-refresh dashboard every 5 minutes
        setTimeout(function() {
            window.location.reload();
        }, 300000);
    </script>
    
</body>
</html>