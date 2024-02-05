# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

When a new release is proposed:

1. Create a new branch `bump-version-x.x.x` (this isn't a long-lived branch!!!);
2. The Unreleased section on `CHANGELOG.md` gets a version number and date;
3. Open a Pull Request with the bump version changes targeting the `main` branch;
4. When the Pull Request is merged, a new git tag must be created using [GitHub environment](https://github.com/rios0rios0/boss).

Releases to productive environments should run from a tagged version.
Exceptions are acceptable depending on the circumstances (critical bug fixes that can be cherry-picked, etc.).

## [Unreleased]

### Added

- added Apache Benchmark to perform stress test against every URL
- added Apache JMeter to perform stress test against Java APIs
- added Grafana + Prometheus as a monitoring platform to check API performance and consumption
- added OpenApi specification conversion to JMX specification file to be used inside the JMeter
- added Apache JMeter test file to manage all API tests

### Changed

- corrected structure to get WSL IP automatically through the `ifconfig`

### Removed

-
