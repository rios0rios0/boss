# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

When a new release is proposed:

1. Create a new branch `bump-version-x.x.x` (this isn't a long-lived branch!!!);
2. The Unreleased section on `CHANGELOG.md` gets a version number and date;
3. Open a Pull Request with the bump version changes targeting the `main` branch;
4. When the Pull Request is merged, a new git tag must be created using [GitHub environment](https://github.com/rios0rios0/boss/tags).

Releases to productive environments should run from a tagged version.
Exceptions are acceptable depending on the circumstances (critical bug fixes that can be cherry-picked, etc.).

## [Unreleased]

## [0.1.1] - 2026-04-23

### Changed

- changed the Docker base image `amazoncorretto` from `17.0.18-alpine` to `17.0.19-alpine`

## [0.1.0] - 2026-03-12

### Added

- added Apache Benchmark to perform stress test against every URL
- added Apache JMeter test file to manage all API tests
- added Apache JMeter to perform stress test against Java APIs
- added Grafana + Prometheus as a monitoring platform to check API performance and consumption
- added OpenApi specification conversion to JMX specification file to be used inside the JMeter
- added Python script to read and concisely print output csv
- added Python script to verify the behavior of a list of endpoints

### Changed

- changed the Docker base image amazoncorretto from 17.0.4-alpine to 17.0.18-alpine
- changed the Docker base images using Alpine from 3.16.1 to 3.16.9 (apache-benchmark/Dockerfile, nghttp2/Dockerfile)
- corrected structure to get WSL IP automatically through the `ifconfig`
- replaced minimal README with comprehensive documentation covering all tools, configuration, and project structure

