package com.creditcontrol.service;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Simple Risk Assessment Engine - POC Implementation
 * 简单的风险评估引擎 - POC实现
 */
public class RiskAssessmentEngine {
    
    // Database connection details
    private static final String DB_URL = "jdbc:postgresql://172.31.19.10:5432/creditcontrol";
    private static final String DB_USER = "creditapp";
    private static final String DB_PASSWORD = "secure123";
    
    // Cache for risk assessment weights
    private static Map<String, Double> riskWeightsCache = new HashMap<>();
    private static long lastRiskWeightsCacheUpdate = 0;
    private static final long CACHE_TTL = 300000; // 5 minutes TTL
    
    /**
     * 计算客户风险评分 (0-100分，分数越高风险越低)
     * @param customerData 客户数据
     * @return 风险评估结果
     */
    public static RiskAssessmentResult calculateRiskScore(CustomerRiskData customerData) {
        RiskAssessmentResult result = new RiskAssessmentResult();
        
        // 1. 信用评级评分 (40%)
        double creditRatingScore = getCreditRatingScore(customerData.getCreditRating());
        
        // 2. 付款历史评分 (30%)
        double paymentHistoryScore = getPaymentHistoryScore(customerData.getPaymentDelayDays(), 
                                                           customerData.getTotalTransactions());
        
        // 3. 未偿余额评分 (20%)
        double balanceScore = getBalanceRiskScore(customerData.getOutstandingBalance(), 
                                                customerData.getCreditLimit());
        
        // 4. 行业风险评分 (10%)
        double industryScore = getIndustryRiskScore(customerData.getIndustry());
        
        // 5. 综合评分计算 - 使用数据库中的权重
        double creditRatingWeight = getRiskWeight("CREDIT_RATING");
        double paymentHistoryWeight = getRiskWeight("PAYMENT_HISTORY");
        double outstandingBalanceWeight = getRiskWeight("OUTSTANDING_BALANCE");
        double industryRiskWeight = getRiskWeight("INDUSTRY_RISK");
        
        double totalScore = (creditRatingScore * creditRatingWeight) +
                          (paymentHistoryScore * paymentHistoryWeight) +
                          (balanceScore * outstandingBalanceWeight) +
                          (industryScore * industryRiskWeight);
        
        // 6. 设置结果
        result.setRiskScore((int) Math.round(totalScore));
        result.setRiskLevel(determineRiskLevel(result.getRiskScore()));
        result.setCreditRatingScore(creditRatingScore);
        result.setPaymentHistoryScore(paymentHistoryScore);
        result.setBalanceScore(balanceScore);
        result.setIndustryScore(industryScore);
        result.setAssessmentDate(new Date());
        
        // 7. 生成建议
        result.setRecommendation(generateRecommendation(result));
        
        return result;
    }
    
    /**
     * 根据信用评级计算分数
     */
    private static double getCreditRatingScore(String rating) {
        if (rating == null) return 30.0;
        
        switch (rating.toUpperCase()) {
            case "AAA": return 95.0;
            case "AA": return 85.0;
            case "A": return 75.0;
            case "BBB": return 65.0;
            case "BB": return 50.0;
            case "B": return 35.0;
            case "C": return 20.0;
            default: return 30.0;
        }
    }
    
    /**
     * 根据付款历史计算分数
     */
    private static double getPaymentHistoryScore(int avgDelayDays, int totalTransactions) {
        if (totalTransactions == 0) return 50.0; // 新客户默认中等分数
        
        // 基于平均延迟天数计算
        if (avgDelayDays <= 0) return 95.0;      // 提前或按时付款
        else if (avgDelayDays <= 5) return 85.0;  // 轻微延迟
        else if (avgDelayDays <= 15) return 70.0; // 中等延迟
        else if (avgDelayDays <= 30) return 50.0; // 严重延迟
        else return 25.0; // 非常严重延迟
    }
    
