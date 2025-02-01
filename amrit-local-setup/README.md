# AMRIT Local Environment Setup Guide

## System Requirements

### Mandatory Dependencies

- Docker Engine + Docker Compose
- Maven 3.6+
- Git version control
- OpenJDK 17+

## Architecture Overview

The setup leverages containerization for consistent development environments across the team. Core services are orchestrated via Docker, with MySQL, Mongo and Redis instances running in isolated containers.

## Deployment Steps

First, clone the DevOps repository and navigate to the local setup directory:

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

**Note:** Before proceeding:

- Verify that the Docker container is running
### 2. Database Schema Management Service Deployment

#### Repository Configuration

```bash
git clone https://github.com/PSMRI/AMRIT-DB.git
cd AMRIT-DB
```
1. **Setup Local Properties**:  
   - Copy `common_example.properties` to `common_local.properties`.  
   - File location: `src/main/environment`  

2. **Create Build Configuration through CLI**:
      ```
      mvn clean install -DENV_VAR=local
     ```
---

## Run Configuration  

1. **Setup Spring Boot through CLI**:
      ```
      mvn spring-boot:run -DENV_VAR=local
     ```
---

### 3. Load Sample Data

#### Data Package Setup

1. Download the Data zip folder (`Amrit_MastersData.zip`) from the [official documentation](https://piramal-swasthya.gitbook.io/amrit/data-management/database-schema)
2. Extract the archive contents
3. Update the data path in the appropriate script:
   - Line 10 in `loaddummydata.sh` (Linux/MacOS)
   - Line 10 in `loaddummydata.bat` (Windows)

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
