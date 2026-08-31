# What do you want to do?

MISP Docker Lifecycle Manager helps operate an official [`MISP/misp-docker`](https://github.com/MISP/misp-docker) single-server deployment without taking ownership of the generated upstream checkout.

It is an independent community project, not part of, endorsed by, certified by, sponsored by, or supported by the MISP project, CIRCL, or the upstream MISP maintainers. Read [project origin and transparency](project-origin-and-transparency.md) for naming, support-boundary, validation, and AI-assisted development details.

Choose the task that matches what you need now:

| I want to… | Start here | Continue with |
| --- | --- | --- |
| **Evaluate support** | [Support matrix](support-matrix.md) | [Compatibility](compatibility.md) |
| **Install for the first time** | [Getting started](getting-started.md) | [Operator bundle](operator-bundle.md) for the checksummed release artifact |
| **Operate or update MISP** | [Operator guide](operator-guide.md) | [Upgrade path](upgrade-path.md) and [monitoring](monitoring.md) |
| **Connect Nagios XI through NCPA** | [Nagios XI with NCPA](nagios-xi-ncpa.md) | [Monitoring contract](monitoring.md) and [integration evidence](validation/nagios-xi-ncpa-v1.4.1.md) |
| **Back up or recover** | [Backup, restore, and rollback](backup-restore-and-rollback.md) | Review recovery before an update or incident |
| **Deploy securely** | [Production deployment](production-deployment.md) | [Security model](security.md) and [architecture](architecture.md) |
| **Troubleshoot or report a problem** | [Troubleshooting](troubleshooting.md) | [Anonymous SOS reports](sos-report.md) or [`SECURITY.md`](../SECURITY.md) for sensitive issues |
| **Inspect compatibility evidence** | [Latest validated `v1.4.1` report](validation/compatibility-v1.4.1-misp-core-v2.5.44.md) | [Validation matrix](validation/matrix.md) and [evidence archive](validation/README.md) |

> **Important — Release channels**
>
> `v1.4.1` is the latest published and latest validated-compatible release. Install and report immutable SemVer tags; `stable` and `latest` are not Git tags in this project.

## New operator path

If this is your first visit, use this short path:

1. Confirm the deployment shape in the [support matrix](support-matrix.md).
2. Complete the [getting-started](getting-started.md) installation and verification pass.
3. Follow the [operator guide](operator-guide.md) for normal lifecycle work.
4. Read [backup, restore, and rollback](backup-restore-and-rollback.md) before the first update.
5. Use the [production deployment guide](production-deployment.md) before exposing a real service.

The lifecycle manager does not modify the host firewall. Remote reverse-proxy deployments require the explicit bind and source-restricted Docker-aware firewall procedure in the production guide.

## Current compatibility evidence

Compatibility is an explicit pair:

```text
manager release/ref × official MISP Docker component set = status
```

The current validated tuple is manager `v1.4.1`, MISP core `v2.5.44`, modules `v3.0.9`, and guard `v1.2`. Read the [current report](validation/compatibility-v1.4.1-misp-core-v2.5.44.md) for scope and limitations. Older immutable reports remain available in the [evidence archive](validation/README.md).

## Contribute or maintain

Contributor, release, policy, script-reference, transparency, and project-identity material is collected in [Contribute and maintain](contribute-and-maintain.md). Operators do not need that material to follow the task paths above.

## Offline and versioned documentation

The current hosted documentation is available at [`misp-docker-lifecycle-manager.readthedocs.io/en/latest/`](https://misp-docker-lifecycle-manager.readthedocs.io/en/latest/).

These pages also live in the repository and remain usable from an exact branch or tag. Start from this `docs/README.md` file when reading offline; root policies such as [`SECURITY.md`](../SECURITY.md) and [`CONTRIBUTING.md`](../CONTRIBUTING.md) remain canonical.

Hosted release-tag pages begin with releases that include the MkDocs/Read the Docs foundation. Older tags such as `v1.4.0` predate that foundation, so use the repository tag for their version-correct documentation.

Do not move or rewrite old release tags to make hosted pages build. RTD `latest` remains the default hosted version until a post-foundation release tag is active, built, and verified as `stable`.
