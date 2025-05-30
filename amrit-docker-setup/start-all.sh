#!/bin/bash
set -euo pipefail

echo "Starting infrastructure services (MySQL, Redis, MongoDB)..."
docker compose -f docker-compose.infra.yml up -d

# Load .env file if exists
if [ -f .env ]; then
  export "$(grep -v '^#' .env | xargs)"
fi

# Wait for MySQL
echo "Waiting for MySQL to be ready..."
until docker exec mysql-container mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD}" --silent; do
  echo "MySQL is starting up..."
  sleep 3
done
echo "MySQL is ready!"

# Wait for MongoDB
echo "Waiting for MongoDB to be ready..."
until docker exec mongodb-container mongosh --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  echo "MongoDB is starting up..."
  sleep 3
done
echo "MongoDB is ready!"

# Wait for Redis
echo "Waiting for Redis to be ready..."
until docker exec redis-container redis-cli ping | grep -q "PONG"; do
  echo "Redis is starting up..."
  sleep 2
done
echo "Redis is ready!"

# Ask user whether to rebuild
echo "Do you want to rebuild the application images? (yes/no)"
read -r user_response

if [[ "$user_response" == "yes" || "$user_response" == "y" ]]; then
  echo "Rebuilding and starting application services..."
  docker compose -f docker-compose.yml up --build -d
else
  echo "Starting application services without rebuilding..."
  docker compose -f docker-compose.yml up -d
fi

echo "All services started. Use 'docker ps' to check status."
