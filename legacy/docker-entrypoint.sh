#!/bin/bash

echo "Starting Legacy Credit Control System..."
echo "Date: $(date)"
echo "Java Version: $(java -version 2>&1 | head -n 1)"

# Set up database connection environment
export DB_HOST=${DB_HOST:-35.77.54.203}
export DB_PORT=${DB_PORT:-5432}
export DB_NAME=${DB_NAME:-creditcontrol}
export DB_USER=${DB_USER:-creditapp}
export DB_PASSWORD=${DB_PASSWORD:-secure123}

echo "Database configuration:"
echo "  Host: $DB_HOST:$DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"

# Create application directories
mkdir -p /app/logs /app/data /app/config

# Copy libraries to Tomcat
cp /app/lib/*.jar $CATALINA_HOME/lib/ 2>/dev/null || true

# Health check endpoints setup
echo "OK - $(date)" > $CATALINA_HOME/webapps/ROOT/health.txt

# Create monitor webapp for port 8081
mkdir -p $CATALINA_HOME/webapps/monitor
echo "<html><body><h1>DB Connection Pool Monitor</h1><p>Status: OK - $(date)</p></body></html>" > $CATALINA_HOME/webapps/monitor/index.html
echo "DB Connection Pool Status: OK - $(date)" > $CATALINA_HOME/webapps/monitor/status

# Create batch webapp for port 8082  
mkdir -p $CATALINA_HOME/webapps/batch
echo "<html><body><h1>Batch Processing Status</h1><p>Status: Ready - $(date)</p></body></html>" > $CATALINA_HOME/webapps/batch/index.html
echo "Batch Processing Status: Ready - $(date)" > $CATALINA_HOME/webapps/batch/status

echo "Starting Tomcat..."
echo "Port mappings:"
echo "  Main Application: 8080 -> 4000"
echo "  DB Monitor: 8081 -> 4001" 
echo "  Batch API: 8082 -> 4002"

# Start Tomcat in foreground
exec $CATALINA_HOME/bin/catalina.sh run