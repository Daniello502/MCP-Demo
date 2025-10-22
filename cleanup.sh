#!/bin/bash

# MCP Service Mesh Demo Cleanup Script
# This script removes all deployed resources

set -e

echo "🧹 Cleaning up MCP Service Mesh Demo..."

# Remove Kubernetes resources
echo "🗑️ Removing Kubernetes resources..."

# Remove monitoring stack
kubectl delete -f monitoring/grafana.yaml --ignore-not-found=true
kubectl delete -f monitoring/prometheus.yaml --ignore-not-found=true

# Remove Istio configuration
kubectl delete -f istio/telemetry.yaml --ignore-not-found=true
kubectl delete -f istio/destination-rules.yaml --ignore-not-found=true
kubectl delete -f istio/gateway.yaml --ignore-not-found=true

# Remove MCP servers
kubectl delete -f kubernetes/mcp-servers.yaml --ignore-not-found=true

# Remove Go Event Dashboard
kubectl delete -f kubernetes/go-event-dashboard.yaml --ignore-not-found=true

# Remove namespace (this will remove all remaining resources)
kubectl delete -f kubernetes/namespace.yaml --ignore-not-found=true

echo "✅ Cleanup completed successfully!"
echo ""
echo "📋 To verify cleanup:"
echo "kubectl get all -n mcp-demo"
echo "kubectl get namespace mcp-demo"
