# Legacy Credit Control System

## 项目概述

Legacy Credit Control System 是一个基于传统Java技术栈的信用控制管理系统，采用POC（概念验证）方式实现。系统使用经典的JSP + Servlet + JDBC架构，模拟保险公司的信用管理业务流程。

## 技术架构

### 核心技术栈
- **前端**: JSP (JavaServer Pages) + HTML + CSS + JavaScript
- **后端**: Java 8 (OpenJDK 1.8.0_402)
- **应用服务器**: Apache Tomcat 8.5.100
- **数据库**: PostgreSQL 13+
- **容器**: Podman + Docker
- **构建**: 传统Javac编译

### 系统架构
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   前端层 (JSP)   │    │   业务逻辑层      │    │   数据访问层     │
│                │    │   (Java 8)      │    │   (JDBC)       │
│ • 客户搜索      │────│ • CustomerDAO    │────│ • PostgreSQL   │
│ • 信用管理      │    │ • CreditService  │    │ • 8个核心表     │
│ • 报表分析      │    │ • RiskEngine     │    │ • 连接池        │
│ • 监控面板      │    │ • BusinessRule   │    │                │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### 端口配置
- **4000**: 主应用入口 (Tomcat 8080映射)
- **4001**: 数据库监控面板 (Tomcat 8081映射)  
- **4002**: 批处理状态监控 (Tomcat 8082映射)

## 数据库结构

### 核心数据表 (8张表)

#### 1. 客户管理表
```sql
-- 客户基本信息
customers (
    customer_id, customer_code, company_name, 
    contact_person, phone, email, address, 
    industry, status
)

-- 客户信用档案  
customer_credit (
    credit_id, customer_id, credit_limit, 
    available_credit, credit_rating, risk_score,
    last_review_date, credit_officer
)
```

#### 2. 交易处理表
```sql
-- TableA: 日常交易数据
daily_transactions (
    transaction_id, customer_code, transaction_type,
    amount, transaction_date, description, status
)

-- TableB: 批处理汇总数据  
customer_summaries (
    summary_id, customer_code, summary_date,
    total_transactions, total_amount, risk_level
)
```

#### 3. 业务支撑表
```sql
-- 付款历史
payment_history (
    payment_id, customer_code, payment_date,
    amount, payment_method, status
)

-- 催收管理
collections (
    collection_id, customer_code, overdue_amount,
    overdue_days, priority, status, assigned_officer
)

-- 系统配置
system_config (
    config_id, config_key, config_value, description
)

-- 操作日志  
access_log (
    log_id, user_id, action, table_name, 
    timestamp, ip_address
)
```

## 业务架构

### 核心功能模块

#### 1. 客户管理模块
| 页面 | 功能 | 数据操作 |
|------|------|----------|
| `customer-search-working.jsp` | 客户搜索查询 | 读取 `customers`, `customer_credit` |
| `customer/customer-details.jsp` | 客户详情查看 | 读取 `customers`, `customer_credit`, `payment_history` |
| `customer/credit-limit-modify.jsp` | 信用额度修改 | 更新 `customer_credit` 表 |

#### 2. 风险评估模块
| 页面 | 功能 | 数据操作 |
|------|------|----------|
| `risk/risk-assessment.jsp` | 风险评估仪表板 | 读取 `customer_credit`, `daily_transactions` |
| `payment/payment-tracking.jsp` | 付款跟踪 | 读取/更新 `payment_history` |

#### 3. 催收管理模块
| 页面 | 功能 | 数据操作 |
|------|------|----------|
| `collections/collections-management.jsp` | 催收账户管理 | 读取/更新 `collections`, 插入 `contact_logs` |

#### 4. 报表分析模块
| 页面 | 功能 | 数据操作 |
|------|------|----------|
| `reports/reports-dashboard.jsp` | 业务报表仪表板 | 读取多表聚合数据，调用 `get_business_metrics()` |

#### 5. 系统监控模块
| 端口/页面 | 功能 | 数据操作 |
|-----------|------|----------|
| 端口 4001 | 数据库连接监控 | 监控数据库连接状态 |
| 端口 4002 | 批处理状态监控 | 读取 `batch_processing_log` |

### 数据流转图
```
客户搜索 → customers 表查询
    ↓
信用评估 → customer_credit 表读取/更新
    ↓  
交易处理 → daily_transactions 表插入
    ↓
风险分析 → 多表联合查询 + 算法计算
    ↓
催收管理 → collections 表更新 + contact_logs 插入
    ↓
报表生成 → 全表数据聚合分析
```

