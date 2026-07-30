# Compatibility validation: v1.4.0 with MISP core v2.5.44

This public-safe report records exact-tag and published-artifact validation for `misp-docker-lifecycle-manager` `v1.4.0` with the official MISP Docker component set listed below.

| Field | Value |
| --- | --- |
| Manager release/ref | `v1.4.0` |
| Manager commit | `a94dd7dbf1bb3d13a2342c9c95f36f6695eae4fc` |
| MISP core tag | `v2.5.44` |
| MISP modules tag | `v3.0.9` |
| MISP guard tag | `v1.2` |
| Validation date | 2026-07-30 |
| Overall result | ✅ Validated compatible |
| Total duration | 3239 seconds |

## Scope

The validation covered the immutable `v1.4.0` release tag and the published `v1.4.0` operator-bundle artifact from the same GitHub Release. The bundle was downloaded and checksum-verified before validation, then compared against an exact-tag rebuild at the payload and manifest level.

The standard ten-scenario lifecycle matrix used the published bundle as its source. Because explicit remote reverse-proxy binding is new in `v1.4.0`, a separate release-specific gate also installed that published bundle with an explicit remote bind and exercised source filtering, verified backend TLS, browser login, update preservation, and cleanup on approved disposable infrastructure.

## Scenario results

| Scenario | Result | Evidence summary |
| --- | --- | --- |
| Direct-QA fresh install | ✅ Passed | Install, doctor, login check, default credential display, and `installer/` wrapper smoke passed. |
| Browser login validation | ✅ Passed | Chromium reached the login page and authenticated without exposing the generated password. |
| Reverse-proxy fresh install | ✅ Passed | Reverse-proxy deployment, verified-TLS login, invalid-credential rejection, explicit insecure mode, and healthcheck login integration passed. |
| Upgrade path | ✅ Passed | Explicit baseline component-tag install updated to the target component tuple with doctor and login checks passing afterward. |
| Restore-based rollback | ✅ Passed | A failed update created a pre-update backup; restore recovered the deployment and post-restore doctor/login checks passed. |
| Backup, reset dry-run, and no-lock-in smoke | ✅ Passed | Backup completed, reset dry-run remained non-destructive, manual Compose configuration worked from the generated upstream checkout, and login still passed. |
| Restore drill | ✅ Passed | Backup artifacts and checksums were present, destructive reset removed deployment state, restore completed, and doctor/login passed afterward. |
| Failure-mode guardrails | ✅ Passed | Direct-QA loopback URL was rejected before creating deployment state. |
| Monitoring healthcheck | ✅ Passed | JSON, Nagios, Checkmk, and Prometheus contracts passed; healthy, missing-deployment, controlled-outage, and recovery states mapped correctly. |
| Structured SOS privacy | ✅ Passed | The SOS report stayed bounded, used restrictive permissions, and omitted credentials, private paths, backup metadata, and raw helper output. |
| Explicit remote reverse proxy | ✅ Passed | The published bundle preserved explicit bind state across install/update; Docker-aware filtering allowed the proxy and denied a separate source; verified backend TLS, redirect, login page, and authenticated browser login passed before and after update. |

## Cleanup

The disposable validation environment was returned to a clean, residue-free state after the gate completed.

## Notes and limitations

- The result applies only to the listed manager release and official component tuple.
- The remote-proxy gate validates the documented explicit IPv4 bind and source-restricted Docker forwarding model; it does not claim that every proxy, firewall platform, certificate authority, network topology, or IPv6 configuration is supported.
- Native ingestion by running Zabbix, Checkmk, Nagios/Icinga, and Prometheus systems remains separate community testing work. This validation covers producer-side output contracts and status mapping.
- Raw logs, private infrastructure identifiers, credentials, and access details are intentionally excluded from this public report.
- Future manager releases, upstream component sets, deployment topologies, or custom images require separate validation before compatibility is claimed.
