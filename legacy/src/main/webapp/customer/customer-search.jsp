<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Customer Search - Legacy Credit Control System</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .search-form { background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .search-form table { width: 100%; }
        .search-form td { padding: 8px; }
        .search-form input[type="text"], .search-form select { width: 200px; padding: 4px; }
        .search-form input[type="submit"] { background: #0066cc; color: white; padding: 8px 16px; border: none; border-radius: 3px; cursor: pointer; }
        .search-form input[type="submit"]:hover { background: #0056b3; }
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
        <p>Customer Search</p>
    </div>
    
    <div id="main-content">
        
        <!-- Search Form -->
        <div class="search-form">
            <h2>Customer Search</h2>
            
            <html:form action="/customerSearch" method="get">
                <html:hidden property="action" value="search"/>
                <table>
                    <tr>
                        <td><strong>Customer Code:</strong></td>
                        <td>
                            <html:text property="customerCode" />
                            <br><small>Enter full or partial customer code</small>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Company Name:</strong></td>
                        <td>
                            <html:text property="companyName" />
                            <br><small>Enter full or partial company name</small>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Industry:</strong></td>
                        <td>
                            <html:select property="industry">
                                <html:option value="">-- Select Industry --</html:option>
                                <logic:present name="industries">
                                    <html:options collection="industries" property="value" labelProperty="label"/>
                                </logic:present>
                            </html:select>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Status:</strong></td>
                        <td>
                            <html:select property="status">
                                <html:option value="ACTIVE">Active</html:option>
                                <html:option value="INACTIVE">Inactive</html:option>
                                <html:option value="">All</html:option>
                            </html:select>
                        </td>
                    </tr>
                    <tr>
                        <td><strong>Max Results:</strong></td>
                        <td>
                            <html:select property="maxResults">
                                <html:option value="25">25</html:option>
                                <html:option value="50">50</html:option>
                                <html:option value="100">100</html:option>
                            </html:select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <html:submit value="Search" styleClass="search-btn"/>
                            <input type="button" value="Clear" onclick="clearForm()" style="margin-left: 10px;"/>
                        </td>
                    </tr>
                </table>
            </html:form>
        </div>
        
        <!-- Messages -->
        <logic:present name="message">
            <div class="message success">
                <bean:write name="message"/>
            </div>
        </logic:present>
        
        <logic:present name="errorMessage">
            <div class="message error">
                <bean:write name="errorMessage"/>
            </div>
        </logic:present>
        
        <!-- Search Results -->
        <logic:present name="searchResults">
            <div class="search-results">
                <h3>Search Results</h3>
                
                <logic:present name="searchSummary">
                    <p><strong><bean:write name="searchSummary"/></strong></p>
                </logic:present>
                
                <logic:notEmpty name="searchResults">
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
                            <logic:iterate name="searchResults" id="customer">
                                <tr>
                                    <td><bean:write name="customer" property="customerCode"/></td>
                                    <td><bean:write name="customer" property="companyName"/></td>
                                    <td><bean:write name="customer" property="contactPerson"/></td>
                                    <td><bean:write name="customer" property="industry"/></td>
                                    <td><bean:write name="customer" property="phone"/></td>
                                    <td><bean:write name="customer" property="status"/></td>
                                    <td>
                                        <a href="customerDetails.do?action=display&customerId=<bean:write name="customer" property="customerId"/>">View</a> |
                                        <a href="customerDetails.do?action=edit&customerId=<bean:write name="customer" property="customerId"/>">Edit</a> |
                                        <a href="creditLimit.do?action=display&customerId=<bean:write name="customer" property="customerId"/>">Credit</a>
                                    </td>
                                </tr>
                            </logic:iterate>
                        </tbody>
                    </table>
                </logic:notEmpty>
                
                <logic:empty name="searchResults">
                    <p><em>No customers found matching your search criteria.</em></p>
                </logic:empty>
            </div>
        </logic:present>
        
        <!-- Quick Links -->
        <div class="navigation-section">
            <h3>Quick Links</h3>
            <p>
                <a href="../welcome.do">Dashboard</a> |
                <a href="customer-search.jsp">New Search</a> |
                <a href="../creditLimit.do?action=dashboard">Credit Dashboard</a>
            </p>
        </div>
        
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Customer Search Module - Milestone 4 Implementation</p>
    </div>
    
    <script>
        function clearForm() {
            document.forms[0].reset();
            window.location.href = 'customer-search.jsp';
        }
    </script>
    
</body>
</html>