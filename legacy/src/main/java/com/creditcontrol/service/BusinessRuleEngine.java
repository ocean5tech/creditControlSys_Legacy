package com.creditcontrol.service;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Simple Business Rules Engine - POC Implementation
 * 简单的业务规则引擎 - POC实现
 */
public class BusinessRuleEngine {
    
    /**
     * 执行所有业务规则验证
     * @param ruleContext 规则执行上下文
     * @return 规则执行结果
     */
    public static BusinessRuleResult executeRules(BusinessRuleContext ruleContext) {
        BusinessRuleResult result = new BusinessRuleResult();
        List<String> violations = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        List<String> approvals = new ArrayList<>();
        
        // 规则1: 信用限额不能超过最大允许值
        if (!validateCreditLimitRule(ruleContext, violations, warnings)) {
            result.setRulePassed(false);
        }
        
        // 规则2: 风险等级检查
        if (!validateRiskLevelRule(ruleContext, violations, warnings)) {
            result.setRulePassed(false);
        }
        
        // 规则3: 付款历史检查
        if (!validatePaymentHistoryRule(ruleContext, violations, warnings)) {
            result.setRulePassed(false);
        }
        
        // 规则4: 行业限制规则
        if (!validateIndustryRule(ruleContext, violations, warnings)) {
            result.setRulePassed(false);
        }
        
        // 规则5: 客户状态检查
        if (!validateCustomerStatusRule(ruleContext, violations, warnings)) {
            result.setRulePassed(false);
        }
        
        // 设置结果
        result.setViolations(violations);
        result.setWarnings(warnings);
        result.setApprovals(approvals);
        result.setExecutionDate(new Date());
        
        // 如果没有违规，标记为通过
        if (violations.isEmpty()) {
            result.setRulePassed(true);
            approvals.add("所有业务规则验证通过");
        }
        
        return result;
    }
    
    /**
     * 规则1: 信用限额验证
     */
    private static boolean validateCreditLimitRule(BusinessRuleContext context, 
                                                 List<String> violations, List<String> warnings) {
        BigDecimal requestedLimit = context.getRequestedCreditLimit();
        String creditRating = context.getCreditRating();
        
        // 基本验证
        if (requestedLimit == null || requestedLimit.compareTo(BigDecimal.ZERO) <= 0) {
            violations.add("信用限额必须大于0");
            return false;
        }
        
        // 最大限额检查 (POC简单规则)
        BigDecimal maxLimit = getMaxCreditLimit(creditRating);
        if (requestedLimit.compareTo(maxLimit) > 0) {
            violations.add(String.format("请求限额 %s 超过评级 %s 的最大允许限额 %s", 
                requestedLimit, creditRating, maxLimit));
            return false;
        }
        
        // 警告检查
        BigDecimal warningThreshold = maxLimit.multiply(new BigDecimal("0.8"));
        if (requestedLimit.compareTo(warningThreshold) > 0) {
            warnings.add("信用限额接近最大允许值，建议谨慎审批");
        }
        
        return true;
    }
    
    /**
     * 规则2: 风险等级验证
     */
    private static boolean validateRiskLevelRule(BusinessRuleContext context, 
                                               List<String> violations, List<String> warnings) {
        String riskLevel = context.getRiskLevel();
        BigDecimal requestedLimit = context.getRequestedCreditLimit();
        
        if ("VERY_HIGH".equals(riskLevel)) {
            violations.add("客户风险等级过高，不允许给予信用限额");
            return false;
        }
        
        if ("HIGH".equals(riskLevel)) {
            BigDecimal highRiskMaxLimit = getBusinessRuleValue("HIGH_RISK_MAX_LIMIT");
            if (highRiskMaxLimit != null && requestedLimit.compareTo(highRiskMaxLimit) > 0) {
                violations.add("高风险客户信用限额不能超过 " + String.format("%,.0f", highRiskMaxLimit));
                return false;
            }
            warnings.add("高风险客户，建议要求担保");
        }
        
        if ("MEDIUM".equals(riskLevel)) {
            warnings.add("中等风险客户，建议加强监控");
        }
        
        return true;
    }
    
    /**
     * 规则3: 付款历史验证
     */
    private static boolean validatePaymentHistoryRule(BusinessRuleContext context, 
                                                    List<String> violations, List<String> warnings) {
        int avgDelayDays = context.getAveragePaymentDelay();
        int totalTransactions = context.getTotalTransactions();
        
        // 严重逾期客户
        if (avgDelayDays > 60) {
            violations.add("客户平均付款延迟超过60天，不允许给予信用限额");
            return false;
        }
        
        // 中等逾期客户
        if (avgDelayDays > 30) {
            warnings.add("客户付款延迟较严重，建议降低信用限额");
        }
        
        // 新客户
        if (totalTransactions < 3) {
            warnings.add("新客户交易历史较少，建议给予较低的初始信用限额");
        }
        
        return true;
    }
    
