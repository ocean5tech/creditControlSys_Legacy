#!/bin/bash
# Legacy Credit Control System Startup Script
# Version: 3.0 - Integrated Configuration
# Date: 2025-09-28
# Purpose: Complete system startup with configuration integration and proper port mapping

echo "========================================================"
echo "Legacy Credit Control System Startup v3.0"
echo "Integrated Configuration & Health Monitoring"
echo "========================================================"

# Configuration variables from conf/ files
CONTAINER_NAME="credit-control-legacy"
IMAGE_NAME="credit-control-legacy:v3.0"
HOST_IP="35.77.54.203"
MAIN_PORT="4000"
MONITOR_PORT="4001"
API_PORT="4002"
DB_HOST="$HOST_IP"
DB_PORT="5432"
DB_NAME="creditcontrol"
DB_USER="postgres"
DB_PASSWORD="postgres123"

# Pre-flight checks
echo "🔍 Pre-flight system checks..."
echo "Host IP: $HOST_IP"
echo "Allocated Ports: $MAIN_PORT, $MONITOR_PORT, $API_PORT"
echo "Database: $DB_HOST:$DB_PORT/$DB_NAME"
echo

# Check if ports are available
check_port() {
    local port=$1
    if netstat -tuln | grep ":$port " > /dev/null; then
        echo "⚠️  Port $port is in use"
        return 1
    else
        echo "✅ Port $port is available"
        return 0
    fi
}

echo "📊 Port availability check..."
check_port $MAIN_PORT
check_port $MONITOR_PORT  
check_port $API_PORT
echo

# Stop existing container if running
if podman container exists $CONTAINER_NAME; then
    echo "🛑 Stopping existing container..."
    podman stop $CONTAINER_NAME 2>/dev/null || true
    podman rm $CONTAINER_NAME 2>/dev/null || true
fi

# Build latest image
echo "🏗️ Building latest container image..."
cd /home/ubuntu/migdemo/legacy
podman build -t $IMAGE_NAME -f Dockerfile .

# Create logs directory if not exists
mkdir -p /home/ubuntu/migdemo/logs

# Run container with proper configuration
echo "🚀 Starting container with integrated configuration..."
podman run -d \
  --name $CONTAINER_NAME \
  --replace \
  -p $MAIN_PORT:8080 \
  -p $MONITOR_PORT:8081 \
  -p $API_PORT:8082 \
  -v /home/ubuntu/migdemo/logs:/app/logs \
  -e DB_HOST=$DB_HOST \
  -e DB_PORT=$DB_PORT \
  -e DB_NAME=$DB_NAME \
  -e DB_USER=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  -e JAVA_OPTS="-Xms512m -Xmx1024m" \
  $IMAGE_NAME

# Wait for startup
echo "⏳ Waiting for services to start..."
sleep 20

echo "🔍 Performing comprehensive health checks..."

# Health checks
health_status=0

# Test main application
echo "Testing main application..."
if curl -f -s http://$HOST_IP:$MAIN_PORT/customer-search-working.jsp >/dev/null 2>&1; then
    echo "✅ Main application (Port $MAIN_PORT): HEALTHY"
else
    echo "❌ Main application (Port $MAIN_PORT): FAILED"
    health_status=1
fi

# Test all 7 pages
echo "Testing all 7 business pages..."
pages=(
    "customer-search-working.jsp:Customer Search"
    "customer/customer-details.jsp:Customer Details"
    "customer/credit-limit-modify.jsp:Credit Limit Modification"
    "risk/risk-assessment.jsp:Risk Assessment"
    "payment/payment-tracking.jsp:Payment Tracking"
    "collections/collections-management.jsp:Collections Management"
    "reports/reports-dashboard.jsp:Reports Dashboard"
)

for page_info in "${pages[@]}"; do
    IFS=':' read -r page_url page_name <<< "$page_info"
    if curl -f -s http://$HOST_IP:$MAIN_PORT/$page_url >/dev/null 2>&1; then
        echo "✅ $page_name: HEALTHY"
    else
        echo "❌ $page_name: FAILED"
        health_status=1
    fi
done

echo "========================================================"

if [ $health_status -eq 0 ]; then
    echo "🎉 System startup: SUCCESS"
    echo ""
    echo "🌐 System URLs:"
    echo "  Main Entry Point: http://$HOST_IP:$MAIN_PORT/"
    echo "  Customer Search: http://$HOST_IP:$MAIN_PORT/customer-search-working.jsp"
    echo ""
    echo "📊 All 7 Business Function Pages:"
    echo "  1. Customer Search: http://$HOST_IP:$MAIN_PORT/customer-search-working.jsp"
    echo "  2. Customer Details: http://$HOST_IP:$MAIN_PORT/customer/customer-details.jsp?customerCode=CUST001"
    echo "  3. Credit Limit Modify: http://$HOST_IP:$MAIN_PORT/customer/credit-limit-modify.jsp?customerCode=CUST001"
    echo "  4. Risk Assessment: http://$HOST_IP:$MAIN_PORT/risk/risk-assessment.jsp?customerCode=CUST001"
    echo "  5. Payment Tracking: http://$HOST_IP:$MAIN_PORT/payment/payment-tracking.jsp?customerCode=CUST001"
    echo "  6. Collections Management: http://$HOST_IP:$MAIN_PORT/collections/collections-management.jsp"
    echo "  7. Reports Dashboard: http://$HOST_IP:$MAIN_PORT/reports/reports-dashboard.jsp"
    echo ""
    echo "📊 Container Status:"
    podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep $CONTAINER_NAME
    echo ""
    echo "💡 Quick Commands:"
    echo "  Check logs: podman logs $CONTAINER_NAME"
    echo "  Stop system: podman stop $CONTAINER_NAME"
    echo "  Restart: podman restart $CONTAINER_NAME"
    echo ""
    echo "🔧 Configuration Applied:"
    echo "  Database: $DB_HOST:$DB_PORT/$DB_NAME"
    echo "  Java Memory: 512MB-1024MB"
    echo "  Log Directory: /home/ubuntu/migdemo/logs"
else
    echo "❌ System startup: FAILED"
    echo "Check container logs: podman logs $CONTAINER_NAME"
    exit 1
fi

echo "========================================================"