# Upstream monitoring

This repository tracks selected public inputs from the official `MISP/misp-docker` repository.

The goal is not to mirror upstream. The goal is to make upstream drift visible and reviewable before installer assumptions become stale.

## What is monitored

The scheduled monitor watches these upstream files:

```text
template.env
docker-compose.yml
README.md
```

It extracts and records:

- upstream commit
- SHA-256 hashes of watched files
- `CORE_TAG`, `MODULES_TAG`, and `GUARD_TAG`
- `CORE_RUNNING_TAG`, `MODULES_RUNNING_TAG`, and `GUARD_RUNNING_TAG` defaults from `template.env`
- Compose service names
- MISP Docker image expressions for core, modules, and guard
- hash of the upstream README versioning section

## Baseline

The current reviewed upstream state is stored in:

```text
.upstream/misp-docker.lock.json
```

This file is intentionally committed. It is the review baseline used by the scheduled workflow.

## Reports

When upstream drift is detected, the workflow writes a public-safe review report to:

```text
.upstream/reports/misp-docker-upstream-review.md
```

The report is used as the Pull Request body. It contains a review checklist but no private infrastructure details.

## Scheduled workflow

The workflow runs daily and can also be started manually:

```text
.github/workflows/upstream-misp-docker-watch.yml
```

If no relevant upstream drift is detected, no PR is opened.

If relevant upstream drift is detected, the workflow opens or updates a PR with:

```text
.upstream/misp-docker.lock.json
.upstream/reports/misp-docker-upstream-review.md
```

A maintainer then reviews whether installer code or docs need follow-up changes.

## Manual check

Run a local check without changing files:

```bash
python3 scripts/check-upstream-misp-docker.py
```

Update the baseline/report locally:

```bash
python3 scripts/check-upstream-misp-docker.py --write
```

Fail when drift is detected, useful for validation:

```bash
python3 scripts/check-upstream-misp-docker.py --check
```
