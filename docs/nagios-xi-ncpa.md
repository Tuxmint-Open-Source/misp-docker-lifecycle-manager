# Configure Nagios XI with NCPA

This guide connects the MISP Docker Lifecycle Manager healthcheck to Nagios XI through an NCPA custom plugin.

The integration is an **active check**:

```text
Nagios XI -> check_ncpa.py -> NCPA listener -> fixed local wrapper -> lifecycle/healthcheck.sh
```

NCPA runs the wrapper on the MISP host. The wrapper uses fixed arguments and returns the healthcheck's Nagios-compatible output and exit code. Do not allow Nagios XI to provide arbitrary paths or healthcheck arguments.

## Prerequisites

Before starting, confirm:

- MISP DLM and the managed MISP Docker deployment are already installed and healthy;
- NCPA is installed on the MISP host and Nagios XI can query it;
- the NCPA API token is not the installation default;
- NCPA access is restricted to authorized monitoring systems using its listener controls and the host firewall;
- the NCPA TLS certificate and trust policy are configured according to your monitoring environment;
- you know the exact MISP DLM and managed deployment paths.

The examples use:

```text
MISP DLM directory:       /opt/misp-docker-lifecycle-manager
Managed MISP directory:  /opt/misp-docker
NCPA configuration:      /usr/local/ncpa/etc/ncpa.cfg
NCPA plugin directory:   /usr/local/ncpa/plugins
NCPA execution account:  nagios:nagios
```

Replace those paths and the execution account if your installation differs. Do not copy a path from this guide without checking the local system.

## 1. Confirm the NCPA plugin settings

On a default Linux NCPA installation, inspect `/usr/local/ncpa/etc/ncpa.cfg`. Confirm the execution identity and plugin directives:

```ini
[general]
uid = nagios
gid = nagios

[plugin directives]
plugin_path = plugins/
follow_symlinks = 0
plugin_timeout = 35
```

A relative `plugin_path = plugins/` normally resolves below the NCPA installation directory, commonly `/usr/local/ncpa/plugins`.

The timeout ordering in this guide is:

```text
MISP DLM healthcheck:  20 seconds
NCPA plugin timeout:   35 seconds
check_ncpa.py timeout: 40 seconds
Nagios service check:  greater than 40 seconds
```

NCPA's default plugin timeout may already be longer than 35 seconds. The important requirement is that each outer timeout is longer than the healthcheck deadline it contains.

Restart NCPA after changing `ncpa.cfg`:

```bash
sudo systemctl restart ncpa
sudo systemctl status ncpa
```

If your package uses a different service unit, use the unit provided by that package. Do not restart NCPA merely to add a plugin file when no configuration changed.

## 2. Install a fixed NCPA plugin wrapper

Create `/usr/local/ncpa/plugins/check_misp_dlm` with the following content:

```bash
#!/usr/bin/env bash
set -euo pipefail

exec /usr/bin/sudo -n \
  /opt/misp-docker-lifecycle-manager/lifecycle/healthcheck.sh \
  --install-dir /opt/misp-docker \
  --format nagios \
  --timeout 20
```

Use the canonical `lifecycle/healthcheck.sh` from the installed immutable MISP DLM release or operator bundle. Keep the filename exactly `check_misp_dlm`; the Nagios XI wizard must use the same name.

Set trusted ownership and executable permissions:

```bash
sudo chown root:nagios /usr/local/ncpa/plugins/check_misp_dlm
sudo chmod 0750 /usr/local/ncpa/plugins/check_misp_dlm
```

Also ensure that the MISP DLM directory, `lifecycle/healthcheck.sh`, and its supporting files are trusted and not writable by the `nagios` account. The account needs only traversal and read/execute access to the manager files. Do not make the managed deployment's credential files broadly readable.

Keep `follow_symlinks = 0` and install a regular wrapper file in the NCPA plugin directory. Do not use a writable symlink to expose the lifecycle command.

## 3. Permit only the fixed healthcheck through sudo

The healthcheck needs local Docker and deployment access. Do **not** add the `nagios` account to the Docker group; that grants broad root-equivalent Docker control.

Create `/etc/sudoers.d/ncpa-misp-dlm` with one exact command rule:

```sudoers
nagios ALL=(root) NOPASSWD: /opt/misp-docker-lifecycle-manager/lifecycle/healthcheck.sh --install-dir /opt/misp-docker --format nagios --timeout 20
```

Set restrictive ownership and permissions, then validate the file:

```bash
sudo chown root:root /etc/sudoers.d/ncpa-misp-dlm
sudo chmod 0440 /etc/sudoers.d/ncpa-misp-dlm
sudo visudo -cf /etc/sudoers.d/ncpa-misp-dlm
```

The sudoers command must exactly match the wrapper, including paths and arguments. If you change the healthcheck timeout or either installation path, update and revalidate both files together.

Do not grant unrestricted sudo, wildcard Docker command access, or shell-interpreter access to the NCPA account. The single exact healthcheck rule above is the complete required privilege.

## 4. Test as the NCPA execution account

First test the exact wrapper as the account configured under NCPA's `[general]` section:

```bash
sudo -u nagios /usr/local/ncpa/plugins/check_misp_dlm
printf 'exit code: %s\n' "$?"
```

A healthy deployment should return one line beginning with `OK` and exit code `0`, for example:

```text
OK - MISP lifecycle health OK | services_running=... services_expected=... checks_ok=... checks_warning=0 checks_critical=0 checks_unknown=0
exit code: 0
```

