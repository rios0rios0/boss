# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This file is not edited by hand. Every change writes its own fragment under
`.changes/unreleased/` with [chlog](https://github.com/luizjhonata/chlog), and a release compiles
the pending fragments into a version section here — so two branches each adding an entry no
longer touch the same lines, and a rebase that used to conflict on this file now conflicts on
nothing.

When a new release is proposed:

1. Create a new branch `bump-version-x.x.x` (this isn't a long-lived branch!!!);
2. The fragments pending under `.changes/unreleased/` are compiled into a version section by `chlog batch auto && chlog merge` (AutoBump does this for you — it reads the fragments directly);
3. Open a Pull Request with the bump version changes targeting the `main` branch;
4. When the Pull Request is merged, a new git tag must be created using [GitHub environment](https://github.com/rios0rios0/boss/tags).

Releases to productive environments should run from a tagged version.
Exceptions are acceptable depending on the circumstances (critical bug fixes that can be cherry-picked, etc.).

## [Unreleased]

## [0.5.1] - 2026-09-06

### Changed

- changed the Docker base image `alpine` from `3.16.9` to `3.24.1`
- changed the Docker base image `amazoncorretto` from `17.0.20-alpine` to `26.0.2-alpine`

### Security

- restricted the JMeter download in `jmeter.Dockerfile` to HTTPS without following redirects and verified the tarball against its published SHA-512 checksum

## [0.5.0] - 2026-09-02

### Added

- added the `checks` workflow, so pull requests here run the shared `code-check > quality:basic-checks` gate (rebase status and the changelog rule) that every repository with a language pipeline already gets as that pipeline's first job. This repository has no build to attach it to, so it had no changelog enforcement at all — which is how the weekly configuration and documentation refresh hand-edited a generated `CHANGELOG.md` across the fleet before anything objected

## [0.4.1] - 2026-09-01

### Changed

- refreshed `.github/copilot-instructions.md` to document the `claude-review.yaml` and `claude-mention.yaml` per-PR workflows added in `0.4.0`, replacing the stale "no per-PR CI exists yet" claim

## [0.4.0] - 2026-08-28

### Added

- added the Claude automated code review and `@claude` mention responder workflows, `claude-review.yaml` and `claude-mention.yaml`, matching the `reusable-claude-review.yaml` / `reusable-claude-mention.yaml` definitions they call in `rios0rios0/pipelines`, authenticating with the `CLAUDE_CODE_OAUTH_TOKEN` secret

### Fixed

- restored the `.changes/unreleased/` directory with a `.gitkeep`, so the release tooling keeps recognising this project as [chlog](https://github.com/luizjhonata/chlog)-based after a release consumes the last fragment. Git tracks files rather than directories, so the bump commit that removed the final fragment removed the directory too, and the next run read the empty `[Unreleased]` section as "nothing to release"
- restored the `id-token: write` permission on both Claude workflow callers. Without it the caller grants less than the reusable workflow declares, which GitHub rejects before the job starts -- runs ended in `startup_failure`. The action needs the scope because `setupGitHubToken()` exchanges a GitHub OIDC token for the GitHub App token it posts with, unless a `github_token` is passed explicitly.

### Removed

- removed the unused `id-token: write` permission from the Claude workflow callers, and changed `claude-review.yaml`'s display name to `Claude Review` so it matches its file name and its `Claude Mention` sibling. `anthropics/claude-code-action` needs `id-token: write` only for workload identity federation or the Bedrock / Vertex / Foundry OIDC paths; these authenticate with `claude_code_oauth_token`, so the scope allowed minting OIDC tokens for any audience without ever being used.

## [0.3.0] - 2026-08-26

### Added

- added [Go](https://go.dev/dl/) to the `CONTRIBUTING.md` prerequisites: installing `chlog` with `go install` needs a toolchain this repository does not otherwise require
- added a tailored `code-review` skill under `.github/skills/` so GitHub Copilot reviews changes against the [rios0rios0/guide](https://github.com/rios0rios0/guide/wiki) standards and this repository's own load-bearing invariants

### Changed

- changed the changelog to [chlog](https://github.com/luizjhonata/chlog) fragments: a change now writes its own YAML file under `.changes/unreleased/` through `chlog new --kind <Kind> --body "..."`, and `CHANGELOG.md` is GENERATED from them at release time by `chlog batch auto && chlog merge`. That is the one thing a single shared file cannot do — two branches each adding an entry no longer touch the same lines, so a rebase that used to conflict on `CHANGELOG.md` now conflicts on nothing. The `[Unreleased]` section was empty, so nothing had to be carried across. AutoBump already reads the fragments directly, so the release flow is unchanged.

## [0.2.3] - 2026-07-27

### Changed

- changed the Docker base image `amazoncorretto` from `17.0.19-alpine` to `17.0.20-alpine`

## [0.2.2] - 2026-06-03

### Changed

- refreshed `CLAUDE.md` and `.github/copilot-instructions.md` to correct the Python dependency attribution (`test_endpoints.py` needs only `requests`, `result_describer` needs only `pandas`)

## [0.2.1] - 2026-05-19

### Changed

- refreshed `.github/copilot-instructions.md` to document the `release.yaml` CI workflow (was incorrectly listed as having no CI/CD)

## [0.2.0] - 2026-04-28

### Added

- added `CLAUDE.md` with build commands, key conventions, and utility script references

### Changed

- refreshed `.github/copilot-instructions.md` to correct Alpine base image version from 3.16.1 to 3.16.9

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

