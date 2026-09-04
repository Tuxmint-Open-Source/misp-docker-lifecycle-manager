# Compatibility validation: v1.4.1 with MISP core v2.5.45

This public-safe report records exact-tag and published-artifact validation for `misp-docker-lifecycle-manager` `v1.4.1` with the official MISP Docker component set listed below.

| Field | Value |
| --- | --- |
| Manager release/ref | `v1.4.1` |
| Manager commit | `a5cdd48ab22b2b7e7e0370f853bc2631b05f3ad8` |
| MISP core tag | `v2.5.45` |
| MISP modules tag | `v3.0.9` |
| MISP guard tag | `v1.2` |
| Validation date | 2026-09-03 |
| Overall result | ✅ Validated compatible |
| Scenario count | 11 |

## Scope

The validation covered the immutable `v1.4.1` release tag and the checksum-verified published `v1.4.1` operator-bundle artifact from the same GitHub Release.

Official MISP Docker adopted core `v2.5.45` while retaining modules `v3.0.9` and guard `v1.2`. The standard ten-scenario lifecycle matrix used the published bundle as its source. To preserve the established `v1.4.1` trust bar, an eleventh gate also verified artifact/tag payload equivalence, installed the published bundle with an explicit remote reverse-proxy bind, and exercised source filtering, verified backend TLS, browser login, update preservation, and cleanup on approved disposable infrastructure.

## Scenario results

| Scenario | Result | Evidence summary |
| --- | --- | --- |
| Direct-QA fresh install | ✅ Passed | Install, doctor, login check, default credential display, and `installer/` wrapper smoke passed. |
| Browser login validation | ✅ Passed | Chromium reached the login page, required positive same-origin authenticated-session evidence, rejected invalid credentials, and completed without exposing the generated password. |
| Reverse-proxy fresh install | ✅ Passed | Reverse-proxy deployment, verified-TLS login, invalid-credential rejection, explicit insecure validation mode, and healthcheck login integration passed. |
| Upgrade path | ✅ Passed | Explicit baseline component-tag install updated to the target component tuple with doctor and login checks passing afterward. |
| Restore-based rollback | ✅ Passed | A failed update created a pre-update backup; restore recovered the deployment and post-restore doctor/login checks passed. |
| Backup, reset dry-run, and no-lock-in smoke | ✅ Passed | Backup completed, reset dry-run remained non-destructive, manual Compose configuration worked from the generated upstream checkout, and login still passed. |
| Restore drill | ✅ Passed | Backup artifacts and checksums were present, destructive reset removed deployment state, restore completed, and doctor/login passed afterward. |
| Failure-mode guardrails | ✅ Passed | Direct-QA loopback URL was rejected before creating deployment state. |
| Monitoring healthcheck | ✅ Passed | JSON, Nagios, Checkmk, and Prometheus contracts passed; healthy, missing-deployment, controlled-outage, and recovery states mapped correctly. |
| Structured SOS privacy | ✅ Passed | The SOS report stayed bounded, used restrictive permissions, and omitted credentials, deployment-sensitive values, backup metadata, and raw helper output. |
| Explicit remote reverse proxy | ✅ Passed | The published bundle matched the immutable tag payload, preserved explicit bind state across install/update, allowed only the designated proxy source, denied a separate source, verified backend and frontend TLS, and passed positive and negative browser-authentication checks. |

## Cleanup

The disposable validation environment was returned to its approved clean state after every gate completed.

## Notes and limitations

- The result applies only to the listed manager release and official component tuple.
- `v1.4.1` remains the latest published and latest validated manager release; this report validates an additional official component tuple and does not create a new manager release.
- Guard `v1.3` was not part of this validation because official MISP Docker had not adopted it in the reviewed component defaults.
- The remote-proxy gate validates the documented explicit IPv4 bind and source-restricted Docker forwarding model; it does not claim that every proxy, firewall platform, certificate authority, network topology, or IPv6 configuration is supported.
- Native monitoring-platform evidence remains scoped separately. Producer-side output contracts and state mapping are validated, and a named Nagios XI/NCPA healthy path has separate operator-confirmed evidence; other native integrations and non-OK notification behavior remain unvalidated.
- Raw logs, private infrastructure identifiers, credentials, and access details are intentionally excluded from this public report.
- Future manager releases, upstream component sets, deployment topologies, or custom images require separate validation before compatibility is claimed.