If this local test fails, do not continue to the Nagios XI wizard. Correct the local path, execute permission, sudoers match, Docker availability, or deployment health first.

On SELinux-enforcing systems such as Rocky Linux, keep SELinux enabled. If execution is denied despite correct Unix permissions, inspect the audit record and add a narrowly scoped local policy for the required execution path. Do not disable SELinux or use a broad permissive workaround.

## 5. Test through NCPA from Nagios XI

Nagios XI normally includes `check_ncpa.py` when the current NCPA wizard is installed. From the Nagios XI host, first list the NCPA plugin node:

```bash
/usr/local/nagios/libexec/check_ncpa.py \
  -H <NCPA_HOST> \
  -P 5693 \
  -t '<NCPA_TOKEN>' \
  -M plugins \
  --list \
  -T 40
```

Confirm that `check_misp_dlm` appears. Then execute it:

```bash
/usr/local/nagios/libexec/check_ncpa.py \
  -H <NCPA_HOST> \
  -P 5693 \
  -t '<NCPA_TOKEN>' \
  -M 'plugins/check_misp_dlm' \
  -T 40
```

Use the certificate-verification option supported by your installed `check_ncpa.py` and a certificate trusted by the Nagios XI host. Do not weaken certificate verification merely to make the check pass. Avoid exposing the API token in shared shell history, process captures, tickets, or screenshots.

Do not pass `-a`, warning, or critical arguments for this wrapper. MISP DLM already defines the status and exit-code contract, and the wrapper intentionally accepts no caller-controlled arguments.

## 6. Configure the Nagios XI NCPA wizard

In the wizard's **Plugins** section, enable one row and enter:

| Field | Value |
| --- | --- |
| Service Description | `MISP DLM Health` |
| Plugin Name | `check_misp_dlm` |
| Plugin Arguments | leave completely empty |

Do not enter `plugins/check_misp_dlm`, the full filesystem path, or healthcheck arguments in the wizard. The **Plugin Name** is only the filename inside NCPA's configured plugin directory.

For the service schedule, a practical starting point is:

| Wizard setting | Suggested value |
| --- | ---: |
| Normal check interval | 5 minutes |
| Retry interval after a problem | 1 minute |
| Maximum check attempts | 3 |

This runs the healthcheck every five minutes while healthy. After a non-OK result, Nagios retries once per minute and promotes a persistent problem to a hard state according to the configured maximum attempts and notification policy.

Complete the notification settings for your environment and apply the configuration.

## 7. Verify the created service

Open the `MISP DLM Health` service in Nagios XI and confirm:

- the service is active;
- **Last Check** and **Next Check** advance according to the configured interval;
- the healthy state is `OK`;
- the plugin output contains the MISP lifecycle summary;
- performance data includes values such as `services_running`, `services_expected`, and check-status counts;
- no credential, internal URL, deployment path, raw log, or MISP business data appears in the service output.

A healthy result proves the normal execution path. Before claiming complete alerting validation, separately exercise approved non-production WARNING/CRITICAL/UNKNOWN and recovery scenarios and verify the configured notifications.

## Troubleshooting

| Result | Check first |
| --- | --- |
| Plugin not listed by NCPA | `plugin_path`, filename, regular-file placement, ownership, execute permission, and whether NCPA configuration changes were followed by a restart |
| `UNKNOWN` with permission failure | NCPA `uid`/`gid`, wrapper traversal permissions, exact sudoers command match, and `sudo -n` behavior |
| Docker unavailable or permission denied | Ensure the exact wrapper invokes the approved sudo rule; do not add the NCPA account to the Docker group |
| NCPA timeout | Keep the NCPA and `check_ncpa.py` timeouts above the DLM `--timeout` |
| Nagios XI cannot connect | NCPA listener status, allowed hosts, firewall policy, API token, port, and TLS trust |
| Works as root but not through NCPA | Repeat the local test with `sudo -u nagios`; root-only testing does not validate the agent execution path |
| SELinux denial | Inspect the audit record and add only the required local policy; do not disable enforcement |
| Service remains `UNKNOWN` or `CRITICAL` | Run the healthcheck locally, then use [`doctor.sh`](shell-scripts.md#main-commands) and the [troubleshooting guide](troubleshooting.md) |

NCPA's own listener log is commonly below `/usr/local/ncpa/var/log/`, depending on its `ncpa.cfg` logfile setting. Review only the minimum needed for diagnosis and do not publish tokens or deployment-sensitive output.

## Security checklist

- [ ] NCPA API token changed from the installation default and stored only in approved secret/configuration storage.
- [ ] NCPA listener and host firewall restrict access to authorized monitoring systems.
- [ ] TLS trust is configured; certificate verification is not silently disabled.
- [ ] Wrapper is a root-owned regular file and not writable by `nagios`.
- [ ] MISP DLM operator files are not writable by `nagios`.
- [ ] `follow_symlinks = 0` remains enabled.
- [ ] Sudoers permits only the exact fixed healthcheck command.
- [ ] The NCPA account is not a member of the Docker group solely for this check.
- [ ] Plugin Arguments is empty in the Nagios XI wizard.
- [ ] Monitoring output was reviewed for public-adjacent safety.

## Related documentation

- [Monitoring contract and output formats](monitoring.md)
- [Nagios XI/NCPA healthy-path integration evidence](validation/nagios-xi-ncpa-v1.4.1.md)
- [Troubleshooting](troubleshooting.md)
- [Security model](security.md)
