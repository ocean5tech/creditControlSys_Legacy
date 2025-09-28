# Legacy System Design Document
## Credit Control System - Phase 1 Implementation

### Overview
This document specifies the design for implementing a legacy credit control system using JDK5+Struts+JSP architecture for an insurance company. This represents Phase 1 of the migration POC project.

## Infrastructure Design

### Server Environment
- **Deployment Server**: 35.77.54.203
- **Operating System**: Linux (Ubuntu/AWS)
- **Container Runtime**: Podman (rootless containers)
- **Database**: PostgreSQL (existing installation on port 5432)

### Port Allocation (Fixed - Do Not Change)

#### Legacy System Ports
- **4000**: Struts Web Application (Main Interface)
- **4001**: Database Connection Pool Monitor
- **4002**: Batch Processing Status API

## Technology Stack

### Legacy System Implementation
```yaml
Runtime:
  - JDK 5 (via Podman container)
  - Apache Tomcat 5.5.x
  - Struts 1.x Framework
  - JSP/Servlet API

Database:
  - PostgreSQL (existing installation)
  - JDBC Driver compatible with JDK5

Build Tools:
  - Ant (legacy build)
  - Maven wrapper for dependency management

Additional Components:
  - Log4j 1.x for logging
  - Commons libraries (BeanUtils, Collections, etc.)
  - JSTL for JSP tag libraries
```

## Business Description (Hypothetical Insurance Credit Control)

### System Purpose
Credit control system managing customer credit limits, payment tracking, and risk assessment for insurance premium collection.

### Core Business Functions
1. **Customer Credit Query**: Search and display customer credit information
2. **Credit Limit Management**: Modify customer credit limits based on risk assessment
3. **Payment Tracking**: Record and track customer payments
4. **Risk Assessment**: Calculate credit risk scores based on payment history
5. **Batch Processing**: Nightly jobs to summarize daily transactions
6. **Reporting**: Generate credit control reports for management

### User Workflows
- **Credit Analyst**: Query customer data → assess risk → modify limits → approve changes
- **Collections Officer**: Review overdue accounts → update payment status → escalate issues
- **Manager**: Review batch reports → analyze trends → approve policy changes

## Container Architecture

### Podman Images Strategy
```yaml
Base Images:
  - registry.access.redhat.com/openjdk/openjdk-5-rhel7
  - docker.io/library/postgres:13-alpine (if needed for dev)

Custom Images:
  - credit-control-legacy:v1.0
```

## Deployment Method

### Prerequisites Setup
```bash
# Install Podman (if not already installed)
sudo apt update && sudo apt install -y podman

# Create project directories
mkdir -p /home/ubuntu/migdemo/{legacy,data,logs}
cd /home/ubuntu/migdemo
```

### Legacy System Deployment
```bash
# Build legacy application container
podman build -t credit-control-legacy:v1.0 -f legacy/Dockerfile .

# Run legacy system
podman run -d \
  --name credit-control-legacy \
  -p 35.77.54.203:4000:8080 \
  -p 35.77.54.203:4001:8081 \
  -p 35.77.54.203:4002:8082 \
  -v /home/ubuntu/migdemo/logs:/app/logs \
  -e DB_HOST=35.77.54.203 \
  -e DB_PORT=5432 \
  -e DB_NAME=creditcontrol \
  -e DB_USER=creditapp \
  -e DB_PASSWORD=secure123 \
  credit-control-legacy:v1.0
```

## Startup Methods (Future Operations)

### Daily Startup Script
```bash
#!/bin/bash
# File: /home/ubuntu/migdemo/scripts/start-legacy.sh

echo "Starting Legacy Credit Control System..."

# Start legacy system
podman start credit-control-legacy

# Wait for startup
sleep 15

# Health checks
echo "Performing health checks..."
curl -f http://35.77.54.203:4000/health 2>/dev/null && echo "✓ Main application healthy" || echo "✗ Main application not responding"
curl -f http://35.77.54.203:4001/status 2>/dev/null && echo "✓ DB monitor healthy" || echo "✗ DB monitor not responding"
curl -f http://35.77.54.203:4002/batch/status 2>/dev/null && echo "✓ Batch API healthy" || echo "✗ Batch API not responding"

echo "Legacy system available at: http://35.77.54.203:4000"
echo "DB Monitor available at: http://35.77.54.203:4001"
echo "Batch Status available at: http://35.77.54.203:4002"
```

### System Management Commands
```bash
# Start legacy system
./scripts/start-legacy.sh

# Stop legacy system
podman stop credit-control-legacy

# View logs
podman logs -f credit-control-legacy

# System status
podman ps -a --filter name=credit-control-legacy

# Restart system
podman restart credit-control-legacy

# Cleanup (development only)
podman rm -f credit-control-legacy
```

## Network Configuration

### Firewall Rules (if needed)
```bash
# Allow incoming connections on legacy system ports
sudo ufw allow 4000:4002/tcp comment "Legacy Credit Control System"
```

### Access URLs
- **Legacy Web Application**: http://35.77.54.203:4000
- **Database Connection Monitor**: http://35.77.54.203:4001
- **Batch Processing Status**: http://35.77.54.203:4002

## Security Considerations
- All containers run in rootless mode
- Database connections use connection pooling
- No hardcoded credentials (environment variables only)
- Container isolation prevents system-level access
- Log rotation to prevent disk space issues

## Monitoring and Maintenance
- Container health checks enabled
- Application logs centralized in `/home/ubuntu/migdemo/logs`
- Database backup strategy (separate from this POC)
- Container image updates through rebuild process

---

**Important Notes:**
- Port assignments are fixed and cannot be changed: 4000-4002
- All services use the server IP 35.77.54.203 (no localhost)
- Podman containers ensure minimal system dependencies
- This legacy system will serve as the baseline for future migration analysis