#!/bin/bash

# Stop application services first
echo "Stopping application services..."
docker compose -f docker-compose.yml down

# Wait a moment for application services to stop completely
sleep 5

# Stop infrastructure services
echo "Stopping infrastructure services..."
docker compose -f docker-compose.infra.yml down

echo "All services stopped." 