    /**
     * 规则4: 行业限制验证
     */
    private static boolean validateIndustryRule(BusinessRuleContext context, 
                                              List<String> violations, List<String> warnings) {
        String industry = context.getIndustry();
        BigDecimal requestedLimit = context.getRequestedCreditLimit();
        
        // 高风险行业限制
        if ("entertainment".equalsIgnoreCase(industry) || "gambling".equalsIgnoreCase(industry)) {
            BigDecimal industryMaxLimit = new BigDecimal("30000");
            if (requestedLimit.compareTo(industryMaxLimit) > 0) {
                violations.add("娱乐/博彩行业信用限额不能超过30,000");
                return false;
            }
            warnings.add("高风险行业，建议加强审核");
        }
        
        // 建筑行业特殊处理
        if ("construction".equalsIgnoreCase(industry)) {
            warnings.add("建筑行业项目周期长，建议关注现金流");
        }
        
        return true;
    }
    
    /**
     * 规则5: 客户状态验证
     */
    private static boolean validateCustomerStatusRule(BusinessRuleContext context, 
                                                    List<String> violations, List<String> warnings) {
        String customerStatus = context.getCustomerStatus();
        
        if ("INACTIVE".equalsIgnoreCase(customerStatus)) {
            violations.add("非活跃客户不允许给予信用限额");
            return false;
        }
        
        if ("SUSPENDED".equalsIgnoreCase(customerStatus)) {
            violations.add("被暂停客户不允许给予信用限额");
            return false;
        }
        
        if ("NEW".equalsIgnoreCase(customerStatus)) {
            warnings.add("新客户，建议进行尽职调查");
        }
        
        return true;
    }
    
    /**
     * 根据信用评级获取最大信用限额
     */
    private static BigDecimal getMaxCreditLimit(String creditRating) {
        if (creditRating == null) return new BigDecimal("10000");
        
        switch (creditRating.toUpperCase()) {
            case "AAA": return new BigDecimal("1000000");
            case "AA": return new BigDecimal("500000");
            case "A": return new BigDecimal("200000");
            case "BBB": return new BigDecimal("100000");
            case "BB": return new BigDecimal("50000");
            case "B": return new BigDecimal("20000");
            case "C": return new BigDecimal("10000");
            default: return new BigDecimal("10000");
        }
    }
    
    /**
     * 业务规则上下文类 - 包含执行规则所需的所有数据
     */
    public static class BusinessRuleContext {
        private String customerId;
        private String customerStatus;
        private String creditRating;
        private String riskLevel;
        private String industry;
        private BigDecimal requestedCreditLimit;
        private BigDecimal currentCreditLimit;
        private BigDecimal outstandingBalance;
        private int averagePaymentDelay;
        private int totalTransactions;
        private String operationType; // CREATE, UPDATE, SUSPEND
        
        // Constructors
        public BusinessRuleContext() {}
        
        // Getters and Setters
        public String getCustomerId() { return customerId; }
        public void setCustomerId(String customerId) { this.customerId = customerId; }
        
        public String getCustomerStatus() { return customerStatus; }
        public void setCustomerStatus(String customerStatus) { this.customerStatus = customerStatus; }
        
        public String getCreditRating() { return creditRating; }
        public void setCreditRating(String creditRating) { this.creditRating = creditRating; }
        
        public String getRiskLevel() { return riskLevel; }
        public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
        
        public String getIndustry() { return industry; }
        public void setIndustry(String industry) { this.industry = industry; }
        
        public BigDecimal getRequestedCreditLimit() { return requestedCreditLimit; }
        public void setRequestedCreditLimit(BigDecimal requestedCreditLimit) { this.requestedCreditLimit = requestedCreditLimit; }
        
        public BigDecimal getCurrentCreditLimit() { return currentCreditLimit; }
        public void setCurrentCreditLimit(BigDecimal currentCreditLimit) { this.currentCreditLimit = currentCreditLimit; }
        
        public BigDecimal getOutstandingBalance() { return outstandingBalance; }
        public void setOutstandingBalance(BigDecimal outstandingBalance) { this.outstandingBalance = outstandingBalance; }
        
