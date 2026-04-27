# Boss - Performance Testing and Monitoring Toolkit

Boss is a comprehensive performance testing and monitoring toolkit that uses Docker containers to provide Apache Benchmark, Apache JMeter, nghttp2/h2load testing capabilities along with Grafana and Prometheus for monitoring and visualization.

**Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites and Environment Setup
- **CRITICAL**: Always set the WSL_GATEWAY environment variable before running any Docker commands:
  ```bash
  export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
  ```
- Verify Docker and Docker Compose v2 are installed:
  ```bash
  docker --version
  docker compose version
  ```
- Install Python dependencies for result analysis and endpoint testing:
  ```bash
  pip3 install pandas requests
  ```
- **NOTE**: Repository uses legacy `docker-compose` syntax in Makefile. Use `docker compose` (v2) command directly instead.

### Core Build and Setup Commands
- **Basic monitoring stack (Grafana + Prometheus):**
  ```bash
  export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
  docker compose -f docker-compose.yaml up -d
  ```
  - **TIMING**: Takes 2-3 minutes for initial pull. NEVER CANCEL. Set timeout to 300+ seconds.
  - Grafana accessible at http://localhost:3000
  - Prometheus accessible at http://localhost:9090
  - **WARNING**: Prometheus may start but scrape targets will fail until `prometheus/config.yaml` is updated with real targets.

- **Apache Benchmark testing:**
  ```bash
  export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
  docker compose -f docker-compose.ab.yaml up
  ```
  - **TIMING**: Build takes 5-10 minutes on first run. NEVER CANCEL. Set timeout to 600+ seconds.
  - **WARNING**: May fail in environments with restricted network access.

- **Apache JMeter testing:**
  ```bash
  export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
  docker compose -f docker-compose.aj.yaml up
  ```
  - **TIMING**: Build and execution takes 10-15 minutes. NEVER CANCEL. Set timeout to 900+ seconds.

- **h2load (HTTP/2) testing:**
  ```bash
  export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
  docker compose -f docker-compose.h2.yaml up
  ```

### Testing and Validation

#### Endpoint Testing Script
- Test API endpoints with the Python script:
  ```bash
  python3 scripts/test_endpoints.py
  ```
  - **TIMING**: Runs instantly; by default tests example.com placeholder endpoints
  - **NOTE**: Tests will fail with "connection error" for default example URLs — this is expected behavior; edit the `test_cases` list in the script to point at real endpoints
  - Supports three validation modes: `VALID_JSON`, `JSON_FIELD`, `REGEX`

#### Result Analysis
- Analyze JMeter CSV results:
  ```bash
  python3 apache-jmeter/result_describer
  ```
  - Edit the CSV filename inside the script (`output/your csv`) before running
  - JMeter output CSVs are written to `apache-jmeter/output/`
  - Provides: total executions, throughput (req/s), and min/max/average response times (ms)

### Manual Validation Scenarios
**CRITICAL**: After building and running any testing configuration, you MUST:

1. **Monitor Stack Validation:**
   - Access Grafana at http://localhost:3000 (should return HTTP 302)
   - Check container status: `docker ps`
   - Verify Grafana container is running (Prometheus scrape targets will fail until real targets are configured)

2. **Load Testing Validation:**
   - Verify containers build successfully (may require network access)
   - Check environment variables are properly set
   - Monitor container logs for execution progress: `docker logs <container_name>`

### Known Limitations and Workarounds

- **Docker Compose Legacy Syntax**: Makefile uses `docker-compose` (v1) but system has `docker compose` (v2)
  - **WORKAROUND**: Use `docker compose` commands directly, ignore Makefile targets
  
- **Network Connectivity**: Docker builds may fail in restricted environments
  - **WORKAROUND**: Pre-built images may be available, or run in environment with full internet access
  
- **Prometheus Configuration**: Contains placeholder hostnames (`your-api1.com`, `your-api2.com`) causing scrape failures on startup
  - **EXPECTED**: Prometheus container will start but metrics scraping will fail until `prometheus/config.yaml` is updated with real targets; Grafana UI will still work
  
- **WSL Networking**: Requires dynamic IP detection for proper container communication
  - **CRITICAL**: Always export WSL_GATEWAY before running Docker commands

