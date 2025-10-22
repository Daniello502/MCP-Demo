#!/bin/bash

# Test script for local development

echo "Testing go-event-dashboard locally..."

# Test 1: Build both servers
echo "1. Testing build process..."
./build.sh
if [ $? -eq 0 ]; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Test 2: Check if binaries exist
echo "2. Checking binaries..."
if [ -f "bin/http-server" ] && [ -f "bin/grpc-server" ]; then
    echo "✅ Binaries created successfully"
else
    echo "❌ Binaries not found"
    exit 1
fi

# Test 3: Test HTTP server startup (background)
echo "3. Testing HTTP server startup..."
export PORT=8081
export DASH_USER=test
export DASH_PASS=test
export EVENT_BUFFER_SIZE=50

# Start HTTP server in background
./bin/http-server &
HTTP_PID=$!

# Wait a moment for server to start
sleep 2

# Test health endpoint
if curl -s http://localhost:8081/health > /dev/null; then
    echo "✅ HTTP server health check passed"
else
    echo "❌ HTTP server health check failed"
    kill $HTTP_PID 2>/dev/null
    exit 1
fi

# Test metrics endpoint
if curl -s http://localhost:8081/metrics > /dev/null; then
    echo "✅ HTTP server metrics endpoint working"
else
    echo "❌ HTTP server metrics endpoint failed"
fi

# Stop HTTP server
kill $HTTP_PID 2>/dev/null
wait $HTTP_PID 2>/dev/null

echo "4. Testing gRPC server startup..."
export GRPC_PORT=50052

# Start gRPC server in background
./bin/grpc-server &
GRPC_PID=$!

# Wait a moment for server to start
sleep 2

# Check if gRPC server is running
if ps -p $GRPC_PID > /dev/null; then
    echo "✅ gRPC server started successfully"
else
    echo "❌ gRPC server failed to start"
    exit 1
fi

# Stop gRPC server
kill $GRPC_PID 2>/dev/null
wait $GRPC_PID 2>/dev/null

echo ""
echo "🎉 All tests passed! The application is ready for local development."
echo ""
echo "To run the servers:"
echo "  HTTP Server:  ./run-http.sh"
echo "  gRPC Server:  ./run-grpc.sh"
echo ""
echo "Endpoints:"
echo "  HTTP Health:  http://localhost:8080/health"
echo "  HTTP Events:  http://localhost:8080/events (requires auth: admin/demo)"
echo "  HTTP Stats:   http://localhost:8080/stats (requires auth: admin/demo)"
echo "  HTTP Metrics: http://localhost:8080/metrics"
echo "  gRPC Server:  localhost:50051"
