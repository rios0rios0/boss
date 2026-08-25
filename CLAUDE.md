# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Boss is a Docker-based performance testing toolkit. It orchestrates load testing with Apache Benchmark, JMeter, and h2load alongside a Prometheus + Grafana monitoring stack. All services run as Docker containers via Compose.

## Build and Run Commands

Every docker-compose command requires `WSL_GATEWAY` to be set first:

```bash
export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
```

Makefile targets (use `docker-compose` v1 syntax internally):

| Target | Compose File | Purpose |
|---|---|---|
| `up-scrap` | `docker-compose.yaml` | Grafana + Prometheus stack |
| `start-ab` | `docker-compose.ab.yaml` | Apache Benchmark stress test |
| `start-aj` | `docker-compose.aj.yaml` | JMeter load test |
| `start-h2` | `docker-compose.h2.yaml` | h2load HTTP/2 stress test |

Alternatively, use `docker compose` (v2) directly:

```bash
docker compose -f docker-compose.yaml up -d
```

## Key Conventions

- The Makefile uses `docker-compose` (v1). Systems with only v2 should call `docker compose` directly.
- Test targets and environment variables are configured per compose file, not via external config. Edit the relevant `docker-compose.*.yaml` to set `TARGET_URL`, `REQUESTS_TOTAL`, etc.
- `prometheus/config.yaml` ships with placeholder targets -- it must be edited before Prometheus will scrape real metrics.
- JMeter's OpenAPI-to-JMX pipeline: the `open-api` service downloads an OpenAPI spec and converts it to `.jmx` files in `apache-jmeter/input/`, then the `jmeter` service executes them and writes results to `apache-jmeter/output/`.

## Utility Scripts

```bash
python3 scripts/test_endpoints.py         # endpoint validation (edit test_cases in script)
python3 apache-jmeter/result_describer    # JMeter CSV result analysis (edit CSV path in script)
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
  `chlog new --kind <Kind> --body "<imperative description>"`
- Valid kinds: Added, Changed, Deprecated, Removed, Fixed, Security
- Choose the kind that best matches the change (e.g., new feature → Added,
  bug fix → Fixed, behavior change → Changed, removal → Removed, security fix → Security).
- If the change is backward-INCOMPATIBLE with the public API (a breaking
  change), you MUST add the `--breaking` flag:
  `chlog new --kind <Kind> --breaking --body "<description>"`.
  This is the ONLY thing that triggers a major version bump — the kind alone
  never does (per SemVer, major = incompatible change). When unsure whether a
  change breaks compatibility, ask the user instead of guessing.
- Fragments are YAML files in `.changes/unreleased/`; stage them with your commit.
- `chlog check` fails the build when a fragment is missing — never skip it.
<!-- chlog:end -->
