package com.creditcontrol.service;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import com.creditcontrol.util.LoggerUtil;

/**
 * Credit Limit Validation Logic - Database-driven Business Rules
 * 信用限额验证逻辑 - 数据库驱动的业务规则
 */
public class CreditLimitValidator {
    
    private static final String DB_URL = "jdbc:postgresql://35.77.54.203:5432/creditcontrol";
    private static final String DB_USER = "creditapp";
    private static final String DB_PASSWORD = "secure123";
    
    // Cache for credit rating limits to avoid frequent DB calls
    private static Map<String, BigDecimal> creditRatingLimitsCache = new HashMap<>();
    private static long lastCacheUpdate = 0;
    private static final long CACHE_TTL = 300000; // 5 minutes TTL
    
    /**
     * 验证信用限额是否合规
     * @param customerRating 客户信用评级
     * @param requestedLimit 申请的信用限额
     * @return 验证结果
     */
    public static ValidationResult validateCreditLimit(String customerRating, BigDecimal requestedLimit) {
        ValidationResult result = new ValidationResult();
        
        // 记录验证开始
        LoggerUtil.logBusiness("CreditLimitValidation", 
            String.format("Starting validation for rating:%s, limit:%s", customerRating, requestedLimit));
        
        // 1. 基本验证
        if (customerRating == null || customerRating.trim().isEmpty()) {
            result.setValid(false);
            result.setErrorMessage("客户信用评级不能为空");
            LoggerUtil.logBusinessError("CreditLimitValidation", "Missing credit rating", null);
            return result;
        }
        
        if (requestedLimit == null || requestedLimit.compareTo(BigDecimal.ZERO) <= 0) {
            result.setValid(false);
            result.setErrorMessage("申请信用限额必须大于0");
            return result;
        }
        
        // 2. 评级验证 - 从数据库获取
        BigDecimal maxAllowedLimit = getCreditRatingLimit(customerRating.toUpperCase());
        if (maxAllowedLimit == null) {
            result.setValid(false);
            result.setErrorMessage("无效的信用评级: " + customerRating);
            return result;
        }
        
        // 3. 限额验证
        if (requestedLimit.compareTo(maxAllowedLimit) > 0) {
            result.setValid(false);
            result.setErrorMessage(String.format("申请限额 %s 超过评级 %s 的最大允许限额 %s", 
                requestedLimit, customerRating, maxAllowedLimit));
            result.setSuggestedLimit(maxAllowedLimit);
            return result;
        }
        
        // 4. 通过验证
        result.setValid(true);
        result.setMessage("信用限额验证通过");
        result.setApprovedLimit(requestedLimit);
        
        // 记录验证成功
        LoggerUtil.logBusiness("CreditLimitValidation", 
            String.format("Validation passed for rating:%s, approved limit:%s", customerRating, requestedLimit));
        
        return result;
    }
    
    /**
     * 根据评级获取建议的信用限额 - 从数据库获取
     */
    public static BigDecimal getSuggestedCreditLimit(String customerRating) {
        return getCreditRatingLimit(customerRating.toUpperCase());
    }
    
    /**
     * 从数据库获取信用评级对应的最大限额
     */
    private static BigDecimal getCreditRatingLimit(String creditRating) {
        // Check cache first
        if (isCacheValid() && creditRatingLimitsCache.containsKey(creditRating)) {
            return creditRatingLimitsCache.get(creditRating);
        }
        
        // Reload cache from database
        loadCreditRatingLimitsFromDatabase();
        
        return creditRatingLimitsCache.get(creditRating);
    }
    
    /**
     * 检查缓存是否有效
     */
    private static boolean isCacheValid() {
        return (System.currentTimeMillis() - lastCacheUpdate) < CACHE_TTL;
    }
    
    /**
     * 从数据库加载信用评级限额
     */
    private static synchronized void loadCreditRatingLimitsFromDatabase() {
        // Double-check pattern for thread safety
        if (isCacheValid()) {
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT credit_rating, max_credit_limit FROM credit_rating_limits " +
                        "WHERE (effective_date IS NULL OR effective_date <= CURRENT_DATE) " +
                        "AND (expiry_date IS NULL OR expiry_date > CURRENT_DATE) " +
                        "ORDER BY credit_rating";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            Map<String, BigDecimal> newCache = new HashMap<>();
            while (rs.next()) {
                String rating = rs.getString("credit_rating");
                BigDecimal limit = rs.getBigDecimal("max_credit_limit");
                newCache.put(rating, limit);
            }
            
            // Update cache atomically
            creditRatingLimitsCache = newCache;
            lastCacheUpdate = System.currentTimeMillis();
            
            LoggerUtil.logBusiness("CreditLimitValidator", 
                "Loaded " + newCache.size() + " credit rating limits from database");
                
        } catch (Exception e) {
            LoggerUtil.logBusinessError("CreditLimitValidator", 
                "Failed to load credit rating limits from database", e);
            
            // If database fails, use emergency fallback
            if (creditRatingLimitsCache.isEmpty()) {
                loadEmergencyFallbackRules();
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * 紧急情况下的后备规则
     */
    private static void loadEmergencyFallbackRules() {
        Map<String, BigDecimal> fallback = new HashMap<>();
        fallback.put("AAA", new BigDecimal("1000000"));
        fallback.put("AA", new BigDecimal("500000"));
        fallback.put("A", new BigDecimal("200000"));
        fallback.put("BBB", new BigDecimal("100000"));
        fallback.put("BB", new BigDecimal("50000"));
        fallback.put("B", new BigDecimal("20000"));
        fallback.put("C", new BigDecimal("10000"));
        
        creditRatingLimitsCache = fallback;
        lastCacheUpdate = System.currentTimeMillis();
        
        LoggerUtil.logBusinessError("CreditLimitValidator", 
            "Using emergency fallback credit rating limits", null);
    }
    
    /**
     * 验证结果类
     */
    public static class ValidationResult {
        private boolean valid;
        private String message;
        private String errorMessage;
        private BigDecimal approvedLimit;
        private BigDecimal suggestedLimit;
        
        // Getters and Setters
        public boolean isValid() { return valid; }
        public void setValid(boolean valid) { this.valid = valid; }
        
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
        
        public String getErrorMessage() { return errorMessage; }
        public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
        
        public BigDecimal getApprovedLimit() { return approvedLimit; }
        public void setApprovedLimit(BigDecimal approvedLimit) { this.approvedLimit = approvedLimit; }
        
        public BigDecimal getSuggestedLimit() { return suggestedLimit; }
        public void setSuggestedLimit(BigDecimal suggestedLimit) { this.suggestedLimit = suggestedLimit; }
    }
}