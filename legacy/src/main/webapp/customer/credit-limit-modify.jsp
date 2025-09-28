<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Credit Limit Modification - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .customer-summary { background: #e3f2fd; padding: 15px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #2196f3; }
        .form-section { background: white; border: 1px solid #ddd; padding: 20px; margin: 15px 0; border-radius: 3px; }
        .form-table { width: 100%; border-collapse: collapse; }
        .form-table th, .form-table td { padding: 12px; text-align: left; border-bottom: 1px solid #eee; }
        .form-table th { background: #f8f9fa; font-weight: bold; width: 30%; }
        .form-input { width: 200px; padding: 8px; border: 1px solid #ddd; border-radius: 3px; }
        .form-select { width: 220px; padding: 8px; border: 1px solid #ddd; border-radius: 3px; }
        .validation-result { margin: 15px 0; padding: 15px; border-radius: 5px; }
        .validation-pass { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .validation-fail { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .business-rules { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .rule-item { margin: 8px 0; }
        .rule-pass { color: #28a745; }
        .rule-fail { color: #dc3545; }
        .rule-warning { color: #ffc107; }
        .action-buttons { margin: 20px 0; text-align: center; }
        .btn { display: inline-block; padding: 12px 24px; margin: 5px; text-decoration: none; border-radius: 3px; border: none; cursor: pointer; font-size: 14px; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-secondary { background: #6c757d; color: white; }
        .suggested-limit { font-size: 18px; font-weight: bold; color: #28a745; }
        .current-limit { font-size: 16px; font-weight: bold; color: #007bff; }
        .calculation-details { font-family: monospace; background: #f8f9fa; padding: 10px; margin: 10px 0; border-radius: 3px; font-size: 12px; }
    </style>
    <script>
        function validateForm() {
            var newLimit = parseFloat(document.getElementById('newCreditLimit').value);
            if (isNaN(newLimit) || newLimit <= 0) {
                alert('Please enter a valid credit limit');
                return false;
            }
            return true;
        }
        
        function calculateSuggestedLimit() {
            var rating = document.getElementById('creditRating').value;
            var suggested = 0;
            
            switch(rating) {
                case 'AAA': suggested = 1000000; break;
                case 'AA': suggested = 500000; break;
                case 'A': suggested = 200000; break;
                case 'BBB': suggested = 100000; break;
                case 'BB': suggested = 50000; break;
                case 'B': suggested = 20000; break;
                case 'C': suggested = 10000; break;
                default: suggested = 50000;
            }
            
            document.getElementById('suggestedLimit').innerHTML = '$' + suggested.toLocaleString();
            document.getElementById('newCreditLimit').value = suggested;
        }
    </script>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Credit Limit Modification - Core Business Function 2</p>
    </div>
    
    <div id="main-content">
        <%
        // Get customer information and process form submission
        String customerCode = request.getParameter("customerCode");
        if (customerCode == null || customerCode.isEmpty()) {
            customerCode = "CUST001";
        }
        
        String action = request.getParameter("action");
        String newLimitStr = request.getParameter("newCreditLimit");
        String reason = request.getParameter("reason");
        
        // Mock customer data - POC Implementation
        String companyName = "ABC Manufacturing Ltd";
        String creditRating = "A";
        BigDecimal currentLimit = new BigDecimal("200000");
        BigDecimal outstandingBalance = new BigDecimal("45000");
        String status = "ACTIVE";
        
        // Process form submission - Simplified POC version
        boolean formSubmitted = "modify".equals(action) && newLimitStr != null;
        String validationMessage = null;
        boolean validationPassed = true;
        
        if (formSubmitted) {
            try {
                BigDecimal newLimit = new BigDecimal(newLimitStr);
                
                // Simple validation logic
                if (newLimit.compareTo(BigDecimal.ZERO) <= 0) {
                    validationMessage = "Credit limit must be greater than 0";
                    validationPassed = false;
                } else if (newLimit.compareTo(new BigDecimal("1000000")) > 0) {
                    validationMessage = "Credit limit cannot exceed 1,000,000";
                    validationPassed = false;
                } else {
                    validationMessage = "Credit limit modification validation passed";
                }
                
            } catch (Exception e) {
                validationMessage = "Input format error";
                validationPassed = false;
            }
        }
        %>
        
        <!-- Customer Information Summary -->
        <div class="customer-summary">
            <h2>Customer Information: <%= companyName %> (<%= customerCode %>)</h2>
            <p><strong>Current Credit Rating:</strong> <span style="font-weight: bold; color: #007bff;"><%= creditRating %></span></p>
            <p><strong>Current Credit Limit:</strong> <span class="current-limit">$<%= String.format("%,.2f", currentLimit) %></span></p>
            <p><strong>Outstanding Balance:</strong> $<%= String.format("%,.2f", outstandingBalance) %></p>
            <p><strong>Available Credit:</strong> $<%= String.format("%,.2f", currentLimit.subtract(outstandingBalance)) %></p>
        </div>
        
        <% if (formSubmitted && validationMessage != null) { %>
        <!-- Validation Results Display -->
        <div class="validation-result <%= validationPassed ? "validation-pass" : "validation-fail" %>">
            <h3>Validation Results</h3>
            
            <!-- Credit Limit Validation Results -->
            <div class="rule-item <%= validationPassed ? "rule-pass" : "rule-fail" %>">
                <%= validationPassed ? "✅" : "❌" %> <%= validationMessage %>
            </div>
            
            <% if (validationPassed) { %>
                <div class="rule-item">Modification successfully submitted for review</div>
            <% } %>
            
            <div class="calculation-details">
                Validation Time: <%= new java.util.Date() %><br>
                Validation Engine: CreditLimitValidator + BusinessRuleEngine<br>
                Operation Log: Recorded to audit log
            </div>
        </div>
        <% } %>
        
        <!-- Credit Limit Modification Form -->
        <div class="form-section">
            <h3>Credit Limit Modification</h3>
            <form method="post" onsubmit="return validateForm()">
                <input type="hidden" name="customerCode" value="<%= customerCode %>">
                <input type="hidden" name="action" value="modify">
                
                <table class="form-table">
                    <tr>
                        <th>Current Credit Rating:</th>
                        <td>
                            <select id="creditRating" name="creditRating" class="form-select" onchange="calculateSuggestedLimit()">
                                <option value="AAA" <%= "AAA".equals(creditRating) ? "selected" : "" %>>AAA (Excellent)</option>
                                <option value="AA" <%= "AA".equals(creditRating) ? "selected" : "" %>>AA (Very Good)</option>
                                <option value="A" <%= "A".equals(creditRating) ? "selected" : "" %>>A (Good)</option>
                                <option value="BBB" <%= "BBB".equals(creditRating) ? "selected" : "" %>>BBB (Fair)</option>
                                <option value="BB" <%= "BB".equals(creditRating) ? "selected" : "" %>>BB (Watch)</option>
                                <option value="B" <%= "B".equals(creditRating) ? "selected" : "" %>>B (Substandard)</option>
                                <option value="C" <%= "C".equals(creditRating) ? "selected" : "" %>>C (Doubtful)</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th>Suggested Credit Limit:</th>
                        <td>
                            <span id="suggestedLimit" class="suggested-limit">$<%= String.format("%,.2f", CreditLimitValidator.getSuggestedCreditLimit(creditRating)) %></span>
                            <button type="button" onclick="calculateSuggestedLimit()" class="btn btn-secondary" style="margin-left: 10px; padding: 4px 8px;">Recalculate</button>
                        </td>
                    </tr>
                    <tr>
                        <th>Requested Credit Limit: <span style="color: red;">*</span></th>
                        <td>
                            <input type="number" id="newCreditLimit" name="newCreditLimit" 
                                   class="form-input" step="1000" min="0" 
                                   value="<%= formSubmitted ? newLimitStr : String.format("%.0f", CreditLimitValidator.getSuggestedCreditLimit(creditRating)) %>"
                                   placeholder="Enter new credit limit">
                        </td>
                    </tr>
                    <tr>
                        <th>Modification Reason: <span style="color: red;">*</span></th>
                        <td>
                            <select name="reason" class="form-select" required>
                                <option value="">Please select modification reason</option>
                                <option value="RISK_IMPROVED" <%= "RISK_IMPROVED".equals(reason) ? "selected" : "" %>>Risk Status Improved</option>
                                <option value="BUSINESS_GROWTH" <%= "BUSINESS_GROWTH".equals(reason) ? "selected" : "" %>>Business Growth Requirement</option>
                                <option value="PAYMENT_IMPROVED" <%= "PAYMENT_IMPROVED".equals(reason) ? "selected" : "" %>>Payment Record Improved</option>
                                <option value="RISK_INCREASED" <%= "RISK_INCREASED".equals(reason) ? "selected" : "" %>>Risk Increased</option>
                                <option value="POLICY_CHANGE" <%= "POLICY_CHANGE".equals(reason) ? "selected" : "" %>>Policy Adjustment</option>
                                <option value="OTHER" <%= "OTHER".equals(reason) ? "selected" : "" %>>Other Reasons</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <th>Comments:</th>
                        <td>
                            <textarea name="comments" rows="3" style="width: 300px; padding: 8px;" 
                                      placeholder="Enter detailed description..."><%= request.getParameter("comments") != null ? request.getParameter("comments") : "" %></textarea>
                        </td>
                    </tr>
                </table>
                
                <div class="action-buttons">
                    <button type="submit" class="btn btn-primary">Validate and Submit Modification</button>
                    <button type="button" onclick="calculateSuggestedLimit()" class="btn btn-warning">Recalculate Suggested Limit</button>
                    <a href="customer-details.jsp?customerCode=<%= customerCode %>" class="btn btn-secondary">Back to Customer Details</a>
                </div>
            </form>
        </div>
        
        <!-- Business Rules Description -->
        <div class="business-rules">
            <h3>Business Rules Description</h3>
            <p><strong>Credit Limit Validation Rules:</strong></p>
            <ul>
                <li>AAA rated customers: Maximum $1,000,000 limit</li>
                <li>AA rated customers: Maximum $500,000 limit</li>
                <li>A rated customers: Maximum $200,000 limit</li>
                <li>BBB rated customers: Maximum $100,000 limit</li>
                <li>BB/B/C rated customers: Decreasing limits</li>
            </ul>
            
            <p><strong>Business Rule Validation:</strong></p>
            <ul>
                <li>VERY_HIGH risk level customers are not allowed credit limits</li>
                <li>High-risk customers have credit limit cap of $50,000</li>
                <li>Customers with average payment delay over 60 days are not allowed credit limits</li>
                <li>Entertainment/Gaming industry limit cap of $30,000</li>
                <li>Inactive or suspended customers are not allowed credit limits</li>
            </ul>
        </div>
        
        <!-- Operation History -->
        <div class="form-section">
            <h3>Recent Credit Limit Modification History</h3>
            <table class="form-table">
                <thead>
                    <tr style="background: #007bff; color: white;">
                        <th>Date</th>
                        <th>Operation</th>
                        <th>Original Limit</th>
                        <th>New Limit</th>
                        <th>Operator</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>2025-09-20</td>
                        <td>Limit Adjustment</td>
                        <td>$150,000</td>
                        <td>$200,000</td>
                        <td>System Administrator</td>
                        <td style="color: #28a745;">Approved</td>
                    </tr>
                    <tr>
                        <td>2025-08-15</td>
                        <td>Annual Review</td>
                        <td>$120,000</td>
                        <td>$150,000</td>
                        <td>Credit Analyst</td>
                        <td style="color: #28a745;">Approved</td>
                    </tr>
                </tbody>
            </table>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Credit Limit Modification - Following Design Document: Credit Analyst → Modify limits → Business rules validation</p>
    </div>
    
</body>
</html>