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

4. Start the AMRIT platform:

   ```bash
   docker compose up --build -d
   ```

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

- **UI Layer**: Angular applications built as static assets, served directly by NGINX
- **API Layer**: Spring Boot microservices running in separate containers
- **NGINX**: Central reverse proxy that serves static UI content and routes API requests
- **docker-compose.yml**: To spin up all the containerized services of amrit platform

## Directory Structure

After running the setup script, you'll have:

```
amrit-docker-setup/
├── API/                    # All API applications cloned from GitHub
├── UI/                     # All UI applications cloned and built
├── nginx/                  # NGINX configuration
├── docker-compose.yml      # Docker Compose configuration
├── .env                    # Environment variables
└── setup.sh                # Setup script
```

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
| Helpline1097 UI  | http://localhost/helpline1097/  |
| Helpline104 UI   | http://localhost/helpline104/   |

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

### Stopping Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (will delete all data)
docker compose down -v

# Stop specific services
docker compose stop <service-name>
```
