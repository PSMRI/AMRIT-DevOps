# AMRIT Local Environment Setup Guide

## System Requirements

### Mandatory Dependencies

- Docker Engine + Docker Compose
- Maven 3.6+
- Git version control
- OpenJDK 17+
- MySQL Client

## Architecture Overview

The setup leverages containerization for consistent development environments across the team. Core services are orchestrated via Docker, with MySQL, Mongo and Redis instances running in isolated containers.

## Deployment Steps

First, clone the DevOps repository, navigate to the local setup directory and initialize the container services:

```bash
git clone https://github.com/PSMRI/AMRIT-DevOps.git
cd AMRIT-DevOps/amrit-local-setup
```

### 1. Container Orchestration

Initialize the containerized services:

```bash
docker-compose up
```

#### Service Endpoints

- MySQL Instance: `localhost:3306`
- Redis Instance: `localhost:6379`
- Mongo Instance: `localhost:27017`

**Important:** If these services are already running on your host machine, stop the local MySQL, Mongo and Redis instances before proceeding.

**Note:** Before proceeding, Verify that the Docker containers are running for mysql, redis and mongo

### 2. Database Schema Management Service Deployment

#### Repository Configuration

```bash
git clone https://github.com/PSMRI/AMRIT-DB.git
cd AMRIT-DB
cp `src/main/environment/common_example.properties` to `src/main/environment/common_local.properties`
mvn clean install -DENV_VAR=local
```
---

### 3. Load Sample Data

Run the below script to load sample Data into the database tables created in the previous step

#### Execute Data Load

For Linux/Unix systems:

```bash
./loaddummydata.sh
```

For Windows (PowerShell):

```bash
.\loaddummydata.bat
```

The data will be loaded and persistently stored in the containerized MySQL instance.

## Troubleshooting

- Ensure all ports (3306, 6379, 27017) are available before starting the containers
- Verify Docker daemon is running before executing docker-compose
- Check container logs if services fail to start
