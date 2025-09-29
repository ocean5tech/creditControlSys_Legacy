<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Payment Tracking Interface - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .payment-header { background: #e8f5e8; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #28a745; }
        .customer-summary { background: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .payment-form { background: #f8f9fa; border: 1px solid #ddd; padding: 20px; margin: 15px 0; border-radius: 3px; }
        .payment-history { background: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .form-group { margin: 15px 0; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 5px; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; max-width: 300px; padding: 8px; border: 1px solid #ddd; border-radius: 3px; }
        .form-group textarea { height: 80px; max-width: 500px; }
        .btn { display: inline-block; padding: 10px 20px; margin: 5px; text-decoration: none; border-radius: 3px; border: none; cursor: pointer; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-danger { background: #dc3545; color: white; }
        .payment-table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        .payment-table th, .payment-table td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; }
        .payment-table th { background: #f8f9fa; font-weight: bold; }
        .status-pending { color: #ffc107; font-weight: bold; }
        .status-confirmed { color: #28a745; font-weight: bold; }
        .status-failed { color: #dc3545; font-weight: bold; }
        .amount-large { color: #007bff; font-weight: bold; }
        .summary-cards { display: flex; flex-wrap: wrap; gap: 15px; margin: 20px 0; }
        .summary-card { flex: 1; min-width: 200px; background: white; border: 1px solid #ddd; padding: 15px; border-radius: 3px; text-align: center; }
        .summary-value { font-size: 20px; font-weight: bold; margin: 10px 0; }
        .summary-label { color: #666; font-size: 12px; }
        .success-message { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .error-message { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; margin: 15px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Payment Tracking Interface - Core Business Function 3</p>
    </div>
    
    <div id="main-content">
        <%
        // Database connection and real data operations
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        // Get parameters
        String customerCode = request.getParameter("customerCode");
        if (customerCode == null || customerCode.trim().isEmpty()) {
            customerCode = "CUST001";
        }
        
        String action = request.getParameter("action");
        String paymentAmount = request.getParameter("paymentAmount");
        String paymentMethod = request.getParameter("paymentMethod");
        String paymentReference = request.getParameter("paymentReference");
        String notes = request.getParameter("notes");
        
        // Real customer data from database
        String companyName = "";
        BigDecimal currentBalance = BigDecimal.ZERO;
        BigDecimal creditLimit = BigDecimal.ZERO;
        BigDecimal availableCredit = BigDecimal.ZERO;
        String accountStatus = "";
        String errorMessage = null;
        
        // Payment processing result
        boolean paymentRecorded = false;
        String resultMessage = null;
        String messageType = "success";
        
        // Payment statistics
        BigDecimal totalConfirmed = BigDecimal.ZERO;
        BigDecimal totalPending = BigDecimal.ZERO;
        int confirmedCount = 0, pendingCount = 0;
        
        List<Map<String, Object>> paymentHistory = new ArrayList<>();
        
        try {
            // Database connection
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://35.77.54.203:5432/creditcontrol", "creditapp", "secure123");
            
            // Get customer information
            String customerSql = "SELECT c.customer_code, c.company_name, c.status, " +
                               "cc.credit_limit, cc.available_credit " +
                               "FROM customers c " +
                               "LEFT JOIN customer_credit cc ON c.customer_id = cc.customer_id " +
                               "WHERE c.customer_code = ?";
            
            stmt = conn.prepareStatement(customerSql);
            stmt.setString(1, customerCode);
            rs = stmt.executeQuery();
            
            if (rs.next()) {
                companyName = rs.getString("company_name");
                accountStatus = rs.getString("status");
                creditLimit = rs.getBigDecimal("credit_limit");
                availableCredit = rs.getBigDecimal("available_credit");
                
                if (creditLimit != null && availableCredit != null) {
                    currentBalance = creditLimit.subtract(availableCredit);
                }
            } else {
                errorMessage = "Customer not found: " + customerCode;
            }
            rs.close();
            stmt.close();
            
            // Process payment recording
            if ("record".equals(action) && paymentAmount != null && !paymentAmount.trim().isEmpty() && errorMessage == null) {
                try {
                    BigDecimal amount = new BigDecimal(paymentAmount);
                    if (amount.compareTo(BigDecimal.ZERO) > 0) {
                        // Insert payment record into database
                        String insertPaymentSql = "INSERT INTO payments (customer_code, payment_amount, payment_method, " +
                                                "payment_reference, notes, payment_date, status) " +
                                                "VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, 'PENDING')";
                        
                        stmt = conn.prepareStatement(insertPaymentSql, Statement.RETURN_GENERATED_KEYS);
                        stmt.setString(1, customerCode);
                        stmt.setBigDecimal(2, amount);
                        stmt.setString(3, paymentMethod);
                        stmt.setString(4, paymentReference);
                        stmt.setString(5, notes);
                        
                        int rowsInserted = stmt.executeUpdate();
                        
                        if (rowsInserted > 0) {
                            ResultSet generatedKeys = stmt.getGeneratedKeys();
                            String paymentId = "";
                            if (generatedKeys.next()) {
                                paymentId = "PAY-" + generatedKeys.getLong(1);
                            }
                            generatedKeys.close();
                            
                            paymentRecorded = true;
                            resultMessage = "Payment record created successfully. Payment ID: " + paymentId + 
                                          ", Amount: $" + String.format("%,.2f", amount) + ", Status: Pending Confirmation";
                        } else {
                            resultMessage = "Failed to record payment in database";
                            messageType = "error";
                        }
                        stmt.close();
                    } else {
                        resultMessage = "Payment amount must be greater than 0";
                        messageType = "error";
                    }
                } catch (NumberFormatException e) {
                    resultMessage = "Payment amount format error";
                    messageType = "error";
                } catch (SQLException e) {
                    resultMessage = "Database error during payment recording: " + e.getMessage();
                    messageType = "error";
                }
            }
            
            // Fetch payment history from database
            if (errorMessage == null) {
                String paymentHistorySql = "SELECT payment_id, payment_date, payment_amount, payment_method, " +
                                         "payment_reference, status, notes " +
                                         "FROM payments WHERE customer_code = ? ORDER BY payment_date DESC LIMIT 20";
                
                stmt = conn.prepareStatement(paymentHistorySql);
                stmt.setString(1, customerCode);
                rs = stmt.executeQuery();
                
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                
                while (rs.next()) {
                    Map<String, Object> payment = new HashMap<>();
                    payment.put("paymentId", "PAY-" + rs.getLong("payment_id"));
                    payment.put("paymentDate", sdf.format(rs.getTimestamp("payment_date")));
                    payment.put("amount", rs.getBigDecimal("payment_amount"));
                    payment.put("method", rs.getString("payment_method"));
                    payment.put("reference", rs.getString("payment_reference"));
                    payment.put("status", rs.getString("status"));
                    payment.put("notes", rs.getString("notes"));
                    
                    paymentHistory.add(payment);
                    
                    // Calculate statistics
                    BigDecimal amount = rs.getBigDecimal("payment_amount");
                    String status = rs.getString("status");
                    if ("CONFIRMED".equals(status)) {
                        totalConfirmed = totalConfirmed.add(amount);
                        confirmedCount++;
                    } else if ("PENDING".equals(status)) {
                        totalPending = totalPending.add(amount);
                        pendingCount++;
                    }
                }
                rs.close();
                stmt.close();
            }
            
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
        
        <!-- Page title -->
        <div class="payment-header">
            <h2>Payment Tracking Management</h2>
            <p>Customer: <strong><%= companyName %> (<%= customerCode %>)</strong></p>
        </div>
        
        <!-- Customer account summary -->
        <div class="customer-summary">
            <h3>Account Overview</h3>
            <div class="summary-cards">
                <div class="summary-card">
                    <div class="summary-value" style="color: #dc3545;">$<%= String.format("%,.2f", currentBalance) %></div>
                    <div class="summary-label">Current Outstanding Balance</div>
                </div>
                <div class="summary-card">
                    <div class="summary-value" style="color: #007bff;">$<%= String.format("%,.2f", creditLimit) %></div>
                    <div class="summary-label">Credit Limit</div>
                </div>
                <div class="summary-card">
                    <div class="summary-value" style="color: #28a745;">$<%= String.format("%,.2f", availableCredit) %></div>
                    <div class="summary-label">Available Credit</div>
                </div>
                <div class="summary-card">
                    <div class="summary-value" style="color: #6c757d;"><%= accountStatus %></div>
                    <div class="summary-label">Account Status</div>
                </div>
            </div>
        </div>
        
        <!-- Payment statistics -->
        <div class="customer-summary">
            <h3>Payment Statistics</h3>
            <div class="summary-cards">
                <div class="summary-card">
                    <div class="summary-value" style="color: #28a745;">$<%= String.format("%,.2f", totalConfirmed) %></div>
                    <div class="summary-label">Confirmed Payments (<%= confirmedCount %> transactions)</div>
                </div>
                <div class="summary-card">
                    <div class="summary-value" style="color: #ffc107;">$<%= String.format("%,.2f", totalPending) %></div>
                    <div class="summary-label">Pending Payments (<%= pendingCount %> transactions)</div>
                </div>
                <div class="summary-card">
                    <div class="summary-value" style="color: #007bff;">$<%= String.format("%,.2f", totalConfirmed.add(totalPending)) %></div>
                    <div class="summary-label">Total Payment Amount</div>
                </div>
            </div>
        </div>
        
        <!-- Result message -->
        <% if (resultMessage != null) { %>
        <div class="<%= "success".equals(messageType) ? "success-message" : "error-message" %>">
            <%= resultMessage %>
        </div>
        <% } %>
        
        <!-- Payment record form -->
        <div class="payment-form">
            <h3>Record New Payment</h3>
            <form method="post" action="payment-tracking.jsp">
                <input type="hidden" name="customerCode" value="<%= customerCode %>">
                <input type="hidden" name="action" value="record">
                
                <div class="form-group">
                    <label for="paymentAmount">Payment Amount ($):</label>
                    <input type="text" id="paymentAmount" name="paymentAmount" placeholder="Enter payment amount" required>
                </div>
                
                <div class="form-group">
                    <label for="paymentMethod">Payment Method:</label>
                    <select id="paymentMethod" name="paymentMethod" required>
                        <option value="">Select payment method</option>
                        <option value="Bank Transfer">Bank Transfer</option>
                        <option value="Check">Check</option>
                        <option value="Electronic Transfer">Electronic Transfer</option>
                        <option value="Cash">Cash</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="paymentReference">Payment Reference:</label>
                    <input type="text" id="paymentReference" name="paymentReference" placeholder="Transaction/Check number etc.">
                </div>
                
                <div class="form-group">
                    <label for="notes">Notes:</label>
                    <textarea id="notes" name="notes" placeholder="Payment related notes"></textarea>
                </div>
                
                <div class="form-group">
                    <button type="submit" class="btn btn-success">Record Payment</button>
                    <button type="reset" class="btn btn-secondary">Clear Form</button>
                </div>
            </form>
        </div>
        
        <!-- Payment history -->
        <div class="payment-history">
            <h3>Payment History</h3>
            <% if (paymentHistory.isEmpty()) { %>
                <p>No payment records found for this customer.</p>
            <% } else { %>
            <table class="payment-table">
                <thead>
                    <tr>
                        <th>Payment ID</th>
                        <th>Payment Date</th>
                        <th>Amount</th>
                        <th>Payment Method</th>
                        <th>Reference</th>
                        <th>Status</th>
                        <th>Notes</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> payment : paymentHistory) { 
                       String status = (String)payment.get("status");
                       BigDecimal amount = (BigDecimal)payment.get("amount");
                    %>
                    <tr>
                        <td><%= payment.get("paymentId") %></td>
                        <td><%= payment.get("paymentDate") %></td>
                        <td class="amount-large">$<%= String.format("%,.2f", amount) %></td>
                        <td><%= payment.get("method") %></td>
                        <td><%= payment.get("reference") != null ? payment.get("reference") : "" %></td>
                        <td class="status-<%= status.toLowerCase() %>">
                            <% if ("CONFIRMED".equals(status)) { %>
                                Confirmed
                            <% } else if ("PENDING".equals(status)) { %>
                                Pending
                            <% } else { %>
                                Failed
                            <% } %>
                        </td>
                        <td><%= payment.get("notes") != null ? payment.get("notes") : "" %></td>
                        <td>
                            <% if ("PENDING".equals(status)) { %>
                                <button class="btn btn-primary" style="padding: 3px 8px; font-size: 12px;" onclick="confirmPayment('<%= payment.get("paymentId") %>')">Confirm</button>
                                <button class="btn btn-danger" style="padding: 3px 8px; font-size: 12px;" onclick="rejectPayment('<%= payment.get("paymentId") %>')">Reject</button>
                            <% } else { %>
                                <button class="btn btn-secondary" style="padding: 3px 8px; font-size: 12px;">View Details</button>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
        
        <!-- Quick action buttons -->
        <div style="margin: 20px 0; text-align: center;">
            <a href="../customer/customer-details.jsp?customerCode=<%= customerCode %>" class="btn btn-primary">Customer Details</a>
            <a href="../risk/risk-assessment.jsp?customerCode=<%= customerCode %>" class="btn btn-warning">Risk Assessment</a>
            <a href="../customer-search-working.jsp" class="btn btn-secondary">Back to Search</a>
        </div>
        
        <% } %>
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
    
    <script>
        function confirmPayment(paymentId) {
            if (confirm('Are you sure you want to confirm payment ' + paymentId + '?')) {
                // In a real system, this would send an AJAX request to update the database
                alert('Payment ' + paymentId + ' confirmation functionality requires additional implementation');
            }
        }
        
        function rejectPayment(paymentId) {
            if (confirm('Are you sure you want to reject payment ' + paymentId + '?')) {
                // In a real system, this would send an AJAX request to update the database
                alert('Payment ' + paymentId + ' rejection functionality requires additional implementation');
            }
        }
    </script>
</body>
</html>