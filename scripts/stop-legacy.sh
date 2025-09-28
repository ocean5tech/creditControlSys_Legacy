#!/bin/bash
# Legacy Credit Control System Stop Script
# Version: 1.9
# Date: 2025-09-25

echo "=============================================="
echo "Legacy Credit Control System Shutdown v1.9"
echo "=============================================="

# Check if container is running
if podman ps --format "{{.Names}}" | grep -q "credit-control-legacy-container"; then
    echo "🛑 Stopping Legacy Credit Control System..."
    
    # Graceful shutdown
    podman stop credit-control-legacy-container
    
    echo "✅ Container stopped successfully"
    echo ""
    echo "📊 Container Status:"
    podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep credit-control
    
else
    echo "ℹ️  Container is not currently running"
    echo ""
    echo "📊 Container Status:"
    podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep credit-control || echo "No credit-control containers found"
fi

echo ""
echo "💡 Management Commands:"
echo "  Start system: /home/ubuntu/migdemo/scripts/start-legacy.sh"
echo "  Remove container: podman rm credit-control-legacy-container"
echo "  View logs: podman logs credit-control-legacy-container"
echo "  Clean images: podman image prune"

echo "=============================================="