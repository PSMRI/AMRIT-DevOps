#!/bin/bash
set -euo pipefail

# Start infrastructure services first
echo "Starting infrastructure services (MySQL, Redis, MongoDB)..."
docker compose -f docker-compose.infra.yml up -d

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
until docker exec mysql-container mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD}" --silent; do
  echo "MySQL is starting up..."
  sleep 3
done
echo "MySQL is ready!"

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
until docker exec mongodb-container mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  echo "MongoDB is starting up..."
  sleep 3
done
echo "MongoDB is ready!"

# Wait for Redis to be ready
echo "Waiting for Redis to be ready..."
until docker exec redis-container redis-cli ping | grep -q "PONG"; do
  echo "Redis is starting up..."
  sleep 2
done
echo "Redis is ready!"

# Start application services
echo "Starting application services..."
if [ "$BUILD_NGINX" = true ]; then
  echo "Starting other application services..."
  docker compose -f docker-compose.yml up --build
else
  docker compose -f docker-compose.yml up -d
fi

echo "All services started. Use 'docker ps' to check status." 