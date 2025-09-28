<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Credit Limit Management - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .credit-management { background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .credit-form { background: white; padding: 15px; margin: 10px 0; border-radius: 3px; border: 1px solid #ddd; }
        .credit-form table { width: 100%; }
        .credit-form td { padding: 8px; }
        .credit-form input[type="text"], .credit-form input[type="number"], .credit-form select { width: 200px; padding: 5px; }
        .credit-form input[type="submit"] { background: #0066cc; color: white; padding: 8px 16px; border: none; border-radius: 3px; cursor: pointer; }
        .credit-form input[type="submit"]:hover { background: #0056b3; }
        .credit-form input[type="submit"].danger { background: #dc3545; }
        .credit-form input[type="submit"].danger:hover { background: #c82333; }
        .current-info { display: flex; justify-content: space-between; flex-wrap: wrap; margin: 20px 0; }
        .info-card { background: white; padding: 15px; margin: 5px; border-radius: 5px; border-left: 4px solid #0066cc; min-width: 180px; }
        .info-card strong { display: block; color: #0066cc; font-size: 14px; }
        .info-card .value { font-size: 18px; font-weight: bold; margin-top: 5px; }
        .risk-high { border-left-color: #dc3545; }
        .risk-medium { border-left-color: #ffc107; }
        .risk-low { border-left-color: #28a745; }
        .message { padding: 10px; margin: 10px 0; border-radius: 3px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .warning { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; }
        .section-header { background: #0066cc; color: white; padding: 10px; margin: 20px 0 0 0; border-radius: 3px 3px 0 0; }
        .section-content { background: white; padding: 15px; border: 1px solid #ddd; border-top: none; border-radius: 0 0 3px 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Credit Limit Management</p>
    </div>
    
    <div id="main-content">
        
        <!-- Messages -->
        <logic:present name="successMessage">
            <div class="message success">
                <bean:write name="successMessage"/>
            </div>
        </logic:present>
        
        <logic:present name="errorMessage">
            <div class="message error">
                <bean:write name="errorMessage"/>
            </div>
        </logic:present>
        
        <!-- Customer Information -->
        <logic:present name="customer">
            <div class="credit-management">
                <h2>Credit Management for: <bean:write name="customer" property="companyName"/></h2>
                <p><strong>Customer Code:</strong> <bean:write name="customer" property="customerCode"/> | 
                   <strong>ID:</strong> <bean:write name="customer" property="customerId"/></p>
            </div>
        </logic:present>
        
        <!-- Current Credit Information -->
        <logic:present name="customerCredit">
            <div class="section-header">
                <h3>Current Credit Profile</h3>
            </div>
            <div class="section-content">
                <div class="current-info">
                    <div class="info-card">
                        <strong>Credit Limit</strong>
                        <div class="value"><bean:write name="customerCredit" property="formattedCreditLimit"/></div>
                    </div>
                    <div class="info-card">
                        <strong>Available Credit</strong>
                        <div class="value"><bean:write name="customerCredit" property="formattedAvailableCredit"/></div>
                    </div>
                    <div class="info-card">
                        <strong>Credit Utilization</strong>
                        <div class="value"><bean:write name="creditUtilization" format="##0.##"/>%</div>
                    </div>
                    <div class="info-card">
                        <strong>Credit Rating</strong>
                        <div class="value"><bean:write name="customerCredit" property="creditRating"/></div>
                    </div>
                    <div class="info-card risk-<logic:present name="riskLevel"><logic:equal name="riskLevel" value="LOW">low</logic:equal><logic:equal name="riskLevel" value="MEDIUM">medium</logic:equal><logic:equal name="riskLevel" value="HIGH">high</logic:equal><logic:equal name="riskLevel" value="VERY_HIGH">high</logic:equal></logic:present>">
                        <strong>Risk Score</strong>
                        <div class="value"><bean:write name="customerCredit" property="riskScore"/>/100</div>
                        <small>(<bean:write name="riskLevel"/> RISK)</small>
                    </div>
                    <div class="info-card">
                        <strong>Credit Status</strong>
                        <div class="value"><bean:write name="creditStatus"/></div>
                    </div>
                </div>
                
                <p><strong>Credit Officer:</strong> <bean:write name="customerCredit" property="creditOfficer"/> | 
                   <strong>Last Review:</strong> <bean:write name="customerCredit" property="lastReviewDate"/> |
                   <strong>Status:</strong> <bean:write name="customerCredit" property="approvalStatus"/></p>
                
                <logic:equal name="limitIncreaseRecommended" value="true">
                    <div class="message warning">
                        <strong>System Recommendation:</strong> This customer qualifies for a credit limit increase based on their risk profile and credit utilization.
                    </div>
                </logic:equal>
            </div>
        </logic:present>
        
        <!-- Credit Limit Update Form -->
        <logic:present name="customerCredit">
            <div class="section-header">
                <h3>Update Credit Limit</h3>
            </div>
            <div class="section-content">
                <form action="../creditLimit.do" method="post">
                    <input type="hidden" name="action" value="updateLimit"/>
                    <input type="hidden" name="customerId" value="<bean:write name="customer" property="customerId"/>"/>
                    
                    <table>
                        <tr>
                            <td><strong>Current Limit:</strong></td>
                            <td><bean:write name="customerCredit" property="formattedCreditLimit"/></td>
                        </tr>
                        <tr>
                            <td><strong>New Credit Limit:</strong></td>
                            <td>
                                <input type="number" name="newCreditLimit" step="0.01" min="0" max="10000000" 
                                       placeholder="Enter new limit" required/>
                                <br><small>Maximum: $10,000,000</small>
                            </td>
                        </tr>
                        <tr>
                            <td><strong>Credit Officer:</strong></td>
                            <td>
                                <input type="text" name="creditOfficer" maxlength="100" 
                                       value="<bean:write name="customerCredit" property="creditOfficer"/>" required/>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <input type="submit" value="Update Credit Limit"/>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
        </logic:present>
        
        <!-- Risk Assessment Update Form -->
        <logic:present name="customerCredit">
            <div class="section-header">
                <h3>Update Risk Assessment</h3>
            </div>
            <div class="section-content">
                <form action="../creditLimit.do" method="post">
                    <input type="hidden" name="action" value="updateRisk"/>
                    <input type="hidden" name="customerId" value="<bean:write name="customer" property="customerId"/>"/>
                    
                    <table>
                        <tr>
                            <td><strong>Current Risk Score:</strong></td>
                            <td><bean:write name="customerCredit" property="riskScore"/>/100 (<bean:write name="riskLevel"/> RISK)</td>
                        </tr>
                        <tr>
                            <td><strong>New Risk Score:</strong></td>
                            <td>
                                <input type="number" name="riskScore" min="0" max="100" 
                                       value="<bean:write name="customerCredit" property="riskScore"/>" required/>
                                <br><small>0 = Very High Risk, 100 = Very Low Risk</small>
                            </td>
                        </tr>
                        <tr>
                            <td><strong>Current Credit Rating:</strong></td>
                            <td><bean:write name="customerCredit" property="creditRating"/></td>
                        </tr>
                        <tr>
                            <td><strong>New Credit Rating:</strong></td>
                            <td>
                                <select name="creditRating" required>
                                    <option value="">-- Select Rating --</option>
                                    <option value="AAA">AAA - Excellent</option>
                                    <option value="AA">AA - Very Good</option>
                                    <option value="A">A - Good</option>
                                    <option value="BBB">BBB - Acceptable</option>
                                    <option value="BB">BB - Moderate</option>
                                    <option value="B">B - Below Average</option>
                                    <option value="CCC">CCC - Poor</option>
                                    <option value="CC">CC - Very Poor</option>
                                    <option value="C">C - Extremely Poor</option>
                                    <option value="D">D - Default</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td><strong>Credit Officer:</strong></td>
                            <td>
                                <input type="text" name="creditOfficer" maxlength="100" 
                                       value="<bean:write name="customerCredit" property="creditOfficer"/>" required/>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <input type="submit" value="Update Risk Assessment"/>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
        </logic:present>
        
        <!-- Create Credit Profile (if none exists) -->
        <logic:notPresent name="customerCredit">
            <logic:present name="customer">
                <div class="section-header">
                    <h3>Create Credit Profile</h3>
                </div>
                <div class="section-content">
                    <p><em>No credit profile found for this customer. Create one to begin credit management.</em></p>
                    
                    <form action="../creditLimit.do" method="post">
                        <input type="hidden" name="action" value="create"/>
                        <input type="hidden" name="customerId" value="<bean:write name="customer" property="customerId"/>"/>
                        
                        <table>
                            <tr>
                                <td><strong>Initial Credit Limit:</strong></td>
                                <td>
                                    <input type="number" name="initialCreditLimit" step="0.01" min="0" max="10000000" 
                                           placeholder="0.00" value="0"/>
                                    <br><small>Can be set to $0 initially</small>
                                </td>
                            </tr>
                            <tr>
                                <td><strong>Credit Officer:</strong></td>
                                <td>
                                    <input type="text" name="creditOfficer" maxlength="100" 
                                           placeholder="Enter your name" required/>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <input type="submit" value="Create Credit Profile"/>
                                </td>
                            </tr>
                        </table>
                    </form>
                </div>
            </logic:present>
        </logic:notPresent>
        
        <!-- Navigation -->
        <div class="navigation-section">
            <h3>Navigation</h3>
            <p>
                <a href="../welcome.do">Dashboard</a> |
                <a href="../customerSearch.do">Customer Search</a> |
                <logic:present name="customer">
                    <a href="../customerDetails.do?action=display&customerId=<bean:write name="customer" property="customerId"/>">Customer Details</a> |
                </logic:present>
                <a href="../creditLimit.do?action=dashboard">Credit Dashboard</a>
            </p>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Credit Limit Management - Milestone 4 Implementation</p>
    </div>
    
    <script>
        // Auto-populate credit rating based on risk score
        function updateRatingBasedOnScore() {
            const riskScore = document.querySelector('input[name="riskScore"]').value;
            const ratingSelect = document.querySelector('select[name="creditRating"]');
            
            if (riskScore >= 90) ratingSelect.value = 'AAA';
            else if (riskScore >= 80) ratingSelect.value = 'AA';
            else if (riskScore >= 70) ratingSelect.value = 'A';
            else if (riskScore >= 60) ratingSelect.value = 'BBB';
            else if (riskScore >= 50) ratingSelect.value = 'BB';
            else if (riskScore >= 40) ratingSelect.value = 'B';
            else if (riskScore >= 30) ratingSelect.value = 'CCC';
            else if (riskScore >= 20) ratingSelect.value = 'CC';
            else if (riskScore >= 10) ratingSelect.value = 'C';
            else ratingSelect.value = 'D';
        }
        
        // Add event listener if risk score input exists
        const riskScoreInput = document.querySelector('input[name="riskScore"]');
        if (riskScoreInput) {
            riskScoreInput.addEventListener('change', updateRatingBasedOnScore);
        }
    </script>
    
</body>
</html>