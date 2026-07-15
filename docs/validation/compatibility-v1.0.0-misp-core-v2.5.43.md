# Compatibility validation: v1.0.0 with MISP core v2.5.43

## Summary

| Field | Value |
| --- | --- |
| Manager release/ref | `v1.0.0` |
| Manager commit | `e4a4565faab58871431744fb4b485eb6002b6193` |
| Manager version | `1.0.0` |
| MISP core tag | `v2.5.43` |
| MISP modules tag | `v3.0.8` |
| MISP guard tag | `v1.2` |
| Validation date | 2026-07-15 |
| Overall result | ✅ Validated compatible |
| Total duration | 2300 seconds |

This validates the final immutable `v1.0.0` release tag with the documented official MISP Docker component set.

## Scenarios

| Scenario | Result | Duration |
| --- | --- | ---: |
| Direct-QA fresh install | ✅ Passed | 234s |
| Reverse-proxy fresh install with Caddy | ✅ Passed | 267s |
| Install baseline tags and run update path | ✅ Passed | 366s |
| Backup, reset dry-run, and no-lock-in smoke | ✅ Passed | 251s |
| Failure-mode guardrails smoke | ✅ Passed | 0s |
| Restore drill from backup into clean deployment scope | ✅ Passed | 321s |
| Browser login validation for current manager ref | ✅ Passed | 284s |
| Restore-based rollback after failed update | ✅ Passed | 376s |

## Evidence summary

The validation confirmed that:

- direct fresh install completed and `doctor.sh` / `login-check.sh` passed;
- reverse-proxy mode completed behind a Caddy fixture and login passed through the proxied URL;
- explicit baseline component-tag install updated successfully with version-tags image tracking;
- backup, reset dry-run, and no-lock-in Compose usage passed;
- invalid direct-QA `BASE_URL` input was rejected before writing deployment `.env` state;
- restore from backup recovered generated config, host-mounted data, and database state;
- browser login reached an authenticated MISP page without printing the password;
- restore-based rollback recovered after a simulated failed update using the external pre-update backup.

## Limitations

This report covers the exact manager tag and component set listed above.
It does not imply compatibility with future upstream MISP component tags, custom images, forks, Kubernetes, high-availability deployments, or broader operating-system coverage.

Public validation evidence is intentionally summarized. Raw logs, private infrastructure identifiers, private hostnames/IP addresses, credentials, topology, and deployment-specific details are omitted.

## What to read next

- [Compatibility matrix](../compatibility.md)
- [Validation matrix](matrix.md)
- [Production readiness](../production-readiness.md)
- [Backup, restore, and rollback](../backup-restore-and-rollback.md)
