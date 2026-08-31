# Production readiness

`v1.4.1` is the latest published and latest validated-compatible release for the documented single-server Docker lifecycle-manager scope and component tuple.

Production readiness here applies only to the public support matrix and explicitly validated manager release/component pairs. It is not a claim that every operating system, topology, proxy, customization, or future MISP component set is supported.

## Current stable-release status

| Area | Status |
| --- | --- |
| Latest published manager release | `v1.4.1` |
| Latest validated manager/component tuple | manager `v1.4.1`, core `v2.5.44`, modules `v3.0.9`, guard `v1.2` |
| Compatibility status | ✅ `v1.4.1` validated compatible |
| Public compatibility evidence | ✅ [`compatibility.md`](compatibility.md) and [`validation/matrix.md`](validation/matrix.md) |
| Public support scope | ✅ [`support-matrix.md`](support-matrix.md) |
| Production deployment guide | ✅ [`production-deployment.md`](production-deployment.md) |
| Security model | ✅ [`security.md`](security.md) |
| Backup, restore, and rollback | ✅ `v1.4.1` exact-tag and published-artifact evidence |
| Browser-facing login | ✅ `v1.4.1` exact-tag and published-artifact evidence |
| No-lock-in Compose operation | ✅ `v1.4.1` exact-tag and published-artifact evidence |
| Monitoring contract | ✅ `v1.4.1` exact-tag and published-artifact evidence; native platform ingestion remains unvalidated |

## `v1.4.1` release-validation state

`v1.4.1` is a documentation/hosted-docs patch release. Its immutable tag and published operator bundle passed the complete lifecycle matrix for the documented component tuple. The release-specific remote-proxy parity gate also passed explicit remote binding, Docker-aware source allow/deny filtering, verified backend TLS, browser login, update preservation, and cleanup.

## `v1.4.0` release-validation state

`v1.4.0` packages work added after the `v1.3.1` tag, including explicit persisted IPv4 binding for a reverse proxy on another host while preserving loopback as the default, fail-closed exposure-state validation, fresh-install prerequisite fixes, and coordinated immutable-SHA workflow maintenance. The immutable tag and published operator bundle passed the complete lifecycle matrix for the documented component tuple. A separate release-specific gate also passed explicit remote binding, Docker-aware source allow/deny filtering, verified backend TLS, browser login, update preservation, and cleanup.

## `v1.3.1` release-validation state

`v1.3.1` packages lifecycle safety hardening added after the `v1.3.0` tag, including stronger operation locking, backup/restore validation, reset/update recovery checks, and backup restart readiness. PR-branch destructive validation passed before release preparation, and the immutable tag plus published operator-bundle artifact passed exact-tag/package-artifact validation for `v1.3.1`.

## `v1.3.0` release-validation state

`v1.3.0` packages work added after the `v1.2.0` tag, including the lifecycle command-path rename from `installer/` to `lifecycle/` and retained `installer/` compatibility wrappers. The immutable tag and published operator-bundle artifact passed the complete lifecycle validation matrix for the documented component tuple, including canonical `./lifecycle/*.sh` commands and compatibility `./installer/*.sh` wrappers.

## `v1.2.0` release-validation state

`v1.2.0` packages work added after the `v1.1.0` tag, including the required repository gate, upstream-publication token boundary, verified ShellCheck acquisition, and operator-bundle generation/release-asset automation. Its immutable tag and published operator-bundle artifact passed the complete lifecycle validation matrix for the documented component tuple. It remains retained historical validated evidence.

## `v1.1.0` release-validation state

`v1.1.0` packages work added after the `v1.0.0` tag. Its immutable tag passed the full release suite for core `v2.5.44`, modules `v3.0.9`, and guard `v1.2`.

The monitoring healthcheck is contract/parser tested and exercised against a managed MISP deployment in healthy, UNKNOWN, controlled-CRITICAL, and recovery states. A scoped operator test additionally confirmed healthy-path execution, `OK` mapping, and performance-data ingestion through Nagios XI `2026R1.6.1` and NCPA `3.4.3-1` with manager `v1.4.1`. Native non-OK transitions, recovery, notifications, and the other named monitoring platforms remain unvalidated. See [Monitoring](monitoring.md), the [Nagios XI/NCPA report](validation/nagios-xi-ncpa-v1.4.1.md), and the [community testing issue](https://github.com/Tuxmint-Open-Source/misp-docker-lifecycle-manager/issues/62).

The post-tag evidence covers install, reverse proxy, update, lifecycle, failure, restore, browser, rollback, monitoring, and structured SOS scenarios. See the detailed `v1.1.0` compatibility report.

## `v1.0.0` validation coverage

The exact `v1.0.0` tag was validated for:

- direct fresh install;
- reverse-proxy fresh install;
- install/update path with explicit official MISP component tags;
- backup creation;
- restore from backup into a clean deployment scope;
- reset dry-run safety;
- restore-based rollback after a controlled failed update;
- browser-facing login flow;
- failure-mode guardrails;
- no-lock-in/manual Docker Compose usability;
- the official MISP Docker component sets recorded in the compatibility matrix.

See the [validation matrix](validation/matrix.md) for the exact evidence links and limitations.

## Ongoing release gates

Every future release that changes runtime behavior should:

1. keep support and non-goals explicit;
2. validate the immutable release tag rather than only `main`;
3. record the exact official MISP Docker component set;
4. exercise affected install, update, recovery, browser, monitoring, and failure paths;
5. publish a sanitized validation report;
6. avoid extending compatibility claims to untested future component sets.

## What this project does not claim

The current stable line does not claim:

- broad operating-system support beyond the documented validation environment;
- high-availability or multi-node deployment support;
- Kubernetes support;
- support for custom MISP images or forks;
- compatibility with future upstream MISP component sets before validation completes;
- native certification by external monitoring products.

## Evidence policy

Public production-readiness evidence includes:

- manager release/ref;
- official MISP Docker component versions;
- validation date;
- scenario list;
- pass/fail result;
- limitations.

Public evidence must not include private hostnames, private IP addresses, VM identifiers, topology, raw logs, credentials, or private repository paths.

## What to read next

- Return to the [documentation map](README.md) and choose the user/operator path.
- Review the public support scope in [Support matrix](support-matrix.md).
- Plan deployment with [Production deployment guide](production-deployment.md).
- Review compatibility evidence in [Compatibility](compatibility.md).
- Review exact validation coverage in [Validation matrix](validation/matrix.md).
