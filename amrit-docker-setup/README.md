# AMRIT Docker Setup

Production-ready Docker Compose orchestration for deploying the complete AMRIT platform with all microservices, databases, and web interfaces.

## Architecture

The deployment consists of two Docker Compose stacks:

**Infrastructure Layer** (`docker-compose.infra.yml`)
- MySQL 8.0 database server with custom configuration
- Redis 7.2.4 cache server with persistence
- MongoDB 6.0 document store with authentication

**Application Layer** (`docker-compose.yml`)
- 14 Spring Boot microservices (Admin, Common, HWC, MMU, TM, Scheduler, Inventory, ECD, FLW, FHIR, Identity, Helpline104, Helpline1097, BeneficiaryID)
- 10 Angular UI applications served as static assets
- NGINX reverse proxy with caching and load balancing

All API services communicate through the `app-network` Docker network. NGINX serves UI applications as static content and proxies API requests to backend services.

## Prerequisites

**Critical Requirements:**
- **Docker Desktop must be installed and RUNNING** (not just installed)
- **MySQL Server 8.0** installed locally for data loading scripts
  - **Important:** Must be MySQL 8.0 specifically (not 8.1+ or 5.x)
  - MySQL CLI must be in system PATH for data loading
  - Test: `mysql --version` should show 8.0.x

**Required Software:**
- Docker Engine 20.10+
- Docker Compose 2.0+
- Git 2.30+
- Bash shell (Linux/Mac) or Git Bash (Windows)

**System Requirements:**
- 16GB RAM minimum, 32GB recommended
- 50GB available disk space
- Internet connectivity for pulling images and cloning repositories

**First-Time Setup Warning:**
Initial setup takes 15-30 minutes for:
- Downloading Docker images
- Cloning and building API/UI repositories
- Database initialization
- This is normal, be patient

## Installation

### Overview of Setup Process

The complete AMRIT deployment involves three repositories:
1. **AMRIT-DevOps** (this repository) - Infrastructure and application containers
2. **AMRIT-DB** - Database schema migrations (separate repository)
3. **Individual API/UI repositories** - Cloned automatically by setup script

**Setup Order:**
1. Clone AMRIT-DevOps and configure environment
2. Run setup script to clone API/UI repositories
3. Start infrastructure services (MySQL, Redis, MongoDB)
4. Switch to AMRIT-DB and run schema migrations
5. Return to AMRIT-DevOps and start application services

### 1. Clone Repository
```bash
git clone https://github.com/PSMRI/AMRIT-DevOps.git
cd AMRIT-DevOps/amrit-docker-setup
```

### 2. Environment Configuration
```bash
cp .env.example .env
```

Edit `.env` and configure required variables:
```bash
# Database credentials
MYSQL_ROOT_PASSWORD=your_secure_password
MYSQL_USER=amrit_user
MYSQL_PASSWORD=your_db_password
MONGO_ROOT_PASSWORD=your_mongo_password

# Database connection strings
DATABASE_URL=jdbc:mysql://mysql:3306/db_iemr
DATABASE_USERNAME=amrit_user
DATABASE_PASSWORD=your_db_password

# API base URLs (internal Docker network)
COMMON_API_BASE_URL=http://common-api:8080
IDENTITY_API_BASE_URL=http://identity-api:8080
MMU_API_BASE_URL=http://mmu-api:8080
# ... configure remaining API URLs
```

Refer to `.env.example` for complete list of configuration variables.

### 3. Pre-Flight Check

Before proceeding, verify Docker Desktop is running:
```bash
docker ps
# Should show container list (may be empty), not a connection error
```

### 4. Clone and Build Application Repositories
```bash
chmod +x setup.sh
./setup.sh
```

This script:
- Clones all 14 API repositories into `API/` directory
- Clones all 10 UI repositories into `UI/` directory
- Initializes Git submodules for UI projects
- Builds Angular applications and creates production bundles
- Fixes directory structures for NGINX serving

**Note:** This process may take 15-30 minutes depending on network speed and system performance.

### 5. Deploy Infrastructure Services
```bash
docker compose -f docker-compose.infra.yml up -d
```

Wait for services to initialize (30-60 seconds). First-time startup takes longer. Verify health:
```bash
docker compose -f docker-compose.infra.yml ps
```

All services should show status as "Up" with healthy status.

