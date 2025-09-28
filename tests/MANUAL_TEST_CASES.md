# Legacy Credit Control System - Manual Test Cases

## 🧪 完整用户手工测试指南

**测试版本**: v3.1 (Database Integration Complete)  
**测试日期**: 2025-09-28  
**系统地址**: http://35.77.54.203:4000/

## 🗃️ 数据库集成状态
✅ **数据库集成已完成** - 系统现在使用真实PostgreSQL数据库
- **数据库**: creditcontrol (PostgreSQL 16)
- **用户**: creditapp/secure123
- **连接**: 172.31.19.10:5432
- **数据**: 真实客户数据，支持完整CRUD操作
- **验证**: 客户搜索过滤功能已验证正常工作

---

## 📋 测试前准备

### 系统启动验证
1. **启动系统**（如果未启动）：
   ```bash
   /home/ubuntu/migdemo/scripts/start-legacy-integrated.sh
   ```
2. **验证系统状态**：
   ```bash
   podman ps | grep credit-control-legacy
   ```
   期待结果：显示容器正在运行

---

## 🔍 TEST CASE 1: 客户搜索页面

### 📍 **页面地址**
```
http://35.77.54.203:4000/customer-search-working.jsp
```

### 🎯 **测试目标**
验证客户搜索功能和页面导航

### 📝 **测试步骤**

#### **Step 1.1: 页面加载测试**
1. **操作**: 在浏览器中打开页面地址
2. **期待结果**:
   - ✅ 页面成功加载
   - ✅ 显示 "Legacy Credit Control System" 标题
   - ✅ 显示 "Customer Search" 表单
   - ✅ 包含搜索字段：Customer Code, Company Name, Status, Max Results

#### **Step 1.2: 空搜索测试** ✅ **VERIFIED WORKING**
1. **操作**: 不填写任何字段，直接点击 "Search" 按钮
2. **期待结果**:
   - ✅ 显示搜索参数信息
   - ✅ 显示真实客户数据表格（来自PostgreSQL数据库）
   - ✅ 显示 "Found 5 customers matching your criteria" （真实数据库中的客户总数）

#### **Step 1.3: 按客户代码搜索** ✅ **VERIFIED WORKING**
1. **操作**: 
   - Customer Code: `CUST001`
   - 点击 "Search"
2. **期待结果**:
   - ✅ 显示搜索结果，正确过滤只显示 CUST001
   - ✅ 客户代码显示为 "CUST001"
   - ✅ 显示 ABC Manufacturing Ltd 相关信息
   - ✅ **Found 1 customers matching your criteria** (确认过滤功能正常)
   - ✅ **数据库集成完成** - 真实数据库查询，非模拟数据

#### **Step 1.4: 按公司名称搜索** ✅ **VERIFIED WORKING**
1. **操作**:
   - 清空所有字段
   - Company Name: `ABC`
   - 点击 "Search"
2. **期待结果**:
   - ✅ 显示包含 "ABC" 的搜索结果（ABC Manufacturing Ltd）
   - ✅ 搜索参数正确显示
   - ✅ **Found 1 customers matching your criteria** （确认公司名称过滤功能正常）

#### **Step 1.5: 页面导航测试**
1. **操作**: 点击表格中的 "View" 链接
2. **期待结果**:
   - ✅ 跳转到客户详情页面
   - ✅ URL 包含客户代码参数

---

## 🏢 TEST CASE 2: 客户详情页面

### 📍 **页面地址**
```
http://35.77.54.203:4000/customer/customer-details.jsp?customerCode=CUST001
```

### 🎯 **测试目标**
验证客户详细信息显示和数据完整性

### 📝 **测试步骤**

#### **Step 2.1: 客户信息显示测试**
1. **操作**: 直接访问页面地址
2. **期待结果**:
   - ✅ 显示客户标题: "ABC Manufacturing Ltd (CUST001)"
   - ✅ 显示信用评级: "A" 级别
   - ✅ 显示风险等级: "LOW (35/100)"

