# AMRIT — Automated local setup

One entry point for every local dev workflow. Run a single product, a combination, or the entire AMRIT platform in tmux. Start here → [root README](../../README.md).

```bash
bash amrit-local-setup/automation/start.sh           # interactive wizard
bash amrit-local-setup/automation/start.sh --help    # flag-driven options
```

Under the hood, `start.sh`:
1. Runs a preflight check (Docker up; Java/Maven/Node/tmux/git/lsof on PATH; bash ≥ 4; gum present for the wizard).
2. Brings up shared infra from [`../infra/docker-compose.yml`](../infra/docker-compose.yml) and waits for health checks.
3. Runs [AMRIT-DB](https://github.com/PSMRI/AMRIT-DB) Flyway migrations and loads master data (first run only; guarded by `~/.amrit/.db_migrated` and `~/.amrit/.data_loaded`).
4. Clones every API and UI required by the selected product(s) next to `AMRIT-DevOps/` and seeds their `*_local.properties` / `environment.ts`.
5. Launches each service in its own tmux window inside one session (`amrit-<product>`, `amrit-multi`, or `amrit-all`).

## Products

Every product implicitly includes the three shared anchors: **Common-API**, **Identity-API**, and **BeneficiaryID-Generation-API**. They start first so downstream APIs find them built.

| Key     | Description                        | Product-specific APIs (on top of anchors)      | UIs launched                           |
|---------|------------------------------------|-------------------------------------------------|----------------------------------------|
| `ecd`   | Early Childhood Development        | ECD                                             | ECD-UI (`:4209`)                       |
| `hwc`   | Health & Wellness Centers          | HWC + Scheduler + Inventory + MMU               | HWC (`:4204`), HWC-Scheduler, HWC-Inventory |
| `mmu`   | Mobile Medical Unit                | MMU + Scheduler                                 | MMU-UI (`:4202`)                       |
| `tm`    | Telemedicine                       | TM + Scheduler                                  | TM-UI (`:4203`)                        |
| `hl104` | Helpline 104                       | Helpline104                                     | Helpline104-UI (`:4210`)               |
| `hl1097`| Helpline 1097                      | Helpline1097 + FHIR + ECD                       | Helpline1097-UI (`:4211`)              |
| `all`   | Entire platform (14 APIs, 11 UIs)  | every API in the registry, anchors first        | every UI in the registry               |

API ports follow `8081-8095`; UI ports `4201-4211`. Common-API is `:8083`, Identity-API is `:8094`.

## Flag mode (CI / repeat runs)

```bash
bash start.sh --product=ecd
bash start.sh --products=ecd,hwc --skip-db --skip-data
bash start.sh --all --force                     # 24 GB RAM check; --force bypasses
bash start.sh --product=ecd --reset-all         # re-run DB migrations + data load
bash start.sh --reset-db                        # clear sentinel and exit
```

Non-interactive stdin (CI) without flags fails fast with usage help — no silent defaults.

## Wizard mode

With no flags and a TTY, `start.sh` launches a [`gum`](https://github.com/charmbracelet/gum)-driven prompt that walks through:
1. Choose action (single product / multi / full platform / infra-only / reset / quit)
2. Pick product(s)
3. Confirm one-time steps (infra / migrations / master data) — sentinels pre-select skips
4. Review summary and confirm

## tmux cheatsheet

| Keys / command                   | What                                                             |
|----------------------------------|------------------------------------------------------------------|
| `tmux attach -t amrit-ecd`       | Attach to the session (swap `amrit-ecd` for your session name)   |
| `Ctrl+b n` / `Ctrl+b p`          | Next / previous window                                           |
| `Ctrl+b <number>`                | Jump to window N                                                 |
| `Ctrl+b d`                       | Detach (services keep running)                                   |
| `tmux kill-session -t amrit-ecd` | Stop every service in the session                                |

## Adding a new product

Everything is manifest-driven. To add `flw`, for example:

1. Extend `lib/products.conf`:
   ```bash
   PRODUCT_APIS[flw]="Common-API Identity-API FLW-API"
   PRODUCT_UIS[flw]=""                               # mobile-only; no web UI
   PRODUCT_DESC[flw]="Field-Level Workers"
   PRODUCT_ORDER+=(flw)
   ```
2. Confirm the API's repo, port, and properties filenames are in `lib/services.conf` (FLW-API already is).
3. Done — `bash start.sh --product=flw` and the wizard both pick it up.

If the API or UI itself is new (not already in `services.conf`), add one row each to `API_REPO` / `API_PORT` / `API_PROPS` or `UI_REPO` / `UI_PORT` / `UI_ENV`.

## After setup

Edit API keys / external service endpoints in the generated `*_local.properties` and `environment.ts` files that `start.sh` seeded, e.g. `ECD-API/src/main/environment/ecd_local.properties`, then restart the relevant tmux window (`Ctrl+b <n>`, then re-run the displayed command).

## Layout

```
automation/
├── start.sh                       single entry point
├── README.md
└── lib/
    ├── services.conf              per-API / per-UI registry (repo, port, props)
    ├── products.conf              product → APIs/UIs manifest
    ├── common.sh                  logging, clone/setup, infra, DB, tmux, preflight, ensure_gum
    ├── launchers.sh               manifest-driven setup/start, port + memory checks
    ├── engine.sh                  flag parser + run_selection orchestrator
    └── wizard.sh                  gum-driven interactive flow
```

Troubleshooting → see [root README](../../README.md#troubleshooting).