        public int getAveragePaymentDelay() { return averagePaymentDelay; }
        public void setAveragePaymentDelay(int averagePaymentDelay) { this.averagePaymentDelay = averagePaymentDelay; }
        
        public int getTotalTransactions() { return totalTransactions; }
        public void setTotalTransactions(int totalTransactions) { this.totalTransactions = totalTransactions; }
        
        public String getOperationType() { return operationType; }
        public void setOperationType(String operationType) { this.operationType = operationType; }
    }
    
    /**
     * 业务规则执行结果类
     */
    public static class BusinessRuleResult {
        private boolean rulePassed;
        private List<String> violations;
        private List<String> warnings;
        private List<String> approvals;
        private Date executionDate;
        
        public BusinessRuleResult() {
            this.violations = new ArrayList<>();
            this.warnings = new ArrayList<>();
            this.approvals = new ArrayList<>();
            this.rulePassed = true;
        }
        
        // Getters and Setters
        public boolean isRulePassed() { return rulePassed; }
        public void setRulePassed(boolean rulePassed) { this.rulePassed = rulePassed; }
        
        public List<String> getViolations() { return violations; }
        public void setViolations(List<String> violations) { this.violations = violations; }
        
        public List<String> getWarnings() { return warnings; }
        public void setWarnings(List<String> warnings) { this.warnings = warnings; }
        
        public List<String> getApprovals() { return approvals; }
        public void setApprovals(List<String> approvals) { this.approvals = approvals; }
        
        public Date getExecutionDate() { return executionDate; }
        public void setExecutionDate(Date executionDate) { this.executionDate = executionDate; }
    }
    
    // Database connection details
    private static final String DB_URL = "jdbc:postgresql://172.31.19.10:5432/creditcontrol";
    private static final String DB_USER = "creditapp";
    private static final String DB_PASSWORD = "secure123";
    
    // Cache for business rules
    private static Map<String, BigDecimal> businessRulesCache = new HashMap<>();
    private static long lastBusinessRulesCacheUpdate = 0;
    private static final long CACHE_TTL = 300000; // 5 minutes TTL
    
    /**
     * 从数据库获取业务规则值
     */
    private static BigDecimal getBusinessRuleValue(String ruleName) {
        // Check cache first
        if (isBusinessRulesCacheValid() && businessRulesCache.containsKey(ruleName)) {
            return businessRulesCache.get(ruleName);
        }
        
        // Reload cache from database
        loadBusinessRulesFromDatabase();
        
        return businessRulesCache.get(ruleName);
    }
    
    /**
     * 检查业务规则缓存是否有效
     */
    private static boolean isBusinessRulesCacheValid() {
        return (System.currentTimeMillis() - lastBusinessRulesCacheUpdate) < CACHE_TTL;
    }
    
    /**
     * 从数据库加载业务规则
     */
    private static synchronized void loadBusinessRulesFromDatabase() {
        // Double-check pattern for thread safety
        if (isBusinessRulesCacheValid()) {
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT rule_name, rule_value FROM business_rules " +
                        "WHERE is_active = TRUE " +
                        "AND (effective_date IS NULL OR effective_date <= CURRENT_DATE) " +
                        "AND (expiry_date IS NULL OR expiry_date > CURRENT_DATE) " +
                        "AND rule_value IS NOT NULL " +
                        "ORDER BY priority DESC";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            Map<String, BigDecimal> newCache = new HashMap<>();
            while (rs.next()) {
                String ruleName = rs.getString("rule_name");
                BigDecimal ruleValue = rs.getBigDecimal("rule_value");
                newCache.put(ruleName, ruleValue);
            }
            
            // Update cache atomically
            businessRulesCache = newCache;
            lastBusinessRulesCacheUpdate = System.currentTimeMillis();
                
        } catch (Exception e) {
            // If database fails, use emergency fallback
            if (businessRulesCache.isEmpty()) {
                loadEmergencyBusinessRules();
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * 紧急情况下的业务规则后备
     */
    private static void loadEmergencyBusinessRules() {
        Map<String, BigDecimal> fallback = new HashMap<>();
        fallback.put("HIGH_RISK_MAX_LIMIT", new BigDecimal("50000"));
        fallback.put("MAX_CREDIT_LIMIT_GLOBAL", new BigDecimal("10000000"));
        fallback.put("HIGH_VALUE_CUSTOMER_THRESHOLD", new BigDecimal("100000"));
        fallback.put("MIN_CREDIT_LIMIT", new BigDecimal("1000"));
        
        businessRulesCache = fallback;
        lastBusinessRulesCacheUpdate = System.currentTimeMillis();
    }
}