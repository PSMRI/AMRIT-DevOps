# AMRIT-DevOps

[![DeepWiki](https://img.shields.io/badge/DeepWiki-PSMRI%2FAMRIT--DevOps-blue.svg)](https://deepwiki.com/PSMRI/AMRIT-DevOps)

Setup and deployment tooling for **AMRIT** (Accessible Medical Records via Integrated Technology) — an open-source healthcare platform. For what AMRIT is, the service map, and system architecture, see the [official docs](https://piramal-swasthya.gitbook.io/amrit/) and in particular the [system architecture overview](https://piramal-swasthya.gitbook.io/amrit/architecture/system-architecture-overview).

## Pick your path

| You want to … | Run this | Details |
|---|---|---|
| Run one or more products on a laptop | `bash amrit-local-setup/automation/start.sh` | [automation/](amrit-local-setup/automation/README.md) |
| Debug an API or UI in your IDE with containerized infra | `cd amrit-local-setup/infra && docker compose up -d` | see **Manual (IDE) path** below |
| Deploy the full platform (all APIs + UIs + NGINX) | `cd amrit-docker-setup && ./setup.sh && ./start-all.sh` | [amrit-docker-setup/](amrit-docker-setup/README.md) |

All three share the same infrastructure services on the same ports — **don't run two at once**.

## Prerequisites

**Tools:**

- Docker Engine 20.10+ with Compose v2
- Java 17+, Maven 3.6+
- Node 16+, Angular CLI
- tmux, Git, wget, unzip
- MySQL 8.0 CLI on PATH
- **bash 4+** (macOS: `brew install bash`)
- **gum** for the automation wizard (`brew install gum`, or see [gum install](https://github.com/charmbracelet/gum#installation))

**Resources:**

- 16 GB RAM recommended (24 GB+ for `--all` full-platform mode)
- Free ports: `3306`, `6379`, `27017`, `9200`, `9300`, `5601`
- Plus `80` for full stack, or `8081–8095` / `4201–4211` for automation

**Preflight check:**
```bash
docker ps && docker compose version && java -version && mvn -v && node -v && mysql --version && tmux -V && bash --version | head -1
```

## Quickstart (automation path)

```bash
git clone https://github.com/PSMRI/AMRIT-DevOps.git
cd AMRIT-DevOps
bash amrit-local-setup/automation/start.sh        # interactive wizard: pick ECD, HWC, MMU, TM, HL104, HL1097, or --all
tmux attach -t amrit-ecd                          # session name matches the product you chose
```

Open **http://localhost:4209** (ECD UI) once Maven finishes building. First run takes 20–30 min (image pulls, schema migrations, `npm install`, Maven build). Subsequent runs skip one-time steps via sentinels in `~/.amrit/`.

Flag-driven shortcuts:
```bash
bash amrit-local-setup/automation/start.sh --product=ecd --skip-db --skip-data
bash amrit-local-setup/automation/start.sh --products=ecd,hwc
bash amrit-local-setup/automation/start.sh --all --force   # full platform on <24GB machines
bash amrit-local-setup/automation/start.sh --help
```

To edit API keys / external service endpoints after setup: the `*_local.properties` and `environment.ts` files the wizard seeded, e.g. `ECD-API/src/main/environment/ecd_local.properties`. Reset one-time steps with `--reset-db`, `--reset-data`, or `--reset-all`.

## Manual (IDE) path

Bring up infra only, then run APIs / UIs on your host for IDE debugging:

```bash
cd amrit-local-setup/infra && docker compose up -d
```

Default credentials and ports:

| Service | Credentials | Port |
|---|---|---|
| MySQL | `root` / `1234` | `3306` |
| Redis | — | `6379` |
| MongoDB | `root` / `1234` | `27017` |
| Elasticsearch | `elastic` / `piramalES` | `9200` |

Then follow the [AMRIT-DB](https://github.com/PSMRI/AMRIT-DB) README to run Flyway schema migrations, and clone the API/UI repos you need (e.g. `Common-API`, `ECD-UI`) from [PSMRI](https://github.com/PSMRI) — each has its own setup instructions.

Optional master data:
```bash
./amrit-local-setup/infra/loaddummydata.sh     # or loaddummydata.bat on Windows
```

## Database schema

All paths use the same schemas (`db_iemr`, `db_identity`, `db_reporting`, `db_1097_identity`). Migrations are managed in **[PSMRI/AMRIT-DB](https://github.com/PSMRI/AMRIT-DB)** — follow its README. The automation path runs migrations automatically on first setup.

## Layout

```text
AMRIT-DevOps/
├── amrit-local-setup/
│   ├── infra/           # Shared Docker Compose (MySQL, Redis, Mongo, Elasticsearch)
│   └── automation/      # One-command per-product setup (ECD, HWC, …)
├── amrit-docker-setup/  # Full containerized stack (NGINX + 14 APIs + 10 UIs)
└── ELK/                 # Elastic Stack for centralized logging + APM
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot connect to the Docker daemon` | Start Docker Desktop; wait for the tray icon to go green. |
| Port busy (3306 / 6379 / 27017 / 9200 / 80) | Stop host service (`brew services stop mysql`, `sudo systemctl stop mysql`, etc.) or find/kill with `lsof -i :<port>`. |
| `'mysql' is not recognized` during data load | Install MySQL **8.0** CLI and add to PATH (not 8.1+, not 5.x). |
| Elasticsearch password unknown | Local default is `piramalES` (`amrit-local-setup/infra/docker-compose.yml`). Server path uses `.env`. |
| `docker-compose: command not found` | Use `docker compose` (v2, with a space). |
| Memory-killed containers | Raise Docker Desktop memory limit; for the full stack, 16 GB+. |

## Support

- Platform docs: https://piramal-swasthya.gitbook.io/amrit/
- Issues: open on the relevant repo under [PSMRI](https://github.com/PSMRI)

## License

See [LICENSE](LICENSE).
