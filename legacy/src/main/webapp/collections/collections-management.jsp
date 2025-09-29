<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
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
        .success-message { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .error-message { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; margin: 15px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Collections Management - Collections Officer Interface</p>
    </div>
    
    <div id="main-content">
        <%
        // Database connection and real data operations
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        // Get parameters and filters
        String filterPriority = request.getParameter("priority");
        String filterOverdue = request.getParameter("overdue");
        String action = request.getParameter("action");
        String targetCustomer = request.getParameter("customer");
        String contactNotes = request.getParameter("contactNotes");
        String contactMethod = request.getParameter("contactMethod");
        String followUpRequired = request.getParameter("followUpRequired");
        
        List<Map<String, Object>> overdueAccounts = new ArrayList<>();
        List<Map<String, Object>> contactLogs = new ArrayList<>();
        
        // Statistics
        BigDecimal totalOverdue = BigDecimal.ZERO;
        int highPriorityCount = 0, mediumPriorityCount = 0, lowPriorityCount = 0;
        int overdue30 = 0, overdue60 = 0, overdue90 = 0;
        String errorMessage = null;
        String actionResult = null;
        
        try {
            // Database connection
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://172.31.19.10:5432/creditcontrol", "creditapp", "secure123");
            
            // Process actions
            if ("contact".equals(action) && targetCustomer != null && contactNotes != null) {
                // Log contact attempt
                String insertContactSql = "INSERT INTO contact_logs (customer_code, contact_method, contact_person, notes, follow_up_required, follow_up_date) " +
                                        "VALUES (?, ?, 'Collections Officer', ?, ?, ?)";
                
                stmt = conn.prepareStatement(insertContactSql);
                stmt.setString(1, targetCustomer);
                stmt.setString(2, contactMethod != null ? contactMethod : "Phone");
                stmt.setString(3, contactNotes);
                stmt.setBoolean(4, "true".equals(followUpRequired));
                if ("true".equals(followUpRequired)) {
                    stmt.setDate(5, new java.sql.Date(System.currentTimeMillis() + 7 * 24 * 60 * 60 * 1000L)); // 7 days from now
                } else {
                    stmt.setNull(5, Types.DATE);
                }
                
                int contactInserted = stmt.executeUpdate();
                stmt.close();
                
                if (contactInserted > 0) {
                    // Update contact attempts count
                    String updateContactCountSql = "UPDATE collections SET contact_attempts = contact_attempts + 1, " +
                                                 "last_contact_date = CURRENT_DATE WHERE customer_code = ?";
                    stmt = conn.prepareStatement(updateContactCountSql);
                    stmt.setString(1, targetCustomer);
                    stmt.executeUpdate();
                    stmt.close();
                    
                    actionResult = "Contact logged successfully for customer " + targetCustomer;
                } else {
                    actionResult = "Failed to log contact for customer " + targetCustomer;
                }
                
            } else if ("escalate".equals(action) && targetCustomer != null) {
                // Update status to escalated
                String updateStatusSql = "UPDATE collections SET status = 'ESCALATED', priority = 'HIGH', " +
                                       "assigned_officer = 'Legal Department' WHERE customer_code = ?";
                stmt = conn.prepareStatement(updateStatusSql);
                stmt.setString(1, targetCustomer);
                int updated = stmt.executeUpdate();
                stmt.close();
                
                if (updated > 0) {
                    actionResult = "Customer " + targetCustomer + " has been escalated to legal department.";
                } else {
                    actionResult = "Failed to escalate customer " + targetCustomer;
                }
                
            } else if ("update_status".equals(action) && targetCustomer != null) {
                String newStatus = request.getParameter("newStatus");
                if (newStatus != null) {
                    String updateStatusSql = "UPDATE collections SET status = ? WHERE customer_code = ?";
                    stmt = conn.prepareStatement(updateStatusSql);
                    stmt.setString(1, newStatus);
                    stmt.setString(2, targetCustomer);
                    int updated = stmt.executeUpdate();
                    stmt.close();
                    
                    if (updated > 0) {
                        actionResult = "Status updated successfully for customer " + targetCustomer;
                    } else {
                        actionResult = "Failed to update status for customer " + targetCustomer;
                    }
                }
            }
            
            // Fetch overdue accounts from database with customer details
            String overdueAccountsSql = "SELECT c.customer_code, c.company_name, " +
                                      "cc.credit_rating, col.overdue_amount, col.overdue_days, " +
                                      "col.priority, col.status, col.assigned_officer, " +
                                      "col.contact_attempts, col.last_contact_date, " +
                                      "cc.credit_limit, cc.available_credit " +
                                      "FROM collections col " +
                                      "JOIN customers c ON col.customer_code = c.customer_code " +
                                      "LEFT JOIN customer_credit cc ON c.customer_id = cc.customer_id ";
            
            // Apply filters
            List<String> whereConditions = new ArrayList<>();
            if (filterPriority != null && !filterPriority.trim().isEmpty()) {
                whereConditions.add("col.priority = ?");
            }
            if (filterOverdue != null && !filterOverdue.trim().isEmpty()) {
                if ("30+".equals(filterOverdue)) {
                    whereConditions.add("col.overdue_days >= 30");
                } else if ("60+".equals(filterOverdue)) {
                    whereConditions.add("col.overdue_days >= 60");
                } else if ("90+".equals(filterOverdue)) {
                    whereConditions.add("col.overdue_days >= 90");
                }
            }
            
            if (!whereConditions.isEmpty()) {
                overdueAccountsSql += " WHERE " + String.join(" AND ", whereConditions);
            }
            overdueAccountsSql += " ORDER BY col.overdue_days DESC, col.overdue_amount DESC";
            
            stmt = conn.prepareStatement(overdueAccountsSql);
            int paramIndex = 1;
            if (filterPriority != null && !filterPriority.trim().isEmpty()) {
                stmt.setString(paramIndex++, filterPriority);
            }
            
            rs = stmt.executeQuery();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            
            while (rs.next()) {
                Map<String, Object> account = new HashMap<>();
                account.put("customerCode", rs.getString("customer_code"));
                account.put("companyName", rs.getString("company_name"));
                account.put("creditRating", rs.getString("credit_rating"));
                account.put("overdueAmount", rs.getBigDecimal("overdue_amount"));
                account.put("overdueDays", rs.getInt("overdue_days"));
                account.put("priority", rs.getString("priority"));
                account.put("status", rs.getString("status"));
                account.put("assignedOfficer", rs.getString("assigned_officer"));
                account.put("contactAttempts", rs.getInt("contact_attempts"));
                
                Date lastContactDate = rs.getDate("last_contact_date");
                if (lastContactDate != null) {
                    account.put("lastContact", sdf.format(lastContactDate));
                } else {
                    account.put("lastContact", "Never");
                }
                
                BigDecimal creditLimit = rs.getBigDecimal("credit_limit");
                BigDecimal availableCredit = rs.getBigDecimal("available_credit");
                if (creditLimit != null && availableCredit != null) {
                    account.put("totalBalance", creditLimit.subtract(availableCredit));
                } else {
                    account.put("totalBalance", rs.getBigDecimal("overdue_amount"));
                }
                
                overdueAccounts.add(account);
                
                // Calculate statistics
                totalOverdue = totalOverdue.add(rs.getBigDecimal("overdue_amount"));
                String priority = rs.getString("priority");
                int days = rs.getInt("overdue_days");
                
                if ("HIGH".equals(priority)) highPriorityCount++;
                else if ("MEDIUM".equals(priority)) mediumPriorityCount++;
                else lowPriorityCount++;
                
                if (days >= 90) overdue90++;
                else if (days >= 60) overdue60++;
                else if (days >= 30) overdue30++;
            }
            rs.close();
            stmt.close();
            
            // Fetch recent contact logs
            String contactLogsSql = "SELECT cl.customer_code, c.company_name, cl.contact_date, " +
                                  "cl.contact_method, cl.contact_person, cl.notes, " +
                                  "cl.follow_up_required, cl.follow_up_date " +
                                  "FROM contact_logs cl " +
                                  "JOIN customers c ON cl.customer_code = c.customer_code " +
                                  "ORDER BY cl.contact_date DESC LIMIT 10";
            
            stmt = conn.prepareStatement(contactLogsSql);
            rs = stmt.executeQuery();
            
            SimpleDateFormat contactSdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            while (rs.next()) {
                Map<String, Object> log = new HashMap<>();
                log.put("customerCode", rs.getString("customer_code"));
                log.put("companyName", rs.getString("company_name"));
                log.put("contactDate", contactSdf.format(rs.getTimestamp("contact_date")));
                log.put("contactMethod", rs.getString("contact_method"));
                log.put("contactPerson", rs.getString("contact_person"));
                log.put("notes", rs.getString("notes"));
                log.put("followUpRequired", rs.getBoolean("follow_up_required"));
                
                Date followUpDate = rs.getDate("follow_up_date");
                if (followUpDate != null) {
                    log.put("followUpDate", sdf.format(followUpDate));
                } else {
                    log.put("followUpDate", null);
                }
                
                contactLogs.add(log);
            }
            rs.close();
            stmt.close();
            
        } catch (Exception e) {
            errorMessage = "Database connection error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        %>
        
        <% if (errorMessage != null) { %>
        <div class="error-message">
            <strong>Error:</strong> <%= errorMessage %>
        </div>
        <% } else { %>
        
        <!-- Page title and alerts -->
        <div class="collections-header">
            <h2>Overdue Account Management</h2>
            <p>Collections Officer Dashboard - Overdue Account Collection Management</p>
        </div>
        
        <% if (overdue90 > 0) { %>
        <div class="alert-overdue">
            <strong>Critical Alert:</strong> <%= overdue90 %> accounts are overdue 90+ days requiring immediate legal action!
        </div>
        <% } %>
        
        <% if (overdue60 > 0) { %>
        <div class="alert-warning">
            <strong>Warning:</strong> <%= overdue60 %> accounts are overdue 60+ days requiring escalation procedures.
        </div>
        <% } %>
        
        <!-- Result message -->
        <% if (actionResult != null) { %>
        <div class="success-message">
            <%= actionResult %>
        </div>
        <% } %>
        
        <!-- Collections statistics -->
        <div class="collections-summary">
            <h3>Collections Overview</h3>
            <div class="stats-cards">
                <div class="stats-card">
                    <div class="stats-value" style="color: #dc3545;">$<%= String.format("%,.2f", totalOverdue) %></div>
                    <div class="stats-label">Total Overdue Amount</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #dc3545;"><%= overdue90 %></div>
                    <div class="stats-label">90+ Days Overdue</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #fd7e14;"><%= overdue60 %></div>
                    <div class="stats-label">60+ Days Overdue</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #ffc107;"><%= overdue30 %></div>
                    <div class="stats-label">30+ Days Overdue</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #dc3545;"><%= highPriorityCount %></div>
                    <div class="stats-label">High Priority</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #ffc107;"><%= mediumPriorityCount %></div>
                    <div class="stats-label">Medium Priority</div>
                </div>
                <div class="stats-card">
                    <div class="stats-value" style="color: #17a2b8;"><%= lowPriorityCount %></div>
                    <div class="stats-label">Low Priority</div>
                </div>
            </div>
        </div>
        
        <!-- Filter section -->
        <div class="filter-section">
            <h4>Filter Overdue Accounts</h4>
            <form method="get" action="collections-management.jsp" style="display: inline-block;">
                <label>Priority:</label>
                <select name="priority">
                    <option value="">All Priorities</option>
                    <option value="HIGH" <%= "HIGH".equals(filterPriority) ? "selected" : "" %>>High</option>
                    <option value="MEDIUM" <%= "MEDIUM".equals(filterPriority) ? "selected" : "" %>>Medium</option>
                    <option value="LOW" <%= "LOW".equals(filterPriority) ? "selected" : "" %>>Low</option>
                </select>
                
                <label>Overdue Days:</label>
                <select name="overdue">
                    <option value="">All</option>
                    <option value="30+" <%= "30+".equals(filterOverdue) ? "selected" : "" %>>30+ Days</option>
                    <option value="60+" <%= "60+".equals(filterOverdue) ? "selected" : "" %>>60+ Days</option>
                    <option value="90+" <%= "90+".equals(filterOverdue) ? "selected" : "" %>>90+ Days</option>
                </select>
                
                <button type="submit" class="btn btn-primary">Apply Filters</button>
                <a href="collections-management.jsp" class="btn btn-secondary">Clear Filters</a>
            </form>
        </div>
        
        <!-- Overdue accounts table -->
        <div class="overdue-accounts">
            <h3>Overdue Accounts (<%= overdueAccounts.size() %> accounts)</h3>
            <% if (overdueAccounts.isEmpty()) { %>
                <p>No overdue accounts found matching the current filters.</p>
            <% } else { %>
            <table class="accounts-table">
                <thead>
                    <tr>
                        <th>Customer</th>
                        <th>Company Name</th>
                        <th>Credit Rating</th>
                        <th>Overdue Amount</th>
                        <th>Total Balance</th>
                        <th>Days Overdue</th>
                        <th>Priority</th>
                        <th>Status</th>
                        <th>Contact Attempts</th>
                        <th>Last Contact</th>
                        <th>Assigned Officer</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> account : overdueAccounts) {
                       String priority = (String)account.get("priority");
                       int days = (Integer)account.get("overdueDays");
                       String customerCode = (String)account.get("customerCode");
                    %>
                    <tr class="priority-<%= priority.toLowerCase() %>">
                        <td><%= account.get("customerCode") %></td>
                        <td><%= account.get("companyName") %></td>
                        <td><%= account.get("creditRating") != null ? account.get("creditRating") : "N/A" %></td>
                        <td class="amount-overdue">$<%= String.format("%,.2f", (BigDecimal)account.get("overdueAmount")) %></td>
                        <td>$<%= String.format("%,.2f", (BigDecimal)account.get("totalBalance")) %></td>
                        <td class="<%= days >= 90 ? "overdue-90" : days >= 60 ? "overdue-60" : "overdue-30" %>">
                            <%= days %> days
                        </td>
                        <td><%= priority %></td>
                        <td><%= account.get("status") %></td>
                        <td><%= account.get("contactAttempts") %></td>
                        <td><%= account.get("lastContact") %></td>
                        <td><%= account.get("assignedOfficer") != null ? account.get("assignedOfficer") : "Unassigned" %></td>
                        <td>
                            <button class="btn btn-primary" onclick="logContact('<%= customerCode %>')">Log Contact</button>
                            <% if (days >= 90) { %>
                            <a href="collections-management.jsp?action=escalate&customer=<%= customerCode %>" 
                               class="btn btn-danger" onclick="return confirm('Escalate to legal department?')">Escalate</a>
                            <% } %>
                            <a href="../customer/customer-details.jsp?customerCode=<%= customerCode %>" class="btn btn-secondary">View Details</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
        
        <!-- Contact log form (initially hidden) -->
        <div id="contactForm" class="escalation-form">
            <h4>Log Customer Contact</h4>
            <form method="post" action="collections-management.jsp">
                <input type="hidden" name="action" value="contact">
                <input type="hidden" name="customer" id="contactCustomer">
                
                <div style="margin: 10px 0;">
                    <label>Contact Method:</label>
                    <select name="contactMethod" style="width: 200px;">
                        <option value="Phone">Phone</option>
                        <option value="Email">Email</option>
                        <option value="Letter">Letter</option>
                        <option value="In Person">In Person</option>
                    </select>
                </div>
                
                <div style="margin: 10px 0;">
                    <label>Contact Notes:</label><br>
                    <textarea name="contactNotes" rows="4" cols="50" placeholder="Enter contact details and customer response..." required></textarea>
                </div>
                
                <div style="margin: 10px 0;">
                    <label>
                        <input type="checkbox" name="followUpRequired" value="true">
                        Follow-up required (automatically schedules for 7 days)
                    </label>
                </div>
                
                <div style="margin: 10px 0;">
                    <button type="submit" class="btn btn-success">Log Contact</button>
                    <button type="button" class="btn btn-secondary" onclick="hideContactForm()">Cancel</button>
                </div>
            </form>
        </div>
        
        <!-- Recent contact logs -->
        <div class="overdue-accounts">
            <h3>Recent Contact Logs</h3>
            <% if (contactLogs.isEmpty()) { %>
                <p>No contact logs found.</p>
            <% } else { %>
                <% for (Map<String, Object> log : contactLogs) { %>
                <div class="contact-log">
                    <span class="contact-date"><%= log.get("contactDate") %></span> - 
                    <strong><%= log.get("customerCode") %></strong> (<%= log.get("companyName") %>) - 
                    <%= log.get("contactMethod") %> by <%= log.get("contactPerson") %>
                    <br>
                    <em><%= log.get("notes") %></em>
                    <% if ((Boolean)log.get("followUpRequired")) { %>
                        <br><strong>Follow-up required by: <%= log.get("followUpDate") %></strong>
                    <% } %>
                </div>
                <% } %>
            <% } %>
        </div>
        
        <!-- Quick action buttons -->
        <div style="margin: 20px 0; text-align: center;">
            <a href="../customer-search-working.jsp" class="btn btn-primary">Customer Search</a>
            <a href="../payment/payment-tracking.jsp" class="btn btn-warning">Payment Tracking</a>
            <a href="../reports/reports-dashboard.jsp" class="btn btn-secondary">Reports Dashboard</a>
        </div>
        
        <% } %>
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
    
    <script>
        function logContact(customerCode) {
            document.getElementById('contactCustomer').value = customerCode;
            document.getElementById('contactForm').style.display = 'block';
            document.getElementById('contactForm').scrollIntoView();
        }
        
        function hideContactForm() {
            document.getElementById('contactForm').style.display = 'none';
        }
    </script>
</body>
</html>