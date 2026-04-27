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

Both require `pandas` and `requests`.
