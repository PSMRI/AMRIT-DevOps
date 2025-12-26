# AMRIT-DevOps

DevOps automation and infrastructure configuration repository for the AMRIT (Accessible Medical Records via Integrated Technology) platform. Contains Docker orchestration, database management tools, monitoring setup, and deployment automation scripts.

## Overview

This repository provides infrastructure-as-code and DevOps tooling for deploying and managing the AMRIT healthcare platform across multiple environments. It includes containerized deployment configurations, database management utilities, anonymization tools, and monitoring infrastructure.

## Repository Structure

### amrit-docker-setup
Complete Docker-based deployment configuration for production and staging environments. Includes Docker Compose orchestration for all microservices, NGINX reverse proxy configuration, automated build scripts, and environment management.

**Use case:** Full production deployment with containerized infrastructure and application services.

### amrit-local-setup
Lightweight Docker Compose configuration for local development environments. Provides only infrastructure services (MySQL, Redis, MongoDB) while APIs and UIs run directly on the host machine.

**Use case:** Local development environment for debugging and feature development.

### ELK
Elastic Stack configuration for distributed tracing and centralized logging. Includes APM agent setup for WildFly application servers, Filebeat configuration for log aggregation, and Kibana dashboard setup.

**Components:**
- APM Server configuration for application performance monitoring
- Filebeat setup for log collection and forwarding
- WildFly integration configuration
- API key management and security setup

## Prerequisites

### Critical Requirements
- **Docker Desktop** must be installed and RUNNING (the daemon must be active)
- **MySQL Server 8.0** installed locally (not just the containerized version)
  - **Important:** Use MySQL 8.0 specifically. Versions after 8.0 may cause compatibility issues
  - MySQL CLI (`mysql.exe`) must be accessible from command line (added to system PATH)
- Git 2.30+

### Additional Software
- Docker Engine 20.10+ and Docker Compose 2.0+
- For local setup: Maven 3.6+, OpenJDK 17+
- For UI development: Node.js 16+ and npm

### System Requirements
- Minimum 16GB RAM (32GB recommended for full deployment)
- 50GB available disk space
- Linux, macOS, or Windows with WSL2

### First-Time Setup Note
If running for the first time or after a long gap, initial setup will take considerable time (15-30 minutes) for:
- Downloading Docker images
- Building application containers
- Database initialization
- This is normal, be patient

## Quick Start

### Mandatory Pre-Flight Checks

**Before starting, verify:**
```bash
# 1. Docker Desktop is running
docker ps
# Should return container list (even if empty), not an error

# 2. MySQL 8.0 is installed and accessible
mysql --version
# Should show: mysql  Ver 8.0.x

# 3. MySQL CLI is in system PATH
where mysql  # Windows
# or
which mysql  # Linux/macOS
```

### Complete Setup Process

The AMRIT platform requires a specific setup sequence. Follow these steps in order:

**Step 1: Start Infrastructure Services**
```bash
cd amrit-docker-setup
# or
cd amrit-local-setup

# Start MySQL, Redis, MongoDB
docker-compose -f docker-compose.infra.yml up -d  # for docker-setup
# or
docker-compose up -d  # for local-setup

# Wait 30-60 seconds for MySQL to initialize
# First run takes longer - be patient
```

**Step 2: Setup Database Schemas**

Switch to the AMRIT-DB repository to run schema migrations:
```bash
cd ../../AMRIT-DB
cp src/main/environment/common_example.properties src/main/environment/common_local.properties
# Edit common_local.properties with your MySQL credentials
mvn clean install -DENV_VAR=local
mvn spring-boot:run -DENV_VAR=local
# Wait for "Migration successful" message, then stop (Ctrl+C)
```

