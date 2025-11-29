# AMRIT Local Development Environment

Lightweight Docker Compose setup providing only infrastructure services (MySQL, Redis, MongoDB, Elasticsearch) for local AMRIT development. API and UI applications run directly on the host machine for easier debugging and development.

## Overview

This setup is optimized for local development workflows where developers need to run and debug individual services on their host machine while maintaining consistent database and cache infrastructure. Infrastructure services run in Docker containers while application code executes natively for IDE integration and hot-reloading.

## Architecture

**Containerized Infrastructure:**
- MySQL 8.0 on port 3306
- Redis 7.2.4 on port 6379
- MongoDB 6.0 on port 27017
- Elasticsearch 8.12.0 on port 9200

**Host-based Applications:**
- Spring Boot API services (run via Maven/IDE)
- Angular UI applications (run via npm/Angular CLI)

## Prerequisites

### Critical Requirements
- **Docker Desktop must be installed and RUNNING** (not just installed)
- **MySQL Server 8.0** installed locally on host machine
  - **Important:** Must be MySQL 8.0 specifically, not 8.1+ or 5.x
  - MySQL CLI (`mysql.exe` or `mysql`) must be in system PATH
  - Test with: `mysql --version` (should show 8.0.x)

### Required Software
- Docker Engine 20.10+ with Docker Compose 2.0+
- Maven 3.6+ for building and running Spring Boot services
- OpenJDK 17+ (recommended: use SDKMAN or AdoptOpenJDK)
- Node.js 16+ and npm for Angular applications
- Git 2.30+

### System Requirements
- 8GB RAM minimum (16GB recommended)
- 20GB available disk space
- Ports 3306, 6379, 27017, 9200 must be available

## Installation

### Pre-Flight Checks

Before proceeding, verify these requirements:

```bash
# 1. Check Docker Desktop is running
docker ps
# Should show container list (may be empty), not connection error

# 2. Verify MySQL 8.0 is installed
mysql --version
# Must show: mysql  Ver 8.0.x

# 3. Confirm MySQL is in PATH
where mysql  # Windows
which mysql  # Linux/macOS
# Should show path to mysql executable
```