### 6. Setup Database Schemas (AMRIT-DB)

**This is a critical step that must be completed before starting application services.**

Database schemas are managed in a separate repository. You need to switch to it now:

```bash
# Navigate to parent directory
cd ../..

# Clone AMRIT-DB if not already cloned
git clone https://github.com/PSMRI/AMRIT-DB.git
cd AMRIT-DB
```

**Configure database connection:**
```bash
cp src/main/environment/common_example.properties src/main/environment/common_local.properties
```

**Edit** `src/main/environment/common_local.properties` with your MySQL credentials:
```properties
# These should match what you configured in AMRIT-DevOps .env file
spring.datasource.dbiemr.jdbc-url=jdbc:mysql://localhost:3306/db_iemr
spring.datasource.dbiemr.username=root
spring.datasource.dbiemr.password=YOUR_MYSQL_PASSWORD

spring.datasource.dbidentity.jdbc-url=jdbc:mysql://localhost:3306/db_identity
spring.datasource.dbidentity.username=root
spring.datasource.dbidentity.password=YOUR_MYSQL_PASSWORD

spring.datasource.dbreporting.jdbc-url=jdbc:mysql://localhost:3306/db_reporting
spring.datasource.dbreporting.username=root
spring.datasource.dbreporting.password=YOUR_MYSQL_PASSWORD

spring.datasource.db1097identity.jdbc-url=jdbc:mysql://localhost:3306/db_1097_identity
spring.datasource.db1097identity.username=root
spring.datasource.db1097identity.password=YOUR_MYSQL_PASSWORD
```

**Run database migrations:**
```bash
mvn clean install -DENV_VAR=local
mvn spring-boot:run -DENV_VAR=local
```

**Wait for completion.** You should see logs indicating successful migration:
```
Successfully applied X migrations to schema `db_iemr`
Successfully applied Y migrations to schema `db_identity`
Successfully applied Z migrations to schema `db_reporting`
Successfully applied W migrations to schema `db_1097_identity`
```

**Stop the service** with Ctrl+C after migrations complete.

**Verify migrations:**
```bash
docker exec mysql-container mysql -uroot -p -e "USE db_iemr; SELECT COUNT(*) FROM flyway_schema_history;"
```