## 启动方式

### 环境要求
- Podman 4.9+
- PostgreSQL 13+ (运行在 35.77.54.203:5432)
- 可用端口: 4000-4002

### 启动步骤

#### 1. 容器构建
```bash
cd /home/ubuntu/migdemo/legacy
podman build -t localhost/credit-control-legacy:latest .
```

#### 2. 数据库初始化 (如需要)
```bash
cd /home/ubuntu/migdemo/legacy/database
./init-database.sh
```

#### 3. 容器启动
```bash
podman run -d \
  --name credit-control-legacy-container \
  -p 4000:8080 \
  -p 4001:8081 \
  -p 4002:8082 \
  -v /home/ubuntu/migdemo/logs:/app/logs \
  localhost/credit-control-legacy:latest
```

#### 4. 验证启动
```bash
# 检查容器状态
podman ps

# 验证端口访问
curl http://35.77.54.203:4000
curl http://35.77.54.203:4001  
curl http://35.77.54.203:4002
```

### 当前运行状态
```
CONTAINER: credit-control-legacy-container
IMAGE: localhost/credit-control-legacy:latest  
PORTS: 0.0.0.0:4000-4002->8080-8082/tcp
STATUS: Up and Running
```

## 使用说明

### 快速开始测试

#### 第1步: 访问主页
🌐 **入口地址**: http://35.77.54.203:4000

主页显示系统状态和功能导航菜单。

#### 第2步: 开始功能测试

##### 🔍 客户管理测试
1. 点击 **"Customer Search"** 按钮
2. 地址: http://35.77.54.203:4000/customer-search-working.jsp
3. 输入客户代码 `CUST001` 或公司名称进行搜索
4. 测试客户详情查看和信用额度修改功能

##### 📊 报表分析测试  
1. 点击 **"Reports & Analytics"** 按钮
2. 地址: http://35.77.54.203:4000/reports/reports-dashboard.jsp
3. 查看业务指标、报表生成和数据分析功能

##### 💰 催收管理测试
1. 点击 **"Collections Management"** 按钮  
2. 地址: http://35.77.54.203:4000/collections/collections-management.jsp
3. 查看逾期账户、记录联系日志、账户升级操作

##### 🔧 系统监控测试
1. **数据库监控**: http://35.77.54.203:4001
2. **批处理状态**: http://35.77.54.203:4002

### 测试数据

系统预装了5个测试客户:
- **CUST001**: ABC Manufacturing Ltd (评级: A)
- **CUST002**: XYZ Trading Corp (评级: BBB)  
- **CUST003**: Global Logistics Inc (评级: AA)
- **CUST004**: 测试客户4 (评级: B)
- **CUST005**: 测试客户5 (评级: CCC)

### 推荐测试流程

1. **🏠 主页浏览** → 系统概览和导航
2. **🔍 客户搜索** → 核心业务功能测试  
3. **📋 客户详情** → 数据展示和编辑能力
4. **💳 信用管理** → 业务逻辑验证
5. **📊 报表分析** → 数据聚合和可视化
6. **💰 催收管理** → 工作流程完整性
7. **🔧 系统监控** → 运维管理功能

### 故障排除

#### 常见问题
1. **500错误**: 检查数据库连接状态
2. **端口无法访问**: 确认容器端口映射正确
3. **页面加载慢**: 数据库查询性能问题

#### 日志查看
```bash
# 查看容器日志
podman logs credit-control-legacy-container

# 查看应用日志  
cat /home/ubuntu/migdemo/logs/creditcontrol.log
```

## 项目状态

### 开发进度
- ✅ **Milestone 1-4**: 基础架构和核心功能 (100%)
- ✅ **数据库集成**: 完全集成 (100%)  
- ✅ **Web界面**: 主要页面实现 (100%)
- ✅ **报表功能**: 完全实现 (100%)
- ✅ **监控功能**: 完全实现 (100%)

### 技术特色
- 🏗️ **Pure Legacy Stack**: 无现代框架依赖
- 🚀 **Container Ready**: 开箱即用的容器化部署
- 📊 **Real Database**: 真实PostgreSQL数据交互
- 🔧 **Multi-Port**: 分布式监控架构
- 📱 **Responsive UI**: 兼容传统浏览器的界面设计

---

**开发者**: Claude AI + 用户协作  
**最后更新**: 2025-09-29  
**版本**: Legacy POC 1.0