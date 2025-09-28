# Deployment Configuration
## Legacy Credit Control System Deployment Settings

### Container Deployment Configuration

#### Podman Container Settings
```bash
Container Configuration:
  Name: credit-control-legacy-container
  Image: credit-control-legacy:v1.9
  Base: docker.io/library/tomcat:8.5-jdk8
  Size: ~700 MB
  Status: Active (Running)

Network Configuration:
  Mode: Bridge (port mapping)
  Host IP: 35.77.54.203
  Port Bindings:
    - 4000:8080 (Main Application)
    - 4001:8081 (DB Monitor) 
    - 4002:8082 (Batch API)

Volume Mounts:
  - /home/ubuntu/migdemo/logs:/app/logs (Log persistence)
```

#### Container Startup Command (Current)
```bash
# Current active command (simplified port mapping)
podman run -d \
  --name credit-control-legacy-container \
  -p 4000-4002:8080-8082 \
  credit-control-legacy:v1.9

# Full deployment command (recommended)
podman run -d \
  --name credit-control-legacy-container \
  -p 4000:8080 \
  -p 4001:8081 \
  -p 4002:8082 \
  -v /home/ubuntu/migdemo/logs:/app/logs \
  -e DB_HOST=localhost \
  -e DB_PORT=5432 \
  -e DB_NAME=creditcontrol \
  -e DB_USER=postgres \
  -e DB_PASSWORD=postgres123 \
  credit-control-legacy:v1.9
```

### Startup Scripts and Automation

#### System Startup Script (Updated)
```bash
#!/bin/bash
# File: /home/ubuntu/migdemo/scripts/start-legacy.sh

echo "Starting Legacy Credit Control System v1.9..."

# Start legacy container
podman start credit-control-legacy-container

# Wait for startup
sleep 15

# Health checks
curl -f http://35.77.54.203:4000/health && echo "✓ Main application healthy"
curl -f http://35.77.54.203:4000/test-simple.jsp && echo "✓ JSP processing healthy"
curl -f http://35.77.54.203:4000/customer-search-working.jsp && echo "✓ Customer search healthy"
curl -f http://35.77.54.203:4000/milestone4-test.jsp && echo "✓ Milestone 4 test healthy"

echo "Legacy system available at: http://35.77.54.203:4000"
echo "Available test pages:"
echo "  - Customer Search: http://35.77.54.203:4000/customer-search-working.jsp"
echo "  - System Test: http://35.77.54.203:4000/milestone4-test.jsp" 
echo "  - Simple Test: http://35.77.54.203:4000/test-simple.jsp"
```

#### Container Build Process (Updated)
```bash
# Build container image (current version)
podman build -t credit-control-legacy:v1.9 .

# Verify image
podman images | grep credit-control

# Stop and remove old container
podman stop credit-control-legacy-container
podman rm credit-control-legacy-container

# Run new container
podman run -d --name credit-control-legacy-container -p 4000-4002:8080-8082 credit-control-legacy:v1.9

# Test container functionality
podman exec credit-control-legacy-container java -version
curl -f http://localhost:4000/health
```

### Database Connection Configuration

#### Connection Settings in Container
```bash
Environment Variables (Container):
  DB_HOST=localhost (for host network access)
  DB_PORT=5432
  DB_NAME=creditcontrol
  DB_USER=creditapp
  DB_PASSWORD=secure123

JDBC URL (Runtime):
  jdbc:postgresql://localhost:5432/creditcontrol

Connection Pool (Simulated):
  Type: Singleton Pattern
  Max Connections: 1
  Timeout: 20 seconds
```

### File System Layout
```
Production File Structure:
/home/ubuntu/migdemo/
├── conf/                    # Configuration files
│   ├── database-config.md   # Database connection settings
│   ├── application-config.md # Application configuration
│   └── deployment-config.md # This file
├── legacy/                  # Legacy application source
│   ├── src/                 # Java source code
│   ├── database/            # Database scripts
│   ├── Dockerfile           # Container definition
│   └── build.xml           # Ant build configuration
├── logs/                   # Application logs (mounted)
├── scripts/               # Deployment scripts
└── design/               # System design documents
```

