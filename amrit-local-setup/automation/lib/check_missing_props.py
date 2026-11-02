#!/usr/bin/env python3
"""Report keys present in <example> but missing from <local>. Read-only.

Prints the missing keys as a comma-separated list to stdout (nothing if none).
Writes no files: developers own their local config values. This only surfaces
drift so a stale local file doesn't fail at runtime with an opaque
"Could not resolve placeholder ..." once the example template gains a new key.

Usage: check_missing_props.py <example.properties> <local.properties>
"""
import sys


def parse_keys(path):
    keys = set()
    with open(path, errors="replace") as fh:
        for line in fh:
            s = line.strip()
            if not s or s.startswith("#") or s.startswith("!") or "=" not in s:
                continue
            key = s.split("=", 1)[0].strip()
            if key:
                keys.add(key)
    return keys


def main(example, local):
    missing = [k for k in parse_keys(example) if k not in parse_keys(local)]
    if missing:
        print(", ".join(sorted(missing)))
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(2)
    sys.exit(main(sys.argv[1], sys.argv[2]))
