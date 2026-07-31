# Production deployment guide

This guide describes the supported production deployment workflow for `misp-docker-lifecycle-manager` within the documented stable release scope.

`v1.4.1` is the latest published documentation/hosted-docs patch release. `v1.4.0` remains the latest validated-compatible release for the documented component tuple until `v1.4.1` exact-tag validation passes.

## Supported production shape

The validated production deployment shape is:

- one Linux server
- Docker Engine and Docker Compose plugin
- official `MISP/misp-docker` checkout managed in an install directory such as `/opt/misp-docker`
- generated `.env` and `docker-compose.override.yml`
- external reverse proxy terminating public HTTPS
- manager repository used for lifecycle operations, but not required at runtime by MISP itself

## Prerequisites

Before installation, prepare:

- a supported host OS from [`support-matrix.md`](support-matrix.md)
- root or sudo access
- working DNS for the intended public MISP URL
- firewall rules allowing the chosen external access path
- enough disk for Docker images, database growth, attachments, logs, and backups; install requires at least 10 GiB free on Docker's data-root filesystem before its initial image pull, but production capacity planning should allow substantially more
- an email address for the initial MISP administrator
- a backup location and retention plan

## Recommended exposure model

For production-like use, prefer reverse-proxy mode:

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

The reverse proxy should forward to the local HTTPS endpoint documented by the installer output and overlay docs. By default, the manager binds only `127.0.0.1:8080` and `127.0.0.1:8443`, which is the intended same-host proxy shape.

### Firewall ownership

The lifecycle manager does not modify the host firewall: it does **not** add, remove, or inspect host firewall rules. Firewall policy remains operator-owned because interface, zone, source network, and upstream network controls are deployment-specific. A successful installation therefore does not imply that a remote proxy can reach MISP.

### Reverse proxy on another host

The `--proxy-bind-address` option is available in `v1.4.0` and is not available in `v1.3.1`.

Use an explicit IPv4 bind only when the reverse proxy is on another host. Prefer the MISP host's specific interface address; `0.0.0.0` is supported as an explicit choice but listens on every IPv4 interface and therefore requires a source-restricted firewall.

```bash
sudo ./lifecycle/install.sh \
  --install-dir /opt/misp-docker \
  --upstream-ref master \
  --base-url https://misp.example.com \
  --admin-email admin@example.com \
  --admin-org ExampleOrg \
  --timezone Europe/Zurich \
  --exposure reverse-proxy \
  --proxy-bind-address 0.0.0.0
```

Allow TCP 8080/8443 only from the remote proxy's trusted source address or subnet. Docker-published ports are forwarded before ordinary host-zone input rules, so a normal `firewall-cmd --add-port` or zone rich rule is not sufficient proof of restriction. Prefer an upstream network firewall/ACL. If filtering on the Docker host, apply the restriction at the `DOCKER-USER` forwarding boundary and make it persistent with the host's managed firewall tooling.

For example, the following runtime rules accept the documentation-only proxy source and reject other sources based on the original published ports. Replace the source and integrate equivalent rules into the host's persistent firewall policy before relying on them:

```bash
sudo iptables -I DOCKER-USER 1 -p tcp -s 203.0.113.10/32 \
  -m conntrack --ctstate NEW --ctorigdstport 8443 -j ACCEPT
sudo iptables -I DOCKER-USER 2 -p tcp \
  -m conntrack --ctstate NEW --ctorigdstport 8443 -j DROP
sudo iptables -I DOCKER-USER 3 -p tcp -s 203.0.113.10/32 \
  -m conntrack --ctstate NEW --ctorigdstport 8080 -j ACCEPT
sudo iptables -I DOCKER-USER 4 -p tcp \
  -m conntrack --ctstate NEW --ctorigdstport 8080 -j DROP
```

Do not add unrestricted public port rules for 8080/8443. Confirm the persistent rules after reboot and Docker/firewall restarts. Keep TLS verification enabled between the proxy and MISP, validate that the proxy source can connect, and verify from another source that the published ports are denied.

Direct-QA mode is useful for validation and controlled QA. It is not the recommended long-term public exposure model.

## Host preparation

Run host preparation on a supported fresh host:

```bash
sudo ./lifecycle/prepare-host-rocky.sh
```

By default, host preparation does not add the current user to the Docker group. This is intentional because Docker group membership is root-equivalent on the host.

## Post-install verification

After installation, run:

```bash
sudo ./lifecycle/doctor.sh --install-dir /opt/misp-docker
sudo ./lifecycle/login-check.sh --install-dir /opt/misp-docker
sudo ./lifecycle/admin-credentials.sh --install-dir /opt/misp-docker
```

`admin-credentials.sh` hides the generated password by default. Use password-revealing options only on a trusted terminal.

## Updates

Use the update helper from a known validated manager release:

```bash
sudo ./lifecycle/update.sh --install-dir /opt/misp-docker
```

The update workflow creates a backup before changing the running stack, synchronizes official component tags, pulls images, restarts services, runs MISP database updates, waits for readiness, and runs `doctor.sh`.

For explicit component versions:

```bash
sudo ./lifecycle/update.sh \
  --install-dir /opt/misp-docker \
  --core-tag v2.5.44 \
  --modules-tag v3.0.9 \
  --guard-tag v1.2
```

Use only official upstream component tags.

## Backups

Create a backup before planned maintenance and on a regular schedule:

```bash
sudo ./lifecycle/backup.sh --install-dir /opt/misp-docker
```

Backups are sensitive. Treat database dumps and host-data archives as confidential because they can contain operational data, MISP event data, user data, and generated secrets.

See [`backup-restore-and-rollback.md`](backup-restore-and-rollback.md) for the validated restore workflow and restore-based rollback procedure.

## No-lock-in operation

The generated deployment remains a normal official `MISP/misp-docker` checkout. If this installer repository is removed after installation, operators can still inspect and manage the generated deployment with normal Docker Compose commands from the install directory.

No-lock-in behavior passed exact-tag and published-artifact validation for `v1.4.0` with the documented component tuple.

## Compatibility scope

The immutable `v1.4.0` tag and published operator-bundle artifact passed restore, browser-login, restore-based rollback, monitoring, lifecycle, and explicit remote-proxy bind validation for core `v2.5.44`, modules `v3.0.9`, and guard `v1.2`.

## What to read next

- Return to the [documentation map](README.md) and choose the user/operator path.
- Plan recovery with [Backup, restore, and rollback](backup-restore-and-rollback.md).
- Use [Operator guide](operator-guide.md) for day-2 lifecycle flow.
