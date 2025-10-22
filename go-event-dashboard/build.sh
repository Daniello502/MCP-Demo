#!/bin/bash

# Build script for go-event-dashboard

echo "Building go-event-dashboard..."

# Build HTTP server
echo "Building HTTP server..."
go build -o bin/http-server main.go

# Build gRPC server
echo "Building gRPC server..."
go build -o bin/grpc-server cmd/grpc-server/main.go

echo "Build complete! Binaries are in the bin/ directory"
