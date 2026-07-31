# Getting started

This guide gives you one first successful path through MISP Docker Lifecycle Manager.

Use it to install, verify, and identify the next document to read. It is not a replacement for the full [operator guide](operator-guide.md), [production deployment guide](production-deployment.md), or [backup and recovery guide](backup-restore-and-rollback.md).

> **Important**
> `v1.4.0` is the latest published and validated-compatible release for the documented component set and single-server Docker lifecycle-manager scope. Validate your own deployment assumptions and keep backups before relying on a deployment operationally.

## What this path does

The first-install path:

1. checks that your host and deployment shape are in scope;
2. clones the manager and checks out the supported release tag;
3. prepares a Rocky-compatible host when needed;
4. installs MISP behind a reverse proxy;
5. verifies readiness and login;
6. records where to continue for production, updates, backups, recovery, and troubleshooting.

It does **not** replace production planning. Do not expose a deployment publicly until you have reviewed the production and recovery links at the end.

## Supported shape before you run commands

Read the [support matrix](support-matrix.md) first if you are unsure whether this project fits your environment.

This guide assumes:

- one Linux host dedicated to a single-server Docker deployment;
- a supported Rocky-compatible host, or an expert test host outside the support matrix;
- Git is installed before cloning the manager (`sudo dnf install -y git` on a supported Rocky-compatible host);
- Docker and Docker Compose are available or can be installed by the host-preparation helper;
- lifecycle commands are run with `sudo`;
- your public URL is a real hostname such as `https://misp.example.com`;
- generated secrets and runtime `.env` files are never committed.

## Install and verify

### 1. Clone the manager

```bash
git clone https://github.com/Tuxmint-Open-Source/misp-docker-lifecycle-manager.git
cd misp-docker-lifecycle-manager
```

Use the release tag you want to evaluate:

```bash
git checkout v1.4.0
```

### 2. Prepare a Rocky Linux host

```bash
sudo ./lifecycle/prepare-host-rocky.sh
```

By default, this does **not** add your user to the Docker group. Docker group membership is root-equivalent on the host. Use `sudo` unless you intentionally accept that trade-off.

The helper stops before package changes unless it detects a Rocky-compatible Linux distribution on x86_64. The `--allow-unsupported-host` option is for expert testing outside the supported matrix, not a support guarantee.

If your host is already prepared, you can skip this step.

### 3. Install MISP behind a reverse proxy

The default deployment mode expects a reverse proxy in front of MISP.

```bash
sudo ./lifecycle/install.sh \
  --install-dir /opt/misp-docker \
  --upstream-ref master \
  --base-url https://misp.example.com \
  --admin-email admin@example.com \
  --admin-org ExampleOrg \
  --timezone Europe/Zurich \
  --exposure reverse-proxy
```

In `reverse-proxy` mode, the generated MISP deployment listens locally and expects your reverse proxy to publish the external HTTPS hostname.

Typical local targets:

```text
http://127.0.0.1:8080
https://127.0.0.1:8443
```

This loopback bind is the secure default for a proxy on the same host. The lifecycle manager does not modify the host firewall. In `v1.4.0`, a proxy on another host requires the explicit bind and source-restricted firewall procedure in the [production deployment guide](production-deployment.md); do not switch to `direct-qa` for production exposure.

### 4. Verify readiness and login

Run the doctor check:

```bash
sudo ./lifecycle/doctor.sh --install-dir /opt/misp-docker
```

Run the login check. TLS certificates are verified by default, and success requires a positive authenticated-session marker:

```bash
sudo ./lifecycle/login-check.sh --install-dir /opt/misp-docker
```

If a disposable local deployment still uses HTTP or a bootstrap self-signed certificate, replace that transport before production use. The explicit `--insecure` escape hatch sends administrator credentials without authenticated transport and is intended only for isolated, trusted validation environments.

Show the generated admin account without printing the password:

```bash
sudo ./lifecycle/admin-credentials.sh --install-dir /opt/misp-docker
```

Show the password only when you are on a trusted console:

```bash
sudo ./lifecycle/admin-credentials.sh \
  --install-dir /opt/misp-docker \
  --show-password
```

## Before production use

### Check component versions

Check the upstream-declared MISP component tags:

```bash
./lifecycle/get-current-misp-versions.sh
```

Compare a local deployment against upstream:

```bash
./lifecycle/get-current-misp-versions.sh --install-dir /opt/misp-docker
```

Compatibility is tracked as a pair: manager release/ref plus official MISP Docker component tags. See [Compatibility](compatibility.md).

### Take a backup before changing things

```bash
sudo ./lifecycle/backup.sh --install-dir /opt/misp-docker
```

Backups include database dump, host data, generated deployment configuration, and checksums. Read [Backup, restore, and rollback](backup-restore-and-rollback.md) before depending on backups operationally.

## What to read next

- Plan production exposure and reverse-proxy/firewall ownership: [Production deployment guide](production-deployment.md).
- Follow the full lifecycle story: [Operator guide](operator-guide.md).
- Update safely: [Upgrade path](upgrade-path.md).
- Recover from mistakes: [Backup, restore, and rollback](backup-restore-and-rollback.md).
- Debug failures: [Troubleshooting](troubleshooting.md).
