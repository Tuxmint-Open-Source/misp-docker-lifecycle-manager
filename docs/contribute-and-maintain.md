# Contribute and maintain

This path is for people changing the project, reviewing evidence, or operating its release and repository workflows. It is secondary to the [operator task chooser](README.md).

## Contribute safely

- Read [`CONTRIBUTING.md`](../CONTRIBUTING.md) for public-safety rules, pull-request workflow, and validation expectations.
- Read [`AGENTS.md`](../AGENTS.md) when using automated contributors.
- Use [`SECURITY.md`](../SECURITY.md) for sensitive vulnerability reports.
- Use the [anonymous SOS report guide](sos-report.md) for sanitized operational diagnostics.

Public examples must not contain credentials, private infrastructure details, deployment identifiers, or raw sensitive logs.

Monitoring ingestion for Zabbix, Checkmk, Nagios/Icinga, and Prometheus remains community-testing work. Read [Monitoring](monitoring.md), then contribute sanitized evidence through [community testing issue #62](https://github.com/Tuxmint-Open-Source/misp-docker-lifecycle-manager/issues/62).

## Maintain the repository

| I want to… | Read this |
| --- | --- |
| manage issues, labels, SOS triage, and upstream monitoring | [Maintainer workflow](maintainer-workflow.md) |
| understand origin, naming, and AI-assisted development transparency | [Project origin and transparency](project-origin-and-transparency.md) |
| inspect every lifecycle command and option | [Shell scripts reference](shell-scripts.md) |
| understand manager, upstream, and component versions | [Versioning](versioning.md) and [upstream input policy](upstream-inputs.md) |
| review the supported deployment architecture | [Architecture](architecture.md), [security](security.md), and [support matrix](support-matrix.md) |

## Release and evidence

| I want to… | Read this |
| --- | --- |
| cut and verify a release | [Release process](release/release-process.md) |
| review artifact integrity controls | [Release integrity and provenance](release/integrity-and-provenance.md) |
| inspect the current validated component tuple | [Compatibility](compatibility.md), [current validation](validation/compatibility-v1.4.1-misp-core-v2.5.44.md), and [validation matrix](validation/matrix.md) |
| inspect retained historical evidence | [Validation evidence archive](validation/README.md) |
| review current release posture | [Production readiness](production-readiness.md) |

Compatibility claims remain tied to immutable manager release tags and the exact official component set that passed validation.

## Project identity

Read [Brand assets](brand-assets.md) and the canonical [asset license and usage notice](../ASSET-LICENSE.md) before reusing the MISP DLM identity. The repository software remains GPL-3.0; the visual assets have their own terms.

## Return to operator documentation

Go back to the [task-first documentation homepage](README.md) for support, installation, operation, recovery, secure deployment, troubleshooting, and compatibility-evidence paths.
