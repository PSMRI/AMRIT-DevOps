# AMRIT — Full Docker stack

Production-like Compose deployment of the complete AMRIT platform on a single host — all 14 APIs, 10 UIs, and an NGINX reverse proxy. Best for staging servers, performance testing, and full-platform demos.

Start here → [root README](../README.md). For architecture and the service map, see the [system architecture overview](https://piramal-swasthya.gitbook.io/amrit/architecture/system-architecture-overview).

> Running one product on a laptop? Use [`../amrit-local-setup/automation/`](../amrit-local-setup/automation/README.md) instead — much faster.

## Prerequisites

See [root README](../README.md#prerequisites). For this path specifically: **16 GB RAM minimum** (32 GB recommended), **50 GB disk**, and ports 80 + 8082–8095 free. First-time setup takes 15–30 minutes.

## Two Compose stacks

- **Infrastructure** — [`docker-compose.infra.yml`](docker-compose.infra.yml): MySQL 8.0, Redis 7.2, MongoDB 6.0. Env-file-driven passwords, hardened healthchecks.
- **Applications** — [`docker-compose.yml`](docker-compose.yml): 14 Spring Boot APIs, 10 Angular UIs as static bundles, NGINX on port 80.

The dev-focused sibling at [`../amrit-local-setup/infra/docker-compose.yml`](../amrit-local-setup/infra/docker-compose.yml) is intentionally separate (hardcoded dev defaults, includes Elasticsearch + Kibana). Keep both in sync when changing MySQL/Redis/Mongo shape.

## Install

```bash
git clone https://github.com/PSMRI/AMRIT-DevOps.git
cd AMRIT-DevOps/amrit-docker-setup

cp .env.example .env                                          # fill in passwords + API keys
chmod +x setup.sh && ./setup.sh                               # clone + build all API/UI repos (15–30 min)

docker compose -f docker-compose.infra.yml up -d              # start MySQL, Redis, Mongo
```

Then run schema migrations — follow the [AMRIT-DB](https://github.com/PSMRI/AMRIT-DB) README (point it at `localhost:3306` with your `.env`'s `MYSQL_ROOT_PASSWORD`). Come back and start apps:

```bash
docker compose -f docker-compose.yml up -d                    # start all 14 APIs, 10 UIs, NGINX
# or
./start-all.sh                                                # infra + apps, with optional rebuild
```

Verify:
```bash
docker ps                                                     # ~26 containers
curl http://localhost/                                        # NGINX
curl http://localhost/admin-api/v3/api-docs                   # API health
```

## Service access

UIs are served under subpaths on port 80: `/admin/`, `/hwc/`, `/inventory/`, `/tm/`, `/mmu/`, `/scheduler/`, `/hwc-scheduler/`, `/hwc-inventory/`, `/ecd/`.

APIs follow the pattern `/<name>-api/` on port 80, or are directly exposed on host ports 8082–8095. Append `v3/api-docs` or `swagger-ui.html` to any API path for its OpenAPI docs.

| API | NGINX path | Direct port |
|---|---|---|
| Admin / Common / ECD / HWC | `/admin-api/` … | 8082 / 8083 / 8084 / 8085 |
| Inventory / MMU / Scheduler / TM | `/inventory-api/` … | 8086 / 8087 / 8088 / 8089 |
| FLW / FHIR / Helpline104 / Helpline1097 | `/flw-api/` … | 8090 / 8091 / 8092 / 8093 |
| Identity / BeneficiaryID | `/identity-api/` · `/beneficiary-api/` | 8094 / 8095 |

## Operations

```bash
./start-all.sh                                                # start infra + apps
./stop-all.sh                                                 # stop both
docker compose -f docker-compose.yml restart <service>
docker compose -f docker-compose.yml logs -f <service>
docker compose -f docker-compose.yml down -v                  # ⚠ destroys app volumes
docker compose -f docker-compose.infra.yml down -v            # ⚠ destroys DB volumes
```

Database shell:
```bash
docker exec -it mysql-container mysql -uroot -p
docker exec -it mongodb-container mongosh -u root -p
docker exec -it redis-container redis-cli
```

Backup:
```bash
docker exec mysql-container mysqldump -uroot -p db_iemr > backup_$(date +%Y%m%d).sql
docker exec mongodb-container mongodump --out=/data/backup
```

## Troubleshooting

- **Port 80 busy**: `lsof -i :80` — stop the host web server.
- **OOM-killed containers**: raise Docker Desktop memory limit; or bring up a subset first (`admin-api common-api identity-api`).
- **UI returns 404**: `docker exec amrit-nginx nginx -t`; rebuild a UI with `cd UI/<app> && npm install && npm run build`.
- **Build cache corruption**: `docker builder prune -a && docker compose build --no-cache <service>`.
- **App containers can't reach DB**: in `.env`, use `jdbc:mysql://mysql:3306/…` (service name), not `localhost`.

More baseline issues → [root README](../README.md#troubleshooting).

## Security checklist before exposing publicly

1. Replace every default password in `.env`.
2. Remove `ports:` from infra services in `docker-compose.infra.yml` to keep them container-internal.
3. Terminate TLS at NGINX (add certs, switch to `listen 443 ssl`).
4. Add `limit_req_zone` rate limits on API endpoints in `nginx/`.
5. Move secrets to Docker secrets (`docker secret create …`).
6. Restrict `app-network` ingress via host firewall.
7. Enable MySQL SSL for cross-host DB traffic.

## Performance knobs

- **HikariCP** in `.env`: `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE`, `…_MINIMUM_IDLE`, `…_IDLE_TIMEOUT`.
- **JVM heap** per service Dockerfile: `ENV JAVA_OPTS="-Xms512m -Xmx2048m"`.
- **NGINX caching**: `nginx/conf.d/cache-rules.conf` (UI assets 1y, API responses no-cache).

## Production notes

Consider managed databases (RDS / Atlas / ElastiCache), Kubernetes or Swarm for HA, externalized logging via [`../ELK/`](../ELK/), automated backups + DR drills, and health alerting.

## Layout

```
amrit-docker-setup/
├── API/ · UI/                   cloned repos + UI builds (gitignored)
├── nginx/                       NGINX config
├── docker-compose.yml           application containers
├── docker-compose.infra.yml     MySQL / Redis / Mongo (server-tuned)
├── Dockerfile.nginx
├── .env.example                 copy → .env
├── init.sql · mongo-init.js · my.cnf
├── setup.sh                     clone + build
└── start-all.sh · stop-all.sh
```
