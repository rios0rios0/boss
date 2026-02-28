# Contributing

Contributions are welcome. By participating, you agree to maintain a respectful and constructive environment.

For coding standards, testing patterns, architecture guidelines, commit conventions, and all
development practices, refer to the **[Development Guide](https://github.com/rios0rios0/guide/wiki)**.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) v2+
- [GNU Make](https://www.gnu.org/software/make/)
- [Python 3](https://www.python.org/downloads/) (for utility scripts)
- WSL2 with `net-tools` installed (if running on Windows)

## Development Workflow

1. Fork and clone the repository
2. Create a branch: `git checkout -b feat/my-change`
3. Start the monitoring stack (Grafana + Prometheus):
   ```bash
   make up-scrap
   ```
4. Run Apache Benchmark stress tests:
   ```bash
   make start-ab
   ```
5. Run Apache JMeter load tests (with OpenAPI-to-JMX conversion):
   ```bash
   make start-aj
   ```
6. Run HTTP/2 load tests with h2load:
   ```bash
   make start-h2
   ```
7. Run the endpoint validation script:
   ```bash
   python3 scripts/test_endpoints.py
   ```
8. Commit following the [commit conventions](https://github.com/rios0rios0/guide/wiki/Life-Cycle/Git-Flow)
9. Open a pull request against `main`
