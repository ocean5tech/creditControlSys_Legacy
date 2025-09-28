#!/bin/bash

# Database Initialization Script for Legacy Credit Control System
# This script sets up the creditcontrol database and schema

echo "=== Legacy Credit Control Database Initialization ==="
echo "Date: $(date)"

# Database connection parameters
DB_HOST=${DB_HOST:-35.77.54.203}
DB_PORT=${DB_PORT:-5432}
DB_NAME="creditcontrol"
DB_USER="creditapp"
DB_PASSWORD="secure123"
POSTGRES_USER="postgres"

echo "Target Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo "Application User: $DB_USER"

# Function to execute SQL as postgres superuser
execute_as_postgres() {
    local sql="$1"
    echo "Executing as postgres: $sql"
    PGPASSWORD=postgres psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USER -c "$sql"
}

# Function to execute SQL as application user
execute_as_app() {
    local sql="$1"
    echo "Executing as $DB_USER: $sql"
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "$sql"
}

# Function to execute SQL file as application user
execute_file_as_app() {
    local file="$1"
    echo "Executing file as $DB_USER: $file"
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$file"
}

# Step 1: Create database and user (requires postgres superuser access)
echo "Step 1: Creating database and user..."

# Try to create database and user (may fail if already exists)
execute_as_postgres "CREATE DATABASE $DB_NAME;" || echo "Database may already exist"
execute_as_postgres "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" || echo "User may already exist"
execute_as_postgres "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
execute_as_postgres "ALTER USER $DB_USER CREATEDB;" # Allow user to create test databases

echo "Step 2: Testing database connection..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT version();" || {
    echo "ERROR: Cannot connect to database as $DB_USER"
    echo "Please ensure:"
    echo "1. PostgreSQL is running on $DB_HOST:$DB_PORT"
    echo "2. User $DB_USER has been created with password"
    echo "3. Database $DB_NAME exists and $DB_USER has access"
    exit 1
}

echo "✅ Database connection successful!"

# Step 3: Create schema
echo "Step 3: Creating database schema..."
if [ -f "schema.sql" ]; then
    execute_file_as_app "schema.sql"
    echo "✅ Schema creation completed!"
else
    echo "ERROR: schema.sql file not found!"
    exit 1
fi

# Step 4: Verify schema creation
echo "Step 4: Verifying schema..."
echo "Tables created:"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dt"

echo "Sample data verification:"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as customer_count FROM customers;"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as credit_profiles FROM customer_credit;"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) as transactions FROM daily_transactions;"

echo ""
echo "=== Database Initialization Complete ==="
echo "Database: $DB_NAME"
echo "Host: $DB_HOST:$DB_PORT"
echo "User: $DB_USER"
echo "Schema: Tables and sample data created successfully"
echo "Ready for application connection testing"