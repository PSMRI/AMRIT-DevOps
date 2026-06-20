#!/usr/bin/env python3
"""Ensure an Angular project has a `local` build+serve configuration that uses
src/environments/environment.local.ts. Idempotent. Usage:

    ensure_local_ng_config.py <path-to-angular.json>

Bare `ng serve` uses the repo's default (development) configuration, which
file-replaces environment.ts with environment.development.ts (the remote dev
server). AMRIT's local setup copies environment.local.ts -> environment.ts, but
that file is ignored under the development config. Adding a `local` config and
serving with `--configuration=local` makes the app use environment.local.ts.
"""
import json
import sys

LOCAL_ENV = "src/environments/environment.local.ts"
BASE_ENV = "src/environments/environment.ts"


def arch(proj):
    # Angular 13+ uses "architect"; some configs use "targets".
    return proj.get("architect") or proj.get("targets") or {}


def main(path):
    with open(path) as fh:
        cfg = json.load(fh)

    changed = False
    for proj_name, proj in cfg.get("projects", {}).items():
        targets = arch(proj)
        build = targets.get("build")
        serve = targets.get("serve")
        if not build or not serve:
            continue

        # 1) build:local — file-replace environment.ts -> environment.local.ts
        build.setdefault("configurations", {})
        if "local" not in build["configurations"]:
            build["configurations"]["local"] = {
                "fileReplacements": [
                    {"replace": BASE_ENV, "with": LOCAL_ENV}
                ],
                "optimization": False,
                "sourceMap": True,
            }
            changed = True

        # 2) serve:local — clone the development serve config, point it at
        #    build:local (handles both buildTarget and legacy browserTarget).
        serve.setdefault("configurations", {})
        if "local" not in serve["configurations"]:
            dev = serve["configurations"].get("development", {})
            local = dict(dev)
            for key in ("buildTarget", "browserTarget"):
                if key in local and isinstance(local[key], str):
                    base = local[key].rsplit(":", 1)[0]
                    local[key] = f"{base}:local"
            if not any(k in local for k in ("buildTarget", "browserTarget")):
                local["buildTarget"] = f"{proj_name}:build:local"
            serve["configurations"]["local"] = local
            changed = True

    if changed:
        with open(path, "w") as fh:
            json.dump(cfg, fh, indent=2)
        print(f"injected `local` configuration into {path}")
    else:
        print(f"`local` configuration already present in {path}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1]))
