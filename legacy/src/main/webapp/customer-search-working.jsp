<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Customer Search - Working Version</title>
    <link rel="stylesheet" type="text/css" href="css/legacy-style.css">
    <style>
        .search-form { background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .search-form table { width: 100%; }
        .search-form td { padding: 8px; }
        .search-form input[type="text"], .search-form select { width: 200px; padding: 4px; }
        .search-btn { background: #0066cc; color: white; padding: 8px 16px; border: none; border-radius: 3px; cursor: pointer; }
        .search-btn:hover { background: #0056b3; }
        .results-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .results-table th, .results-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .results-table th { background: #0066cc; color: white; }
        .results-table tr:nth-child(even) { background: #f2f2f2; }
        .results-table a { color: #0066cc; text-decoration: none; }
        .results-table a:hover { text-decoration: underline; }
        .message { padding: 10px; margin: 10px 0; border-radius: 3px; }
        .success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Customer Search - Working Version</p>
    </div>
    
    <div id="main-content">
        
        <!-- Search Form -->
        <div class="search-form">
            <h2>Customer Search</h2>
            
            <form action="customer-search-working.jsp" method="get">
                <input type="hidden" name="action" value="search"/>
                <table>
                    <tr>
                        <td><strong>Customer Code:</strong></td>
                        <td>
                            <input type="text" name="customerCode" value="<%= request.getParameter("customerCode") != null ? request.getParameter("customerCode") : "" %>">
                            <br><small>Enter full or partial customer code</small>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Company Name:</strong></td>
                        <td>
                            <input type="text" name="companyName" value="<%= request.getParameter("companyName") != null ? request.getParameter("companyName") : "" %>">
                            <br><small>Enter full or partial company name</small>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Status:</strong></td>
                        <td>
                            <select name="status">
                                <option value="">All</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(request.getParameter("status")) ? "selected" : "" %>>Active</option>
                                <option value="INACTIVE" <%= "INACTIVE".equals(request.getParameter("status")) ? "selected" : "" %>>Inactive</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Max Results:</strong></td>
                        <td>
                            <select name="maxResults">
                                <option value="25" <%= "25".equals(request.getParameter("maxResults")) ? "selected" : "" %>>25</option>
                                <option value="50" <%= "50".equals(request.getParameter("maxResults")) ? "selected" : "" %>>50</option>
                                <option value="100" <%= "100".equals(request.getParameter("maxResults")) ? "selected" : "" %>>100</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="submit" value="Search" class="search-btn"/>
                            <input type="button" value="Clear" onclick="clearForm()" style="margin-left: 10px;"/>
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        
        <%
        // Process search results if form was submitted
        String action = request.getParameter("action");
        if ("search".equals(action)) {
            String customerCode = request.getParameter("customerCode");
            String companyName = request.getParameter("companyName");
            String status = request.getParameter("status");
            String maxResults = request.getParameter("maxResults");
            
            // Database connection and search
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            List<Map<String, Object>> searchResults = new ArrayList<>();
            String errorMessage = null;
            
            try {
                // Database connection
                Class.forName("org.postgresql.Driver");
                conn = DriverManager.getConnection("jdbc:postgresql://35.77.54.203:5432/creditcontrol", "creditapp", "secure123");
                
                // Build dynamic SQL query
                StringBuilder sql = new StringBuilder("SELECT customer_id, customer_code, company_name, contact_person, phone, industry, status FROM customers WHERE 1=1");
                List<Object> params = new ArrayList<>();
                
                if (customerCode != null && !customerCode.trim().isEmpty()) {
                    sql.append(" AND customer_code ILIKE ?");
                    params.add("%" + customerCode.trim() + "%");
                }
                
                if (companyName != null && !companyName.trim().isEmpty()) {
                    sql.append(" AND company_name ILIKE ?");
                    params.add("%" + companyName.trim() + "%");
                }
                
                if (status != null && !status.trim().isEmpty()) {
                    sql.append(" AND status = ?");
                    params.add(status);
                }
                
                sql.append(" ORDER BY customer_code");
                
                if (maxResults != null && !maxResults.isEmpty()) {
                    sql.append(" LIMIT ?");
                    params.add(Integer.parseInt(maxResults));
                }
                
                stmt = conn.prepareStatement(sql.toString());
                
                // Set parameters
                for (int i = 0; i < params.size(); i++) {
                    stmt.setObject(i + 1, params.get(i));
                }
                
                rs = stmt.executeQuery();
                
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("customer_id", rs.getInt("customer_id"));
                    row.put("customer_code", rs.getString("customer_code"));
                    row.put("company_name", rs.getString("company_name"));
                    row.put("contact_person", rs.getString("contact_person"));
                    row.put("phone", rs.getString("phone"));
                    row.put("industry", rs.getString("industry"));
                    row.put("status", rs.getString("status"));
                    searchResults.add(row);
                }
                
            } catch (Exception e) {
                errorMessage = "Database error: " + e.getMessage();
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        %>
        
        <!-- Search Results -->
        <div class="search-results">
            <h3>Search Results</h3>
            
            <div class="message success">
                <strong>Search executed with parameters:</strong><br>
                Customer Code: <%= customerCode != null && !customerCode.isEmpty() ? customerCode : "Any" %><br>
                Company Name: <%= companyName != null && !companyName.isEmpty() ? companyName : "Any" %><br>
                Status: <%= status != null && !status.isEmpty() ? status : "All" %><br>
                Max Results: <%= maxResults != null ? maxResults : "25" %>
            </div>
            
            <% if (errorMessage != null) { %>
                <div class="message error">
                    <strong>Error:</strong> <%= errorMessage %>
                </div>
            <% } else { %>
            
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Customer Code</th>
                        <th>Company Name</th>
                        <th>Contact Person</th>
                        <th>Industry</th>
                        <th>Phone</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (searchResults.isEmpty()) { %>
                        <tr>
                            <td colspan="7" style="text-align: center; font-style: italic;">No customers found matching your criteria.</td>
                        </tr>
                    <% } else { %>
                        <% for (Map<String, Object> row : searchResults) { %>
                        <tr>
                            <td><%= row.get("customer_code") %></td>
                            <td><%= row.get("company_name") %></td>
                            <td><%= row.get("contact_person") %></td>
                            <td><%= row.get("industry") %></td>
                            <td><%= row.get("phone") %></td>
                            <td><%= row.get("status") %></td>
                            <td>
                                <a href="customer/customer-details.jsp?customerCode=<%= row.get("customer_code") %>">View</a> |
                                <a href="customer/credit-limit-modify.jsp?customerCode=<%= row.get("customer_code") %>">Credit</a> |
                                <a href="risk/risk-assessment.jsp?customerCode=<%= row.get("customer_code") %>">Risk</a>
                            </td>
                        </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
            
            <p><em>Found <%= searchResults.size() %> customers matching your criteria.</em></p>
            
            <% } %>
        </div>
        
        <% } else { %>
        
        <div class="message">
            <strong>Instructions:</strong> Enter search criteria above and click "Search" to find customers.
        </div>
        
        <% } %>
        
        <!-- System Status -->
        <div class="search-form">
            <h3>System Status</h3>
            <p><strong>Date:</strong> <%= new java.util.Date() %></p>
            <p><strong>Server:</strong> <%= application.getServerInfo() %></p>
            <p><strong>Search Action:</strong> <%= action != null ? action : "None" %></p>
            <p><strong>Database:</strong> PostgreSQL creditcontrol database</p>
        </div>
        
        <!-- Quick Links -->
        <div class="navigation-section">
            <h3>Quick Links</h3>
            <p>
                <a href="/">Dashboard</a> |
                <a href="customer-search-working.jsp">New Search</a> |
                <a href="payment/payment-tracking.jsp">Payment Tracking</a> |
                <a href="collections/collections-management.jsp">Collections</a> |
                <a href="reports/reports-dashboard.jsp">Reports</a>
            </p>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Customer Search Module - Real Database Integration (PostgreSQL)</p>
    </div>
    
    <script>
        function clearForm() {
            document.forms[0].reset();
            window.location.href = 'customer-search-working.jsp';
        }
    </script>
    
</body>
</html>