    /**
     * 根据余额使用率计算分数
     */
    private static double getBalanceRiskScore(BigDecimal outstandingBalance, BigDecimal creditLimit) {
        if (creditLimit == null || creditLimit.compareTo(BigDecimal.ZERO) == 0) {
            return 50.0; // 默认分数
        }
        
        double utilizationRate = outstandingBalance.divide(creditLimit, 4, BigDecimal.ROUND_HALF_UP).doubleValue();
        
        if (utilizationRate <= 0.3) return 90.0;      // 使用率30%以下 - 低风险
        else if (utilizationRate <= 0.5) return 75.0; // 使用率50%以下 - 中低风险
        else if (utilizationRate <= 0.8) return 55.0; // 使用率80%以下 - 中等风险
        else if (utilizationRate <= 0.95) return 35.0; // 使用率95%以下 - 高风险
        else return 15.0; // 使用率95%以上 - 极高风险
    }
    
    /**
     * 根据行业分类计算风险分数
     */
    private static double getIndustryRiskScore(String industry) {
        if (industry == null) return 50.0;
        
        switch (industry.toLowerCase()) {
            case "manufacturing": return 70.0;    // 制造业 - 中低风险
            case "technology": return 75.0;       // 科技业 - 中低风险
            case "healthcare": return 80.0;       // 医疗 - 低风险
            case "finance": return 65.0;          // 金融 - 中等风险
            case "retail": return 60.0;           // 零售 - 中等风险
            case "construction": return 45.0;     // 建筑 - 中高风险
            case "entertainment": return 40.0;    // 娱乐 - 高风险
            default: return 55.0; // 其他行业 - 中等风险
        }
    }
    
    /**
     * 确定风险等级
     */
    private static String determineRiskLevel(int score) {
        if (score >= 80) return "LOW";          // 低风险
        else if (score >= 60) return "MEDIUM";  // 中等风险
        else if (score >= 40) return "HIGH";    // 高风险
        else return "VERY_HIGH";                // 极高风险
    }
    
    /**
     * 生成风险建议
     */
    private static String generateRecommendation(RiskAssessmentResult result) {
        String riskLevel = result.getRiskLevel();
        int score = result.getRiskScore();
        
        StringBuilder recommendation = new StringBuilder();
        recommendation.append("风险评分: ").append(score).append("/100, ");
        
        switch (riskLevel) {
            case "LOW":
                recommendation.append("建议: 可以给予较高信用限额，正常业务往来。");
                break;
            case "MEDIUM":
                recommendation.append("建议: 给予适中信用限额，加强监控付款情况。");
                break;
            case "HIGH":
                recommendation.append("建议: 限制信用限额，要求担保或预付款。");
                break;
            case "VERY_HIGH":
                recommendation.append("建议: 暂停信用业务，仅接受现金交易。");
                break;
        }
        
        return recommendation.toString();
    }
    
    /**
     * 客户风险数据类
     */
    public static class CustomerRiskData {
        private String creditRating;
        private int paymentDelayDays;
        private int totalTransactions;
        private BigDecimal outstandingBalance;
        private BigDecimal creditLimit;
        private String industry;
        
        // Constructors
        public CustomerRiskData() {}
        
        public CustomerRiskData(String creditRating, int paymentDelayDays, int totalTransactions,
                              BigDecimal outstandingBalance, BigDecimal creditLimit, String industry) {
            this.creditRating = creditRating;
            this.paymentDelayDays = paymentDelayDays;
            this.totalTransactions = totalTransactions;
            this.outstandingBalance = outstandingBalance;
            this.creditLimit = creditLimit;
            this.industry = industry;
        }
        
        // Getters and Setters
        public String getCreditRating() { return creditRating; }
        public void setCreditRating(String creditRating) { this.creditRating = creditRating; }
        
        public int getPaymentDelayDays() { return paymentDelayDays; }
        public void setPaymentDelayDays(int paymentDelayDays) { this.paymentDelayDays = paymentDelayDays; }
        
        public int getTotalTransactions() { return totalTransactions; }
        public void setTotalTransactions(int totalTransactions) { this.totalTransactions = totalTransactions; }
        
        public BigDecimal getOutstandingBalance() { return outstandingBalance; }
        public void setOutstandingBalance(BigDecimal outstandingBalance) { this.outstandingBalance = outstandingBalance; }
        
        public BigDecimal getCreditLimit() { return creditLimit; }
        public void setCreditLimit(BigDecimal creditLimit) { this.creditLimit = creditLimit; }
        
