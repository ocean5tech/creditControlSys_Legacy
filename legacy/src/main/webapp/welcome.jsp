<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="/WEB-INF/struts-html.tld" prefix="html" %>
<%@ taglib uri="/WEB-INF/struts-bean.tld" prefix="bean" %>
<%@ taglib uri="/WEB-INF/struts-logic.tld" prefix="logic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title><bean:write name="systemName" scope="request"/> - Welcome</title>
    <link rel="stylesheet" type="text/css" href="css/legacy-style.css">
    <style>
        .status-operational { color: #28a745; font-weight: bold; }
        .status-degraded { color: #dc3545; font-weight: bold; }
        .status-limited { color: #ffc107; font-weight: bold; }
        .menu-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; margin-top: 20px; }
        .menu-item { background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #0066cc; }
        .menu-item a { color: #0066cc; text-decoration: none; font-weight: bold; }
        .menu-item a:hover { text-decoration: underline; }
        .activity-log { background: #e6f3ff; padding: 15px; border-radius: 5px; margin-top: 20px; }
        .activity-item { margin: 5px 0; padding: 5px; background: white; border-radius: 3px; }
    </style>
</head>
<body>
    <div id="header">
        <h1><bean:write name="systemName" scope="request"/></h1>
        <p>Insurance Company - Credit Management Portal (Struts Framework)</p>
        <p><em>Version: <bean:write name="systemVersion" scope="request"/></em></p>
    </div>
    
    <div id="main-content">
        <!-- System Status Section -->
        <div class="welcome-section">
            <h2>System Status</h2>
            <table border="1" cellpadding="5" cellspacing="0">
                <tr>
                    <th>Component</th>
                    <th>Status</th>
                    <th>Details</th>
                </tr>
                <tr>
                    <td>Overall System</td>
                    <td>
                        <logic:equal name="systemStatus" value="ALL SYSTEMS OPERATIONAL" scope="request">
                            <span class="status-operational">✓ <bean:write name="systemStatus" scope="request"/></span>
                        </logic:equal>
                        <logic:equal name="systemStatus" value="SYSTEM FUNCTIONAL - LIMITED DATA" scope="request">
                            <span class="status-limited">⚠ <bean:write name="systemStatus" scope="request"/></span>
                        </logic:equal>
                        <logic:notEqual name="systemStatus" value="ALL SYSTEMS OPERATIONAL" scope="request">
                            <logic:notEqual name="systemStatus" value="SYSTEM FUNCTIONAL - LIMITED DATA" scope="request">
                                <span class="status-degraded">✗ <bean:write name="systemStatus" scope="request"/></span>
                            </logic:notEqual>
                        </logic:notEqual>
                    </td>
                    <td><bean:write name="buildDate" scope="request"/></td>
                </tr>
                <tr>
                    <td>Database Connection</td>
                    <td>
                        <logic:equal name="databaseHealthy" value="true" scope="request">
                            <span class="status-operational">✓ CONNECTED</span>
                        </logic:equal>
                        <logic:notEqual name="databaseHealthy" value="true" scope="request">
                            <span class="status-degraded">✗ DISCONNECTED</span>
                        </logic:notEqual>
                    </td>
                    <td><bean:write name="connectionStatus" scope="request"/></td>
                </tr>
                <tr>
                    <td>Customer Records</td>
                    <td>
                        <logic:greaterThan name="totalCustomers" value="0" scope="request">
                            <span class="status-operational"><bean:write name="totalCustomers" scope="request"/> ACTIVE</span>
                        </logic:greaterThan>
                        <logic:equal name="totalCustomers" value="0" scope="request">
                            <span class="status-limited">NO DATA</span>
                        </logic:equal>
                    </td>
                    <td>Active customers in database</td>
                </tr>
            </table>
        </div>
        
        <!-- Navigation Menu -->
        <div class="navigation-section">
            <h2>Credit Control Functions</h2>
            <div class="menu-grid">
                <logic:present name="menuItems" scope="request">
                    <logic:iterate name="menuItems" id="menuItem" scope="request">
                        <div class="menu-item">
                            <%
                                String item = (String) pageContext.getAttribute("menuItem");
                                String[] parts = item.split("\\|");
                                String label = parts[0];
                                String url = parts[1];
                            %>
                            <html:link page="<%= url %>"><%= label %></html:link>
                        </div>
                    </logic:iterate>
                </logic:present>
            </div>
        </div>
        
        <!-- System Information -->
        <div class="system-info">
            <h3>System Information</h3>
            <table border="0" cellpadding="5" cellspacing="0" style="width: 100%;">
                <tr>
                    <td><strong>Java Version:</strong></td>
                    <td><bean:write name="javaVersion" scope="request"/></td>
                </tr>
                <tr>
                    <td><strong>Application Server:</strong></td>
                    <td><bean:write name="serverInfo" scope="request"/></td>
                </tr>
                <tr>
                    <td><strong>Framework:</strong></td>
                    <td>Apache Struts 1.3.10 + JSP + PostgreSQL</td>
                </tr>
                <tr>
                    <td><strong>Deployment:</strong></td>
                    <td>Podman Container (credit-control-legacy:v1.0)</td>
                </tr>
                <tr>
                    <td><strong>Server URL:</strong></td>
                    <td>http://35.77.54.203:4000</td>
                </tr>
            </table>
        </div>
        
        <!-- Recent Activity -->
        <div class="activity-log">
            <h3>System Activity</h3>
            <logic:present name="recentActivity" scope="request">
                <logic:iterate name="recentActivity" id="activity" scope="request">
                    <div class="activity-item">
                        ✓ <bean:write name="activity"/>
                    </div>
                </logic:iterate>
            </logic:present>
        </div>
        
        <!-- Error Display -->
        <logic:present name="errorMessage" scope="request">
            <div class="error-section" style="background: #ffebee; border: 1px solid #f44336; padding: 15px; margin-top: 20px; border-radius: 5px;">
                <h3 style="color: #d32f2f;">System Error</h3>
                <p style="color: #d32f2f;"><bean:write name="errorMessage" scope="request"/></p>
            </div>
        </logic:present>
        
        <!-- Quick Links -->
        <div class="navigation-section">
            <h2>Quick Links</h2>
            <p>
                <html:link page="/customerSearch.do">Customer Search</html:link> | 
                <html:link page="/systemStatus.do">System Status</html:link> | 
                <html:link page="/health">Health Check</html:link> |
                <a href="http://35.77.54.203:4001/" target="_blank">DB Monitor</a> |
                <a href="http://35.77.54.203:4002/" target="_blank">Batch Status</a>
            </p>
        </div>
    </div>
    
    <div id="footer">
        <p>&copy; 2025 Insurance Company - Legacy Credit Control System</p>
        <p>Phase 1: Legacy System with Struts Framework - Milestone 3 Implementation</p>
        <p><em>Built with Apache Struts 1.3.10, JSP, and PostgreSQL</em></p>
    </div>
    
    <script>
        // Auto-refresh system status every 30 seconds
        setTimeout(function() {
            window.location.reload();
        }, 30000);
    </script>
</body>
</html>