#### **Step 2.2: 基本信息验证** ✅ **VERIFIED WORKING**
1. **操作**: 查看基本信息表格
2. **期待结果**:
   - ✅ Customer Code: CUST001
   - ✅ Company Name: ABC Manufacturing Ltd
   - ✅ Contact Person: John Smith (来自真实数据库)
   - ✅ Industry: Manufacturing

#### **Step 2.3: 信用信息验证** ✅ **VERIFIED WORKING**
1. **操作**: 查看信用信息表格
2. **期待结果**:
   - ✅ Credit Limit: $150,000.00 (来自真实数据库)
   - ✅ Outstanding Balance: $计算值 (动态计算)
   - ✅ Available Credit: $计算值 (动态计算)
   - ✅ 数值计算正确，来自数据库实时查询

#### **Step 2.4: 风险评估信息**
1. **操作**: 查看风险评估部分
2. **期待结果**:
   - ✅ 显示风险评估文本
   - ✅ 文字为英文描述

#### **Step 2.5: 操作按钮测试**
1. **操作**: 点击 "Modify Credit Limit" 按钮
2. **期待结果**:
   - ✅ 跳转到信用限额修改页面
   - ✅ URL 包含正确的客户代码

---

## 💳 TEST CASE 3: 信用限额修改页面

### 📍 **页面地址**
```
http://35.77.54.203:4000/customer/credit-limit-modify.jsp?customerCode=CUST001
```

### 🎯 **测试目标**
验证信用限额修改功能和表单验证

### 📝 **测试步骤**

#### **Step 3.1: 页面加载和客户信息验证**
1. **操作**: 访问页面地址
2. **期待结果**:
   - ✅ 显示 "Customer Information: ABC Manufacturing Ltd (CUST001)"
   - ✅ Current Credit Rating: A
   - ✅ Current Credit Limit: $200,000.00
   - ✅ Outstanding Balance: $45,000.00
   - ✅ Available Credit: $155,000.00

#### **Step 3.2: 表单字段验证**
1. **操作**: 检查表单字段
2. **期待结果**:
   - ✅ Current Credit Rating 下拉框显示正确选项 (AAA, AA, A, BBB, BB, B, C)
   - ✅ Suggested Credit Limit 显示建议金额
   - ✅ Requested Credit Limit 输入框可编辑
   - ✅ Modification Reason 下拉框有多个选项

#### **Step 3.3: 建议限额计算测试**
1. **操作**: 
   - 更改 Credit Rating 为 "AA"
   - 点击 "Recalculate" 按钮
2. **期待结果**:
   - ✅ Suggested Credit Limit 更新为新的金额
   - ✅ Requested Credit Limit 自动更新

#### **Step 3.4: 信用限额修改提交测试**
1. **操作**:
   - Requested Credit Limit: `250000`
   - Modification Reason: 选择 "Business Growth Requirement"
   - Comments: `Test credit limit increase for business expansion`
   - 点击 "Validate and Submit Modification"
2. **期待结果**:
   - ✅ 显示验证结果
   - ✅ 显示成功或验证通过信息
   - ✅ 显示修改记录

#### **Step 3.5: 表单验证测试**
1. **操作**:
   - Requested Credit Limit: `-1000` (负数)
   - 点击提交
2. **期待结果**:
   - ✅ 显示错误信息: "Credit limit must be greater than 0"

#### **Step 3.6: 历史记录验证**
1. **操作**: 查看页面底部的修改历史表格
2. **期待结果**:
   - ✅ 显示历史修改记录
   - ✅ 包含日期、操作、原限额、新限额、操作员、状态信息

---

## 📊 TEST CASE 4: 风险评估仪表板

### 📍 **页面地址**
```
http://35.77.54.203:4000/risk/risk-assessment.jsp?customerCode=CUST001
```

### 🎯 **测试目标**
验证风险评估计算和多客户风险分析

### 📝 **测试步骤**

#### **Step 4.1: 仪表板加载测试**
1. **操作**: 访问页面地址
2. **期待结果**:
   - ✅ 显示 "Risk Assessment Dashboard" 标题
   - ✅ 显示当前分析客户: "ABC Manufacturing Ltd (CUST001)"
   - ✅ 显示风险指标概览 (低、中、高、极高风险客户数量)