- **No CI/CD Workflows**: The `.github/workflows/` directory contains only a `.gitkeep` placeholder — no automated pipelines are configured yet
  - **NOTE**: All validation must be done manually as described in the sections above

## Common Tasks

### Repository Structure
```
boss/
├── README.md                    # Comprehensive documentation
├── Makefile                     # Docker Compose shortcuts (uses legacy docker-compose v1 syntax)
├── docker-compose.yaml          # Grafana + Prometheus monitoring
├── docker-compose.ab.yaml       # Apache Benchmark testing
├── docker-compose.aj.yaml       # Apache JMeter testing  
├── docker-compose.h2.yaml       # h2load HTTP/2 testing
├── apache-benchmark/            # Apache Benchmark container (Alpine 3.16.9)
│   ├── Dockerfile
│   └── entrypoint.sh
├── apache-jmeter/               # JMeter container and configs
│   ├── input/                   # JMX test plan inputs (populated by open-api service)
│   ├── output/                  # Test results: CSV files + HTML reports
│   ├── jmeter.Dockerfile        # JMeter 5.5 on Amazon Corretto 17
│   ├── jmeter.entrypoint.sh
│   ├── open-api.Dockerfile      # OpenAPI-to-JMX converter (openapi-generator-cli v6.0.1)
│   ├── open-api.entrypoint.sh
│   └── result_describer         # Python CSV analyzer script
├── nghttp2/                     # h2load container (Alpine 3.16.9)
│   ├── Dockerfile
│   └── entrypoint.sh
├── grafana/
│   ├── dashboards/              # Provisioned dashboards: JVM (Micrometer), Spring Boot 2.1 System Monitor
│   └── data-sources/            # Prometheus data source config
├── prometheus/
│   └── config.yaml              # Prometheus scrape configuration
└── scripts/
    └── test_endpoints.py        # Endpoint validation script (requires: pandas, requests)
```

### Key Configuration Files
- `prometheus/config.yaml`: Prometheus scrape configuration (placeholder targets — update with real API hostnames)
- `grafana/dashboards/`: Grafana dashboard JSON files (JVM Micrometer, Spring Boot 2.1 System Monitor)
- `grafana/data-sources/datasource.yaml`: Prometheus data source configuration
- `apache-jmeter/result_describer`: Python CSV analyzer (edit the filename inside the script before running)
- `scripts/test_endpoints.py`: Configurable endpoint testing with `VALID_JSON`, `JSON_FIELD`, and `REGEX` validation modes

### Environment Variables for Testing
Modify these in docker-compose files for your target APIs:
- `WSL_GATEWAY`: WSL2 host gateway IP (auto-detected by Makefile)
- `TARGET_URL`: Base URL for API testing (ab, h2load)
- `TARGET_RELATIVE_PATH`: API endpoint path (ab, h2load)
- `REQUESTS_HEADER`: Custom HTTP header for requests (ab, h2load)
- `REQUESTS_TOTAL`: Number of requests to send (ab, h2load)
- `REQUESTS_CONCURRENT`: Concurrent connection count (ab, h2load)
- `SOCKET_TIMEOUT_SECONDS`: Socket timeout in seconds (ab only)
- `TARGET_DOCS_URL`: URL to the OpenAPI spec to download and convert (JMeter open-api service)
- `INPUT_FOLDER`: Container path for JMX input files (JMeter services)
- `OUTPUT_FOLDER`: Container path for test results (JMeter services)
- `TARGET_API_NAMES`: Comma-separated JMeter test names to execute

### Cleanup Commands
- Stop and remove all containers:
  ```bash
  docker compose -f docker-compose.yaml down
  docker compose -f docker-compose.ab.yaml down  
  docker compose -f docker-compose.aj.yaml down
  docker compose -f docker-compose.h2.yaml down
  ```

## Timing Expectations
- **Docker image pulls**: 2-5 minutes per compose file
- **Container builds**: 5-15 minutes (may fail due to network restrictions)
- **Load test execution**: Varies based on configuration (seconds to hours)
- **Result analysis**: Instant for Python scripts

**CRITICAL TIMING NOTES:**
- **NEVER CANCEL** builds or long-running commands
- Set timeouts to 600+ seconds for builds, 900+ seconds for full test runs
- Network-dependent operations may take significantly longer in restricted environments