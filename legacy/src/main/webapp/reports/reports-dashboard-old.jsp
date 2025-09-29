<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.math.BigDecimal, java.util.*, java.text.SimpleDateFormat" %>
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
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Reports Dashboard - Management Reporting Interface (Core Function 6)</p>
    </div>
    
    <div id="main-content">
        <%
        // Get parameters
        String reportType = request.getParameter("reportType");
        String dateRange = request.getParameter("dateRange");
        String action = request.getParameter("action");
        String reportId = request.getParameter("reportId");
        
        // Simulate business metrics data
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        Date currentDate = new Date();
        
        // This month's statistical data
        BigDecimal totalCreditLimits = new BigDecimal("2500000");
        BigDecimal totalOutstanding = new BigDecimal("875000");
        BigDecimal monthlyPayments = new BigDecimal("425000");
        BigDecimal overdueAmounts = new BigDecimal("135000");
        int totalCustomers = 156;
        int activeCustomers = 142;
        int overdueAccounts = 8;
        int highRiskAccounts = 3;
        
        // Trend data (compared to last month)
        double creditTrend = 5.2;  // Growth 5.2%
        double paymentTrend = -2.1; // Decline 2.1%  
        double overdueTrend = 15.6; // Growth 15.6%
        double riskTrend = -8.3; // Decline 8.3%
        
        // Predefined report list
        List<Map<String, Object>> availableReports = new ArrayList<>();
        
        // Credit control report
        Map<String, Object> report1 = new HashMap<>();
        report1.put("id", "CREDIT_SUMMARY");
        report1.put("name", "Credit Control Monthly Summary");
        report1.put("description", "Monthly summary report of customer credit limits, usage, and risk assessment");
        report1.put("category", "Credit Management");
        report1.put("frequency", "Monthly");
        report1.put("lastRun", "2025-01-20");
        report1.put("format", "PDF/Excel");
        availableReports.add(report1);
        
        Map<String, Object> report2 = new HashMap<>();
        report2.put("id", "PAYMENT_ANALYSIS");
        report2.put("name", "Payment Trend Analysis");
        report2.put("description", "Customer payment patterns, delay analysis, and cash flow forecasting");
        report2.put("category", "Payment Management");
        report2.put("frequency", "Weekly");
        report2.put("lastRun", "2025-01-22");
        report2.put("format", "PDF/Excel");
        availableReports.add(report2);
        
        Map<String, Object> report3 = new HashMap<>();
        report3.put("id", "RISK_ASSESSMENT");
        report3.put("name", "Risk Assessment Report");
        report3.put("description", "Customer risk level distribution, risk change trends, and early warning analysis");
        report3.put("category", "Risk Management");
        report3.put("frequency", "Bi-weekly");
        report3.put("lastRun", "2025-01-18");
        report3.put("format", "PDF");
        availableReports.add(report3);
        
        Map<String, Object> report4 = new HashMap<>();
        report4.put("id", "COLLECTIONS_REPORT");
        report4.put("name", "Overdue Collections Report");
        report4.put("description", "Overdue account status, collection effectiveness, and legal escalation situations");
        report4.put("category", "Collections Management");
        report4.put("frequency", "Monthly");
        report4.put("lastRun", "2025-01-19");
        report4.put("format", "PDF/Excel");
        availableReports.add(report4);
        
        Map<String, Object> report5 = new HashMap<>();
        report5.put("id", "EXECUTIVE_DASHBOARD");
        report5.put("name", "Executive Dashboard");
        report5.put("description", "Senior management key indicators, business trends, and decision support data");
        report5.put("category", "Management Decision");
        report5.put("frequency", "Daily");
        report5.put("lastRun", "2025-01-23");
        report5.put("format", "PDF");
        availableReports.add(report5);
        
        Map<String, Object> report6 = new HashMap<>();
        report6.put("id", "REGULATORY_COMPLIANCE");
        report6.put("name", "Regulatory Compliance Report");
        report6.put("description", "Regulatory compliance checks, risk exposure, and compliance indicators");
        report6.put("category", "Compliance Management");
        report6.put("frequency", "Quarterly");
        report6.put("lastRun", "2025-01-15");
        report6.put("format", "PDF");
        availableReports.add(report6);
        
        // Scheduled report tasks
        List<Map<String, Object>> scheduledReports = new ArrayList<>();
        
        Map<String, Object> schedule1 = new HashMap<>();
        schedule1.put("reportName", "Credit Control Monthly Summary");
        schedule1.put("schedule", "1st of every month 09:00");
        schedule1.put("recipients", "General Manager, CFO, Risk Manager");
        schedule1.put("status", "ACTIVE");
        schedule1.put("nextRun", "2025-02-01 09:00");
        scheduledReports.add(schedule1);
        
        Map<String, Object> schedule2 = new HashMap<>();
        schedule2.put("reportName", "Executive Dashboard");
        schedule2.put("schedule", "Daily 08:00");
        schedule2.put("recipients", "Senior Management Team");
        schedule2.put("status", "ACTIVE");
        schedule2.put("nextRun", "2025-01-24 08:00");
        scheduledReports.add(schedule2);
        
        Map<String, Object> schedule3 = new HashMap<>();
        schedule3.put("reportName", "Payment Trend Analysis");
        schedule3.put("schedule", "Every Monday 10:00");
        schedule3.put("recipients", "Finance Department");
        schedule3.put("status", "PENDING");
        schedule3.put("nextRun", "2025-01-27 10:00");
        scheduledReports.add(schedule3);
        
        // Process report generation requests
        String actionResult = null;
        if ("generate".equals(action) && reportId != null) {
            // Simulate report generation
            for (Map<String, Object> report : availableReports) {
                if (reportId.equals(report.get("id"))) {
                    actionResult = "Report '" + report.get("name") + "' generated successfully! Sent to management email.";
                    break;
                }
            }
        }
        %>
        
        <!-- Page title -->
        <div class="reports-header">
            <h2>Management Reporting Center</h2>
            <p>Management Reporting Center - Providing key business metrics and decision support for management</p>
        </div>
        
        <!-- Key metrics overview -->
        <div class="report-category">
            <h3>📊 Key Business Metrics</h3>
            <div class="summary-metrics">
                <div class="metric-box">
                    <div class="metric-value" style="color: #007bff;">$<%= String.format("%,.0f", totalCreditLimits) %></div>
                    <div class="metric-label">Total Credit Limits</div>
                    <div class="<%= creditTrend > 0 ? "trend-positive" : "trend-negative" %>">
                        <%= creditTrend > 0 ? "↗" : "↘" %> <%= String.format("%.1f", Math.abs(creditTrend)) %>%
                    </div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #28a745;">$<%= String.format("%,.0f", monthlyPayments) %></div>
                    <div class="metric-label">Monthly Collections</div>
                    <div class="<%= paymentTrend > 0 ? "trend-positive" : "trend-negative" %>">
                        <%= paymentTrend > 0 ? "↗" : "↘" %> <%= String.format("%.1f", Math.abs(paymentTrend)) %>%
                    </div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #dc3545;">$<%= String.format("%,.0f", overdueAmounts) %></div>
                    <div class="metric-label">Overdue Amount</div>
                    <div class="<%= overdueTrend > 0 ? "trend-negative" : "trend-positive" %>">
                        <%= overdueTrend > 0 ? "↗" : "↘" %> <%= String.format("%.1f", Math.abs(overdueTrend)) %>%
                    </div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #ffc107;"><%= highRiskAccounts %></div>
                    <div class="metric-label">High Risk Customers</div>
                    <div class="<%= riskTrend > 0 ? "trend-negative" : "trend-positive" %>">
                        <%= riskTrend > 0 ? "↗" : "↘" %> <%= String.format("%.1f", Math.abs(riskTrend)) %>%
                    </div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #17a2b8;"><%= String.format("%.1f", totalOutstanding.divide(totalCreditLimits, 3, BigDecimal.ROUND_HALF_UP).multiply(new BigDecimal("100"))) %>%</div>
                    <div class="metric-label">Credit Utilization Rate</div>
                    <div class="trend-neutral">Stable</div>
                </div>
                <div class="metric-box">
                    <div class="metric-value" style="color: #6c757d;"><%= activeCustomers %>/<%= totalCustomers %></div>
                    <div class="metric-label">Active Customers</div>
                    <div class="trend-positive">↗ 3.2%</div>
                </div>
            </div>
        </div>
        
        <!-- Operation result -->
        <% if (actionResult != null) { %>
        <div style="background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 15px; margin: 15px 0; border-radius: 3px;">
            <strong>✅ <%= actionResult %></strong>
        </div>
        <% } %>
        
        <!-- Report filters -->
        <div class="filter-panel">
            <strong>📅 Report Filters:</strong>
            <select name="category" onchange="filterReports()">
                <option value="">All Categories</option>
                <option value="Credit Management">Credit Management</option>
                <option value="Payment Management">Payment Management</option>
                <option value="Risk Management">Risk Management</option>
                <option value="Collections Management">Collections Management</option>
                <option value="Management Decision">Management Decision</option>
                <option value="Compliance Management">Compliance Management</option>
            </select>
            
            <select name="frequency" onchange="filterReports()">
                <option value="">All Frequencies</option>
                <option value="Daily">Daily</option>
                <option value="Weekly">Weekly</option>
                <option value="Monthly">Monthly</option>
                <option value="Quarterly">Quarterly</option>
            </select>
            
            <input type="date" name="startDate" value="2025-01-01">
            <input type="date" name="endDate" value="2025-01-31">
            
            <button class="btn btn-primary" onclick="applyFilters()">Apply Filters</button>
            <button class="btn btn-secondary" onclick="resetFilters()">Reset</button>
        </div>
        
        <!-- Predefined reports -->
        <div class="report-category">
            <h3>📋 Available Reports</h3>
            <div class="report-grid">
                <% for (Map<String, Object> report : availableReports) { %>
                <div class="report-card">
                    <h4><%= report.get("name") %></h4>
                    <p><%= report.get("description") %></p>
                    <p><strong>Category:</strong> <%= report.get("category") %> | 
                       <strong>Frequency:</strong> <%= report.get("frequency") %> | 
                       <strong>Format:</strong> <%= report.get("format") %></p>
                    <p><strong>Last Run:</strong> <%= report.get("lastRun") %></p>
                    
                    <div style="margin-top: 15px;">
                        <a href="reports-dashboard.jsp?action=generate&reportId=<%= report.get("id") %>" class="btn btn-success">Generate Report</a>
                        <button class="btn btn-info" onclick="previewReport('<%= report.get("id") %>')">Preview</button>
                        <button class="btn btn-warning" onclick="scheduleReport('<%= report.get("id") %>')">Schedule Settings</button>
                        <button class="btn btn-secondary" onclick="downloadTemplate('<%= report.get("id") %>')">Download Template</button>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
        
        <!-- Chart area -->
        <div class="report-category">
            <h3>📈 Trend Analysis Charts</h3>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                <div>
                    <h4>Monthly Collection Trends</h4>
                    <div class="chart-placeholder">
                        [Monthly Collection Trend Chart Placeholder]<br>
                        <small>Will integrate chart library (e.g. Chart.js) in actual deployment</small>
                    </div>
                </div>
                <div>
                    <h4>Risk Level Distribution</h4>
                    <div class="chart-placeholder">
                        [Risk Level Distribution Pie Chart Placeholder]<br>
                        <small>Will integrate chart library in actual deployment</small>
                    </div>
                </div>
                <div>
                    <h4>Overdue Account Trends</h4>
                    <div class="chart-placeholder">
                        [Overdue Account Trend Chart Placeholder]<br>
                        <small>Will integrate chart library in actual deployment</small>
                    </div>
                </div>
                <div>
                    <h4>Customer Growth Analysis</h4>
                    <div class="chart-placeholder">
                        [Customer Growth Analysis Chart Placeholder]<br>
                        <small>Will integrate chart library in actual deployment</small>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Scheduled report management -->
        <div class="scheduled-reports">
            <h3>⏰ Scheduled Report Tasks</h3>
            <table class="schedule-table">
                <thead>
                    <tr>
                        <th>Report Name</th>
                        <th>Execution Schedule</th>
                        <th>Recipients</th>
                        <th>Status</th>
                        <th>Next Run</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Map<String, Object> schedule : scheduledReports) { 
                       String status = (String)schedule.get("status");
                    %>
                    <tr>
                        <td><%= schedule.get("reportName") %></td>
                        <td><%= schedule.get("schedule") %></td>
                        <td><%= schedule.get("recipients") %></td>
                        <td class="status-<%= status.toLowerCase() %>">
                            <% if ("ACTIVE".equals(status)) { %>
                                Running
                            <% } else if ("PENDING".equals(status)) { %>
                                Waiting
                            <% } else { %>
                                Stopped
                            <% } %>
                        </td>
                        <td><%= schedule.get("nextRun") %></td>
                        <td>
                            <% if ("ACTIVE".equals(status)) { %>
                                <button class="btn btn-warning" onclick="pauseSchedule()">Pause</button>
                            <% } else { %>
                                <button class="btn btn-success" onclick="resumeSchedule()">Start</button>
                            <% } %>
                            <button class="btn btn-secondary" onclick="editSchedule()">Edit</button>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
        
        <!-- Management operations -->
        <div class="report-actions">
            <h3>🔧 Management Operations</h3>
            <button class="btn btn-primary" onclick="generateBatchReports()">Generate Batch Reports</button>
            <button class="btn btn-success" onclick="exportAllData()">Export All Data</button>
            <button class="btn btn-warning" onclick="createCustomReport()">Create Custom Report</button>
            <button class="btn btn-info" onclick="viewAuditLog()">View Audit Log</button>
            <button class="btn btn-secondary" onclick="systemSettings()">System Settings</button>
        </div>
        
        <!-- Navigation buttons -->
        <div style="margin: 20px 0; text-align: center;">
            <a href="../risk/risk-assessment.jsp" class="btn btn-primary">Risk Assessment</a>
            <a href="../collections/collections-management.jsp" class="btn btn-warning">Collections Management</a>
            <a href="../payment/payment-tracking.jsp" class="btn btn-info">Payment Tracking</a>
            <a href="../customer-search-working.jsp" class="btn btn-secondary">Customer Search</a>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
    
    <script>
        function previewReport(reportId) {
            alert('Generating report preview: ' + reportId + '\nPreview will open in new window.');
        }
        
        function scheduleReport(reportId) {
            var frequency = prompt('Please enter scheduling frequency (daily/weekly/monthly):', 'monthly');
            if (frequency) {
                alert('Report ' + reportId + ' has been set for ' + frequency + ' scheduled execution.');
            }
        }
        
        function downloadTemplate(reportId) {
            alert('Downloading report template: ' + reportId + '\nTemplate file will be automatically downloaded.');
        }
        
        function generateBatchReports() {
            if (confirm('Are you sure you want to generate all scheduled reports? This may take several minutes.')) {
                alert('Batch report generation started, email notification will be sent upon completion.');
            }
        }
        
        function exportAllData() {
            if (confirm('Are you sure you want to export all credit control data?')) {
                alert('Data export in progress, Excel file will be sent to your email.');
            }
        }
        
        function createCustomReport() {
            alert('Redirecting to custom report designer...');
        }
        
        function viewAuditLog() {
            alert('Displaying system audit log, including all user operation records.');
        }
        
        function systemSettings() {
            alert('Opening system settings panel, configure report parameters and user permissions.');
        }
        
        function filterReports() {
            alert('Applying report filter criteria...');
        }
        
        function applyFilters() {
            alert('Filter criteria applied, reloading report list.');
        }
        
        function resetFilters() {
            alert('Filter criteria have been reset.');
            location.reload();
        }
        
        function pauseSchedule() {
            alert('Scheduled task has been paused.');
        }
        
        function resumeSchedule() {
            alert('Scheduled task has been started.');
        }
        
        function editSchedule() {
            alert('Opening scheduled task editor...');
        }
    </script>
</body>
</html>