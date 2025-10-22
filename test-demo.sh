#!/bin/bash

# MCP Service Mesh Demo Test Script
# This script tests the deployed demo

set -e

echo "🧪 Testing MCP Service Mesh Demo..."

# Check if namespace exists
if ! kubectl get namespace mcp-demo >/dev/null 2>&1; then
    echo "❌ mcp-demo namespace not found. Please run deploy.sh first."
    exit 1
fi

echo "✅ Namespace found"

# Test pod health
echo "🔍 Checking pod health..."
kubectl get pods -n mcp-demo

# Test services
echo "🌐 Testing services..."
kubectl get services -n mcp-demo

# Test Go Event Dashboard
echo "📊 Testing Go Event Dashboard..."
DASHBOARD_IP=$(minikube ip)
DASHBOARD_PORT=$(kubectl get service go-event-dashboard -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')

if curl -s "http://$DASHBOARD_IP:$DASHBOARD_PORT/health" >/dev/null; then
    echo "✅ Go Event Dashboard is healthy"
else
    echo "❌ Go Event Dashboard health check failed"
fi

# Test MCP servers
echo "🔧 Testing MCP servers..."

# Test data processor
DATA_PROCESSOR_IP=$(minikube ip)
DATA_PROCESSOR_PORT=$(kubectl get service mcp-data-processor -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')

if curl -s "http://$DATA_PROCESSOR_IP:$DATA_PROCESSOR_PORT" >/dev/null; then
    echo "✅ MCP Data Processor is accessible"
else
    echo "❌ MCP Data Processor is not accessible"
fi

# Test analytics
ANALYTICS_IP=$(minikube ip)
ANALYTICS_PORT=$(kubectl get service mcp-analytics -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')

if curl -s "http://$ANALYTICS_IP:$ANALYTICS_PORT" >/dev/null; then
    echo "✅ MCP Analytics is accessible"
else
    echo "❌ MCP Analytics is not accessible"
fi

# Test notification
NOTIFICATION_IP=$(minikube ip)
NOTIFICATION_PORT=$(kubectl get service mcp-notification -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')

if curl -s "http://$NOTIFICATION_IP:$NOTIFICATION_PORT" >/dev/null; then
    echo "✅ MCP Notification is accessible"
else
    echo "❌ MCP Notification is not accessible"
fi

# Test monitoring stack
echo "📊 Testing monitoring stack..."

# Test Prometheus
PROMETHEUS_IP=$(minikube ip)
PROMETHEUS_PORT=$(kubectl get service prometheus -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')

if curl -s "http://$PROMETHEUS_IP:$PROMETHEUS_PORT" >/dev/null; then
    echo "✅ Prometheus is accessible"
else
    echo "❌ Prometheus is not accessible"
fi

# Test Grafana
GRAFANA_IP=$(minikube ip)
GRAFANA_PORT=$(kubectl get service grafana -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')

if curl -s "http://$GRAFANA_IP:$GRAFANA_PORT" >/dev/null; then
    echo "✅ Grafana is accessible"
else
    echo "❌ Grafana is not accessible"
fi

echo ""
echo "🎉 Demo testing completed!"
echo ""
echo "📋 Service URLs:"
echo "=================="
echo "Go Event Dashboard: http://$DASHBOARD_IP:$DASHBOARD_PORT"
echo "Prometheus: http://$PROMETHEUS_IP:$PROMETHEUS_PORT"
echo "Grafana: http://$GRAFANA_IP:$GRAFANA_PORT"
echo ""
echo "🔐 Default credentials:"
echo "Dashboard: admin/demo"
echo "Grafana: admin/admin"