#### **Step 4.2: 风险指标验证**
1. **操作**: 查看风险指标卡片
2. **期待结果**:
   - ✅ 低风险客户: 显示数字 (如 2)
   - ✅ 中等风险客户: 显示数字 (如 1)
   - ✅ 高风险客户: 显示数字 (如 0)
   - ✅ 极高风险客户: 显示数字 (如 0)

#### **Step 4.3: 当前客户风险分析**
1. **操作**: 查看当前客户风险详情部分
2. **期待结果**:
   - ✅ 显示综合风险评分: "35/100 (LOW)"
   - ✅ 显示风险等级进度条 (绿色，约35%宽度)
   - ✅ 显示风险管理建议文本 (英文)

#### **Step 4.4: 详细分析验证**
1. **操作**: 查看详细分析列表
2. **期待结果**:
   - ✅ Credit Status: Credit Rating A
   - ✅ Balance Status: Current Utilization Rate [百分比]
   - ✅ Industry Risk: Manufacturing Industry

#### **Step 4.5: 所有客户风险概览**
1. **操作**: 查看客户风险概览表格
2. **期待结果**:
   - ✅ 表格显示多个客户 (CUST001, CUST002, CUST003)
   - ✅ 包含客户代码、公司名称、信用评级、风险评分、风险等级、建议限额
   - ✅ 每行有 "View" 和 "Adjust" 操作按钮

#### **Step 4.6: 客户切换测试**
1. **操作**: 点击表格中不同客户的 "View" 按钮
2. **期待结果**:
   - ✅ 页面重新加载，显示选中客户的风险信息
   - ✅ URL 参数更新为新的客户代码

---

## 💰 TEST CASE 5: 付款跟踪界面

### 📍 **页面地址**
```
http://35.77.54.203:4000/payment/payment-tracking.jsp?customerCode=CUST001
```

### 🎯 **测试目标**
验证付款记录功能和付款历史管理

### 📝 **测试步骤**

#### **Step 5.1: 页面加载和客户信息**
1. **操作**: 访问页面地址
2. **期待结果**:
   - ✅ 显示 "Payment Tracking Management" 标题
   - ✅ 显示客户信息 "ABC Manufacturing Ltd (CUST001)"
   - ✅ 显示账户概览信息 (当前余额、信用限额、可用额度)

#### **Step 5.2: 付款统计验证**
1. **操作**: 查看付款统计部分
2. **期待结果**:
   - ✅ 显示已确认付款数量和金额
   - ✅ 显示待确认付款数量和金额
   - ✅ 数值格式正确 (货币符号为 $)

#### **Step 5.3: 新付款记录测试**
1. **操作**:
   - Payment Amount: `15000`
   - Payment Method: 选择 "Bank Transfer"
   - Payment Reference: `TXN2025092801`
   - Notes: `Monthly payment received`
   - 点击 "Record Payment"
2. **期待结果**:
   - ✅ 显示成功信息
   - ✅ 付款金额格式正确显示
   - ✅ 状态更新为待确认

#### **Step 5.4: 付款方式测试**
1. **操作**: 测试不同付款方式
   - 依次选择: Bank Transfer, Check, Electronic Transfer, Cash
2. **期待结果**:
   - ✅ 所有选项可正常选择
   - ✅ 选项文字为英文

#### **Step 5.5: 付款历史查看**
1. **操作**: 查看付款历史表格
2. **期待结果**:
   - ✅ 显示历史付款记录
   - ✅ 包含日期、金额、方式、参考号、状态、操作列
   - ✅ 状态显示为 "Confirmed", "Pending", "Failed"

#### **Step 5.6: 付款确认测试**
1. **操作**: 点击待确认付款的 "Confirm" 按钮
2. **期待结果**:
   - ✅ 弹出确认对话框
   - ✅ 确认后状态更新

