# Application Configuration
## Legacy Credit Control System Application Settings

### Application Server Configuration

#### Container and Runtime Settings
```
Container Name: credit-control-legacy
Container Image: credit-control-legacy:v1.0
Base Image: docker.io/library/tomcat:8.5-jdk8
Container Runtime: Podman 4.9.3

Java Configuration:
  Version: OpenJDK 1.8.0_402 (Temurin)
  Memory: -Xms512m -Xmx1024m
  Compatibility: JDK5 compatible mode
```

#### Network Configuration
```
Server IP: 35.77.54.203 (fixed, no localhost)
Port Mapping (Host -> Container):
  4000 -> 8080 (Main Web Application)
  4001 -> 8081 (Database Monitor)
  4002 -> 8082 (Batch Processing Status)

Internal Container Ports:
  8080: Tomcat HTTP Connector
  8081: DB Monitor Service
  8082: Batch Status API
```

#### Directory Structure
```
Host Directories:
  Project Root: /home/ubuntu/migdemo/
  Legacy Source: /home/ubuntu/migdemo/legacy/
  Configurations: /home/ubuntu/migdemo/conf/
  Database Scripts: /home/ubuntu/migdemo/legacy/database/
  Log Directory: /home/ubuntu/migdemo/logs/

Container Directories:
  Tomcat Home: /usr/local/tomcat
  Application Root: /usr/local/tomcat/webapps/ROOT/
  Classes: /usr/local/tomcat/webapps/ROOT/WEB-INF/classes/
  Libraries: /app/lib/
  Application Logs: /app/logs (mounted from host)
```

### Application Environment Variables
```
Database Connection:
  DB_HOST=localhost (internal container access)
  DB_PORT=5432
  DB_NAME=creditcontrol
  DB_USER=creditapp
  DB_PASSWORD=secure123

Java Runtime:
  JAVA_HOME=/opt/java/openjdk
  CATALINA_HOME=/usr/local/tomcat
  CATALINA_BASE=/usr/local/tomcat
  JAVA_OPTS=-Xms512m -Xmx1024m
```

### Build Configuration
```
Build System: Apache Ant
Build File: /home/ubuntu/migdemo/legacy/build.xml

Available Targets:
  - clean: Clean build directory
  - compile: Compile Java sources  
  - war: Create WAR file
  - deploy-classes: Copy classes to webapp
  - build: Complete build (default)
  - test-db: Test database connectivity

Dependencies:
  - PostgreSQL JDBC Driver: postgresql-42.2.29.jar
  - Servlet API: servlet-api.jar (from Tomcat)
  - JSP API: jsp-api.jar (from Tomcat)
```

### Service URLs and Endpoints
```
Main Application:
  URL: http://35.77.54.203:4000/
  Health Check: http://35.77.54.203:4000/health
  Index Page: http://35.77.54.203:4000/index.html

Database Monitor:
  URL: http://35.77.54.203:4001/
  Status: http://35.77.54.203:4001/status

Batch Processing:
  URL: http://35.77.54.203:4002/
  Status: http://35.77.54.203:4002/batch/status
```

### Container Management Commands
```bash
# Start Services
podman start credit-control-legacy

# Stop Services  
podman stop credit-control-legacy

# View Logs
podman logs -f credit-control-legacy

# Container Status
podman ps -a --filter name=credit-control

# Restart System
podman restart credit-control-legacy

# Access Container Shell
podman exec -it credit-control-legacy /bin/bash
```

### Application Properties (Legacy Style)
```properties
# Database Configuration
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://localhost:5432/creditcontrol
db.username=creditapp
db.password=secure123
db.maxConnections=10

# Application Configuration
app.name=Legacy Credit Control System
app.version=1.0-SNAPSHOT
app.environment=development

# Logging Configuration  
log.level=INFO
log.file=/app/logs/creditcontrol.log
```

### Security Configuration
```
Authentication: None (POC environment)
Authorization: None (POC environment)
SSL/TLS: Disabled
Session Management: Default Tomcat settings
CSRF Protection: None (legacy compatibility)

Production Recommendations:
- Implement authentication (JAAS or Spring Security)
- Enable HTTPS/SSL
- Add session security
- Implement CSRF protection
```

---
**Created**: 2025-09-25  
**Last Updated**: 2025-09-25  
**Environment**: Development/POC  
**Configuration Level**: Basic Development Setup