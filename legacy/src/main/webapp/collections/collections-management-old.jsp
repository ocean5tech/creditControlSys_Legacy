<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Collections Management - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .collections-header { background: #fff3cd; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #ffc107; }
        .alert-overdue { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .alert-warning { background: #fff3cd; border: 1px solid #ffeaa7; color: #856404; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .collections-summary { background: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .overdue-accounts { background: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .action-panel { background: #f8f9fa; border: 1px solid #ddd; padding: 20px; margin: 15px 0; border-radius: 3px; }
        .accounts-table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        .accounts-table th, .accounts-table td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; }
        .accounts-table th { background: #f8f9fa; font-weight: bold; }
        .priority-high { background: #f8d7da !important; }
        .priority-medium { background: #fff3cd !important; }
        .priority-low { background: #d1ecf1 !important; }
        .overdue-30 { color: #ffc107; font-weight: bold; }
        .overdue-60 { color: #fd7e14; font-weight: bold; }
        .overdue-90 { color: #dc3545; font-weight: bold; }
        .amount-overdue { color: #dc3545; font-weight: bold; font-size: 14px; }
        .btn { display: inline-block; padding: 8px 15px; margin: 2px; text-decoration: none; border-radius: 3px; border: none; cursor: pointer; font-size: 12px; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .stats-cards { display: flex; flex-wrap: wrap; gap: 15px; margin: 20px 0; }
        .stats-card { flex: 1; min-width: 180px; background: white; border: 1px solid #ddd; padding: 15px; border-radius: 3px; text-align: center; }
        .stats-value { font-size: 18px; font-weight: bold; margin: 8px 0; }
        .stats-label { color: #666; font-size: 11px; }
        .escalation-form { background: #e3f2fd; border: 1px solid #bbdefb; padding: 15px; margin: 10px 0; border-radius: 3px; display: none; }
        .contact-log { background: #f8f9fa; border: 1px solid #ddd; padding: 10px; margin: 10px 0; border-radius: 3px; font-size: 12px; }
        .contact-date { font-weight: bold; color: #007bff; }
        .filter-section { background: #f8f9fa; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .filter-section select, .filter-section input { margin: 5px; padding: 5px; border: 1px solid #ddd; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Collections Management - Collections Officer Interface</p>
    </div>
    
    <div id="main-content">
        <%
        // Get parameters and filters
        String filterPriority = request.getParameter("priority");
        String filterOverdue = request.getParameter("overdue");
        String action = request.getParameter("action");
        String targetCustomer = request.getParameter("customer");
        
        // Simulate overdue account data
        List<Map<String, Object>> overdueAccounts = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Calendar cal = Calendar.getInstance();
        
        // Severely overdue account 1
        Map<String, Object> account1 = new HashMap<>();
        account1.put("customerCode", "CUST002");
        account1.put("companyName", "XYZ Trading Corp");
        account1.put("creditRating", "BBB");
        account1.put("overdueAmount", new BigDecimal("85000"));
        account1.put("totalBalance", new BigDecimal("85000"));
        cal.add(Calendar.DAY_OF_MONTH, -95);
        account1.put("lastPayment", sdf.format(cal.getTime()));
        account1.put("overdueDays", 95);
        account1.put("priority", "HIGH");
        account1.put("contactAttempts", 8);
        account1.put("lastContact", "2025-01-20");
        account1.put("status", "ESCALATED");
        account1.put("assignedOfficer", "Manager Zhang");
        overdueAccounts.add(account1);
        
        // Moderately overdue account 2
        Map<String, Object> account2 = new HashMap<>();
        account2.put("customerCode", "CUST004");
        account2.put("companyName", "Delta Services Ltd");
        account2.put("creditRating", "B");
        account2.put("overdueAmount", new BigDecimal("35000"));
        account2.put("totalBalance", new BigDecimal("55000"));
        cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, -45);
        account2.put("lastPayment", sdf.format(cal.getTime()));
        account2.put("overdueDays", 45);
        account2.put("priority", "MEDIUM");
        account2.put("contactAttempts", 4);
        account2.put("lastContact", "2025-01-18");
        account2.put("status", "FOLLOW_UP");
        account2.put("assignedOfficer", "Specialist Li");
        overdueAccounts.add(account2);
        
        // Mildly overdue account 3
        Map<String, Object> account3 = new HashMap<>();
        account3.put("customerCode", "CUST005");
        account3.put("companyName", "Alpha Industries");
        account3.put("creditRating", "A-");
        account3.put("overdueAmount", new BigDecimal("15000"));
        account3.put("totalBalance", new BigDecimal("25000"));
        cal = Calendar.getInstance();
        cal.add(Calendar.DAY_OF_MONTH, -25);
        account3.put("lastPayment", sdf.format(cal.getTime()));
        account3.put("overdueDays", 25);
        account3.put("priority", "LOW");
        account3.put("contactAttempts", 2);
        account3.put("lastContact", "2025-01-22");
        account3.put("status", "INITIAL_CONTACT");
        account3.put("assignedOfficer", "Specialist Wang");
        overdueAccounts.add(account3);
        
        // Statistical data
        BigDecimal totalOverdue = BigDecimal.ZERO;
        int highPriorityCount = 0, mediumPriorityCount = 0, lowPriorityCount = 0;
        int overdue30 = 0, overdue60 = 0, overdue90 = 0;
        
        for (Map<String, Object> account : overdueAccounts) {
            totalOverdue = totalOverdue.add((BigDecimal)account.get("overdueAmount"));
            String priority = (String)account.get("priority");
            int days = (Integer)account.get("overdueDays");
            
            if ("HIGH".equals(priority)) highPriorityCount++;
            else if ("MEDIUM".equals(priority)) mediumPriorityCount++;
            else lowPriorityCount++;
            
            if (days >= 90) overdue90++;
            else if (days >= 60) overdue60++;
            else if (days >= 30) overdue30++;
        }
        
        // Process operations
        String actionResult = null;
        if ("escalate".equals(action) && targetCustomer != null) {
            actionResult = "Customer " + targetCustomer + " has been submitted to legal department for processing.";
        } else if ("contact".equals(action) && targetCustomer != null) {
            actionResult = "Contact record for customer " + targetCustomer + " has been logged.";
        } else if ("update_status".equals(action) && targetCustomer != null) {
            actionResult = "Status for customer " + targetCustomer + " has been updated.";
        }
        %>
        
        <!-- Page title and alerts -->
        <div class="collections-header">
            <h2>Overdue Account Management</h2>
            <p>Collections Officer Dashboard - Overdue Account Collection Management</p>
        </div>
        
        <!-- Emergency alerts -->
        <% if (overdue90 > 0) { %>
        <div class="alert-overdue">
            <strong>⚠️ Emergency Alert:</strong> <strong><%= overdue90 %></strong> accounts are overdue more than 90 days, total amount $85,000, requiring immediate legal action!
        </div>
        <% } %>
        
        <% if (overdue60 > 0) { %>
        <div class="alert-warning">
            <strong>🔔 Notice:</strong> <strong><%= overdue60 %></strong> accounts are overdue more than 60 days, recommend contacting customers as soon as possible.
        </div>
        <% } %>
        
        <!-- Operation result message -->
        <% if (actionResult != null) { %>
        <div style="background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; margin: 15px 0; border-radius: 3px;">
            <%= actionResult %>
        </div>
        <% } %>
        
        <!-- Overdue statistics -->
        <div class="collections-summary">
            <h3>Overdue Account Overview</h3>
            <div class="stats-cards">
                <div class="stats-card">
                    <div class="stats-value" style="color: #dc3545;">$<%= String.format("%,.0f", totalOverdue) %></div>
                    <div class="stats-label">Total Overdue Amount</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #dc3545;"><%= highPriorityCount %></div>
                    <div class="stats-label">High Priority Accounts</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #ffc107;"><%= mediumPriorityCount %></div>
                    <div class="stats-label">Medium Priority Accounts</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #17a2b8;"><%= lowPriorityCount %></div>
                    <div class="stats-label">Low Priority Accounts</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #dc3545;"><%= overdue90 %></div>
                    <div class="stats-label">Overdue 90+ Days</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #fd7e14;"><%= overdue60 %></div>
                    <div class="stats-label">Overdue 60+ Days</div>
                </div>
            </div>
        </div>
        
        <!-- Filters -->
        <div class="filter-section">
            <strong>Filter Criteria:</strong>
            <select name="priority" onchange="applyFilter()">
                <option value="">All Priorities</option>
                <option value="HIGH" <%= "HIGH".equals(filterPriority) ? "selected" : "" %>>High Priority</option>
                <option value="MEDIUM" <%= "MEDIUM".equals(filterPriority) ? "selected" : "" %>>Medium Priority</option>
                <option value="LOW" <%= "LOW".equals(filterPriority) ? "selected" : "" %>>Low Priority</option>
            </select>
            
            <select name="overdue" onchange="applyFilter()">
                <option value="">All Overdue</option>
                <option value="30" <%= "30".equals(filterOverdue) ? "selected" : "" %>>Overdue 30+ Days</option>
                <option value="60" <%= "60".equals(filterOverdue) ? "selected" : "" %>>Overdue 60+ Days</option>
                <option value="90" <%= "90".equals(filterOverdue) ? "selected" : "" %>>Overdue 90+ Days</option>
            </select>
            
            <button class="btn btn-primary" onclick="refreshData()">Refresh Data</button>
        </div>
        
        <!-- Overdue account details -->
        <div class="overdue-accounts">
            <h3>Overdue Account Details</h3>
            <table class="accounts-table">
                <thead>
                    <tr>
                        <th>Customer</th>
                        <th>Credit Rating</th>
                        <th>Overdue Amount</th>
                        <th>Overdue Days</th>
                        <th>Last Payment</th>
                        <th>Contact Attempts</th>
                        <th>Last Contact</th>
                        <th>Status</th>
                        <th>Assigned Officer</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> account : overdueAccounts) { 
                       String priority = (String)account.get("priority");
                       int days = (Integer)account.get("overdueDays");
                       String customerCode = (String)account.get("customerCode");
                       String rowClass = "";
                       
                       if ("HIGH".equals(priority)) rowClass = "priority-high";
                       else if ("MEDIUM".equals(priority)) rowClass = "priority-medium";
                       else rowClass = "priority-low";
                    %>
                    <tr class="<%= rowClass %>">
                        <td>
                            <strong><%= account.get("companyName") %></strong><br>
                            <small><%= customerCode %></small>
                        </td>
                        <td><%= account.get("creditRating") %></td>
                        <td class="amount-overdue">$<%= String.format("%,.0f", account.get("overdueAmount")) %></td>
                        <td class="<%= days >= 90 ? "overdue-90" : (days >= 60 ? "overdue-60" : "overdue-30") %>">
                            <%= days %> days
                        </td>
                        <td><%= account.get("lastPayment") %></td>
                        <td><%= account.get("contactAttempts") %> times</td>
                        <td><%= account.get("lastContact") %></td>
                        <td>
                            <% String status = (String)account.get("status");
                               if ("ESCALATED".equals(status)) { %>
                                <span style="color: #dc3545; font-weight: bold;">Escalated</span>
                            <% } else if ("FOLLOW_UP".equals(status)) { %>
                                <span style="color: #ffc107; font-weight: bold;">Follow Up</span>
                            <% } else { %>
                                <span style="color: #17a2b8; font-weight: bold;">Initial Contact</span>
                            <% } %>
                        </td>
                        <td><%= account.get("assignedOfficer") %></td>
                        <td>
                            <button class="btn btn-primary" onclick="showContactForm('<%= customerCode %>')">Contact Record</button>
                            <% if (days >= 90) { %>
                                <button class="btn btn-danger" onclick="escalateAccount('<%= customerCode %>')">Legal Escalation</button>
                            <% } else { %>
                                <button class="btn btn-warning" onclick="followUp('<%= customerCode %>')">Follow Up</button>
                            <% } %>
                            <br style="margin: 3px;">
                            <button class="btn btn-success" onclick="updateStatus('<%= customerCode %>')">Update Status</button>
                            <button class="btn btn-secondary" onclick="viewHistory('<%= customerCode %>')">View Details</button>
                        </td>
                    </tr>
                    <!-- Contact record expansion area -->
                    <tr id="contact-<%= customerCode %>" style="display: none;">
                        <td colspan="10">
                            <div class="contact-log">
                                <strong>Recent Contact Records:</strong><br>
                                <div class="contact-date">2025-01-20:</div> Phone contact, customer promised payment within this week - Manager Zhang<br>
                                <div class="contact-date">2025-01-15:</div> Sent dunning email, customer replied with cash flow difficulties - Manager Zhang<br>
                                <div class="contact-date">2025-01-10:</div> On-site visit, developed installment payment plan - Manager Zhang<br>
                                
                                <div class="escalation-form" id="escalation-<%= customerCode %>">
                                    <h4>Escalation Processing</h4>
                                    <form method="post">
                                        <input type="hidden" name="action" value="escalate">
                                        <input type="hidden" name="customer" value="<%= customerCode %>">
                                        <textarea name="escalation_reason" placeholder="Escalation reason and detailed explanation..." style="width: 100%; height: 80px; margin: 10px 0;"></textarea>
                                        <button type="submit" class="btn btn-danger">Submit to Legal Department</button>
                                        <button type="button" class="btn btn-secondary" onclick="hideEscalationForm('<%= customerCode %>')">Cancel</button>
                                    </form>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Quick action panel -->
        <div class="action-panel">
            <h3>Batch Operations</h3>
            <button class="btn btn-warning" onclick="batchContact()">Batch Contact Reminder</button>
            <button class="btn btn-danger" onclick="batchEscalate()">Batch Escalation</button>
            <button class="btn btn-primary" onclick="generateReport()">Generate Collection Report</button>
            <button class="btn btn-success" onclick="exportData()">Export Data</button>
        </div>
        
        <!-- Navigation buttons -->
        <div style="margin: 20px 0; text-align: center;">
            <a href="../payment/payment-tracking.jsp" class="btn btn-primary">Payment Tracking</a>
            <a href="../risk/risk-assessment.jsp" class="btn btn-warning">Risk Assessment</a>
            <a href="../customer-search-working.jsp" class="btn btn-secondary">Customer Search</a>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
    
    <script>
        function showContactForm(customerCode) {
            var contactRow = document.getElementById('contact-' + customerCode);
            if (contactRow.style.display === 'none') {
                contactRow.style.display = 'table-row';
            } else {
                contactRow.style.display = 'none';
            }
        }
        
        function escalateAccount(customerCode) {
            if (confirm('Are you sure you want to escalate customer ' + customerCode + ' to legal department?')) {
                var form = document.getElementById('escalation-' + customerCode);
                form.style.display = 'block';
            }
        }
        
        function hideEscalationForm(customerCode) {
            var form = document.getElementById('escalation-' + customerCode);
            form.style.display = 'none';
        }
        
        function followUp(customerCode) {
            if (confirm('Are you sure you want to create a follow-up task for customer ' + customerCode + '?')) {
                alert('Follow-up task created, will remind in 3 days.');
                location.href = 'collections-management.jsp?action=contact&customer=' + customerCode;
            }
        }
        
        function updateStatus(customerCode) {
            var newStatus = prompt('Please enter new status information:', '');
            if (newStatus) {
                alert('Customer ' + customerCode + ' status has been updated to: ' + newStatus);
                location.href = 'collections-management.jsp?action=update_status&customer=' + customerCode;
            }
        }
        
        function viewHistory(customerCode) {
            alert('Will redirect to customer ' + customerCode + ' detailed history page.');
            // window.open('../customer/customer-details.jsp?customerCode=' + customerCode, '_blank');
        }
        
        function batchContact() {
            if (confirm('Are you sure you want to send dunning notices to all overdue customers?')) {
                alert('Batch dunning notices have been sent to 3 customers.');
            }
        }
        
        function batchEscalate() {
            if (confirm('Are you sure you want to submit all 90+ days overdue accounts to legal department?')) {
                alert('1 overdue account has been submitted to legal department.');
            }
        }
        
        function generateReport() {
            alert('Collection report is being generated, will be sent to your email.');
        }
        
        function exportData() {
            alert('Data export in progress, CSV file will be automatically downloaded.');
        }
        
        function applyFilter() {
            alert('Filter function triggered, page will be reloaded.');
        }
        
        function refreshData() {
            location.reload();
        }
    </script>
</body>
</html>