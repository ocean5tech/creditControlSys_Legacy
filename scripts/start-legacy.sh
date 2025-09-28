#!/bin/bash
# Legacy Credit Control System Startup Script
# Version: 1.9
# Date: 2025-09-25

echo "=============================================="
echo "Legacy Credit Control System Startup v1.9"
echo "=============================================="

# Check if container exists
if ! podman container exists credit-control-legacy-container; then
    echo "❌ Container 'credit-control-legacy-container' not found"
    echo "Creating new container..."
    
    # Build and run new container
    cd /home/ubuntu/migdemo/legacy
    podman build -t credit-control-legacy:v1.9 .
    podman run -d --name credit-control-legacy-container -p 4000-4002:8080-8082 credit-control-legacy:v1.9
else
    echo "📦 Starting existing container..."
    podman start credit-control-legacy-container
fi

# Wait for startup
echo "⏳ Waiting for services to start..."
sleep 15

echo "🔍 Performing health checks..."

# Health checks
health_status=0

# Test main application
if curl -f -s http://35.77.54.203:4000/health >/dev/null 2>&1; then
    echo "✅ Main application: HEALTHY"
else
    echo "❌ Main application: FAILED"
    health_status=1
fi

# Test JSP processing
if curl -f -s http://35.77.54.203:4000/test-simple.jsp >/dev/null 2>&1; then
    echo "✅ JSP processing: HEALTHY"
else
    echo "❌ JSP processing: FAILED"
    health_status=1
fi

# Test customer search
if curl -f -s http://35.77.54.203:4000/customer-search-working.jsp >/dev/null 2>&1; then
    echo "✅ Customer search: HEALTHY"
else
    echo "❌ Customer search: FAILED" 
    health_status=1
fi

# Test milestone 4 functionality
if curl -f -s http://35.77.54.203:4000/milestone4-test.jsp >/dev/null 2>&1; then
    echo "✅ Milestone 4 test: HEALTHY"
else
    echo "❌ Milestone 4 test: FAILED"
    health_status=1
fi

echo "=============================================="

if [ $health_status -eq 0 ]; then
    echo "🎉 System startup: SUCCESS"
    echo ""
    echo "🌐 System URLs:"
    echo "  Main Dashboard: http://35.77.54.203:4000/"
    echo "  Customer Search: http://35.77.54.203:4000/customer-search-working.jsp"
    echo "  System Test: http://35.77.54.203:4000/milestone4-test.jsp"
    echo "  Simple Test: http://35.77.54.203:4000/test-simple.jsp"
    echo ""
    echo "📊 Container Status:"
    podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep credit-control
    echo ""
    echo "💡 Quick Commands:"
    echo "  Check logs: podman logs credit-control-legacy-container"
    echo "  Stop system: podman stop credit-control-legacy-container"
    echo "  Restart: podman restart credit-control-legacy-container"
else
    echo "❌ System startup: FAILED"
    echo "Check container logs: podman logs credit-control-legacy-container"
    exit 1
fi

echo "=============================================="