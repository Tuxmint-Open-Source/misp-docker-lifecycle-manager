<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/brand/png/misp-dlm-lockup-1408.png">
    <img class="misp-dlm-readme-lockup" src="docs/assets/brand/png/misp-dlm-lockup-light-1408.png" alt="MISP DLM — Docker Lifecycle Manager" width="352">
  </picture>
</p>

# MISP Docker Lifecycle Manager

A non-invasive lifecycle manager for official [`MISP/misp-docker`](https://github.com/MISP/misp-docker) single-server Docker deployments.

> **Important — Release channels**
>
> | Channel | Version | Meaning |
> | --- | --- | --- |
> | Latest published | `v1.4.0` | Newest normal SemVer release |
> | Latest validated | `v1.4.0` | Newest immutable release tag that passed the full compatibility matrix |
>
> Install and report the immutable SemVer tag. [`.release-channels.json`](.release-channels.json) is the machine-readable source; mutable `stable` and `latest` Git tags are intentionally not used.

Current `VERSION` value on `main`: `1.4.0`.

The manager installs, configures, validates, updates, backs up, restores, and safely removes a supported deployment while leaving `/opt/misp-docker` as a normal official upstream checkout. It does **not** fork or replace MISP, and it is not a Kubernetes, high-availability, or multi-node orchestration layer.

## Start with your task

For the current hosted reader experience, start at the verified Read the Docs site:
[`misp-docker-lifecycle-manager.readthedocs.io`](https://misp-docker-lifecycle-manager.readthedocs.io/).
The repository-local links below remain the versioned/offline source of truth for exact branches and tags.

| I want to… | Read this |
| --- | --- |
| choose the right path | [`docs/README.md`](docs/README.md) |
| check whether my deployment is supported | [`docs/support-matrix.md`](docs/support-matrix.md) |
| install and verify for the first time | [`docs/getting-started.md`](docs/getting-started.md) |
| follow normal lifecycle operations | [`docs/operator-guide.md`](docs/operator-guide.md) and [`docs/monitoring.md`](docs/monitoring.md) |
| deploy behind a reverse proxy | [`docs/production-deployment.md`](docs/production-deployment.md) |
| update safely | [`docs/upgrade-path.md`](docs/upgrade-path.md) |
| back up, restore, or recover | [`docs/backup-restore-and-rollback.md`](docs/backup-restore-and-rollback.md) |
| troubleshoot or create a sanitized report | [`docs/troubleshooting.md`](docs/troubleshooting.md) and [`docs/sos-report.md`](docs/sos-report.md) |
| inspect validated compatibility evidence | [`docs/compatibility.md`](docs/compatibility.md) and [`docs/validation/matrix.md`](docs/validation/matrix.md) |
| contribute or maintain the project | [`docs/contribute-and-maintain.md`](docs/contribute-and-maintain.md) |

## Quick test path

For the supported first-install workflow, read [`docs/getting-started.md`](docs/getting-started.md). Git is required before cloning:

```bash
sudo dnf install -y git
git clone https://github.com/Tuxmint-Open-Source/misp-docker-lifecycle-manager.git
cd misp-docker-lifecycle-manager
git checkout v1.4.0
sudo ./lifecycle/prepare-host-rocky.sh
sudo ./lifecycle/install.sh \
  --install-dir /opt/misp-docker \
  --upstream-ref master \
  --base-url https://misp.example.com \
  --admin-email admin@example.com \
  --admin-org ExampleOrg \
  --timezone Europe/Zurich \
  --exposure reverse-proxy
```

Then verify the deployment:

```bash
sudo ./lifecycle/doctor.sh --install-dir /opt/misp-docker
sudo ./lifecycle/login-check.sh --install-dir /opt/misp-docker
```

For production, recovery, updates, and limitations, use the linked guides rather than this abbreviated path. The default reverse-proxy path binds to loopback. A proxy on another host requires the explicit bind and source-restricted Docker-aware firewall procedure in the [production deployment guide](docs/production-deployment.md). The lifecycle manager does not modify the host firewall.

## Validated compatibility

```text
manager release/ref × official MISP Docker component set = status
```

The current validated tuple is manager `v1.4.0`, MISP core `v2.5.44`, modules `v3.0.9`, and guard `v1.2`. See [compatibility](docs/compatibility.md), the [current validation report](docs/validation/compatibility-v1.4.0-misp-core-v2.5.44.md), and the [evidence archive](docs/validation/README.md).

## Policy and project links

- Security reports: [`SECURITY.md`](SECURITY.md)
- Contributions: [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Quality gates: [`QA.md`](QA.md)
- Project identity: [`ASSET-LICENSE.md`](ASSET-LICENSE.md) and [brand assets](docs/brand-assets.md)
- Release history: [`CHANGELOG.md`](CHANGELOG.md)

Repository-local documentation remains the versioned and offline source of truth. The hosted `latest` documentation renders the current `main` branch. Older release tags before the MkDocs/Read the Docs foundation, including `v1.4.0`, should be read from the repository tag rather than expected to have hosted release-tag pages.
