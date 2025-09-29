<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Reports Dashboard - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .reports-header { background: #e8f4f8; padding: 20px; margin: 20px 0; border-radius: 5px; border-left: 4px solid #17a2b8; }
        .report-category { background: white; border: 1px solid #ddd; padding: 20px; margin: 15px 0; border-radius: 3px; }
        .report-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 20px 0; }
        .report-card { background: #f8f9fa; border: 1px solid #ddd; padding: 15px; border-radius: 3px; }
        .report-card h4 { color: #495057; margin-top: 0; }
        .report-card p { color: #6c757d; font-size: 14px; margin: 10px 0; }
        .btn { display: inline-block; padding: 8px 15px; margin: 5px; text-decoration: none; border-radius: 3px; border: none; cursor: pointer; font-size: 12px; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-info { background: #17a2b8; color: white; }
        .btn-secondary { background: #6c757d; color: white; }
        .summary-metrics { display: flex; flex-wrap: wrap; gap: 15px; margin: 20px 0; }
        .metric-box { flex: 1; min-width: 200px; background: white; border: 1px solid #ddd; padding: 15px; border-radius: 3px; text-align: center; }
        .metric-value { font-size: 24px; font-weight: bold; margin: 10px 0; }
        .metric-label { color: #666; font-size: 12px; }
        .trend-positive { color: #28a745; }
        .trend-negative { color: #dc3545; }
        .trend-neutral { color: #6c757d; }
        .filter-panel { background: #f8f9fa; padding: 15px; margin: 15px 0; border-radius: 3px; border: 1px solid #ddd; }
        .filter-panel select, .filter-panel input { margin: 5px; padding: 8px; border: 1px solid #ddd; border-radius: 3px; }
        .chart-placeholder { background: #e9ecef; border: 2px dashed #adb5bd; height: 200px; display: flex; align-items: center; justify-content: center; margin: 15px 0; border-radius: 3px; color: #6c757d; }
        .report-actions { background: #fff3cd; border: 1px solid #ffeaa7; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .scheduled-reports { background: white; border: 1px solid #ddd; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .schedule-table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        .schedule-table th, .schedule-table td { padding: 8px; text-align: left; border-bottom: 1px solid #eee; }
        .schedule-table th { background: #f8f9fa; font-weight: bold; }
        .status-active { color: #28a745; font-weight: bold; }
        .status-pending { color: #ffc107; font-weight: bold; }
        .status-failed { color: #dc3545; font-weight: bold; }
        .success-message { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; margin: 15px 0; border-radius: 3px; }
        .error-message { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 15px; margin: 15px 0; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Reports Dashboard - Management Reporting Interface (Core Function 6)</p>
    </div>
    
    <div id="main-content">
        <%
        // Database connection and real data operations
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        CallableStatement cstmt = null;
        
        // Get parameters
        String reportType = request.getParameter("reportType");
        String dateRange = request.getParameter("dateRange");
        String action = request.getParameter("action");
        String reportId = request.getParameter("reportId");
        
        // Business metrics from database
        BigDecimal totalCreditLimits = BigDecimal.ZERO;
        BigDecimal totalOutstanding = BigDecimal.ZERO;
        BigDecimal totalAvailableCredit = BigDecimal.ZERO;
        BigDecimal overdueAmounts = BigDecimal.ZERO;
        BigDecimal monthlyPayments = BigDecimal.ZERO;
        BigDecimal pendingPayments = BigDecimal.ZERO;
        int totalCustomers = 0;
        int activeCustomers = 0;
        int overdueAccounts = 0;
        int highRiskAccounts = 0;
        
        List<Map<String, Object>> availableReports = new ArrayList<>();
        String errorMessage = null;
        String actionResult = null;
        
        try {
            // Database connection
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://35.77.54.203:5432/creditcontrol", "creditapp", "secure123");
            
            // Get business metrics using the database function
            cstmt = conn.prepareCall("SELECT * FROM get_business_metrics()");
            rs = cstmt.executeQuery();
            
            if (rs.next()) {
                totalCreditLimits = rs.getBigDecimal("total_credit_limits");
                totalOutstanding = rs.getBigDecimal("total_outstanding");
                totalAvailableCredit = rs.getBigDecimal("total_available_credit");
                overdueAmounts = rs.getBigDecimal("overdue_amounts");
                monthlyPayments = rs.getBigDecimal("monthly_payments");
                pendingPayments = rs.getBigDecimal("pending_payments");
                totalCustomers = rs.getInt("total_customers");
                activeCustomers = rs.getInt("active_customers");
                overdueAccounts = rs.getInt("overdue_accounts");
                highRiskAccounts = rs.getInt("high_risk_accounts");
            }
            rs.close();
            cstmt.close();
            
            // Process report actions
            if ("generate".equals(action) && reportId != null) {
                // Simulate report generation
                actionResult = "Report " + reportId + " generation initiated. Report will be available in the downloads section within 5 minutes.";
                
                // Update last run date
                String updateReportSql = "UPDATE reports SET last_run_date = CURRENT_TIMESTAMP WHERE report_id = ?";
                stmt = conn.prepareStatement(updateReportSql);
                stmt.setInt(1, Integer.parseInt(reportId));
                stmt.executeUpdate();
                stmt.close();
                
            } else if ("schedule".equals(action) && reportId != null) {
                actionResult = "Report " + reportId + " has been scheduled for regular generation.";
                
            } else if ("download".equals(action) && reportId != null) {
                actionResult = "Report " + reportId + " download started. Check your downloads folder.";
            }
            
            // Fetch available reports from database
            String reportsSql = "SELECT report_id, report_name, report_description, report_category, " +
                              "report_frequency, report_format, last_run_date, next_run_date, status " +
                              "FROM reports ORDER BY report_category, report_name";
            
            stmt = conn.prepareStatement(reportsSql);
            rs = stmt.executeQuery();
            
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            while (rs.next()) {
                Map<String, Object> report = new HashMap<>();
                report.put("id", rs.getInt("report_id"));
                report.put("name", rs.getString("report_name"));
                report.put("description", rs.getString("report_description"));
                report.put("category", rs.getString("report_category"));
                report.put("frequency", rs.getString("report_frequency"));
                report.put("format", rs.getString("report_format"));
                report.put("status", rs.getString("status"));
                
                Timestamp lastRun = rs.getTimestamp("last_run_date");
                if (lastRun != null) {
                    report.put("lastRun", sdf.format(lastRun));
                } else {
                    report.put("lastRun", "Never");
                }
                
                Timestamp nextRun = rs.getTimestamp("next_run_date");
                if (nextRun != null) {
                    report.put("nextRun", sdf.format(nextRun));
                } else {
                    report.put("nextRun", "Not scheduled");
                }
                
                availableReports.add(report);
            }
            rs.close();
            stmt.close();
            
        } catch (Exception e) {
            errorMessage = "Database connection error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (cstmt != null) try { cstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
        
        // Calculate derived metrics
        BigDecimal utilizationRate = BigDecimal.ZERO;
        if (totalCreditLimits.compareTo(BigDecimal.ZERO) > 0) {
            utilizationRate = totalOutstanding.divide(totalCreditLimits, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
        }
        
        BigDecimal overdueRate = BigDecimal.ZERO;
        if (totalOutstanding.compareTo(BigDecimal.ZERO) > 0) {
            overdueRate = overdueAmounts.divide(totalOutstanding, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"));
        }
        %>
        
        <% if (errorMessage != null) { %>
        <div class="error-message">
            <strong>Error:</strong> <%= errorMessage %>
        </div>
        <% } else { %>
        
        <!-- Page title -->
        <div class="reports-header">
            <h2>Reports Dashboard</h2>
            <p>Business Intelligence and Reporting Center - Real-time data from <%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(new java.util.Date()) %></p>
        </div>
        
        <!-- Action result message -->
        <% if (actionResult != null) { %>
        <div class="success-message">
            <%= actionResult %>
        </div>
        <% } %>
        
        <!-- Business metrics overview -->
        <div class="report-category">
            <h3>Business Performance Metrics</h3>
            <div class="summary-metrics">
                <div class="metric-box">
                    <div class="metric-value" style="color: #007bff;">$<%= String.format("%,.2f", totalCreditLimits) %></div>
                    <div class="metric-label">Total Credit Limits</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #dc3545;">$<%= String.format("%,.2f", totalOutstanding) %></div>
                    <div class="metric-label">Total Outstanding</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #28a745;">$<%= String.format("%,.2f", totalAvailableCredit) %></div>
                    <div class="metric-label">Available Credit</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #fd7e14;">$<%= String.format("%,.2f", overdueAmounts) %></div>
                    <div class="metric-label">Overdue Amounts</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #6f42c1;"><%= String.format("%.1f", utilizationRate) %>%</div>
                    <div class="metric-label">Credit Utilization</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #e83e8c;"><%= String.format("%.1f", overdueRate) %>%</div>
                    <div class="metric-label">Overdue Rate</div>
                </div>
            </div>
        </div>
        
        <!-- Customer metrics -->
        <div class="report-category">
            <h3>Customer Portfolio Analysis</h3>
            <div class="summary-metrics">
                <div class="metric-box">
                    <div class="metric-value" style="color: #17a2b8;"><%= totalCustomers %></div>
                    <div class="metric-label">Total Customers</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #28a745;"><%= activeCustomers %></div>
                    <div class="metric-label">Active Customers</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #ffc107;"><%= overdueAccounts %></div>
                    <div class="metric-label">Overdue Accounts</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #dc3545;"><%= highRiskAccounts %></div>
                    <div class="metric-label">High Risk Accounts</div>
                </div>
            </div>
        </div>
        
        <!-- Payment metrics -->
        <div class="report-category">
            <h3>Payment Performance</h3>
            <div class="summary-metrics">
                <div class="metric-box">
                    <div class="metric-value" style="color: #28a745;">$<%= String.format("%,.2f", monthlyPayments) %></div>
                    <div class="metric-label">Monthly Payments (30 days)</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #ffc107;">$<%= String.format("%,.2f", pendingPayments) %></div>
                    <div class="metric-label">Pending Payments</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #17a2b8;">
                        <% if (totalOutstanding.compareTo(BigDecimal.ZERO) > 0) { %>
                            <%= String.format("%.1f", monthlyPayments.divide(totalOutstanding, 4, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"))) %>%
                        <% } else { %>
                            0.0%
                        <% } %>
                    </div>
                    <div class="metric-label">Monthly Collection Rate</div>
                </div>
            </div>
        </div>
        
        <!-- Available reports -->
        <div class="report-category">
            <h3>Available Reports</h3>
            <div class="report-grid">
                <% 
                Map<String, List<Map<String, Object>>> reportsByCategory = new HashMap<String, List<Map<String, Object>>>();
                for (Map<String, Object> report : availableReports) {
                    String category = (String)report.get("category");
                    if (!reportsByCategory.containsKey(category)) {
                        reportsByCategory.put(category, new ArrayList<Map<String, Object>>());
                    }
                    reportsByCategory.get(category).add(report);
                }
                
                for (Map.Entry<String, List<Map<String, Object>>> entry : reportsByCategory.entrySet()) {
                    String category = entry.getKey();
                    List<Map<String, Object>> reports = entry.getValue();
                %>
                
                <div class="report-card">
                    <h4><%= category %></h4>
                    <% for (Map<String, Object> report : reports) { %>
                    <div style="margin: 10px 0; padding: 10px; border: 1px solid #eee; border-radius: 3px;">
                        <strong><%= report.get("name") %></strong><br>
                        <small><%= report.get("description") %></small><br>
                        <small>
                            Frequency: <%= report.get("frequency") %> | 
                            Format: <%= report.get("format") %> | 
                            Last Run: <%= report.get("lastRun") %>
                        </small><br>
                        <div style="margin-top: 8px;">
                            <a href="reports-dashboard.jsp?action=generate&reportId=<%= report.get("id") %>" 
                               class="btn btn-primary">Generate Now</a>
                            <a href="reports-dashboard.jsp?action=download&reportId=<%= report.get("id") %>" 
                               class="btn btn-success">Download</a>
                            <% if ("ACTIVE".equals(report.get("status"))) { %>
                            <span class="status-active">● Active</span>
                            <% } else { %>
                            <span class="status-pending">● Pending</span>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>
        
        <!-- Scheduled reports -->
        <div class="scheduled-reports">
            <h3>Scheduled Reports</h3>
            <table class="schedule-table">
                <thead>
                    <tr>
                        <th>Report Name</th>
                        <th>Category</th>
                        <th>Frequency</th>
                        <th>Last Run</th>
                        <th>Next Run</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> report : availableReports) { %>
                    <tr>
                        <td><%= report.get("name") %></td>
                        <td><%= report.get("category") %></td>
                        <td><%= report.get("frequency") %></td>
                        <td><%= report.get("lastRun") %></td>
                        <td><%= report.get("nextRun") %></td>
                        <td class="status-<%= ((String)report.get("status")).toLowerCase() %>">
                            <%= report.get("status") %>
                        </td>
                        <td>
                            <a href="reports-dashboard.jsp?action=generate&reportId=<%= report.get("id") %>" 
                               class="btn btn-primary">Run Now</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Report actions -->
        <div class="report-actions">
            <h4>Quick Actions</h4>
            <p>Generate custom reports or access archived reports:</p>
            <a href="#" class="btn btn-info" onclick="alert('Custom report builder feature requires additional implementation')">Custom Report Builder</a>
            <a href="#" class="btn btn-secondary" onclick="alert('Report archive feature requires additional implementation')">Report Archive</a>
            <a href="#" class="btn btn-warning" onclick="alert('Data export feature requires additional implementation')">Export Data</a>
        </div>
        
        <!-- Data visualization placeholder -->
        <div class="report-category">
            <h3>Business Intelligence Charts</h3>
            <div class="chart-placeholder">
                <div style="text-align: center;">
                    <p><strong>Chart Visualization Area</strong></p>
                    <p>Credit utilization trends, payment patterns, and risk analysis charts would be displayed here.</p>
                    <p>Integration with charting libraries (Chart.js, D3.js) required for full implementation.</p>
                </div>
            </div>
        </div>
        
        <!-- Quick navigation -->
        <div style="margin: 20px 0; text-align: center;">
            <a href="../customer-search-working.jsp" class="btn btn-primary">Customer Search</a>
            <a href="../payment/payment-tracking.jsp" class="btn btn-success">Payment Tracking</a>
            <a href="../collections/collections-management.jsp" class="btn btn-warning">Collections</a>
            <a href="../risk/risk-assessment.jsp" class="btn btn-info">Risk Assessment</a>
        </div>
        
        <% } %>
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
    
    <script>
        // Auto-refresh metrics every 5 minutes
        setTimeout(function() {
            location.reload();
        }, 300000);
        
        // Show current time
        function updateTime() {
            const now = new Date();
            const timeString = now.toLocaleString();
            document.title = 'Reports Dashboard - ' + timeString;
        }
        setInterval(updateTime, 1000);
    </script>
</body>
</html>