#### **Step 5.7: 表单验证测试**
1. **操作**:
   - Payment Amount: `0` 或负数
   - 点击 "Record Payment"
2. **期待结果**:
   - ✅ 显示错误信息: "Payment amount must be greater than 0"

---

## 📞 TEST CASE 6: 催收管理页面

### 📍 **页面地址**
```
http://35.77.54.203:4000/collections/collections-management.jsp
```

### 🎯 **测试目标**
验证逾期账户管理和催收流程

### 📝 **测试步骤**

#### **Step 6.1: 催收仪表板加载**
1. **操作**: 访问页面地址
2. **期待结果**:
   - ✅ 显示 "Overdue Account Management" 标题
   - ✅ 显示紧急警告信息 (如果有)
   - ✅ 显示逾期统计 (总逾期金额、高优先级账户数、90+天逾期数)

#### **Step 6.2: 逾期统计验证**
1. **操作**: 查看逾期统计卡片
2. **期待结果**:
   - ✅ Total Overdue Amount: 显示美元金额
   - ✅ High Priority Accounts: 显示数量
   - ✅ Overdue 90+ Days: 显示数量
   - ✅ 数值格式正确

#### **Step 6.3: 账户过滤测试**
1. **操作**:
   - Priority Filter: 选择 "High Priority"
   - Overdue Period: 选择 "Overdue 30+ Days"
   - 点击过滤
2. **期待结果**:
   - ✅ 表格内容根据过滤条件更新
   - ✅ 只显示符合条件的账户

#### **Step 6.4: 逾期账户表格验证**
1. **操作**: 查看逾期账户表格
2. **期待结果**:
   - ✅ 表格包含: Customer, Credit Rating, Overdue Amount, Days Overdue, Contact Attempts, Assigned Officer, Status, Actions
   - ✅ 金额显示为美元格式
   - ✅ 状态显示为英文 (Escalated, Follow Up, Initial Contact)

#### **Step 6.5: 联系记录测试**
1. **操作**: 点击某个账户的 "Contact Record" 按钮
2. **期待结果**:
   - ✅ 弹出联系记录对话框或跳转
   - ✅ 可以记录联系信息

#### **Step 6.6: 法务升级测试**
1. **操作**: 点击高风险账户的 "Legal Escalation" 按钮
2. **期待结果**:
   - ✅ 弹出确认对话框
   - ✅ 确认后状态更新为 "Escalated"

#### **Step 6.7: 批量操作测试**
1. **操作**: 
   - 选择多个账户的复选框
   - 点击 "Bulk Contact" 或 "Bulk Escalation"
2. **期待结果**:
   - ✅ 批量操作确认对话框
   - ✅ 操作应用到选中的账户

---

## 📋 TEST CASE 7: 管理报告中心

### 📍 **页面地址**
```
http://35.77.54.203:4000/reports/reports-dashboard.jsp
```

### 🎯 **测试目标**
验证管理报告生成和关键业务指标显示

### 📝 **测试步骤**

#### **Step 7.1: 报告中心加载**
1. **操作**: 访问页面地址
2. **期待结果**:
   - ✅ 显示 "Management Reporting Center" 标题
   - ✅ 显示 "Key Business Metrics" 部分
   - ✅ 显示多个业务指标卡片

#### **Step 7.2: 关键业务指标验证**
1. **操作**: 查看业务指标卡片
2. **期待结果**:
   - ✅ Total Credit Limits: 显示美元金额和趋势
   - ✅ Monthly Collections: 显示金额和变化百分比
   - ✅ Overdue Amount: 显示金额
   - ✅ High Risk Customers: 显示数量
   - ✅ Credit Utilization Rate: 显示百分比
   - ✅ Active Customers: 显示数量

#### **Step 7.3: 报告库浏览**
1. **操作**: 查看报告库部分
2. **期待结果**:
   - ✅ 报告按类别分组: Credit Management, Payment Management, Risk Management, Collections Management, Compliance Management
   - ✅ 每个报告显示名称、描述、频率、最后更新时间