See [AMRIT-DB README](https://github.com/PSMRI/AMRIT-DB) for detailed instructions.

**Step 3: Return and Start Application Services**
```bash
cd ../AMRIT-DevOps/amrit-docker-setup
./start-all.sh
# or for local setup, manually start individual API/UI services
```

### Quick Start Options

**Option 1: Full Docker Deployment**
```bash
cd amrit-docker-setup
cp .env.example .env
# Configure environment variables in .env
./setup.sh
./start-all.sh
```

**Option 2: Local Development Environment**
```bash
cd amrit-local-setup
docker-compose up -d
# Clone and run individual API/UI repositories on host
```

**Important:** Both options require running [AMRIT-DB](https://github.com/PSMRI/AMRIT-DB) migrations after infrastructure is up but before starting application services.

## Related Repositories

This DevOps repository works in conjunction with:
- [AMRIT-DB](https://github.com/PSMRI/AMRIT-DB) - Database schema management and migrations
- [AmritMasterData](https://github.com/PSMRI/AmritMasterData) - Initial master data and reference datasets
- API Repositories - Individual microservice implementations (Common-API, Admin-API, HWC-API, etc.)
- UI Repositories - Angular frontend applications

## Configuration Management

Environment-specific configurations are managed through:
- `.env` files for Docker deployments (see `.env.example` for reference)
- `application.properties` for Spring Boot services
- Docker Compose override files for environment-specific customization

## Documentation

Detailed setup and configuration instructions are available in each subdirectory:
- [Docker Setup Guide](amrit-docker-setup/README.md)
- [Local Development Setup](amrit-local-setup/README.md)
- [ELK Monitoring Setup](ELK/SETUP.md)

## Common Issues and Troubleshooting

### Docker Compose Version Error

**Error:** `version is obsolete` or similar Docker Compose version warning

**Solution:** Remove or comment out the `version:` line in docker-compose files
```yaml
# version: "3.9"  # Comment this out or remove it
services:
  ...
```

Modern Docker Compose doesn't require the version field.

### MySQL Command Not Recognized

**Error:** `'mysql' is not recognized as an internal or external command`

**Cause:** MySQL is not installed locally OR not added to system PATH

**Solutions:**

**Option 1: Install MySQL 8.0**
- Download from [MySQL official site](https://dev.mysql.com/downloads/mysql/8.0.html)
- During installation, ensure "Add to PATH" is selected
- Restart terminal after installation

**Option 2: Add MySQL to PATH manually**

Windows:
```powershell
# Find mysql.exe location (usually C:\Program Files\MySQL\MySQL Server 8.0\bin)
# Add to System Environment Variables > Path
# Or temporarily:
$env:PATH += ";C:\Program Files\MySQL\MySQL Server 8.0\bin"
```

Linux/macOS:
```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH=$PATH:/usr/local/mysql/bin
source ~/.bashrc
```

**Option 3: Use Docker exec**
If you only have containerized MySQL:
```bash
# Instead of mysql command, use:
docker exec -i mysql-container mysql -uroot -p < script.sql
```

### Docker Desktop Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solution:** Start Docker Desktop application before running any docker commands

### First-Time Startup Very Slow

**Symptom:** Containers taking 15-30 minutes to start

**This is normal for:**
- First-time setup
- After long gap (images expired)
- After Docker cache clear

**What's happening:**
- Downloading large images (MySQL, Redis, MongoDB, etc.)
- Building application containers
- Database initialization scripts running

Just be patient and monitor logs: `docker-compose logs -f`

### MySQL Version Compatibility Issues

**Error:** Authentication plugin errors or connection failures

**Solution:** Ensure you're using MySQL 8.0, not 8.1+ or 5.x
```bash
mysql --version
# Should show 8.0.x
```

If you have a different version:
- Uninstall current MySQL
- Install MySQL 8.0 specifically
- Or modify docker-compose.yml to use matching version

### Port Already in Use

**Error:** `Bind for 0.0.0.0:3306 failed: port is already allocated`

**Solution:** Stop local MySQL service
```bash
# Windows
net stop MySQL80

# Linux
sudo systemctl stop mysql

# macOS
brew services stop mysql
```

### Data Loading Script Fails

**Error:** Script shows errors but no specific message

**Checklist:**
1. Is MySQL CLI in PATH? Test: `mysql --version`
2. Are containers running? Test: `docker ps`
3. Is MySQL container healthy? Test: `docker exec mysql-container mysql -uroot -p1234 -e "SELECT 1;"`
4. Did you download and extract the master data?
5. Did you update the DATA_PATH in the script?

## Security Considerations

- Never commit `.env` files or credentials to version control
- Use secure password generation for all database credentials
- Restrict network access to database ports in production
- Implement proper API key rotation for ELK stack
- Review anonymization configuration before running on production data

## Support

For platform documentation and technical support, refer to the [official AMRIT documentation](https://piramal-swasthya.gitbook.io/amrit/).

## License

Refer to LICENSE file in this repository.
