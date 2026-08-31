# Nagios XI with NCPA healthy-path integration report

## Scope

This report records a sanitized operator-confirmed integration of MISP Docker Lifecycle Manager with a running Nagios XI and NCPA deployment.

| Component | Tested version |
| --- | --- |
| MISP Docker Lifecycle Manager | `v1.4.1` |
| Nagios XI | `2026R1.6.1` |
| NCPA agent | `3.4.3-1` (`x86_64`) |
| NCPA host operating system | Rocky Linux 9 |

## Adapter shape

The NCPA agent executed a fixed custom plugin named `check_misp_dlm`. The plugin wrapper invoked the lifecycle-manager healthcheck locally with Nagios output and no caller-controlled arguments:

```bash
#!/usr/bin/env bash
exec /usr/bin/sudo -n \
  /path/to/misp-docker-lifecycle-manager/lifecycle/healthcheck.sh \
  --install-dir /opt/misp-docker \
  --format nagios \
  --timeout 20
```

The Nagios XI NCPA wizard used:

| Wizard field | Value |
| --- | --- |
| Service Description | `MISP DLM Health` |
| Plugin Name | `check_misp_dlm` |
| Plugin Arguments | empty |

The wrapper and lifecycle-manager files must be trusted and not writable by the NCPA execution account. Where elevated access is required, sudoers should allow only the exact fixed command rather than unrestricted Docker or shell access.

## Observed result

The running integration confirmed:

- NCPA discovered and executed the custom plugin;
- Nagios XI created and ran the service check;
- a healthy managed deployment mapped to `OK`;
- Nagios XI accepted the performance data emitted after the plugin-output separator (`|`).

No credentials, deployment identifiers, raw logs, or MISP business data are included in this report.

## Evidence classification and limitations

This is **operator-confirmed healthy-path native integration evidence** for the exact versions listed above. It is not vendor certification or a universal compatibility claim.

This test did **not** deliberately exercise:

- WARNING, CRITICAL, or UNKNOWN mapping through NCPA and Nagios XI;
- recovery from a non-OK state back to OK;
- notification delivery or escalation;
- NCPA passive checks through NRDP;
- other Nagios XI, NCPA, operating-system, or lifecycle-manager versions.

Producer-side automated and disposable-deployment tests separately cover the healthcheck's healthy, UNKNOWN, controlled-CRITICAL, and recovery behavior. A future native-platform test should repeat those transitions through Nagios XI before the project describes complete status-transition and alerting validation.

## Related documentation

- [Monitoring contract and integration examples](../monitoring.md)
- [Producer-side monitoring healthcheck validation](monitoring-healthcheck-pr61.md)
- [Community monitoring integration issue](https://github.com/Tuxmint-Open-Source/misp-docker-lifecycle-manager/issues/62)
