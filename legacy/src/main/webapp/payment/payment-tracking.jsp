<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.util.*, java.text.SimpleDateFormat" %>
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
        
        // Simulate customer data
        String companyName = "ABC Manufacturing Ltd";
        BigDecimal currentBalance = new BigDecimal("45000");
        BigDecimal creditLimit = new BigDecimal("200000");
        String accountStatus = "ACTIVE";
        
        // Process payment records
        boolean paymentRecorded = false;
        String resultMessage = null;
        String messageType = "success";
        
        if ("record".equals(action) && paymentAmount != null && !paymentAmount.trim().isEmpty()) {
            try {
                BigDecimal amount = new BigDecimal(paymentAmount);
                if (amount.compareTo(BigDecimal.ZERO) > 0) {
                    // Simple validation successful
                    paymentRecorded = true;
                    resultMessage = "Payment record created successfully. Payment amount: $" + String.format("%,.2f", amount) + ", awaiting confirmation.";
                    
                    // Simulate balance update
                    currentBalance = currentBalance.subtract(amount);
                    if (currentBalance.compareTo(BigDecimal.ZERO) < 0) {
                        currentBalance = BigDecimal.ZERO;
                    }
                } else {
                    resultMessage = "Payment amount must be greater than 0";
                    messageType = "error";
                }
            } catch (NumberFormatException e) {
                resultMessage = "Payment amount format error";
                messageType = "error";
            }
        }
        
        // Simulate payment history data
        List<Map<String, Object>> paymentHistory = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        Calendar cal = Calendar.getInstance();
        
        // Historical payment 1
        Map<String, Object> payment1 = new HashMap<>();
        payment1.put("paymentId", "PAY-2025-001");
        cal.add(Calendar.DAY_OF_MONTH, -5);
        payment1.put("paymentDate", sdf.format(cal.getTime()));
        payment1.put("amount", new BigDecimal("25000"));
        payment1.put("method", "Bank Transfer");
        payment1.put("reference", "TXN20250120001");
        payment1.put("status", "CONFIRMED");
        payment1.put("notes", "Regular payment");
        paymentHistory.add(payment1);
        
        // Historical payment 2
        Map<String, Object> payment2 = new HashMap<>();
        payment2.put("paymentId", "PAY-2025-002");
        cal.add(Calendar.DAY_OF_MONTH, -3);
        payment2.put("paymentDate", sdf.format(cal.getTime()));
        payment2.put("amount", new BigDecimal("15000"));
        payment2.put("method", "Check");
        payment2.put("reference", "CHK-789456");
        payment2.put("status", "PENDING");
        payment2.put("notes", "Supplemental payment");
        paymentHistory.add(payment2);
        
        // Historical payment 3
        Map<String, Object> payment3 = new HashMap<>();
        payment3.put("paymentId", "PAY-2025-003");
        cal.add(Calendar.DAY_OF_MONTH, -1);
        payment3.put("paymentDate", sdf.format(cal.getTime()));
        payment3.put("amount", new BigDecimal("5000"));
        payment3.put("method", "Electronic Transfer");
        payment3.put("reference", "EFT-456789");
        payment3.put("status", "CONFIRMED");
        payment3.put("notes", "Partial payment");
        paymentHistory.add(payment3);
        
        // Statistical data
        BigDecimal totalConfirmed = BigDecimal.ZERO;
        BigDecimal totalPending = BigDecimal.ZERO;
        int confirmedCount = 0, pendingCount = 0;
        
        for (Map<String, Object> payment : paymentHistory) {
            BigDecimal amount = (BigDecimal)payment.get("amount");
            String status = (String)payment.get("status");
            if ("CONFIRMED".equals(status)) {
                totalConfirmed = totalConfirmed.add(amount);
                confirmedCount++;
            } else if ("PENDING".equals(status)) {
                totalPending = totalPending.add(amount);
                pendingCount++;
            }
        }
        %>
        
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
                    <div class="summary-value" style="color: #28a745;">$<%= String.format("%,.2f", creditLimit.subtract(currentBalance)) %></div>
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
                        <td><%= payment.get("reference") %></td>
                        <td class="status-<%= status.toLowerCase() %>">
                            <% if ("CONFIRMED".equals(status)) { %>
                                Confirmed
                            <% } else if ("PENDING".equals(status)) { %>
                                Pending
                            <% } else { %>
                                Failed
                            <% } %>
                        </td>
                        <td><%= payment.get("notes") %></td>
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
        </div>
        
        <!-- Quick action buttons -->
        <div style="margin: 20px 0; text-align: center;">
            <a href="../customer/customer-details.jsp?customerCode=<%= customerCode %>" class="btn btn-primary">Customer Details</a>
            <a href="../risk/risk-assessment.jsp?customerCode=<%= customerCode %>" class="btn btn-warning">Risk Assessment</a>
            <a href="../customer-search-working.jsp" class="btn btn-secondary">Back to Search</a>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
    
    <script>
        function confirmPayment(paymentId) {
            if (confirm('Are you sure you want to confirm payment ' + paymentId + '?')) {
                alert('Payment ' + paymentId + ' has been confirmed');
                // In actual system, this would send AJAX request to server
                location.reload();
            }
        }
        
        function rejectPayment(paymentId) {
            if (confirm('Are you sure you want to reject payment ' + paymentId + '?')) {
                alert('Payment ' + paymentId + ' has been rejected');
                // In actual system, this would send AJAX request to server
                location.reload();
            }
        }
    </script>
</body>
</html>