If any check fails, see [Troubleshooting](#troubleshooting) section below.

### Setup Overview

Local development setup involves two repositories:
1. **AMRIT-DevOps/amrit-local-setup** (this directory) - Infrastructure services
2. **AMRIT-DB** (separate repository) - Database schema management

**Setup Order:**
1. Start infrastructure services (MySQL, Redis, MongoDB)
2. Switch to AMRIT-DB and run schema migrations
3. Load master data (optional)
4. Return and start individual API/UI services on host

### 1. Clone Repository
```bash
git clone https://github.com/PSMRI/AMRIT-DevOps.git
cd AMRIT-DevOps/amrit-local-setup
```

### 2. Start Infrastructure Services
```bash
docker-compose up -d
```

**Wait 30-60 seconds** for services to initialize. First-time setup takes longer (5-10 minutes) as images are downloaded.

Monitor startup: `docker-compose logs -f`

### 3. Verify Services
```bash
# Check container status
docker-compose ps

# Test MySQL connection
docker exec mysql-container mysql -uroot -p1234 -e "SHOW DATABASES;"

# Test Redis connection
docker exec redis-container redis-cli ping

# Test MongoDB connection
docker exec mongodb-container mongosh -u root -p1234 --eval "db.adminCommand({listDatabases: 1})"
```

### 4. Setup Database Schema (AMRIT-DB)

**This critical step creates all required database tables and structures.**

**Navigate to parent directory and clone AMRIT-DB:**
```bash
cd ../..
git clone https://github.com/PSMRI/AMRIT-DB.git
cd AMRIT-DB
cp src/main/environment/common_example.properties src/main/environment/common_local.properties
mvn clean install -DENV_VAR=local
mvn spring-boot:run -DENV_VAR=local
```

**Configure local environment:**
```bash
cp src/main/environment/common_example.properties src/main/environment/common_local.properties
```

**Edit** `common_local.properties` with connection details:
```properties
# Database URLs point to localhost since MySQL is exposed on port 3306
spring.datasource.dbiemr.jdbc-url=jdbc:mysql://localhost:3306/db_iemr
spring.datasource.dbiemr.username=root
spring.datasource.dbiemr.password=1234

spring.datasource.dbidentity.jdbc-url=jdbc:mysql://localhost:3306/db_identity
spring.datasource.dbidentity.username=root
spring.datasource.dbidentity.password=1234

spring.datasource.dbreporting.jdbc-url=jdbc:mysql://localhost:3306/db_reporting
spring.datasource.dbreporting.username=root
spring.datasource.dbreporting.password=1234

spring.datasource.db1097identity.jdbc-url=jdbc:mysql://localhost:3306/db_1097_identity
spring.datasource.db1097identity.username=root
spring.datasource.db1097identity.password=1234
```

**Build and run schema migrations:**
```bash
mvn clean install -DENV_VAR=local
mvn spring-boot:run -DENV_VAR=local
```

**Monitor the logs** for migration progress. You should see:
```
Successfully applied migrations to schema `db_iemr`
Successfully applied migrations to schema `db_identity`
Successfully applied migrations to schema `db_reporting`
Successfully applied migrations to schema `db_1097_identity`
```

**Stop the service** (Ctrl+C) after migrations complete successfully.

**Verify schema creation:**
```bash
# Check that tables were created
docker exec mysql-container mysql -uroot -p1234 db_iemr -e "SHOW TABLES;"
docker exec mysql-container mysql -uroot -p1234 db_identity -e "SHOW TABLES;"
```

For detailed troubleshooting, see [AMRIT-DB README](https://github.com/PSMRI/AMRIT-DB).

### 5. Load Master Data (Optional)

**Return to amrit-local-setup directory:**
```bash
cd ../AMRIT-DevOps/amrit-local-setup
```

**Execute data load:**
```bash
# Linux/macOS
chmod +x loaddummydata.sh
./loaddummydata.sh

# Windows (PowerShell or CMD)
.\loaddummydata.bat
```

Data loading may take 5-15 minutes depending on dataset size.

### 6. Start Application Services

Now you can start individual API and UI services on your host machine for development.

## Running Application Services

### API Services (Spring Boot)

**Example: Running Common-API locally**

```bash
# Clone API repository
git clone https://github.com/PSMRI/Common-API.git
cd Common-API

# Configure local properties
cp src/main/environment/common_example.properties src/main/environment/common_local.properties

# Edit common_local.properties with connection details
# Update database URLs to point to localhost:3306
# Update Redis URL to localhost:6379
# Update MongoDB URL to localhost:27017

# Build and run
mvn clean install -DENV_VAR=local
mvn spring-boot:run -DENV_VAR=local
```

Service will start on configured port (usually 8080-8095 range).

**Using IDE (IntelliJ IDEA / Eclipse):**
1. Import as Maven project
2. Set VM options: `-DENV_VAR=local`
3. Run main application class
4. Enable hot-reload for development

### UI Applications (Angular)

**Example: Running Admin-UI locally**

```bash
# Clone UI repository
git clone https://github.com/PSMRI/ADMIN-UI.git
cd ADMIN-UI

# Initialize submodules
git submodule update --init --recursive

# Install dependencies
npm install

# Configure API endpoints in environment file
# Edit src/environments/environment.ts

# Start development server
ng serve --port 4200

# Or use npm script
npm start
```

Access UI at http://localhost:4200

**Angular Development Server Options:**
```bash
# Serve with proxy configuration
ng serve --proxy-config proxy.conf.json

# Serve with specific host binding
ng serve --host 0.0.0.0 --port 4200

# Enable polling for file changes (for Docker volumes)
ng serve --poll 2000
```

## Configuration

### Database Credentials (Default)

**MySQL:**
```
Host: localhost
Port: 3306
User: root
Password: 1234
Databases: db_iemr, db_identity, db_reporting, mydatabase
```

**MongoDB:**
```
Host: localhost
Port: 27017
User: root
Password: 1234
Auth Database: admin
```

**Redis:**
```
Host: localhost
Port: 6379
Password: (none - no authentication by default)
```

**Elasticsearch:**
```
Host: localhost
Port: 9200
User: elastic
Password: (check docker logs for auto-generated password)
```

### Modifying Credentials

Edit `docker-compose.yml` before first startup:
```yaml
mysql:
  environment:
    MYSQL_ROOT_PASSWORD: your_secure_password

mongodb:
  environment:
    MONGO_INITDB_ROOT_PASSWORD: your_mongo_password
```

**Important:** If changing credentials after initial setup, remove volumes and restart:
```bash
docker-compose down -v
docker-compose up -d
```

## Service Management

### Starting Services
```bash
# Start all infrastructure services
docker-compose up -d

# Start specific service
docker-compose up -d mysql

# Start with logs visible
docker-compose up
```

### Stopping Services
```bash
# Stop all services
docker-compose down

# Stop and remove data volumes
docker-compose down -v

# Stop specific service
docker-compose stop mysql
```

### Monitoring
```bash
# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f mysql

# Check service status
docker-compose ps

# Check resource usage
docker stats
```

## Database Access

### MySQL CLI
```bash
# Connect to MySQL
docker exec -it mysql-container mysql -uroot -p1234

# Run query directly
docker exec mysql-container mysql -uroot -p1234 -e "USE db_iemr; SHOW TABLES;"
```

### MySQL Workbench / DBeaver
```
Connection Type: MySQL
Host: localhost
Port: 3306
Username: root
Password: 1234
```

### MongoDB Compass
```
Connection String: mongodb://root:1234@localhost:27017/?authSource=admin
```

### Redis CLI
```bash
# Connect to Redis
docker exec -it redis-container redis-cli

# Monitor commands
docker exec redis-container redis-cli MONITOR

# Get info
docker exec redis-container redis-cli INFO
```

## Troubleshooting

### Pre-Setup Issues

#### Docker Desktop Not Running

**Error:** `Cannot connect to the Docker daemon at unix:///var/run/docker.sock`

**Solution:** Open Docker Desktop application and wait for it to fully start. The Docker icon should show as running in system tray.

#### MySQL Not Installed or Not in PATH

**Error when running data load script:**
```
'mysql' is not recognized as an internal or external command
```

**Root Cause:** MySQL CLI is not installed or not accessible from command line.

**Solutions:**

**A. Install MySQL 8.0**
1. Download MySQL 8.0 from [official site](https://dev.mysql.com/downloads/mysql/8.0.html)
2. During installation, check "Add MySQL to PATH"
3. Restart terminal/PowerShell
4. Verify: `mysql --version`

**B. Add Existing MySQL to PATH**

Windows PowerShell:
```powershell
# Find MySQL installation
dir "C:\Program Files\MySQL" -Recurse -Filter mysql.exe

# Add to PATH (temporary for current session)
$env:PATH += ";C:\Program Files\MySQL\MySQL Server 8.0\bin"

# Or add permanently via System Environment Variables
```

Linux/macOS:
```bash
# Add to ~/.bashrc or ~/.zshrc
echo 'export PATH="/usr/local/mysql/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**C. Use Docker Exec Alternative**

If you can't install MySQL locally, modify the data loading approach:
```bash
# Instead of using mysql command, use docker exec
docker exec -i mysql-container mysql -uroot -p1234 db_iemr < AmritMasterData.sql
```

#### Wrong MySQL Version

**Error:** Authentication failures or incompatible SQL syntax

**Check version:**
```bash
mysql --version
```

**Required:** Must show `8.0.x`

**If you have 8.1+ or 5.x:**
- Uninstall current version
- Install MySQL 8.0 specifically
- Or update docker-compose.yml to match your version (not recommended)

### Setup Issues

#### Docker Compose Version Warning

**Error:** `version is obsolete` or Docker Compose compatibility warning

**Solution:** Edit `docker-compose.yml` and remove or comment out the version line:
```yaml
# version: \"3.9\"  # Remove or comment this line

services:
  mysql:
    ...
```

Modern Docker Compose doesn't require explicit version specification.

### Port Already in Use

**Check what's using the port:**
```bash
# Linux/macOS
sudo lsof -i :3306
sudo lsof -i :6379
sudo lsof -i :27017

# Windows PowerShell
netstat -ano | findstr :3306
```

**Stop conflicting services:**
```bash
# Linux
sudo systemctl stop mysql
sudo systemctl stop redis-server
sudo systemctl stop mongod

# Windows
Stop-Service MySQL80
Stop-Service Redis
Stop-Service MongoDB
```

### Container Fails to Start

**Check logs for errors:**
```bash
docker-compose logs mysql
docker-compose logs mongodb
docker-compose logs redis
```

**Common issues:**
- Insufficient memory: increase Docker memory limit
- Volume permission issues: check directory permissions
- Port conflicts: stop conflicting services

### Database Connection Refused

**Verify container is running:**
```bash
docker-compose ps
```

**Check if port is exposed:**
```bash
docker port mysql-container 3306
```

**Test connection from host:**
```bash
telnet localhost 3306
```

### Cannot Connect to Elasticsearch

**Get generated password:**
```bash
docker-compose logs elasticsearch | grep "Password for the elastic user"
```

**Reset Elasticsearch password:**
```bash
docker exec -it amrit-elasticsearch bin/elasticsearch-reset-password -u elastic -i
```

### Data Persistence

Volumes are named and persist across container restarts:
- `mysql-data`: MySQL database files
- `mongodb-data`: MongoDB database files
- `redis-data`: Redis persistence files

**To completely reset data:**
```bash
docker-compose down -v
docker volume prune
docker-compose up -d
```

## Directory Structure

```
amrit-local-setup/
├── docker-compose.yml       # Service definitions
├── init.sql                 # MySQL initialization script
├── my.cnf                   # MySQL configuration
├── loaddummydata.sh         # Data loader (Linux/macOS)
├── loaddummydata.bat        # Data loader (Windows)
└── README.md
```

## Performance Optimization

### MySQL Configuration

Custom configuration in `my.cnf`:
```ini
[mysqld]
max_connections=200
innodb_buffer_pool_size=512M
innodb_log_file_size=256M
```

### Redis Persistence

For development, disable persistence for better performance:
```yaml
redis:
  command: redis-server --save "" --appendonly no
```

### Elasticsearch Memory

Adjust heap size for development:
```yaml
elasticsearch:
  environment:
    - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
```

## Development Workflow

**Typical daily workflow:**

1. Start infrastructure: `docker-compose up -d`
2. Open API project in IDE, run with `-DENV_VAR=local`
3. Open UI project in terminal, run `ng serve`
4. Make code changes (hot-reload active)
5. Test API endpoints via Postman/Swagger
6. Debug using IDE breakpoints
7. Commit changes to Git
8. Stop services: `docker-compose down`

## Differences from Docker Setup

| Feature | Local Setup | Docker Setup |
|---------|-------------|--------------|
| Infrastructure | Containerized | Containerized |
| API Services | Host machine | Containerized |
| UI Applications | Host machine | Static files in NGINX |
| Debugging | IDE debugger | Remote debugging |
| Hot Reload | Native support | Requires volume mounts |
| Resource Usage | Lower | Higher |
| Production-like | No | Yes |

## Related Documentation

- [Main DevOps Repository](../README.md)
- [Full Docker Setup](../amrit-docker-setup/README.md)
- [AMRIT-DB Repository](https://github.com/PSMRI/AMRIT-DB)
- [AMRIT Platform Documentation](https://piramal-swasthya.gitbook.io/amrit/)

