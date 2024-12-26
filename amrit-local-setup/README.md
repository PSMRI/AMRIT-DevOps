# AMRIT Local Environment Setup Guide

## System Requirements

### Mandatory Dependencies

- Docker Engine + Docker Compose
- Maven 3.6+
- Git version control
- OpenJDK 17+

## Architecture Overview

The setup leverages containerization for consistent development environments across the team. Core services are orchestrated via Docker, with MySQL and Redis instances running in isolated containers.

## Deployment Steps

### 1. Container Orchestration

Initialize the containerized services:

```bash
docker-compose up --build
```

#### Service Endpoints

- MySQL Instance: `localhost:3307`
- Redis Instance: `localhost:4407`

### 2. Schema Management Service Deployment

#### Repository Configuration

```bash
git clone https://github.com/PSMRI/AMRIT-DB.git
cd AMRIT-DB
```

**Note**: Verify container is alive.

#### Build Configuration

Execute Maven build sequence:

```bash
mvn clean install
mvn spring-boot:run
```

### 3. Load the dummy Data corresponding to the schema

#### Data Package Setup

1. Download the Data zip folder(Amrit_MastersData.zip) from this [link](https://piramal-swasthya.gitbook.io/amrit/data-management/database-schema)
2. Extract archive contents
3. Configure data path(Line 10) in `loaddummydata.sh`(Linux/MacOS) or in `loaddummydata.bat`(Windows)

#### Execute Data Load

```bash
# Linux/Unix Systems
./loaddummydata.sh

# Windows Environment(PowerShell)
.\loaddummydata.bat

```
