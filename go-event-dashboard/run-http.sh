#!/bin/bash

# Run HTTP server script

echo "Starting HTTP server..."

# Set default environment variables if not set
export PORT=${PORT:-8080}
export EVENT_BUFFER_SIZE=${EVENT_BUFFER_SIZE:-100}
export DASH_USER=${DASH_USER:-admin}
export DASH_PASS=${DASH_PASS:-demo}

echo "Server will start on port $PORT"
echo "Dashboard credentials: $DASH_USER / $DASH_PASS"
echo "Event buffer size: $EVENT_BUFFER_SIZE"

# Run the HTTP server
go run main.go
