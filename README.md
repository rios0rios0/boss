# Boss

> Because just like a real boss, it puts your APIs under stress.

Docker-based performance testing toolkit that orchestrates load testing with Apache Benchmark, JMeter, and h2load alongside a Prometheus + Grafana monitoring stack. Includes OpenAPI-to-JMX conversion, Python-powered result analysis, and WSL2-aware networking for seamless local development.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [Monitoring Stack (Grafana + Prometheus)](#monitoring-stack-grafana--prometheus)
  - [Apache Benchmark](#apache-benchmark)
  - [Apache JMeter](#apache-jmeter)
  - [HTTP/2 Load Testing (h2load)](#http2-load-testing-h2load)
- [Utility Scripts](#utility-scripts)
  - [Endpoint Tester](#endpoint-tester)
  - [JMeter Result Analyzer](#jmeter-result-analyzer)
  - [JMeter CSV to HTML Report](#jmeter-csv-to-html-report)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
  - [Prometheus Targets](#prometheus-targets)
  - [Grafana Dashboards](#grafana-dashboards)
- [Project Structure](#project-structure)
- [License](#license)

## Features

- **Multi-tool load testing** — run stress tests with Apache Benchmark, Apache JMeter, or h2load, each in isolated Docker containers
- **OpenAPI to JMX conversion** — automatically convert OpenAPI specs into JMeter test plans
- **Monitoring stack** — pre-configured Grafana dashboards and Prometheus scraping for real-time performance metrics
- **WSL2-aware networking** — auto-detects the WSL gateway IP so containers can reach services on the host
- **Result analysis** — Python scripts for CSV-based throughput/response-time analysis and endpoint validation

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Boss Toolkit                         │
├──────────────┬──────────────┬──────────────┬────────────────┤
│   Apache     │   Apache     │   h2load     │  Monitoring    │
│   Benchmark  │   JMeter     │  (HTTP/2)    │  Stack         │
│              │              │              │                │
│  ab stress   │  OpenAPI →   │  nghttp2     │  Prometheus    │
│  testing     │  JMX → run   │  stress test │  + Grafana     │
├──────────────┴──────────────┴──────────────┴────────────────┤
│                     Docker Compose                          │
├─────────────────────────────────────────────────────────────┤
│              WSL2 Host Network (auto-detected)              │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) (v2+)
- WSL2 (if running on Windows) with `ifconfig` available (`net-tools` package)
- Python 3 with `pandas` and `requests` (only for the utility scripts)

## Getting Started

All Compose files rely on the `WSL_GATEWAY` environment variable so containers can reach services running on the host. The Makefile sets this automatically, but you can also export it manually:

```bash
export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
```

### Monitoring Stack (Grafana + Prometheus)

Start the monitoring stack to collect metrics and visualize them in Grafana:

```bash
make up-scrap
```

Or directly with Compose:

```bash
docker compose -f docker-compose.yaml up -d
```

| Service    | URL                    |
|------------|------------------------|
| Grafana    | http://localhost:3000  |
| Prometheus | http://localhost:9090  |

Edit `prometheus/config.yaml` to point at your API targets before starting.

### Apache Benchmark

Run HTTP/1.1 stress tests with [Apache Benchmark](https://httpd.apache.org/docs/2.4/programs/ab.html):

```bash
make start-ab
```

Configure the test by editing environment variables in `docker-compose.ab.yaml`:

```yaml
environment:
  TARGET_URL: "http://host.docker.wsl:8080"
  TARGET_RELATIVE_PATH: "/api/path/to/it"
  REQUESTS_HEADER: "Authorization: Bearer token"
  REQUESTS_TOTAL: 100000
  REQUESTS_CONCURRENT: 100
  SOCKET_TIMEOUT_SECONDS: 300
```

### Apache JMeter

Run JMeter-based load tests with automatic OpenAPI-to-JMX conversion:

```bash
make start-aj
```

This spins up two services:

1. **open-api** — downloads your OpenAPI spec and converts it to `.jmx` test plans
2. **jmeter** — executes the generated test plans and outputs results

Configure in `docker-compose.aj.yaml`:

```yaml
# open-api service
TARGET_DOCS_URL: "http://host.docker.wsl:8080/docs.yaml"

# jmeter service
TARGET_API_NAMES: "Api1,Api2,Api3"
```

- Input files (`.jmx`) go in `apache-jmeter/input/`
- Results (CSV + HTML reports) appear in `apache-jmeter/output/`

### HTTP/2 Load Testing (h2load)

Run HTTP/2 stress tests with [h2load](https://nghttp2.org/documentation/h2load-howto.html):

```bash
make start-h2
```

Configure in `docker-compose.h2.yaml`:

```yaml
environment:
  TARGET_URL: "http://host.docker.wsl:8080"
  TARGET_RELATIVE_PATH: "/api/path/to/it"
  REQUESTS_HEADER: "any-header: any-value"
  REQUESTS_TOTAL: 100000
  REQUESTS_CONCURRENT: 100
```

## Utility Scripts

### Endpoint Tester

Validate a list of API endpoints with expected status codes and response patterns:

```bash
python3 scripts/test_endpoints.py
```

Supports three validation modes:

| Mode         | Description                                        |
|--------------|----------------------------------------------------|
| `VALID_JSON` | Asserts the response body is valid JSON            |
| `JSON_FIELD` | Asserts specific key-value pairs exist in the JSON |
| `REGEX`      | Matches the response body against a regex pattern  |

Edit the `test_cases` list in the script to define your own tests.

### JMeter Result Analyzer

Analyze JMeter CSV output for throughput and response time statistics:

```bash
python3 apache-jmeter/result_describer
```

Edit the script to point to your CSV file. It outputs:

- Total executions
- Throughput (requests/second)
- Min / Max / Average response time (ms)

### JMeter CSV to HTML Report

Convert a JMeter CSV result file into a full HTML report:

```bash
jmeter -g <csv_path> -e -o <output_path>
```

## Configuration

### Environment Variables

| Variable                 | Used By           | Description                               |
|--------------------------|-------------------|-------------------------------------------|
| `WSL_GATEWAY`            | All               | WSL2 host gateway IP (auto-detected)      |
| `TARGET_URL`             | ab, h2load        | Base URL of the target API                |
| `TARGET_RELATIVE_PATH`   | ab, h2load        | API endpoint path to test                 |
| `REQUESTS_HEADER`        | ab, h2load        | Custom HTTP header for requests           |
| `REQUESTS_TOTAL`         | ab, h2load        | Total number of requests to send          |
| `REQUESTS_CONCURRENT`    | ab, h2load        | Number of concurrent connections          |
| `SOCKET_TIMEOUT_SECONDS` | ab                | Socket timeout in seconds                 |
| `TARGET_DOCS_URL`        | JMeter (open-api) | URL to the OpenAPI specification          |
| `TARGET_API_NAMES`       | JMeter            | Comma-separated list of API names to test |

### Prometheus Targets

Edit `prometheus/config.yaml` to add your scrape targets:

```yaml
scrape_configs:
  - job_name: 'api'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['your-api.com']
        labels:
          application: 'your-api'
```

### Grafana Dashboards

Two dashboards are pre-provisioned:

| Dashboard                          | Use Case                                  |
|------------------------------------|-------------------------------------------|
| JVM (Micrometer)                   | JVM heap, threads, GC, and class metrics  |
| Spring Boot 2.1 System Monitor     | HTTP requests, error rates, system stats  |

Custom dashboards can be added as JSON files in `grafana/dashboards/`.

## Project Structure

```
boss/
├── apache-benchmark/          # Apache Benchmark Docker setup
│   ├── Dockerfile
│   └── entrypoint.sh
├── apache-jmeter/             # Apache JMeter Docker setup
│   ├── input/                 # JMX test plan inputs
│   ├── output/                # Test results and reports
│   ├── jmeter.Dockerfile
│   ├── jmeter.entrypoint.sh
│   ├── open-api.Dockerfile    # OpenAPI-to-JMX converter
│   ├── open-api.entrypoint.sh
│   └── result_describer       # Python CSV analyzer
├── grafana/
│   ├── dashboards/            # Provisioned Grafana dashboards
│   └── data-sources/          # Prometheus data source config
├── nghttp2/                   # h2load Docker setup
│   ├── Dockerfile
│   └── entrypoint.sh
├── prometheus/
│   └── config.yaml            # Prometheus scrape configuration
├── scripts/
│   └── test_endpoints.py      # Endpoint validation script
├── docker-compose.yaml        # Monitoring stack (Grafana + Prometheus)
├── docker-compose.ab.yaml     # Apache Benchmark
├── docker-compose.aj.yaml     # Apache JMeter
├── docker-compose.h2.yaml     # h2load (HTTP/2)
└── Makefile                   # Convenience commands
```

## License

This project is licensed under the [MIT License](LICENSE).
