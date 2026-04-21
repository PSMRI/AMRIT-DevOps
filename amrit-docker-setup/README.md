# AMRIT — Full Docker stack

Production-like Compose deployment of the complete AMRIT platform on a single host — all 14 APIs, 10 UIs, and an NGINX reverse proxy. Best for staging servers, performance testing, and full-platform demos.

Start here → [root README](../README.md). For architecture and the service map, see the [system architecture overview](https://piramal-swasthya.gitbook.io/amrit/architecture/system-architecture-overview).

> Running one product on a laptop? Use [`../amrit-local-setup/automation/`](../amrit-local-setup/automation/README.md) instead — much faster.

## Architecture

Two Docker Compose stacks:

**Infrastructure Layer** ([`docker-compose.infra.yml`](docker-compose.infra.yml))
- MySQL 8.0 with custom `my.cnf`
- Redis 7.2 with AOF persistence
- MongoDB 6.0 with authentication

**Application Layer** ([`docker-compose.yml`](docker-compose.yml))
- 14 Spring Boot microservices (Admin, Common, HWC, MMU, TM, Scheduler, Inventory, ECD, FLW, FHIR, Identity, Helpline104, Helpline1097, BeneficiaryID)
- 10 Angular UIs built as static bundles
- NGINX reverse proxy on port 80

All API containers talk to each other on the shared `app-network`. NGINX serves UI bundles and proxies `/<service>-api/` requests to backend services.

The dev-focused sibling at [`../amrit-local-setup/infra/docker-compose.yml`](../amrit-local-setup/infra/docker-compose.yml) is intentionally separate (hardcoded dev defaults, adds Elasticsearch + Kibana). Keep both in sync when changing MySQL/Redis/Mongo shape.

## Prerequisites

See [root README — Prerequisites](../README.md#prerequisites) for the shared list. Specific to this path:

- **16 GB RAM minimum**, 32 GB recommended
- **50 GB disk** for images + repos + logs
- Ports **80** and **8081–8095** free on the host
- First-time setup takes **15–30 minutes** (image pulls, repo clones, UI builds)

## Install

### Overview

Three repos are involved:

1. **AMRIT-DevOps** (this repo) — containers and orchestration
2. **[AMRIT-DB](https://github.com/PSMRI/AMRIT-DB)** — Flyway migrations (separate repo)
3. **Per-service API/UI repos** — cloned automatically by `setup.sh`

Sequence: clone this repo → `.env` → `setup.sh` → start infra → run migrations → start apps.

### 1. Clone

```bash
git clone https://github.com/PSMRI/AMRIT-DevOps.git
cd AMRIT-DevOps/amrit-docker-setup
```

### 2. Environment

```bash
cp .env.example .env
```

Edit `.env` and set at minimum:

```bash
MYSQL_ROOT_PASSWORD=<strong-password>
MYSQL_USER=amrit_user
MYSQL_PASSWORD=<db-password>
MONGO_ROOT_PASSWORD=<mongo-password>

# JDBC URL uses the Docker service name, not localhost
DATABASE_URL=jdbc:mysql://mysql:3306/db_iemr
DATABASE_USERNAME=root
DATABASE_PASSWORD=<same as MYSQL_ROOT_PASSWORD>
```

See `.env.example` for the full list (API base URLs, CORS origins, JWT secrets, Hikari pool knobs, etc.).

### 3. Pre-flight

```bash
docker ps                            # should list containers (empty is fine), not "Cannot connect"
docker compose version               # v2.x
```

### 4. Clone + build all API/UI repos

```bash
chmod +x setup.sh
./setup.sh
```

This:
- Clones all 14 API repos into `API/`
- Clones all 10 UI repos into `UI/`
- Runs `git submodule update --init --recursive` for each UI (pulls `Common-UI`)
- Runs `npm install && npm run build` for each UI and lays the `dist/` bundles where NGINX expects them

Takes 15–30 min depending on network and laptop.

### 5. Start infrastructure

```bash
docker compose -f docker-compose.infra.yml up -d
```

Wait 30–60 s for first-time init, then verify:

```bash
docker compose -f docker-compose.infra.yml ps
# Every row should show "Up" and "healthy"
```

### 6. Run database migrations (AMRIT-DB)

**Critical step — run before starting application services.** Migrations live in a separate repo.

```bash
cd ../..
git clone https://github.com/PSMRI/AMRIT-DB.git
cd AMRIT-DB

cp src/main/environment/common_example.properties src/main/environment/common_local.properties
```

Edit `src/main/environment/common_local.properties` — point each datasource at `localhost:3306` with your `MYSQL_ROOT_PASSWORD`:

```properties
spring.datasource.dbiemr.jdbc-url=jdbc:mysql://localhost:3306/db_iemr
spring.datasource.dbiemr.username=root
spring.datasource.dbiemr.password=<MYSQL_ROOT_PASSWORD>

spring.datasource.dbidentity.jdbc-url=jdbc:mysql://localhost:3306/db_identity
spring.datasource.dbidentity.username=root
spring.datasource.dbidentity.password=<MYSQL_ROOT_PASSWORD>

spring.datasource.dbreporting.jdbc-url=jdbc:mysql://localhost:3306/db_reporting
spring.datasource.dbreporting.username=root
spring.datasource.dbreporting.password=<MYSQL_ROOT_PASSWORD>

spring.datasource.db1097identity.jdbc-url=jdbc:mysql://localhost:3306/db_1097_identity
spring.datasource.db1097identity.username=root
spring.datasource.db1097identity.password=<MYSQL_ROOT_PASSWORD>
```

Run migrations:

```bash
mvn clean install -DENV_VAR=local
mvn spring-boot:run -DENV_VAR=local
```

Expect per-schema confirmation:

```
Successfully applied X migrations to schema `db_iemr`
Successfully applied Y migrations to schema `db_identity`
Successfully applied Z migrations to schema `db_reporting`
Successfully applied W migrations to schema `db_1097_identity`
```

Stop with `Ctrl+C` once complete. Verify:

```bash
docker exec mysql-container mysql -uroot -p -e "USE db_iemr; SELECT COUNT(*) FROM flyway_schema_history;"
```

For deeper troubleshooting see the [AMRIT-DB README](https://github.com/PSMRI/AMRIT-DB).

### 7. (Optional) Load master/dummy data

```bash
cd ../AMRIT-DevOps/amrit-local-setup/infra
bash loaddummydata.sh
```

> **Known issue**: the hosted `AmritMasterData.zip` is currently out of sync with the latest AMRIT-DB schema — `INSERT … VALUES (…)` tuples have fewer values than the current tables have columns, so MySQL rejects most rows with `ERROR 1136 Column count doesn't match value count at row 1`. Only `db_1097_identity` loads cleanly. Tracking issue should be filed against AMRIT-DB (upstream fix: regenerate the zip with `--complete-insert`).

### 8. Start application services

```bash
cd ../../../AMRIT-DevOps/amrit-docker-setup
docker compose -f docker-compose.yml up -d
```

Initial startup is 5–10 min while services compile + warm up.

### 9. Verify

```bash
docker ps                                                    # ~26 containers
curl http://localhost/                                       # NGINX landing
curl -f http://localhost/admin-api/v3/api-docs               # one API health check
```

`./start-all.sh` is a convenience wrapper that runs infra + apps with an optional rebuild prompt.

## Service access

### Web applications (all on port 80 via NGINX)

| Application      | URL                             |
|------------------|---------------------------------|
| Admin UI         | http://localhost/admin/         |
| HWC UI           | http://localhost/hwc/           |
| HWC Scheduler UI | http://localhost/hwc-scheduler/ |
| HWC Inventory UI | http://localhost/hwc-inventory/ |
| Inventory UI     | http://localhost/inventory/     |
| Scheduler UI     | http://localhost/scheduler/     |
| TM UI            | http://localhost/tm/            |
| MMU UI           | http://localhost/mmu/           |
| ECD UI           | http://localhost/ecd/           |
| Helpline104 UI   | http://localhost/104/           |
| Helpline1097 UI  | http://localhost/1097/          |

### API services

Each API is reachable via NGINX (`http://localhost/<name>-api/…`) and directly on its host port. Append `v3/api-docs` or `swagger-ui.html` for OpenAPI docs.

| Service                     | NGINX path                | Direct port |
|-----------------------------|---------------------------|-------------|
| FLW API                     | `/flw-api/`               | 8081        |
| Admin API                   | `/admin-api/`             | 8082        |
| Common API                  | `/common-api/`            | 8083        |
| ECD API                     | `/ecd-api/`               | 8084        |
| HWC API                     | `/hwc-api/`               | 8085        |
| Inventory API               | `/inventory-api/`         | 8086        |
| MMU API                     | `/mmu-api/`               | 8087        |
| Scheduler API               | `/scheduler-api/`         | 8088        |
| TM API                      | `/tm-api/`                | 8089        |
| Helpline1097 API            | `/helpline1097-api/`      | 8090        |
| Helpline104 API             | `/helpline104-api/`       | 8091        |
| BeneficiaryID-Generation    | `/beneficiary-api/`       | 8092        |
| FHIR API                    | `/fhir-api/`              | 8093        |
| Identity API                | `/identity-api/`          | 8094        |

### Infrastructure

| Service  | Port  | Credentials                     |
|----------|-------|---------------------------------|
| MySQL    | 3306  | `root` / `$MYSQL_ROOT_PASSWORD` |
| Redis    | 6379  | no auth by default              |
| MongoDB  | 27017 | `root` / `$MONGO_ROOT_PASSWORD` |

## Operations

### Starting

```bash
./start-all.sh                                                  # infra + apps, with optional rebuild prompt
docker compose -f docker-compose.infra.yml up -d                # infra only
docker compose -f docker-compose.yml up -d                      # apps only
docker compose -f docker-compose.yml up -d admin-api            # a single service
```

### Stopping

```bash
./stop-all.sh                                                   # both stacks
docker compose -f docker-compose.yml down                       # apps only
docker compose -f docker-compose.yml down -v                    # ⚠ also wipes app volumes
docker compose -f docker-compose.infra.yml down -v              # ⚠ wipes DB volumes
```

### Monitoring

```bash
docker ps                                                       # running containers
docker logs -f <container>                                      # follow logs
docker logs --tail 100 <container>                              # last 100 lines
docker compose -f docker-compose.yml logs -f admin-api          # follow one service
docker stats                                                    # live CPU/mem/net
docker inspect --format='{{json .State.Health}}' <container> | jq
```

### Database shells

```bash
docker exec -it mysql-container   mysql -uroot -p
docker exec -it mongodb-container mongosh -u root -p
docker exec -it redis-container   redis-cli
```

### Backup / restore

```bash
# MySQL
docker exec mysql-container mysqldump -uroot -p db_iemr > backup_$(date +%Y%m%d).sql
docker exec -i mysql-container mysql -uroot -p db_iemr < backup_YYYYMMDD.sql

# MongoDB
docker exec mongodb-container mongodump --out=/data/backup
docker cp mongodb-container:/data/backup ./mongodb_backup
```

## Troubleshooting

### Docker daemon not running

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```
Start Docker Desktop; wait for the tray icon to go green before retrying.

### `docker-compose: command not found`

You have Compose v1 or none. Install Compose v2 (`docker compose` with a space).

### MySQL CLI not on host PATH (data loading fails)

```
'mysql' is not recognized as an internal or external command
```
Install MySQL 8.0 CLI (`brew install mysql@8.0` on macOS, `apt install mysql-client` on Debian/Ubuntu). Or bypass the host CLI and pipe a SQL file through the container:
```bash
docker exec -i mysql-container mysql -uroot -p db_iemr < data.sql
```

### First-time setup taking 20–30 minutes

Expected on a cold machine: image pulls, repo clones, `npm install` for 10 UIs, Maven dependency resolution for 14 APIs. Monitor with `docker compose logs -f`. Not a bug.

### Services won't start

```bash
docker compose -f docker-compose.yml ps                         # who's unhealthy?
docker compose -f docker-compose.yml logs <service>             # why?
docker compose -f docker-compose.yml restart <service>
```

### Port conflicts (80 / 3306 / 6379 / 27017)

```bash
# macOS / Linux
lsof -iTCP:<port> -sTCP:LISTEN -P
sudo systemctl stop mysql redis mongod                          # Linux host services
brew services stop mysql                                        # macOS / Homebrew
```

### OOM-killed containers

Raise Docker Desktop memory limit (Settings → Resources → Memory). Or bring up a subset first:
```bash
docker compose -f docker-compose.yml up -d admin-api common-api identity-api
```
Check live usage with `docker stats --no-stream`.

### App containers can't reach the DB

In `.env`, use `jdbc:mysql://mysql:3306/…` (Docker service name), **not** `localhost`. Apps run inside the Docker network; `localhost` resolves to the container itself.

Verify connectivity:
```bash
docker exec mysql-container mysqladmin ping -uroot -p
docker network inspect amrit-network
docker compose -f docker-compose.yml config                     # rendered env for every service
```

### Build cache / image corruption

```bash
docker builder prune -a
docker compose -f docker-compose.yml build --no-cache <service>
docker compose -f docker-compose.yml up -d <service>
```

### UI returns 404

```bash
docker exec amrit-nginx nginx -t                                # validate config
docker exec amrit-nginx ls -la /usr/share/nginx/html/           # are bundles present?
cd UI/<app> && npm install && npm run build                     # rebuild one UI
```

## Directory structure

```
amrit-docker-setup/
├── API/                            # cloned API repos (gitignored)
├── UI/                             # cloned UI repos + built dist bundles (gitignored)
├── nginx/
│   ├── nginx.conf
│   └── conf.d/
│       ├── cache-rules.conf
│       ├── common_headers.conf
│       └── proxy_settings.conf
├── logs/                           # per-service log volume (gitignored)
├── docker-compose.yml              # application containers
├── docker-compose.infra.yml        # MySQL / Redis / Mongo (server-tuned)
├── Dockerfile.nginx
├── .env.example                    # copy → .env
├── init.sql · mongo-init.js · my.cnf
├── setup.sh                        # clone + build all API/UI repos
├── start-all.sh · stop-all.sh
└── README.md
```

## Performance tuning

### HikariCP (`.env`)

```bash
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=20
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=5
SPRING_DATASOURCE_HIKARI_IDLE_TIMEOUT=300000
```

### JVM heap (per-service Dockerfile)

```dockerfile
ENV JAVA_OPTS="-Xms512m -Xmx2048m"
```

### Redis persistence

AOF is enabled by default for durability. For more throughput with acceptable data-loss risk, disable AOF in `docker-compose.infra.yml`.

### NGINX caching

Configured in `nginx/conf.d/cache-rules.conf`: UI assets 1 year, API responses no-cache, health checks no-cache.

### Spring profiles

```bash
SPRING_PROFILES_ACTIVE=production
```

## Security checklist (before exposing publicly)

1. Replace every default password in `.env`.
2. Remove `ports:` from infra services in `docker-compose.infra.yml` so they stay container-internal.
3. Terminate TLS at NGINX (add certs, switch to `listen 443 ssl`).
4. Add `limit_req_zone` rate limits on API endpoints in `nginx/conf.d/`.
5. Move secrets to Docker secrets (`docker secret create …`) rather than `.env`.
6. Restrict `app-network` ingress with a host firewall.
7. Enable MySQL SSL if DB traffic crosses hosts.

## Production notes

- Prefer managed databases (RDS / Atlas / ElastiCache) over containerised infra.
- Orchestrate with Kubernetes or Docker Swarm for HA + rolling deploys.
- Centralise logs via [`../ELK/`](../ELK/) or equivalent.
- Automate backups and run DR drills.
- Add health-based alerting (Prometheus + Alertmanager, Datadog, etc.).
- Pin container resource limits (`mem_limit`, `cpus`) per service.

## Related docs

- [Root README](../README.md) — decision tree + prereqs
- [Local automation setup](../amrit-local-setup/automation/README.md) — one-command per-product dev workflow
- [ELK monitoring](../ELK/) — optional log aggregation + APM
- [AMRIT platform docs](https://piramal-swasthya.gitbook.io/amrit/)
