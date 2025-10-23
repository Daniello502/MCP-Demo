#!/bin/bash

# MCP Service Mesh Demo Deployment Script
# This script deploys the entire MCP service mesh demo

set -e

echo "🚀 Deploying MCP Service Mesh Demo..."

# Check prerequisites
echo "📋 Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Aborting." >&2; exit 1; }
command -v podman >/dev/null 2>&1 || { echo "❌ podman is required but not installed. Aborting." >&2; exit 1; }

# Check if minikube is running
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ Kubernetes cluster is not accessible. Please ensure minikube is running."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Build and push images
echo "🔨 Building and pushing container images..."

# Build Go Event Dashboard
echo "Building go-event-dashboard..."
podman build -f Dockerfile.go-event-dashboard -t "docker.io/maxperreo/mcp-demo-go-event-dashboard:latest" .
podman push "docker.io/maxperreo/mcp-demo-go-event-dashboard:latest"

# Build MCP Servers
echo "Building MCP servers..."
cd mcp-servers/data-processor
podman build -t "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-data-processor:$GIT_COMMIT" .
podman push "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-data-processor:$GIT_COMMIT"
podman tag "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-data-processor:$GIT_COMMIT" "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-data-processor:latest"
podman push "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-data-processor:latest"
cd ../..

cd mcp-servers/analytics
podman build -t "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-analytics:$GIT_COMMIT" .
podman push "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-analytics:$GIT_COMMIT"
podman tag "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-analytics:$GIT_COMMIT" "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-analytics:latest"
podman push "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-analytics:latest"
cd ../..

cd mcp-servers/notification
podman build -t "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-notification:$GIT_COMMIT" .
podman push "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-notification:$GIT_COMMIT"
podman tag "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-notification:$GIT_COMMIT" "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-notification:latest"
podman push "docker.io/$DOCKER_HUB_USERNAME/mcp-demo-notification:latest"
cd ../..

echo "✅ Container images built and pushed"

# Deploy Kubernetes resources
echo "🚀 Deploying Kubernetes resources..."

# Create namespace
kubectl apply -f kubernetes/namespace.yaml

# Create Docker Hub secret
echo "🔐 Creating Docker Hub secret..."
kubectl delete secret docker-hub-secret -n mcp-demo --ignore-not-found=true
kubectl create secret docker-registry docker-hub-secret \
  --docker-server="docker.io" \
  --docker-username="maxperreo" \
  --docker-password="$DOCKER_HUB_TOKEN" \
  --namespace=mcp-demo

# Deploy Go Event Dashboard
kubectl apply -f kubernetes/go-event-dashboard.yaml

# Deploy MCP Servers
kubectl apply -f kubernetes/mcp-servers.yaml

# Kubernetes will automatically detect the new images and redeploy

# Deploy Istio configuration
echo "🔧 Applying Istio configuration..."
kubectl apply -f istio/gateway.yaml
kubectl apply -f istio/destination-rules.yaml
kubectl apply -f istio/telemetry.yaml

# Deploy monitoring stack
echo "📊 Deploying monitoring stack..."
kubectl apply -f monitoring/prometheus.yaml
kubectl apply -f monitoring/grafana.yaml

echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=180s deployment/go-event-dashboard -n mcp-demo
kubectl wait --for=condition=available --timeout=180s deployment/mcp-data-processor -n mcp-demo
kubectl wait --for=condition=available --timeout=180s deployment/mcp-analytics -n mcp-demo
kubectl wait --for=condition=available --timeout=180s deployment/mcp-notification -n mcp-demo

echo "🎉 Deployment completed successfully!"

# Get service URLs
echo ""
echo "📋 Service URLs:"
echo "=================="
echo "Go Event Dashboard: http://$(minikube ip):$(kubectl get service go-event-dashboard -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')"
echo "Prometheus: http://$(minikube ip):$(kubectl get service prometheus -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')"
echo "Grafana: http://$(minikube ip):$(kubectl get service grafana -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}')"
echo ""
echo "🔐 Default credentials:"
echo "Dashboard: admin/demo"
echo "Grafana: admin/admin"
echo ""
echo "📊 To view logs:"
echo "kubectl logs -f deployment/go-event-dashboard -n mcp-demo"
echo "kubectl logs -f deployment/mcp-data-processor -n mcp-demo"
echo "kubectl logs -f deployment/mcp-analytics -n mcp-demo"
echo "kubectl logs -f deployment/mcp-notification -n mcp-demo"
