<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Error - Credit Management</title>
    <link rel="stylesheet" type="text/css" href="../css/legacy-style.css">
    <style>
        .error-container { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .error-container h2 { color: #721c24; }
    </style>
</head>
<body>
    <div id="header">
        <h1>Legacy Credit Control System</h1>
        <p>Credit Management Error</p>
    </div>
    
    <div id="main-content">
        <div class="error-container">
            <h2>💳 Credit Management Error</h2>
            
            <logic:present name="errorMessage">
                <p><strong>Error:</strong> <bean:write name="errorMessage"/></p>
            </logic:present>
            
            <logic:notPresent name="errorMessage">
                <p>An unexpected error occurred while processing your credit management request.</p>
            </logic:notPresent>
            
            <p>Please verify the information and try again, or contact your system administrator if the problem persists.</p>
        </div>
        
        <div class="navigation-section">
            <h3>What would you like to do?</h3>
            <p>
                <a href="../welcome.do">Return to Dashboard</a> |
                <a href="../customerSearch.do">Search Customers</a> |
                <a href="../creditLimit.do?action=dashboard">Credit Dashboard</a> |
                <a href="javascript:history.back()">Go Back</a>
            </p>
        </div>
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
    </div>
</body>
</html>