# AMRIT Applications — Local Setup Automation

This directory contains automation scripts for setting up and running AMRIT product applications in a local development environment. Each product folder contains a `start.sh` script that handles the full setup — from infrastructure and database migrations to service startup — in a single command.

## Overview

Each product script follows the same sequence:

1. **Common platform bootstrap** — `Common-Platform/start.sh` runs first, blocking until complete:
   - Starts Docker infrastructure (MySQL, Redis, MongoDB, Elasticsearch) and waits for all containers to be healthy
   - Runs database schema migrations via AMRIT-DB and Flyway (one-time)
   - Loads master/dummy data (one-time)
2. **Product repository setup** — Clones product API and UI repositories, initializes submodules, and installs npm dependencies.
3. **Service startup** — Launches Common-API, product API, and product UI in a tmux session.

### What is automated

| Task | Method |
|------|--------|
| Starting infrastructure (MySQL, Redis, MongoDB, Elasticsearch) | Docker Compose |
| Health checks for infrastructure readiness | Script-based polling |
| Database schema migrations | AMRIT-DB + Flyway (one-time, sentinel-guarded) |
| Loading master/dummy data | `loaddummydata.sh` (one-time, sentinel-guarded) |
| Cloning API and UI repositories | git clone |
| Copying example config files to local properties | Bash |
| Installing npm dependencies | npm install |
| Maven build and Spring Boot startup | mvn spring-boot:run |
| Angular dev server startup | ng serve |

### What requires manual steps

After cloning, edit the generated local properties files with API keys and external service endpoints (SMS, email, video consultation, etc.). Database credentials do not need editing for the default Docker setup.

---

## Prerequisites

- **Docker Engine** 20.10+ and **Docker Compose** 2.0+
- **Java** (OpenJDK 17+)
- **Maven** 3.6+
- **Node.js** 16+ and **npm**
- **Angular CLI** (`npm install -g @angular/cli`)
- **tmux**
- **Git**
- **wget**, **unzip**, and **mysql** CLI (used by the master data loader)

---

## Architecture

```
bash Applications/ECD/start.sh  (or HWC/start.sh)
│
└── Common-Platform/start.sh          blocking — runs to completion in main process
    ├── setup_common_api()             clone Common-API + copy properties
    ├── setup_common_ui()              clone Common-UI
    ├── start_infrastructure()         docker compose up + wait for health checks
    ├── run_db_migrations()            [ONE-TIME] clone AMRIT-DB → Flyway migrations
    └── load_master_data()             [ONE-TIME] download + load master SQL files
        │
        └── returns to product start.sh
            ├── setup_[product]_api()  clone product API + copy properties
            ├── setup_[product]_ui()   clone product UI + submodules + npm install
            │
            └── tmux session: amrit-[product]
                ├── window 0: common-api      mvn spring-boot:run
                ├── window 1: [product]-api   mvn spring-boot:run
                └── window 2: [product]-ui    ng serve
```

---

## One-time steps and sentinel files

Database migrations and master data loading run only once. After each step completes, a sentinel file is written to `~/.amrit/`. Subsequent runs skip the step automatically.

| Sentinel file | Guards |
|---------------|--------|
| `~/.amrit/.db_migrated` | AMRIT-DB Flyway migrations |
| `~/.amrit/.data_loaded` | Master/dummy data loading |

To force a re-run, pass a reset flag:

```bash
bash start.sh --reset-db      # re-run migrations only
bash start.sh --reset-data    # re-load master data only
bash start.sh --reset-all     # re-run both
```

---

## Folder Structure

```
Applications/
├── Common-Platform/        # Shared library and bootstrap script
│   ├── lib.sh              # Shared bash functions (logging, Docker, DB migration, git, tmux)
│   └── start.sh            # Bootstrap: infra + migrations + data loading
├── ECD/
│   └── start.sh            # Sets up and starts the ECD product
├── HWC/
│   └── start.sh            # Sets up and starts the HWC product
├── MMU/                    # Placeholder (not yet implemented)
├── TM/                     # Placeholder (not yet implemented)
├── HelpLine104/            # Placeholder (not yet implemented)
└── HelpLine1097/           # Placeholder (not yet implemented)
```

---

## Setting Up ECD (Electronic Clinical Decision Support)

### Step 1 — Run the setup script

```bash
cd Applications/ECD
bash start.sh
```

### Step 2 — Edit configuration files

Update the generated properties file with API keys and external service endpoints:

```
ECD-API/src/main/environment/ecd_local.properties
```

### Step 3 — Attach to the tmux session

```bash
tmux attach -t amrit-ecd
```

| Key | Window |
|-----|--------|
| `Ctrl+b 0` | common-api |
| `Ctrl+b 1` | ecd-api |
| `Ctrl+b 2` | ecd-ui |

### Step 4 — Access the application

| Service | URL |
|---------|-----|
| ECD UI | http://localhost:4209 |
| ECD API | http://localhost:8084 |
| Common API | http://localhost:8083 |

---

## Setting Up HWC (Health and Wellness Center)

### Step 1 — Run the setup script

```bash
cd Applications/HWC
bash start.sh
```

### Step 2 — Edit configuration files

Update the generated properties file with API keys and external service endpoints:

```
HWC-API/src/main/environment/hwc_local.properties
```

### Step 3 — Attach to the tmux session

```bash
tmux attach -t amrit-hwc
```

| Key | Window |
|-----|--------|
| `Ctrl+b 0` | common-api |
| `Ctrl+b 1` | hwc-api |
| `Ctrl+b 2` | hwc-ui |

### Step 4 — Access the application

| Service | URL |
|---------|-----|
| HWC UI | http://localhost:4204 |
| HWC API | http://localhost:8085 |
| Common API | http://localhost:8083 |

---

## Useful tmux Commands

| Command | Description |
|---------|-------------|
| `tmux attach -t amrit-ecd` | Attach to the ECD session |
| `tmux attach -t amrit-hwc` | Attach to the HWC session |
| `tmux ls` | List all active sessions |
| `Ctrl+b d` | Detach (keeps services running) |
| `Ctrl+b [` | Scroll mode — `q` to exit |
| `tmux kill-session -t amrit-ecd` | Stop ECD services |
| `tmux kill-session -t amrit-hwc` | Stop HWC services |

---

## Troubleshooting

**Infrastructure containers not starting**
Run `docker ps` and `docker logs <container-name>`. Ensure ports 3306, 6379, 27017, and 9200 are free.

**DB migrations fail**
Verify infrastructure is healthy (`docker ps`). If AMRIT-DB was partially cloned, delete it and re-run. Use `--reset-db` to retry.

**Master data loading fails**
Ensure `wget`, `unzip`, and `mysql` are in `PATH`. Setup continues without master data — some dropdowns may be empty. Use `--reset-data` to retry.

**Maven build failures**
Run `mvn -version` and `java -version` to confirm Java 17+ and Maven 3.6+. Check that the local properties file has valid credentials.

**npm install fails**
Run `node -v` and `npm -v` to confirm Node.js 16+. For submodule failures, run `git submodule update --init --recursive` inside the UI repository manually.

**UI port already in use**
ECD UI uses port 4209, HWC UI uses port 4204. Kill the conflicting process with `fuser -k <port>/tcp` or stop the other tmux session first.
