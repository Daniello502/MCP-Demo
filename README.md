# Service Mesh with MCP Servers

This project implements a service mesh architecture using Istio, connecting multiple Model Context Protocol (MCP) servers for enhanced insights and observability.

## Project Structure

- `mcp-servers/`: Contains the MCP server implementations
- `kubernetes/`: Kubernetes manifests for deploying the services
- `istio/`: Istio configuration and service mesh setup
- `monitoring/`: Monitoring and observability components

## Prerequisites

- Podman for macOS (container runtime)
- minikube (for local Kubernetes cluster)
- Istio CLI (will be installed during setup)
- Python 3.8+
- kubectl

## Getting Started

Instructions for setting up and running the project will be added as we progress with the implementation.

## Components

1. MCP Servers
   - Multiple instances for different data processing tasks
   - Containerized deployment
   
2. Service Mesh (Istio)
   - Traffic management
   - Security
   - Observability
   
3. Monitoring
   - Prometheus for metrics
   - Grafana for visualization
   - Jaeger for distributed tracing