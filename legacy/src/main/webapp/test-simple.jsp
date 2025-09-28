<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Simple Test Page - Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="css/legacy-style.css">
    <style>
        .test-form { background: #f8f9fa; padding: 20px; margin: 20px 0; border-radius: 5px; }
        .test-form table { width: 100%; }
        .test-form td { padding: 8px; }
        .test-form input, .test-form select { width: 200px; padding: 4px; }
        .test-btn { background: #0066cc; color: white; padding: 8px 16px; border: none; border-radius: 3px; cursor: pointer; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Simple Test Page (No Struts)</p>
    </div>
    
    <div id="main-content">
        <div class="test-form">
            <h2>Customer Search (Simple HTML Form)</h2>
            
            <form action="/customer/customer-search.jsp" method="get">
                <table>
                    <tr>
                        <td><strong>Customer Code:</strong></td>
                        <td>
                            <input type="text" name="customerCode" value="">
                            <br><small>Enter full or partial customer code</small>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Company Name:</strong></td>
                        <td>
                            <input type="text" name="companyName" value="">
                            <br><small>Enter full or partial company name</small>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Status:</strong></td>
                        <td>
                            <select name="status">
                                <option value="">All</option>
                                <option value="ACTIVE">Active</option>
                                <option value="INACTIVE">Inactive</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <input type="submit" value="Search" class="test-btn">
                            <input type="button" value="Clear" onclick="clearForm()" style="margin-left: 10px;">
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        
        <div class="navigation-section">
            <h3>Quick Links</h3>
            <p>
                <a href="/">Dashboard</a> |
                <a href="test-simple.jsp">Refresh Test</a> |
                <a href="customer/customer-search.jsp">Struts Form (with errors)</a>
            </p>
        </div>
        
        <!-- System Status -->
        <div class="test-form">
            <h3>System Status</h3>
            <p><strong>Date:</strong> <%= new java.util.Date() %></p>
            <p><strong>Request URL:</strong> <%= request.getRequestURL() %></p>
            <p><strong>Context Path:</strong> <%= request.getContextPath() %></p>
            <p><strong>Server Info:</strong> <%= application.getServerInfo() %></p>
        </div>
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Simple Test Page - Working without Struts taglibs</p>
    </div>
    
    <script>
        function clearForm() {
            document.forms[0].reset();
        }
    </script>
</body>
</html>