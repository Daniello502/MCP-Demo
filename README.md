# Service Mesh with MCP Servers

This project implements a service mesh architecture using Istio, connecting multiple Model Context Protocol (MCP) servers for enhanced insights and observability.

## 🏗️ Project Structure

```
MCP-Demo/
├── go-event-dashboard/          # Go application for monitoring
├── mcp-servers/                 # MCP server implementations
│   ├── data-processor/          # Data processing MCP server
│   ├── analytics/               # Analytics MCP server
│   └── notification/            # Notification MCP server
├── kubernetes/                  # Kubernetes deployment manifests
├── istio/                       # Istio service mesh configuration
├── monitoring/                  # Monitoring stack (Prometheus, Grafana)
├── deploy.sh                    # Deployment script
├── cleanup.sh                   # Cleanup script
└── test-demo.sh                 # Test script
```

## 🚀 Quick Start

### Prerequisites

- **Podman** for container runtime
- **minikube** with Istio enabled
- **kubectl** for Kubernetes management
- **Python 3.8+** for MCP servers

### Deploy the Demo

```bash
# 1. Deploy everything
./deploy.sh

# 2. Test the deployment
./test-demo.sh

# 3. Clean up when done
./cleanup.sh
```

## 🎯 Components

### 1. MCP Servers
- **Data Processor**: Processes and analyzes data from various sources
- **Analytics**: Provides analytics and insights for the service mesh
- **Notification**: Handles notifications and alerts

### 2. Go Event Dashboard
- **HTTP Server**: REST API for querying Kubernetes events
- **gRPC Server**: Real-time event streaming
- **Event Buffer**: Thread-safe in-memory buffer for storing events

### 3. Service Mesh (Istio)
- **Traffic Management**: Load balancing and routing
- **Security**: mTLS and authentication
- **Observability**: Metrics, logs, and tracing

### 4. Monitoring Stack
- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Jaeger**: Distributed tracing

## 📊 Service URLs

After deployment, access these services:

- **Go Event Dashboard**: `http://<minikube-ip>:<port>`
- **Prometheus**: `http://<minikube-ip>:<port>`
- **Grafana**: `http://<minikube-ip>:<port>`

### Default Credentials
- **Dashboard**: `admin/demo`
- **Grafana**: `admin/admin`

## 🔧 Development

### Local Development

```bash
# Test Go application locally
cd go-event-dashboard
./test-local.sh

# Run individual components
./run-http.sh    # HTTP server
./run-grpc.sh    # gRPC server
```

### Building Images

```bash
# Build Go Event Dashboard
podman build -f Dockerfile.go-event-dashboard -t go-event-dashboard:latest .

# Build MCP servers
cd mcp-servers/data-processor
podman build -t mcp-data-processor:latest .
```

## 📋 API Endpoints

### Go Event Dashboard
- `GET /health` - Health check
- `GET /metrics` - Prometheus metrics
- `GET /events` - Query events (requires auth)
- `GET /stats` - Event statistics (requires auth)

### MCP Servers
Each MCP server provides tools for:
- **Data Processing**: `process_data`, `get_statistics`
- **Analytics**: `get_metrics`, `generate_report`, `record_event`
- **Notifications**: `send_notification`, `subscribe`, `get_notifications`

## 🧪 Testing

```bash
# Test the entire demo
./test-demo.sh

# Check pod health
kubectl get pods -n mcp-demo

# View logs
kubectl logs -f deployment/go-event-dashboard -n mcp-demo
```

## 🧹 Cleanup

```bash
# Remove all resources
./cleanup.sh

# Verify cleanup
kubectl get all -n mcp-demo
```

## 📚 Architecture

The demo showcases:
1. **Service Mesh**: Istio manages traffic between MCP servers
2. **Observability**: Prometheus collects metrics, Grafana visualizes them
3. **Event Monitoring**: Go dashboard watches Kubernetes events
4. **MCP Integration**: Multiple MCP servers interact through the service mesh
5. **Security**: mTLS and authentication between services

This creates a comprehensive demonstration of modern microservices architecture with service mesh capabilities.