#!/bin/bash

# Run gRPC server script

echo "Starting gRPC server..."

# Set default environment variables if not set
export GRPC_PORT=${GRPC_PORT:-50051}

echo "gRPC server will start on port $GRPC_PORT"

# Run the gRPC server
go run cmd/grpc-server/main.go
