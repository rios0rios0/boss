# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Codex, Cursor, GitHub Copilot) when working with code in this repository.

## Overview

Boss is a Docker-based performance testing toolkit. It orchestrates load testing with Apache Benchmark, JMeter, and h2load alongside a Prometheus + Grafana monitoring stack. All services run as Docker containers via Compose.

## Build and Run Commands

The compose files map `host.docker.wsl` to `WSL_GATEWAY`. The Makefile sets it itself; export it before calling `docker compose` directly:

```bash
export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
```

Makefile targets (they invoke the v1 `docker-compose` binary; where only Compose v2 is installed, run `docker compose -f <file> up -d` instead):

| Target | Compose File | Purpose |
|---|---|---|
| `up-scrap` | `docker-compose.yaml` | Grafana + Prometheus stack |
| `start-ab` | `docker-compose.ab.yaml` | Apache Benchmark stress test |
| `start-aj` | `docker-compose.aj.yaml` | JMeter load test |
| `start-h2` | `docker-compose.h2.yaml` | h2load HTTP/2 stress test |

## Key Conventions

- Test targets and environment variables are configured per compose file, not via external config. Edit the relevant `docker-compose.*.yaml` to set `TARGET_URL`, `REQUESTS_TOTAL`, etc.
- `prometheus/config.yaml` ships with placeholder targets -- it must be edited before Prometheus will scrape real metrics.
- JMeter's OpenAPI-to-JMX pipeline: the `open-api` service downloads the spec to `apache-jmeter/input/open-api.yaml` and generates `.jmx` plans into `apache-jmeter/output/`. The `jmeter` service runs `apache-jmeter/input/<name>.jmx` for each name in `TARGET_API_NAMES` and writes `output/<name>-test.csv` plus an HTML report in `output/<name>/`, so the plans it runs must be in `input/`.

## Utility Scripts

```bash
python3 scripts/test_endpoints.py         # endpoint validation (edit test_cases in script)
cd apache-jmeter && python3 result_describer  # JMeter CSV analysis; the CSV path in the script is relative to the working directory
```

`test_endpoints.py` requires `requests`; `result_describer` requires `pandas`.

<!-- chlog:start -->
## Changelog (chlog) — MANDATORY

If the repository you are working in uses chlog (a `.chlog.yaml` or `.chlog.yml`
config file, or a `.changes/` directory, exists at the project root), the
following is binding and ALWAYS applies: whenever you make ANY change, you MUST
create a changelog fragment as part of the same change — automatically, without
being asked, before committing.

- Do NOT edit CHANGELOG.md directly; it is generated from fragments.
- Create the fragment with:
  `chlog new --kind <Kind> --body '<past-tense description>'`
- Write an apostrophe inside the single-quoted body as `'\''`.
- Valid kinds: Added, Changed, Deprecated, Removed, Fixed, Security
- Choose the kind that best matches the change (e.g., new feature → Added,
  bug fix → Fixed, behavior change → Changed, removal → Removed, security fix → Security).
- If the change is backward-INCOMPATIBLE with the public API (a breaking
  change), you MUST add the `--breaking` flag:
  `chlog new --kind <Kind> --breaking --body '<past-tense description>'`.
  This is the ONLY thing that triggers a major version bump — the kind alone
  never does (per SemVer, major = incompatible change). When unsure whether a
  change breaks compatibility, ask the user instead of guessing.
- Fragments are YAML files in `.changes/unreleased/`; stage them with your commit.
- `chlog check` fails the build when a fragment is missing — never skip it.
<!-- chlog:end -->
