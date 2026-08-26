---
name: code-review
description: "Review pull requests and diffs in boss — the dockerised performance-testing and monitoring toolkit — against the rios0rios0/guide standards, with extra weight on the compose stack, WSL2 gateway handling, Python analysis scripts, and keeping load targets parameterised. Use when reviewing a PR, a branch, or staged changes here."
---

# Code review — `boss`

`boss` orchestrates Apache Benchmark, JMeter and h2load against a target, alongside a Prometheus and Grafana monitoring stack, with OpenAPI-to-JMX conversion and Python-powered result analysis. It generates real load, so a mis-set target is a self-inflicted denial of service.

## When to use this skill

Use it whenever you are asked to review a pull request, a diff, a branch, or staged changes
in this repository — and before opening a pull request of your own, as a self-check. It is a
**review** skill: it produces findings, not commits.

## Source of truth

The canonical engineering standards live in the
**[rios0rios0/guide wiki](https://github.com/rios0rios0/guide/wiki)**. This file is a
repo-tailored index into that guide plus the rules that only apply here. Precedence, highest
first:

1. This repository's `.github/copilot-instructions.md`, `CLAUDE.md`, and `CONTRIBUTING.md` —
   they describe *this* codebase and its load-bearing invariants.
2. The **rios0rios0/guide** wiki — the shared standard.
3. General language idiom.

When the guide and a general convention disagree, the guide wins. When this file and the
guide disagree, the guide wins and this file should be corrected in the same pull request.

### Guide pages that apply here

| Topic | Page |
|-------|------|
| Python — the Zen and the toolchain | [Python](https://github.com/rios0rios0/guide/wiki/Python) |
| Python Conventions — naming and meaningful comments | [Python-Conventions](https://github.com/rios0rios0/guide/wiki/Python-Conventions) |
| Python Formatting and Linting — Black, isort, Flake8 | [Python-Formatting-and-Linting](https://github.com/rios0rios0/guide/wiki/Python-Formatting-and-Linting) |
| Python Type System — type hints everywhere | [Python-Type-System](https://github.com/rios0rios0/guide/wiki/Python-Type-System) |
| Python Logging — Loguru | [Python-Logging](https://github.com/rios0rios0/guide/wiki/Python-Logging) |
| Python Testing — pytest and BDD blocks | [Python-Testing](https://github.com/rios0rios0/guide/wiki/Python-Testing) |
| Python Project Structure | [Python-Project-Structure](https://github.com/rios0rios0/guide/wiki/Python-Project-Structure) |
| YAML Conventions — `.yaml`, single quotes, unquoted scalars | [YAML](https://github.com/rios0rios0/guide/wiki/YAML) |
| Mapper Design Pattern — replacing `switch`/`case` | [Mapper-Design-Pattern](https://github.com/rios0rios0/guide/wiki/Mapper-Design-Pattern) |
| Git Flow — branches, commits, SemVer, breaking changes | [Git-Flow](https://github.com/rios0rios0/guide/wiki/Git-Flow) |
| Documentation & Change Control — changelog and docs discipline | [Documentation-&-Change-Control](https://github.com/rios0rios0/guide/wiki/Documentation-&-Change-Control) |
| CHANGELOG Formatting — capitalisation and backticks | [CHANGELOG-Formatting](https://github.com/rios0rios0/guide/wiki/CHANGELOG-Formatting) |
| Security — OWASP checklist, secret hygiene, SAST | [Security](https://github.com/rios0rios0/guide/wiki/Security) |
| CI & CD — pipeline stages and the local quality gates | [CI-&-CD](https://github.com/rios0rios0/guide/wiki/CI-&-CD) |
| Code Style — baseline naming and the operations vocabulary | [Code-Style](https://github.com/rios0rios0/guide/wiki/Code-Style) |

## How to run the review

1. **Establish the range.** Resolve the default branch with
   `git symbolic-ref refs/remotes/origin/HEAD` (strip `refs/remotes/origin/`; fall back to `main`),
   then read the diff with `git diff <default>...HEAD` and the file list with
   `git diff <default>...HEAD --name-only`.
2. **Read whole files, not just hunks.** A hunk cannot show a layering violation, a missing
   test, or a duplicated helper. Open every changed file in full, plus the files it imports
   from the layer below.
3. **Check the change set as a unit** — not only the code. A change that alters behaviour,
   configuration, or architecture is incomplete without its changelog entry and its
   documentation update, and that omission is a finding in its own right.
4. **Map every finding to a rule.** Each finding must name the rule it breaks and link the
   guide page (or the repository file) that states it. A comment that cannot be traced to a
   rule is a suggestion, not a defect — label it as such.
5. **Report, do not rewrite.** Produce the review in the output format below. Only edit files
   when the request explicitly asks for fixes.

## What matters most in `boss`

These are the checks that catch real defects in this repository. Work through
them before the generic ones.

- **No load target may be hard-coded.** Targets come from configuration and environment; a host committed as a default will be hammered by the next person who runs the stack. **Critical.**
- **`WSL_GATEWAY` must be exported before any Docker command** — it is how the containers reach a service running on the WSL2 host. A script that assumes `localhost` works from inside a container is a defect that reports zero throughput with no error.
- **The Makefile still uses the legacy `docker-compose` spelling** while the documented path is Docker Compose v2 (`docker compose`). Keep any new target consistent with whichever the Makefile actually invokes, and say which one you tested.
- **Each compose file has one job** — `docker-compose.yaml` for the monitoring stack, `.ab.yaml`, `.aj.yaml`, `.h2.yaml` for the three load generators. Merging them, or adding a load generator to the monitoring stack, breaks the ability to run monitoring without generating load.
- **Prometheus scrape targets and Grafana dashboards move together.** A metric renamed in `prometheus/` without the dashboard update leaves a panel silently empty.
- **Load parameters belong in configuration, not in a script literal.** Concurrency, duration, and request count are what a user changes most often.
- **JMeter input and output directories are the contract** — `apache-jmeter/input/` for `.jmx` files, `apache-jmeter/output/` for results. Results must not be committed.
- **Python analysis scripts follow the Python standards below** — type hints, Loguru rather than `print`, Black formatting — and must fail loudly on a malformed result file rather than reporting zeros.
- **Builds are slow, not hung** — 5–10 minutes for Apache Benchmark, 10–15 for JMeter. Do not report a long build as a defect.

### Commands a reviewer should be able to quote

```bash
export WSL_GATEWAY=$(ifconfig eth0 | grep 'inet ' | sed -e 's/  */:/g' | cut -d: -f3)
docker compose -f docker-compose.yaml up -d      # Grafana :3000, Prometheus :9090
docker compose -f docker-compose.ab.yaml up
docker compose -f docker-compose.aj.yaml up
docker compose -f docker-compose.h2.yaml up
```

## Python conventions

See [Python Conventions](https://github.com/rios0rios0/guide/wiki/Python-Conventions), [Python Type System](https://github.com/rios0rios0/guide/wiki/Python-Type-System),
[Python Logging](https://github.com/rios0rios0/guide/wiki/Python-Logging), and
[Formatting and Linting](https://github.com/rios0rios0/guide/wiki/Python-Formatting-and-Linting).

- `snake_case` for modules, functions, and variables; `PascalCase` for classes.
- **Type hints on every parameter and return type.** `Any` as a catch-all is prohibited.
- Logging uses Loguru (`from loguru import logger`) — not the standard `logging` module and
  not `print()`. Normal output goes to stdout, warnings and errors to stderr.
- Formatting is Black, imports are ordered by isort, linting is Flake8. Comments explain
  *why*, not *what*.
- Tests use pytest with `# given` / `# when` / `# then` blocks, mirroring the source tree
  under `tests/`.

### Dispatch tables over `switch`

See [Mapper Design Pattern](https://github.com/rios0rios0/guide/wiki/Mapper-Design-Pattern). Two or three stable cases may stay a
`switch`. Four or more, or a set that grows with features, becomes a map from key to handler
so that adding a case is a new entry rather than an edit to the dispatcher. Flag new
`switch`/`if-else` chains that dispatch on a string or enum key.

### YAML

See [YAML Conventions](https://github.com/rios0rios0/guide/wiki/YAML). The extension is `.yaml`, never `.yml`. String values are
single-quoted; double quotes appear only where interpolation or an escape needs them;
booleans and numbers are never quoted. This applies to workflows, compose files, manifests,
and YAML blocks inside Markdown.

## Tests

There is no automated test suite. Verification is bringing up the affected compose stack, running one load cycle against a target you own, and confirming the Grafana panels populate.

## Documentation and change control

See [Documentation & Change Control](https://github.com/rios0rios0/guide/wiki/Documentation-&-Change-Control) and
[CHANGELOG Formatting](https://github.com/rios0rios0/guide/wiki/CHANGELOG-Formatting).

This repository uses **chlog fragments**. `CHANGELOG.md` is generated and is never edited by
hand.

- Every change ships a fragment created with `chlog new --kind <Kind> --body "…"`, staged in
  the **same commit** as the code. Kinds: `Added`, `Changed`, `Deprecated`, `Removed`,
  `Fixed`, `Security`.
- A backward-incompatible change to the public interface additionally carries `--breaking`.
  The kind alone never triggers a major bump.
- A hand-edited `CHANGELOG.md`, or a code change with no fragment under
  `.changes/unreleased/`, is a **Critical** finding — `chlog check` fails the build for it.
- Fragment bodies start with a lowercase verb in simple past tense, capitalise proper nouns
  (GitHub, Go, Docker), and wrap code identifiers and versions in backticks.
- `README.md` is updated whenever usage, setup, configuration, or architecture changes;
  `.github/copilot-instructions.md` and `CLAUDE.md` whenever the workflow, commands, or
  structure changes. Documentation and code ship in one commit.

## Git Flow and pull-request hygiene

See [Git Flow](https://github.com/rios0rios0/guide/wiki/Git-Flow) and [Merge Guide](https://github.com/rios0rios0/guide/wiki/Merge-Guide).

- Branch names are `feat/`, `fix/`, `refactor/`, `chore/`, `test/`, or `docs/` followed by a
  ticket ID or a short slug — `feat/TICKET-000`, `fix/input-mask`.
- Commit subjects are `type(SCOPE): message`: simple past tense (`added`, `fixed`, `changed`,
  `removed`), lowercase first word, no trailing period, code identifiers in backticks.
- Branches are synchronised with `git rebase`, never `git merge`. A merge commit from the
  default branch inside a feature branch is a finding.
- Breaking changes are flagged in **three** places: the commit footer
  (`**BREAKING CHANGE:** …`), the changelog, and the pull-request description. One or two of
  the three is not enough.
- Versions follow [SemVer](https://semver.org/): MAJOR for incompatible changes, MINOR for
  features, PATCH for fixes.

## Security

See [Security](https://github.com/rios0rios0/guide/wiki/Security).

- **No hard-coded secrets.** API keys, tokens, passwords, and private keys belong in
  environment variables or a secret manager — never in source, tests, fixtures, or the
  changelog. A secret that reaches a commit must be rotated, not merely deleted.
- **Never write a PEM header sentinel or a realistic key shape into a fixture**
  (`ghp_…`, `sk-…`, `AKIA…`, `xoxb-…`, JWT-shaped strings, or the dashed `BEGIN …` banners).
  Gitleaks matches the shape, not the value, so a placeholder that merely *looks* like a
  credential fails the pipeline. Use inert placeholders such as `fixture-token-placeholder`.
- **Suppressions must be justified.** Entries in `.gitleaksignore`, `.trivyignore`,
  `.semgrepignore`, or `.codeql-false-positives` need a fingerprint, a dated comment, and a
  reason. A suppression added to silence a real finding is a Critical.
- Validate and sanitise every external input; use parameterised queries; apply least
  privilege; keep secrets out of logs.
- Dependency manifest changes are reviewed for new transitive vulnerabilities. When a fix
  exists, bump the version rather than suppressing the finding.

## What not to flag

A review that raises noise gets ignored. Do not report these:

- First-run image pulls and builds taking several minutes.
- The `docker-compose` versus `docker compose` inconsistency existing — flag it only when a change makes it worse.
- Anything the guide does not require and this file does not list, unless it is a genuine correctness or security defect — say so plainly and label it a Suggestion.

## Review output format

```
## Code review: <branch or PR>

### Critical (must fix before merge)
- `path/to/file.ext:LINE` — <what is wrong> — violates <rule> (<guide page or repo file>)

### Warning (should fix)
- `path/to/file.ext:LINE` — <what is wrong> — violates <rule>

### Suggestion (optional)
- `path/to/file.ext:LINE` — <improvement>

### Change-control checklist
- [ ] Changelog entry present for every behavioural change
- [ ] `README.md` updated if usage, setup, or architecture changed
- [ ] `.github/copilot-instructions.md` and `CLAUDE.md` updated if the workflow, commands, or structure changed
- [ ] Commit messages follow `type(SCOPE): message` in simple past tense
- [ ] Breaking changes flagged in the commit footer, the changelog, and the PR description

### Verdict: APPROVE / REQUEST CHANGES
<one paragraph: the blocking findings, or why the change is ready>
```

## Severity

| Severity       | Use for                                                                                                                            |
|----------------|------------------------------------------------------------------------------------------------------------------------------------|
| **Critical**   | Broken dependency direction, a leaked secret, an injection or authentication flaw, a missing changelog entry, a banned mock library, a load-bearing invariant broken, a test deleted rather than fixed. |
| **Warning**    | Naming that departs from the guide, a missing test for a new branch of logic, an unexplained magic value, a stale README or instructions file, a `switch` that should be a map. |
| **Suggestion** | Readability, consistency with neighbouring modules, and performance ideas that no rule mandates.                                     |

Rank findings most severe first, and state plainly when nothing blocks the merge — an empty
Critical section is a valid, useful review.
