# Database Configuration
## Legacy Credit Control System Database Settings

### Database Connection Information

#### PostgreSQL Database Details
```
Host: localhost (35.77.54.203 from external)
Port: 5432
Database Name: creditcontrol
Schema: public
```

#### Database Users and Credentials
```
Superuser Account:
  Username: postgres
  Password: postgres (default)
  Access: Full administrative access

Application User:
  Username: creditapp  
  Password: secure123
  Database: creditcontrol
  Privileges: ALL PRIVILEGES on creditcontrol database
  Purpose: Application database operations
```

#### JDBC Connection String
```
Primary Connection (from container):
jdbc:postgresql://localhost:5432/creditcontrol

External Connection (from host):
jdbc:postgresql://35.77.54.203:5432/creditcontrol

Driver Class: org.postgresql.Driver
Driver JAR: postgresql-42.2.29.jar (located in /app/lib/)
```

### Database Schema Summary
```
Tables Created: 8
- customers (customer basic information)
- customer_credit (credit profiles and limits)
- daily_transactions (TableA - operational transactions)
- customer_summaries (TableB - batch processed summaries)
- payment_history (payment tracking)
- batch_processing_log (batch job monitoring)
- system_config (system parameters)
- access_log (audit trail)

Sample Data: 5 test customers with credit profiles and transactions
```

### Connection Pool Settings (Simulated)
```
Connection Pool Type: Singleton Pattern (Legacy Style)
Max Connections: 1 (simplified for POC)
Connection Timeout: 20 seconds
Auto Reconnect: Enabled
SSL Mode: Disabled (local development)
```

### Database Initialization Commands
```sql
-- Run as postgres superuser
CREATE DATABASE creditcontrol;
CREATE USER creditapp WITH PASSWORD 'secure123';
GRANT ALL PRIVILEGES ON DATABASE creditcontrol TO creditapp;
ALTER USER creditapp CREATEDB;

-- Schema and data initialization
-- Run: psql -d creditcontrol -f /home/ubuntu/migdemo/legacy/database/schema.sql
```

### Security Notes
- **Development Environment**: Passwords are stored in plain text for POC
- **Production Recommendation**: Use environment variables or encrypted config
- **Network Security**: Currently allows local connections only
- **User Separation**: Dedicated application user with limited privileges

### Backup and Recovery
```bash
# Database backup
pg_dump -h localhost -U creditapp -d creditcontrol > backup.sql

# Database restore  
psql -h localhost -U creditapp -d creditcontrol < backup.sql
```

---
**Created**: 2025-09-25  
**Last Updated**: 2025-09-25  
**Environment**: Development/POC  
**Security Level**: Low (development credentials)