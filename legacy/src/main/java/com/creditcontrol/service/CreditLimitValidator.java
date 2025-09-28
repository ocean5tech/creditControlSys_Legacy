package com.creditcontrol.service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import com.creditcontrol.util.LoggerUtil;

/**
 * Simple Credit Limit Validation Logic - POC Implementation
 * 简单的信用限额验证逻辑 - POC实现
 */
public class CreditLimitValidator {
    
    // 简单的信用评级到限额映射 (POC数据)
    private static final Map<String, BigDecimal> CREDIT_RATING_LIMITS = new HashMap<>();
    
    static {
        CREDIT_RATING_LIMITS.put("AAA", new BigDecimal("1000000")); // 100万
        CREDIT_RATING_LIMITS.put("AA", new BigDecimal("500000"));   // 50万
        CREDIT_RATING_LIMITS.put("A", new BigDecimal("200000"));    // 20万
        CREDIT_RATING_LIMITS.put("BBB", new BigDecimal("100000"));  // 10万
        CREDIT_RATING_LIMITS.put("BB", new BigDecimal("50000"));    // 5万
        CREDIT_RATING_LIMITS.put("B", new BigDecimal("20000"));     // 2万
        CREDIT_RATING_LIMITS.put("C", new BigDecimal("10000"));     // 1万
    }
    
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
        
        // 2. 评级验证
        BigDecimal maxAllowedLimit = CREDIT_RATING_LIMITS.get(customerRating.toUpperCase());
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
     * 根据评级获取建议的信用限额
     */
    public static BigDecimal getSuggestedCreditLimit(String customerRating) {
        return CREDIT_RATING_LIMITS.get(customerRating.toUpperCase());
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