#### **Step 7.4: 报告生成测试**
1. **操作**:
   - 选择 "Credit Control Monthly Summary"
   - 点击 "Generate Report"
2. **期待结果**:
   - ✅ 显示报告生成进度或成功信息
   - ✅ 可以预览或下载报告

#### **Step 7.5: 报告过滤测试**
1. **操作**:
   - Category Filter: 选择 "Credit Management"
   - Frequency Filter: 选择 "Monthly"
   - 应用过滤
2. **期待结果**:
   - ✅ 报告列表根据过滤条件更新
   - ✅ 只显示符合条件的报告

#### **Step 7.6: 定时报告管理**
1. **操作**: 查看定时报告任务部分
2. **期待结果**:
   - ✅ 显示定时任务列表
   - ✅ 包含报告名称、执行计划、下次执行时间、收件人、状态
   - ✅ 可以启用/禁用定时任务

#### **Step 7.7: 图表显示测试**
1. **操作**: 查看月度收款趋势图表区域
2. **期待结果**:
   - ✅ 显示图表占位符或实际图表
   - ✅ 图表标题为英文

#### **Step 7.8: 管理操作测试**
1. **操作**: 查看管理操作部分
2. **期待结果**:
   - ✅ 显示管理功能按钮
   - ✅ 包含 "Custom Report Builder", "Export Data", "Audit Logs", "System Settings"

---

## 🔄 TEST CASE 8: 完整业务流程测试

### 🎯 **测试目标**
验证完整的业务工作流程

### 📝 **信用分析师工作流程**

#### **Flow 8.1: 客户信用评估流程**
1. **Step 1**: 访问客户搜索 → 搜索 CUST001
2. **Step 2**: 查看客户详情 → 验证基本信息
3. **Step 3**: 查看风险评估 → 分析风险等级
4. **Step 4**: 修改信用限额 → 提交修改申请
5. **期待结果**: 完整流程无障碍执行

#### **Flow 8.2: 催收专员工作流程**
1. **Step 1**: 访问催收管理 → 查看逾期账户
2. **Step 2**: 访问付款跟踪 → 记录新付款
3. **Step 3**: 更新账户状态 → 升级高风险账户
4. **期待结果**: 催收流程完整可执行

#### **Flow 8.3: 管理员工作流程**
1. **Step 1**: 访问报告中心 → 查看关键指标
2. **Step 2**: 生成月度报告 → 验证报告内容
3. **Step 3**: 分析趋势数据 → 查看风险分布
4. **期待结果**: 管理决策支持完整

---

## ✅ 测试完成检查清单

### 页面功能检查
- [ ] 所有7个页面可正常访问
- [ ] 页面标题和内容为英文
- [ ] 货币符号显示为美元 ($)
- [ ] 表单提交功能正常
- [ ] 数据验证规则生效
- [ ] 页面间导航链接正常

### 数据完整性检查
- [ ] 客户信息显示正确
- [ ] 计算结果准确 (信用额度、余额等)
- [ ] 日期格式统一
- [ ] 状态值显示正确

### 用户体验检查
- [ ] 页面加载速度合理 (< 3秒)
- [ ] 错误信息清晰易懂
- [ ] 操作流程符合业务逻辑
- [ ] 界面布局合理美观

### 技术功能检查
- [ ] 表单验证正常工作
- [ ] AJAX 交互正常 (如果有)
- [ ] 浏览器兼容性良好
- [ ] 响应时间在可接受范围内

---

## 🐛 问题记录表

| 页面 | 问题描述 | 严重程度 | 状态 | 备注 |
|------|----------|----------|------|------|
| 示例 | 示例问题 | 高/中/低 | 未解决/已解决 | 详细说明 |
|      |          |          |      |      |

---

## 📞 测试支持信息

- **系统版本**: Legacy Credit Control System v3.0
- **测试环境**: http://35.77.54.203:4000/
- **技术栈**: JDK8 + Tomcat 8.5 + JSP + Struts
- **浏览器建议**: Chrome, Firefox, Safari 最新版本

**测试完成后请将结果反馈，包括任何发现的问题或改进建议。**