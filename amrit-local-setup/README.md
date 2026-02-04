# AMRIT Local Environment Setup Guide

## Overview

AMRIT Local Database Environment Setup activity involves three activities

1) Start the MySQL, MongoDB and Redis databases as Docker Containers 
2) Create the Database Schema for AMRIT
3) Load the Database with Sample Data

### Mandatory Dependencies

- Docker Engine + Docker Compose
- Maven 3.6+
- Git version control
- OpenJDK 17+
- MySQL Client


## Deployment Steps

### 1. Start the Databases

First, run the below commands to clone the DevOps repository, navigate to the local setup directory and initialize the container services:

```bash
git clone https://github.com/PSMRI/AMRIT-DevOps.git
cd AMRIT-DevOps/amrit-local-setup
docker-compose up
```

#### Service Endpoints

- MySQL Instance: `localhost:3306`
- Redis Instance: `localhost:6379`
- Mongo Instance: `localhost:27017`

**Important:** If these services are already running on your host machine, stop the local MySQL, Mongo and Redis instances before proceeding.

**Note:** Before proceeding, Verify that the Docker containers are running for MySQL, Mongo and Redis.

### 2. Create the Database Schema

Use the below commands to Run the Database Schema Management Service. This is a Java Service which is used to create the database schema in MySQL Instance


```bash
git clone https://github.com/PSMRI/AMRIT-DB.git
cd AMRIT-DB
cp src/main/environment/common_example.properties src/main/environment/common_local.properties
mvn clean install -DENV_VAR=local
mvn spring-boot:run -DENV_VAR=local
```
---

### 3. Load Sample Data in the Database Tables

Run the below script to load sample Data into the database tables.The data will be loaded and persistently stored in the MySQL instance.

For Linux/Unix systems:

```bash
./loaddummydata.sh
```

For Windows (PowerShell):

```bash
.\loaddummydata.bat
```

## Troubleshooting Tips

- Verify Docker daemon is running before executing docker-compose
- Ensure all ports (3306, 6379, 27017) are available before starting the containers
- Check the container logs to see if services failed to start
