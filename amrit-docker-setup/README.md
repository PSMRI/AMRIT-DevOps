# AMRIT Docker Setup Guide

This directory contains everything needed to deploy the AMRIT platform using Docker. The setup follows a microservices architecture with UI applications served as static content through NGINX and API services running as separate containers.

## Prerequisites

- Docker/Docker Desktop installed
- Git (to clone repositories)
- Minimum 16-32GB RAM recommended for running all services

## Quick Start

1. Clone this repository:

   ```bash
   git clone https://github.com/PSMRI/AMRIT-DevOps.git
   cd AMRIT-DevOps/amrit-docker-setup
   ```

2. Copy the environment file and configure it:

   ```bash
   cp .env.example .env
   # Edit .env with your specific configuration
   ```

3. Run the setup script to clone and build all required repositories:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

4. Start all services using the provided scripts:

   ```bash
   # For Linux/Mac
   chmod +x start-all.sh
   ./start-all.sh

   # For Windows
   start-all.bat
   ```

   This will:

   - Start infrastructure services (MySQL, Redis, MongoDB) first
   - Wait for them to initialize
   - Start application services (APIs and NGINX)

5. Check if all containers are running:

   ```bash
   docker ps
   ```

6. View logs for a specific service:
   ```bash
   docker logs -f <service-name>
   # Example: docker logs -f amrit-nginx
   # or
   docker logs <container-id>
   ```

## Architecture Overview

The AMRIT Docker setup implements a modern microservices architecture:

- **Infrastructure Layer** (`docker-compose.infra.yml`):
  - MySQL database
  - Redis cache
  - MongoDB database
- **Application Layer** (`docker-compose.yml`):
  - **UI Layer**: Angular applications built as static assets, served directly by NGINX
  - **API Layer**: Spring Boot microservices running in separate containers
  - **NGINX**: Central reverse proxy that serves static UI content and routes API requests

This separation allows for better management of infrastructure and application components independently.

## Directory Structure

After running the setup script, you'll have:

```
AMRIT-DevOps/
└── amrit-docker-setup/
    ├── API/                     # All API applications cloned from GitHub (not tracked by Git)
    ├── UI/                      # All UI applications cloned and built (not tracked by Git)
    ├── nginx/                   # NGINX configuration
    ├── docker-compose.yml       # Application Docker Compose configuration
    ├── docker-compose.infra.yml # Infrastructure Docker Compose configuration
    ├── .env                     # Environment variables (not tracked by Git)
    ├── setup.sh                 # Setup script
    ├── start-all.sh/bat         # Scripts to start all services
    └── stop-all.sh/bat          # Scripts to stop all services
```

> **Note:** The `API/`, `UI/`, and `logs/` directories are excluded from Git tracking via the `.gitignore` file. When cloning this repository, these directories will be empty until you run the setup script.

## Available Services and Access URLs

### UI Applications

| Application      | URL                             |
| ---------------- | ------------------------------- |
| Admin UI         | http://localhost/admin/         |
| HWC UI           | http://localhost/hwc/           |
| Inventory UI     | http://localhost/inventory/     |
| TM UI            | http://localhost/tm/            |
| MMU UI           | http://localhost/mmu/           |
| Scheduler UI     | http://localhost/scheduler/     |
| HWC Scheduler UI | http://localhost/hwc-scheduler/ |
| HWC Inventory UI | http://localhost/hwc-inventory/ |
| ECD UI           | http://localhost/ecd/           |

### API Services

| Service           | URL                                | Health Check URL                              |
| ----------------- | ---------------------------------- | --------------------------------------------- |
| Admin API         | http://localhost/admin-api/        | http://localhost/admin-api/v3/api-docs        |
| Common API        | http://localhost/common-api/       | http://localhost/common-api/v3/api-docs       |
| ECD API           | http://localhost/ecd-api/          | http://localhost/ecd-api/v3/api-docs          |
| FLW API           | http://localhost/flw-api/          | http://localhost/flw-api/v3/api-docs          |
| HWC API           | http://localhost/hwc-api/          | http://localhost/hwc-api/v3/api-docs          |
| Inventory API     | http://localhost/inventory-api/    | http://localhost/inventory-api/v3/api-docs    |
| MMU API           | http://localhost/mmu-api/          | http://localhost/mmu-api/v3/api-docs          |
| Scheduler API     | http://localhost/scheduler-api/    | http://localhost/scheduler-api/v3/api-docs    |
| TM API            | http://localhost/tm-api/           | http://localhost/tm-api/v3/api-docs           |
| Helpline1097 API  | http://localhost/helpline1097-api/ | http://localhost/helpline1097-api/v3/api-docs |
| Helpline104 API   | http://localhost/helpline104-api/  | http://localhost/helpline104-api/v3/api-docs  |
| BeneficiaryID API | http://localhost/beneficiary-api/  | http://localhost/beneficiary-api/v3/api-docs  |
| FHIR API          | http://localhost/fhir-api/         | http://localhost/fhir-api/v3/api-docs         |
| Identity API      | http://localhost/identity-api/     | http://localhost/identity-api/v3/api-docs     |

### Starting and Stopping Services

```bash
# To start all services (infrastructure and applications)
# For Linux/Mac
./start-all.sh

# To stop all services
# For Linux/Mac
./stop-all.sh

# To start only infrastructure services
docker compose -f docker-compose.infra.yml up -d

# To start only application services
docker compose -f docker-compose.yml up -d

# To stop only application services
docker compose -f docker-compose.yml down

# To stop only infrastructure services
docker compose -f docker-compose.infra.yml down

# To stop and remove volumes (will delete all data)
docker compose -f docker-compose.infra.yml down -v

# To stop specific services
docker compose -f docker-compose.yml stop <service-name>
```

### Verifying Database Connectivity and Data Storage

After starting all services, you can verify that the databases are properly configured and storing data:

#### MySQL Database

```bash
# Connect to MySQL container
docker exec -it mysql-container mysql -uroot -p1234

# List all databases (should show db_iemr, db_identity, db_reporting, and mydatabase)
SHOW DATABASES;

# Select a database to check
USE db_iemr;

# List tables in the database (after application has been used)
SHOW TABLES;

# Check sample data from a table (replace 'table_name' with an actual table)
SELECT * FROM table_name LIMIT 10;

# Exit MySQL
exit
```

#### MongoDB Database

```bash
# Connect to MongoDB container
docker exec -it mongodb-container mongosh -u dbuser -p 1234 --authenticationDatabase mydatabase

# Show databases
show dbs

# Use the application database
use mydatabase

# List collections
show collections

# Query data from a collection (replace 'collection_name' with an actual collection)
db.collection_name.find().limit(5)

# Exit MongoDB
exit
```

#### Redis Cache

```bash
# Connect to Redis container
docker exec -it redis-container redis-cli

# Check if Redis is running
PING

# List all keys (may show application cache keys)
KEYS *

# Exit Redis
exit
```

#### Checking Logs for Database Connection Issues

If you suspect database connectivity issues, check the application logs:

```bash
# Check the last 100 lines of logs for database errors
docker logs mysql-container --tail 100
docker logs mongodb-container --tail 100
docker logs redis-container --tail 100
```
