# Go Event Dashboard

A Kubernetes event monitoring dashboard built with Go, featuring both HTTP REST API and gRPC streaming capabilities.

## Features

- **HTTP Server**: REST API for querying Kubernetes events with authentication
- **gRPC Server**: Real-time event streaming via gRPC
- **Event Buffer**: Thread-safe in-memory buffer for storing recent events
- **Prometheus Metrics**: Built-in metrics collection for monitoring
- **Kubernetes Integration**: Watches Pods, Services, and Deployments

## Project Structure

```
go-event-dashboard/
├── main.go                    # HTTP server main
├── cmd/grpc-server/main.go   # gRPC server main
├── internal/eventbuffer/      # Event buffer implementation
├── pkg/grpc-event-stream/     # Generated protobuf code
├── grpc-event-stream/        # Proto definitions
├── bin/                       # Built binaries
└── scripts/                   # Build and run scripts
```

## Prerequisites

- Go 1.19+
- Kubernetes cluster access (kubeconfig)
- protobuf compiler (protoc)

## Quick Start

### 1. Build the Application

```bash
./build.sh
```

### 2. Run HTTP Server

```bash
./run-http.sh
```

### 3. Run gRPC Server

```bash
./run-grpc.sh
```

### 4. Test Locally

```bash
./test-local.sh
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 8080 | HTTP server port |
| `GRPC_PORT` | 50051 | gRPC server port |
| `EVENT_BUFFER_SIZE` | 100 | Maximum events to buffer |
| `DASH_USER` | admin | Dashboard username |
| `DASH_PASS` | demo | Dashboard password |
| `KUBECONFIG` | ~/.kube/config | Kubernetes config path |

## API Endpoints

### HTTP Server

- `GET /health` - Health check
- `GET /metrics` - Prometheus metrics
- `GET /events` - Query events (requires auth)
- `GET /stats` - Event statistics (requires auth)

### Query Parameters

- `resource` - Filter by resource type (Pod, Service, Deployment)
- `type` - Filter by event type (ADDED, MODIFIED, DELETED)
- `namespace` - Filter by namespace

### Example Requests

```bash
# Get all events
curl -u admin:demo http://localhost:8080/events

# Get pod events only
curl -u admin:demo http://localhost:8080/events?resource=Pod

# Get events from specific namespace
curl -u admin:demo http://localhost:8080/events?namespace=default
```

## gRPC API

The gRPC server provides two methods:

- `GetRecentEvents` - Get recent events with limit
- `StreamEvents` - Stream events in real-time

## Development

### Building

```bash
# Build both servers
./build.sh

# Build HTTP server only
go build -o bin/http-server main.go

# Build gRPC server only
go build -o bin/grpc-server cmd/grpc-server/main.go
```

### Running

```bash
# Run HTTP server
go run main.go

# Run gRPC server
go run cmd/grpc-server/main.go
```

### Testing

```bash
# Run comprehensive tests
./test-local.sh
```

## Dependencies

- `github.com/prometheus/client_golang` - Prometheus metrics
- `k8s.io/client-go` - Kubernetes client
- `google.golang.org/grpc` - gRPC framework
- `google.golang.org/protobuf` - Protocol buffers

## Notes

- The application requires access to a Kubernetes cluster
- Events are stored in memory and will be lost on restart
- Authentication is basic HTTP auth (not suitable for production)
- The gRPC server uses simple polling for streaming (can be optimized with channels)