        public String getIndustry() { return industry; }
        public void setIndustry(String industry) { this.industry = industry; }
    }
    
    /**
     * 风险评估结果类
     */
    public static class RiskAssessmentResult {
        private int riskScore;
        private String riskLevel;
        private double creditRatingScore;
        private double paymentHistoryScore;
        private double balanceScore;
        private double industryScore;
        private String recommendation;
        private Date assessmentDate;
        
        // Getters and Setters
        public int getRiskScore() { return riskScore; }
        public void setRiskScore(int riskScore) { this.riskScore = riskScore; }
        
        public String getRiskLevel() { return riskLevel; }
        public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
        
        public double getCreditRatingScore() { return creditRatingScore; }
        public void setCreditRatingScore(double creditRatingScore) { this.creditRatingScore = creditRatingScore; }
        
        public double getPaymentHistoryScore() { return paymentHistoryScore; }
        public void setPaymentHistoryScore(double paymentHistoryScore) { this.paymentHistoryScore = paymentHistoryScore; }
        
        public double getBalanceScore() { return balanceScore; }
        public void setBalanceScore(double balanceScore) { this.balanceScore = balanceScore; }
        
        public double getIndustryScore() { return industryScore; }
        public void setIndustryScore(double industryScore) { this.industryScore = industryScore; }
        
        public String getRecommendation() { return recommendation; }
        public void setRecommendation(String recommendation) { this.recommendation = recommendation; }
        
        public Date getAssessmentDate() { return assessmentDate; }
        public void setAssessmentDate(Date assessmentDate) { this.assessmentDate = assessmentDate; }
    }
    
    /**
     * 从数据库获取风险权重
     */
    private static double getRiskWeight(String factorName) {
        // Check cache first
        if (isRiskWeightsCacheValid() && riskWeightsCache.containsKey(factorName)) {
            return riskWeightsCache.get(factorName);
        }
        
        // Reload cache from database
        loadRiskWeightsFromDatabase();
        
        // Return cached value or default fallback
        Double weight = riskWeightsCache.get(factorName);
        if (weight != null) {
            return weight;
        }
        
        // Emergency fallback weights
        switch (factorName) {
            case "CREDIT_RATING": return 0.4;
            case "PAYMENT_HISTORY": return 0.3;
            case "OUTSTANDING_BALANCE": return 0.2;
            case "INDUSTRY_RISK": return 0.1;
            default: return 0.0;
        }
    }
    
    /**
     * 检查风险权重缓存是否有效
     */
    private static boolean isRiskWeightsCacheValid() {
        return (System.currentTimeMillis() - lastRiskWeightsCacheUpdate) < CACHE_TTL;
    }
    
    /**
     * 从数据库加载风险权重
     */
    private static synchronized void loadRiskWeightsFromDatabase() {
        // Double-check pattern for thread safety
        if (isRiskWeightsCacheValid()) {
            return;
        }
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            String sql = "SELECT factor_name, weight_value FROM risk_assessment_weights " +
                        "WHERE effective_date <= CURRENT_DATE " +
                        "ORDER BY factor_name";
            
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            
            Map<String, Double> newCache = new HashMap<>();
            while (rs.next()) {
                String factorName = rs.getString("factor_name");
                Double weightValue = rs.getDouble("weight_value");
                newCache.put(factorName, weightValue);
            }
            
            // Update cache atomically
            riskWeightsCache = newCache;
            lastRiskWeightsCacheUpdate = System.currentTimeMillis();
                
        } catch (Exception e) {
            // If database fails, use emergency fallback
            if (riskWeightsCache.isEmpty()) {
                loadEmergencyRiskWeights();
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * 紧急情况下的风险权重后备
     */
    private static void loadEmergencyRiskWeights() {
        Map<String, Double> fallback = new HashMap<>();
        fallback.put("CREDIT_RATING", 0.4);
        fallback.put("PAYMENT_HISTORY", 0.3);
        fallback.put("OUTSTANDING_BALANCE", 0.2);
        fallback.put("INDUSTRY_RISK", 0.1);
        
        riskWeightsCache = fallback;
        lastRiskWeightsCacheUpdate = System.currentTimeMillis();
    }
}