# Production readiness roadmap

This project is on a deliberate path toward a first production-ready major release.

The current release, `v0.3.3`, is validated compatible with the latest reviewed official MISP Docker component set, but the repository still carries a **not production ready** warning because production readiness requires more than successful install/update compatibility.

## Current status

| Area | Status |
| --- | --- |
| Latest installer release | `v0.3.3` |
| Latest validated MISP component set | core `v2.5.43`, modules `v3.0.8`, guard `v1.2` |
| Compatibility status | ✅ `v0.3.3` is validated compatible with that component set |
| Public compatibility docs | ✅ available in [`compatibility.md`](compatibility.md) and [`validation/matrix.md`](validation/matrix.md) |
| Production-ready status | not yet |

## What must be true before `v1.0.0`

`v1.0.0` should mean the supported operator workflow is stable, documented, and backed by exact release-tag validation.

Before removing the public production warning, the project should have:

| Requirement | Status | Notes |
| --- | --- | --- |
| Exact release-tag compatibility validation | ✅ for `v0.3.3` | Must be repeated for every release and final `v1.0.0`. |
| Public compatibility matrix | ✅ | Tracks installer release/ref × official MISP Docker component set. |
| Public support matrix | planned | Must state supported OS, deployment shape, architecture, proxy model, and non-goals. |
| Production deployment guide | planned | Must cover prerequisites, DNS/TLS, install, verification, operations, and limitations. |
| Security model and hardening statement | planned | Must explain secret handling, backup sensitivity, Docker group risk, destructive safeguards, and upstream inheritance. |
| Backup restore documentation | planned | Backup exists, but production readiness requires a documented restore procedure. |
| Real restore validation | planned | Must prove a backup can be restored into a clean deployment and become usable. |
| Rollback/failure recovery docs | planned | Must explain what operators do after failed install/update scenarios. |
| Current-release browser login validation | planned | `v0.3.3` compatibility used CLI login checks; v1 readiness should include browser-facing validation. |
| Public production-readiness validation report | planned | Must summarize exact release-tag evidence without private infrastructure details. |

## Required validation before `v1.0.0`

The final `v1.0.0` tag should pass at least these scenarios:

- direct fresh install
- reverse-proxy fresh install
- install/update path with explicit official MISP component tags
- backup creation
- restore from backup into a clean deployment scope
- reset dry-run safety
- rollback or documented failure-recovery path
- browser-facing login flow
- failure-mode guardrails
- no-lock-in/manual Docker Compose usability
- compatibility with the latest reviewed official MISP Docker component set

## Release path

The recommended release path is:

1. Complete the documentation and validation gaps above.
2. Publish `v1.0.0-rc.1` as a release candidate.
3. Validate the immutable `v1.0.0-rc.1` tag.
4. Fix any release-candidate findings.
5. Publish `v1.0.0` only after the final release tag passes the full validation set.
6. Mark `v1.0.0` **validated compatible** only after exact-tag validation passes.

## What this does not claim yet

Until `v1.0.0` is published and validated, this project does not claim:

- broad operating-system support beyond documented validation
- high-availability or multi-node deployment support
- Kubernetes support
- support for custom MISP images or forks
- complete disaster-recovery assurance without restore validation
- compatibility with future upstream MISP component sets before validation completes

## Evidence policy

Public production-readiness evidence should include:

- release/ref
- official MISP Docker component versions
- validation date
- scenario list
- pass/fail result
- limitations

Public evidence must not include private hostnames, private IP addresses, VM IDs, topology, raw logs, credentials, or private repository paths.
