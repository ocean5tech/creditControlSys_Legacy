package com.creditcontrol.util;

import org.apache.log4j.Logger;

/**
 * Log4j日志工具类 - POC实现
 * 提供统一的日志记录接口
 */
public class LoggerUtil {
    
    // 业务日志记录器
    private static final Logger BUSINESS_LOGGER = Logger.getLogger("com.creditcontrol.service");
    
    // 审计日志记录器
    private static final Logger AUDIT_LOGGER = Logger.getLogger("com.creditcontrol.audit");
    
    // 数据库操作日志记录器
    private static final Logger DATABASE_LOGGER = Logger.getLogger("com.creditcontrol.dao");
    
    /**
     * 记录业务操作日志
     */
    public static void logBusiness(String operation, String details) {
        BUSINESS_LOGGER.info(String.format("[BUSINESS] %s: %s", operation, details));
    }
    
    /**
     * 记录业务错误日志
     */
    public static void logBusinessError(String operation, String error, Exception e) {
        BUSINESS_LOGGER.error(String.format("[BUSINESS_ERROR] %s: %s", operation, error), e);
    }
    
    /**
     * 记录审计日志 - 用户操作追踪
     */
    public static void logAudit(String userId, String action, String target, String result) {
        AUDIT_LOGGER.info(String.format("User:%s Action:%s Target:%s Result:%s", 
            userId != null ? userId : "SYSTEM", action, target, result));
    }
    
    /**
     * 记录数据库操作日志
     */
    public static void logDatabase(String operation, String table, String details) {
        DATABASE_LOGGER.debug(String.format("[DB_OP] %s on %s: %s", operation, table, details));
    }
    
    /**
     * 记录数据库错误
     */
    public static void logDatabaseError(String operation, String table, Exception e) {
        DATABASE_LOGGER.error(String.format("[DB_ERROR] %s on %s failed", operation, table), e);
    }
    
    /**
     * 记录系统级别日志
     */
    public static void logSystem(Class<?> clazz, String level, String message) {
        Logger logger = Logger.getLogger(clazz);
        
        if ("DEBUG".equals(level)) {
            logger.debug(message);
        } else if ("INFO".equals(level)) {
            logger.info(message);
        } else if ("WARN".equals(level)) {
            logger.warn(message);
        } else if ("ERROR".equals(level)) {
            logger.error(message);
        }
    }
    
    /**
     * 记录系统错误
     */
    public static void logSystemError(Class<?> clazz, String message, Exception e) {
        Logger logger = Logger.getLogger(clazz);
        logger.error(message, e);
    }
    
    /**
     * 记录信用控制特定操作
     */
    public static void logCreditOperation(String customerId, String operation, String oldValue, String newValue) {
        logAudit("SYSTEM", "CREDIT_" + operation, customerId, 
            String.format("Changed from [%s] to [%s]", oldValue, newValue));
        logBusiness("CreditControl", 
            String.format("Customer %s: %s changed from %s to %s", customerId, operation, oldValue, newValue));
    }
    
    /**
     * 记录风险评估操作
     */
    public static void logRiskAssessment(String customerId, int riskScore, String riskLevel) {
        logBusiness("RiskAssessment", 
            String.format("Customer %s: Risk score %d, Level %s", customerId, riskScore, riskLevel));
    }
    
    /**
     * 记录业务规则验证
     */
    public static void logBusinessRuleValidation(String customerId, boolean passed, String details) {
        String result = passed ? "PASSED" : "FAILED";
        logAudit("SYSTEM", "BUSINESS_RULE_CHECK", customerId, result);
        logBusiness("BusinessRule", 
            String.format("Customer %s: Validation %s - %s", customerId, result, details));
    }
}