For detailed troubleshooting, see [AMRIT-DB README](https://github.com/PSMRI/AMRIT-DB).

### 7. Deploy Application Services

**Return to AMRIT-DevOps:**
```bash
cd ../AMRIT-DevOps/amrit-docker-setup
```

**Start all application services:**
```bash
docker compose -f docker-compose.yml up -d
```

Initial startup takes 5-10 minutes as services compile and initialize.

### 8. Verify Deployment
```bash
# Check all containers
docker ps

# Verify NGINX is accessible
curl http://localhost/

# Check API health
curl http://localhost/admin-api/v3/api-docs
```

## Service Access

### Web Applications

| Application      | URL                             |
|------------------|---------------------------------|
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

| Service           | Health Check Endpoint                         | Direct Port |
|-------------------|-----------------------------------------------|-------------|
| Admin API         | http://localhost/admin-api/v3/api-docs        | 8082        |
| Common API        | http://localhost/common-api/v3/api-docs       | 8083        |
| ECD API           | http://localhost/ecd-api/v3/api-docs          | 8084        |
| HWC API           | http://localhost/hwc-api/v3/api-docs          | 8085        |
| Inventory API     | http://localhost/inventory-api/v3/api-docs    | 8086        |
| MMU API           | http://localhost/mmu-api/v3/api-docs          | 8087        |
| Scheduler API     | http://localhost/scheduler-api/v3/api-docs    | 8088        |
| TM API            | http://localhost/tm-api/v3/api-docs           | 8089        |
| FLW API           | http://localhost/flw-api/v3/api-docs          | 8090        |
| FHIR API          | http://localhost/fhir-api/v3/api-docs         | 8091        |
| Helpline104 API   | http://localhost/helpline104-api/v3/api-docs  | 8092        |
| Helpline1097 API  | http://localhost/helpline1097-api/v3/api-docs | 8093        |
| Identity API      | http://localhost/identity-api/v3/api-docs     | 8094        |
| BeneficiaryID API | http://localhost/beneficiary-api/v3/api-docs  | 8095        |

### Infrastructure Services

| Service  | Port  | Credentials (default)          |
|----------|-------|--------------------------------|
| MySQL    | 3306  | root/configured_in_.env        |
| Redis    | 6379  | No authentication by default   |
| MongoDB  | 27017 | root/configured_in_.env        |

## Operations

### Starting Services

**Start all services (recommended):**
```bash
./start-all.sh
```

**Start infrastructure only:**
```bash
docker compose -f docker-compose.infra.yml up -d
```

**Start applications only:**
```bash
docker compose -f docker-compose.yml up -d
```

**Start specific service:**
```bash
docker compose -f docker-compose.yml up -d admin-api
```

### Stopping Services

**Stop all services:**
```bash
./stop-all.sh
```

**Stop applications only:**
```bash
docker compose -f docker-compose.yml down
```

**Stop and remove all data volumes:**
```bash
docker compose -f docker-compose.infra.yml down -v
docker compose -f docker-compose.yml down -v
```

### Monitoring

**View all running containers:**
```bash
docker ps
```

**View container logs:**
```bash
# Follow logs in real-time
docker logs -f <container-name>

# View last 100 lines
docker logs --tail 100 <container-name>

# View logs from specific service
docker compose -f docker-compose.yml logs -f admin-api
```

**Check container resource usage:**
```bash
docker stats
```

**Inspect container health:**
```bash
docker inspect --format='{{json .State.Health}}' <container-name> | jq
```

### Database Management

**MySQL:**
```bash
# Connect to MySQL
docker exec -it mysql-container mysql -uroot -p

# Show databases
SHOW DATABASES;

# Access specific database
USE db_iemr;

# List tables
SHOW TABLES;
```

**MongoDB:**
```bash
# Connect to MongoDB
docker exec -it mongodb-container mongosh -u root -p

# Show databases
show dbs

# Use database
use mydatabase

# List collections
show collections
```

**Redis:**
```bash
# Connect to Redis CLI
docker exec -it redis-container redis-cli

# Test connection
PING

# View all keys
KEYS *

# Get cache statistics
INFO stats
```

### Backup and Restore

**MySQL Backup:**
```bash
docker exec mysql-container mysqldump -uroot -p db_iemr > backup_$(date +%Y%m%d).sql
```

**MySQL Restore:**
```bash
docker exec -i mysql-container mysql -uroot -p db_iemr < backup_20250101.sql
```

**MongoDB Backup:**
```bash
docker exec mongodb-container mongodump --out=/data/backup
docker cp mongodb-container:/data/backup ./mongodb_backup
```

## Troubleshooting

### Common Setup Issues

#### Docker Desktop Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solution:** Start Docker Desktop and wait for it to fully initialize before running any docker commands.

#### Docker Compose Version Warning

**Error:** `version is obsolete` or Docker Compose compatibility warning

**Solution:** Edit `docker-compose.yml` and `docker-compose.infra.yml`, remove or comment out the version line:
```yaml
# version: \"3.9\"  # Remove or comment this line

services:
  ...
```

Modern Docker Compose doesn't require explicit version specification.

#### MySQL Command Not Recognized (Data Loading)

**Error:** `'mysql' is not recognized as an internal or external command`

**Cause:** MySQL CLI not installed or not in PATH

**Solutions:**
1. Install MySQL 8.0 and add to PATH
2. Or use Docker exec for data loading:
   ```bash
   docker exec -i mysql-container mysql -uroot -p < data.sql
   ```

#### First-Time Setup Very Slow

**Symptom:** Setup taking 20-30 minutes

**This is normal for:**
- First-time installation
- After long gap between runs
- After clearing Docker cache

Monitor progress: `docker-compose logs -f`

### Service Runtime Issues

### Services Not Starting

**Check container status:**
```bash
docker compose -f docker-compose.yml ps
docker compose -f docker-compose.infra.yml ps
```

**View error logs:**
```bash
docker compose -f docker-compose.yml logs <service-name>
```

**Restart specific service:**
```bash
docker compose -f docker-compose.yml restart <service-name>
```

### Port Conflicts

If ports 80, 3306, 6379, or 27017 are already in use:
```bash
# Check what's using a port
netstat -tulpn | grep <port>

# Stop conflicting services
sudo systemctl stop mysql
sudo systemctl stop redis
sudo systemctl stop mongod
```

### Database Connection Issues

**Verify database is accessible:**
```bash
docker exec mysql-container mysqladmin ping -uroot -p
```

**Check network connectivity:**
```bash
docker network inspect amrit_app-network
```

**Verify environment variables:**
```bash
docker compose -f docker-compose.yml config
```

### Memory Issues

If containers are killed due to OOM:
```bash
# Increase Docker memory limit
# On Docker Desktop: Settings > Resources > Memory

# Check current memory usage
docker stats --no-stream

# Restart with fewer services initially
docker compose -f docker-compose.yml up -d admin-api common-api identity-api
```

### Build Failures

**Clear Docker build cache:**
```bash
docker builder prune -a
```

**Rebuild specific service:**
```bash
docker compose -f docker-compose.yml build --no-cache <service-name>
docker compose -f docker-compose.yml up -d <service-name>
```

### UI Not Loading

**Verify NGINX configuration:**
```bash
docker exec amrit-nginx nginx -t
```

**Check if static files exist:**
```bash
docker exec amrit-nginx ls -la /usr/share/nginx/html/
```

**Rebuild UI applications:**
```bash
cd UI/<app-name>
npm install
npm run build
```

## Directory Structure

```
amrit-docker-setup/
├── API/                        # API repositories (gitignored)
│   ├── Admin-API/
│   ├── Common-API/
│   ├── HWC-API/
│   └── ... (14 total)
├── UI/                         # UI repositories (gitignored)
│   ├── ADMIN-UI/
│   ├── Common-UI/
│   ├── HWC-UI/
│   └── ... (10 total)
├── nginx/                      # NGINX configuration
│   ├── nginx.conf
│   └── conf.d/
│       ├── cache-rules.conf
│       ├── common_headers.conf
│       └── proxy_settings.conf
├── logs/                       # Application logs (gitignored)
├── docker-compose.yml          # Application services
├── docker-compose.infra.yml    # Infrastructure services
├── Dockerfile.nginx            # NGINX container definition
├── .env                        # Environment configuration (gitignored)
├── .env.example                # Environment template
├── init.sql                    # MySQL initialization
├── mongo-init.js               # MongoDB initialization
├── my.cnf                      # MySQL configuration
├── setup.sh                    # Repository setup script
├── start-all.sh                # Start all services
└── stop-all.sh                 # Stop all services
```

## Performance Tuning

### Database Optimization

**MySQL connection pooling** (configure in `.env`):
```bash
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=20
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=5
SPRING_DATASOURCE_HIKARI_IDLE_TIMEOUT=300000
```

**Redis persistence:**
- Current configuration uses AOF (Append Only File) for durability
- For better performance with acceptable data loss: disable AOF in `docker-compose.infra.yml`

### NGINX Caching

Static asset caching is configured in `nginx/conf.d/cache-rules.conf`:
- UI assets: 1 year cache
- API responses: No cache
- Health checks: No cache

### Application Performance

**Java heap size** (modify in service Dockerfile):
```bash
ENV JAVA_OPTS="-Xms512m -Xmx2048m"
```

**Spring Boot profiles:**
Set in `.env` for production optimizations:
```bash
SPRING_PROFILES_ACTIVE=production
```

## Security Considerations

1. Change all default passwords in `.env` before deployment
2. Restrict database ports exposure (remove from `ports:` in production)
3. Enable HTTPS by configuring SSL certificates in NGINX
4. Implement rate limiting in NGINX for API endpoints
5. Use Docker secrets for sensitive credentials in production
6. Enable MySQL SSL connections for production databases
7. Configure firewall rules to restrict access to infrastructure ports

## Production Deployment

For production environments:

1. Use external managed databases instead of containerized ones
2. Implement horizontal scaling with multiple NGINX instances
3. Configure centralized logging (ELK stack, CloudWatch, etc.)
4. Set up health monitoring and alerting
5. Implement automated backups and disaster recovery
6. Use container orchestration (Kubernetes, Docker Swarm)
7. Enable SSL/TLS with valid certificates
8. Configure proper resource limits for each container

## Related Documentation

- [Main DevOps Repository](../README.md)
- [Local Development Setup](../amrit-local-setup/README.md)
- [Database Anonymization](../db-anonymization/)
- [ELK Monitoring Setup](../ELK/SETUP.md)
- [AMRIT Platform Documentation](https://piramal-swasthya.gitbook.io/amrit/)