### Port Allocation (Fixed)
```
Port Assignment Policy:
  Range: 4000-4002 (Legacy System)
  Protocol: HTTP
  External Access: Yes
  
Specific Assignments:
  4000: Main Web Application
    - Legacy UI interface
    - Customer management
    - Credit control operations
    
  4001: Database Connection Monitor  
    - Connection pool status
    - Database health metrics
    - System monitoring
    
  4002: Batch Processing Status API
    - Batch job monitoring
    - Processing status
    - Job scheduling interface
```

### Health Check Configuration
```
Health Check Endpoints:
  Primary: http://35.77.54.203:4000/health
  Monitor: http://35.77.54.203:4001/status  
  Batch: http://35.77.54.203:4002/batch/status

Health Check Script:
#!/bin/bash
for port in 4000 4001 4002; do
  curl -f http://35.77.54.203:$port/ >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "Port $port: ✓ HEALTHY"
  else
    echo "Port $port: ✗ FAILED"
  fi
done
```

### Firewall and Network Security
```bash
Required Firewall Rules:
# Allow incoming connections on legacy system ports
sudo ufw allow 4000:4002/tcp comment "Legacy Credit Control System"

Network Security Notes:
- Ports exposed on all interfaces (0.0.0.0)
- No SSL/TLS encryption (development environment)
- Database access limited to localhost
- Container isolation provides basic security
```

### Backup and Recovery Procedures
```bash
# Application Backup
podman export credit-control-legacy > credit-control-backup.tar

# Database Backup
pg_dump -h localhost -U creditapp -d creditcontrol > database-backup.sql

# Configuration Backup
tar -czf config-backup.tar.gz /home/ubuntu/migdemo/conf/

# Full System Backup
tar -czf full-backup-$(date +%Y%m%d).tar.gz \
  /home/ubuntu/migdemo/ \
  database-backup.sql
```

### Monitoring and Maintenance
```
Log Monitoring:
  Application Logs: /home/ubuntu/migdemo/logs/
  Container Logs: podman logs credit-control-legacy
  System Logs: /var/log/syslog

Maintenance Schedule:
  Daily: Health check verification
  Weekly: Log rotation and cleanup  
  Monthly: Security updates and patches
  Quarterly: Full system backup

Resource Monitoring:
  Memory Usage: podman stats credit-control-legacy
  Disk Usage: du -sh /home/ubuntu/migdemo/
  Network: ss -tlnp | grep -E ':(400[0-2])'
```

### Current Deployment Status (Live System)
```bash
Current System Status (2025-09-25):

Container Info:
  Name: credit-control-legacy-container
  Image: credit-control-legacy:v1.9  
  Status: Up and running
  Ports: 4000-4002:8080-8082/tcp

Functional URLs:
  Main Application: http://35.77.54.203:4000/
  Customer Search: http://35.77.54.203:4000/customer-search-working.jsp
  System Test: http://35.77.54.203:4000/milestone4-test.jsp
  Simple Test: http://35.77.54.203:4000/test-simple.jsp
  Health Check: http://35.77.54.203:4000/health

Quick Commands:
  Check Status: podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
  View Logs: podman logs credit-control-legacy-container
  Restart: podman restart credit-control-legacy-container
  Health Test: curl -s http://localhost:4000/milestone4-test.jsp | grep PASS

Development Progress:
  Milestones Completed: 4/9 (44%)
  Current Phase: Milestone 5 preparation
  Last Container Update: v1.9 (JSP + Customer Search working)
  Database Status: Not connected (PostgreSQL setup needed)
  Struts Status: Taglibs working, Actions pending
```

### Troubleshooting Commands
```bash
# Container diagnostics
podman inspect credit-control-legacy-container | grep -E "(Status|Health|Ports)"

# Port connectivity test
for port in 4000 4001 4002; do
  echo "Testing port $port:"
  curl -I http://35.77.54.203:$port/ 2>/dev/null | head -1 || echo "Port $port not responding"
done

# Application functionality test
curl -s http://35.77.54.203:4000/milestone4-test.jsp | grep -E "(PASS|FAIL|PENDING)" | head -5

# System resources
podman stats credit-control-legacy-container --no-stream
```

---
**Created**: 2025-09-25  
**Last Updated**: 2025-09-25 (Updated with v1.9 deployment status)  
**Deployment Environment**: AWS EC2 Instance  
**Network**: 35.77.54.203 (Static IP)  
**Container Runtime**: Podman 4.9.3  
**Current Version**: credit-control-legacy:v1.9