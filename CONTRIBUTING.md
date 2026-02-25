# Contributing

Contributions are welcome. By participating, you agree to maintain a respectful and constructive environment.

For coding standards, testing patterns, architecture guidelines, commit conventions, and all
development practices, refer to the **[Development Guide](https://github.com/rios0rios0/guide/wiki)**.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) v2+
- [Make](https://www.gnu.org/software/make/)
- [Python 3](https://www.python.org/) with `pandas` and `requests` (only for utility scripts)
- WSL2 with `net-tools` package (if running on Windows)

## Development Workflow

1. Fork and clone the repository
2. Create a branch: `git checkout -b feat/my-change`
3. Set the WSL gateway (auto-detected by the Makefile):
   ```bash
   export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')
   ```
4. Make your changes
5. Test with the relevant tool:
   ```bash
   make up-scrap     # monitoring stack (Grafana + Prometheus)
   make start-ab     # Apache Benchmark
   make start-aj     # Apache JMeter
   ```
6. Update `CHANGELOG.md` under `[Unreleased]`
7. Commit following the [commit conventions](https://github.com/rios0rios0/guide/wiki/Life-Cycle/Git-Flow)
8. Open a pull request against `main`
