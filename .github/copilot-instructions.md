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
- Install Python dependencies for result analysis:
  ```bash
  pip3 install pandas
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
  - **WARNING**: Prometheus may fail due to invalid hostnames in config. This is expected.

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
  - **TIMING**: Runs instantly, tests connection to example.com endpoints
  - **NOTE**: Tests will fail with "connection error" for default example URLs - this is expected behavior

#### Result Analysis
- Analyze JMeter CSV results:
  ```bash
  python3 apache-jmeter/result_describer
  ```
  - Edit the script to point to your actual CSV output file
  - Provides throughput and response time statistics

### Manual Validation Scenarios
**CRITICAL**: After building and running any testing configuration, you MUST:

1. **Monitor Stack Validation:**
   - Access Grafana at http://localhost:3000 (should return HTTP 302)
   - Check container status: `docker ps`
   - Verify Grafana container is running (Prometheus may fail due to config issues)

2. **Load Testing Validation:**
   - Verify containers build successfully (may require network access)
   - Check environment variables are properly set
   - Monitor container logs for execution progress: `docker logs <container_name>`

### Known Limitations and Workarounds

- **Docker Compose Legacy Syntax**: Makefile uses `docker-compose` (v1) but system has `docker compose` (v2)
  - **WORKAROUND**: Use `docker compose` commands directly, ignore Makefile targets
  
- **Network Connectivity**: Docker builds may fail in restricted environments
  - **WORKAROUND**: Pre-built images may be available, or run in environment with full internet access
  
- **Prometheus Configuration**: Contains invalid hostnames causing startup failures
  - **EXPECTED**: Prometheus container will exit with error, Grafana will work fine
  
- **WSL Networking**: Requires dynamic IP detection for proper container communication
  - **CRITICAL**: Always export WSL_GATEWAY before running Docker commands

## Common Tasks

### Repository Structure
```
boss/
├── README.md                    # Brief JMeter usage info
├── Makefile                     # Docker Compose shortcuts (legacy syntax)
├── docker-compose.yaml          # Grafana + Prometheus monitoring
├── docker-compose.ab.yaml       # Apache Benchmark testing
├── docker-compose.aj.yaml       # Apache JMeter testing  
├── docker-compose.h2.yaml       # h2load HTTP/2 testing
├── apache-benchmark/            # Apache Benchmark container
├── apache-jmeter/               # JMeter container and configs
├── nghttp2/                     # h2load container
├── grafana/                     # Grafana dashboards and datasources
├── prometheus/                  # Prometheus configuration
└── scripts/                     # Python testing utilities
    └── test_endpoints.py        # Endpoint validation script
```

### Key Configuration Files
- `prometheus/config.yaml`: Prometheus scrape configuration (contains invalid hostnames)
- `grafana/dashboards/`: Grafana dashboard definitions
- `apache-jmeter/result_describer`: Python script for analyzing JMeter CSV results
- `scripts/test_endpoints.py`: Configurable endpoint testing with validation

### Environment Variables for Testing
Modify these in docker-compose files for your target APIs:
- `TARGET_URL`: Base URL for API testing
- `TARGET_RELATIVE_PATH`: API endpoint path  
- `REQUESTS_TOTAL`: Number of requests to send
- `REQUESTS_CONCURRENT`: Concurrent connection count
- `TARGET_API_NAMES`: Comma-separated JMeter test names

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