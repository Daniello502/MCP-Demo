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

# Get git commit hash for unique image tags (short version)
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "dev-$(date +%s)")
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
IMAGE_TAG="${GIT_COMMIT}-${TIMESTAMP}"
echo "Using image tag: $IMAGE_TAG"

# Build Go Event Dashboard
echo "Building go-event-dashboard..."
podman build -f Dockerfile.go-event-dashboard -t "docker.io/maxperreo/mcp-demo-go-event-dashboard:$IMAGE_TAG" .
podman push "docker.io/maxperreo/mcp-demo-go-event-dashboard:$IMAGE_TAG"
podman tag "docker.io/maxperreo/mcp-demo-go-event-dashboard:$IMAGE_TAG" "docker.io/maxperreo/mcp-demo-go-event-dashboard:latest"
podman push "docker.io/maxperreo/mcp-demo-go-event-dashboard:latest"

# Build MCP Servers
echo "Building data-processor..."
cd mcp-servers/data-processor
podman build -t "docker.io/maxperreo/mcp-demo-data-processor:$IMAGE_TAG" .
podman push "docker.io/maxperreo/mcp-demo-data-processor:$IMAGE_TAG"
podman tag "docker.io/maxperreo/mcp-demo-data-processor:$IMAGE_TAG" "docker.io/maxperreo/mcp-demo-data-processor:latest"
podman push "docker.io/maxperreo/mcp-demo-data-processor:latest"
cd ../..

echo "Building analytics..."
cd mcp-servers/analytics
podman build -t "docker.io/maxperreo/mcp-demo-analytics:$IMAGE_TAG" .
podman push "docker.io/maxperreo/mcp-demo-analytics:$IMAGE_TAG"
podman tag "docker.io/maxperreo/mcp-demo-analytics:$IMAGE_TAG" "docker.io/maxperreo/mcp-demo-analytics:latest"
podman push "docker.io/maxperreo/mcp-demo-analytics:latest"
cd ../..

echo "Building notification..."
cd mcp-servers/notification
podman build -t "docker.io/maxperreo/mcp-demo-notification:$IMAGE_TAG" .
podman push "docker.io/maxperreo/mcp-demo-notification:$IMAGE_TAG"
podman tag "docker.io/maxperreo/mcp-demo-notification:$IMAGE_TAG" "docker.io/maxperreo/mcp-demo-notification:latest"
podman push "docker.io/maxperreo/mcp-demo-notification:latest"
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

# Force rollout restart to pull new images
echo "🔄 Forcing deployment rollout..."
kubectl rollout restart deployment/go-event-dashboard -n mcp-demo
kubectl rollout restart deployment/mcp-data-processor -n mcp-demo
kubectl rollout restart deployment/mcp-analytics -n mcp-demo
kubectl rollout restart deployment/mcp-notification -n mcp-demo

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
kubectl rollout status deployment/go-event-dashboard -n mcp-demo --timeout=180s
kubectl rollout status deployment/mcp-data-processor -n mcp-demo --timeout=180s
kubectl rollout status deployment/mcp-analytics -n mcp-demo --timeout=180s
kubectl rollout status deployment/mcp-notification -n mcp-demo --timeout=180s

echo "🎉 Deployment completed successfully!"

# Get service URLs
echo ""
echo "📋 Service URLs:"
echo "=================="
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "localhost")
echo "Go Event Dashboard: http://${MINIKUBE_IP}:$(kubectl get service go-event-dashboard -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo 'N/A')"
echo "Prometheus: http://${MINIKUBE_IP}:$(kubectl get service prometheus -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo 'N/A')"
echo "Grafana: http://${MINIKUBE_IP}:$(kubectl get service grafana -n mcp-demo -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo 'N/A')"
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
echo ""
echo "🔍 To check deployment status:"
echo "kubectl get pods -n mcp-demo"
echo "kubectl describe pod <pod-name> -n mcp-demo"