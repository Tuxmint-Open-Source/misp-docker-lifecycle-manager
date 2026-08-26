# Upstream MISP Docker review

## Summary

The scheduled upstream monitor detected lifecycle-sensitive changes in official `MISP/misp-docker` inputs or a new official MISP component release. Upstream commit movement without a watched-file, extracted-fact, or component-release change does not create a review.

Detected classes: **A**

Validation status: **reviewed / not adopted by official MISP Docker / not validated**

## Reviewed disposition

MISP core `v2.5.45` is a substantial upstream release, including UI, LDAP, security, scheduler, API, and packaging changes. The official `MISP/misp-docker` defaults and all watched lifecycle inputs remain unchanged at this review point: core `v2.5.44`, modules `v3.0.9`, and guard `v1.2`.

No lifecycle-manager code, documentation, or compatibility claim changes are needed now. Do not validate or advertise the speculative core `v2.5.45` combination before official MISP Docker adopts it. Reassess and run the applicable exact manager-ref × component-set validation when adoption or another concrete supported-combination decision occurs.

## Lifecycle-manager context

- `VERSION` value: `1.4.1`
- Source commit at detection time: `578cd1fb0fd5aa404cc0ae7964b06f7aeb373be6`

## Upstream

- Repository: `https://github.com/MISP/misp-docker.git`
- Ref: `master`
- Previous reviewed commit: `223b675c4480730832f928e113b6f2e5260b450d`
- Current commit: `223b675c4480730832f928e113b6f2e5260b450d`
- Compare: https://github.com/MISP/misp-docker/compare/223b675c4480730832f928e113b6f2e5260b450d...223b675c4480730832f928e113b6f2e5260b450d

## Detected changes

- **Class A** — Official component release tags changed.

## Component tags

| Component | Previous | Current |
|---|---:|---:|
| `CORE_TAG` | `v2.5.44` | `v2.5.44` |
| `MODULES_TAG` | `v3.0.9` | `v3.0.9` |
| `GUARD_TAG` | `v1.2` | `v1.2` |

## Latest official component releases

| Component | Official Docker default | Latest official release | Adopted by Docker default? |
|---|---:|---:|---|
| `CORE_TAG` | `v2.5.44` | `v2.5.45` | no — review before validation |
| `MODULES_TAG` | `v3.0.9` | `v3.0.9` | yes |
| `GUARD_TAG` | `v1.2` | `v1.2` | yes |

A component release that is not yet adopted by official MISP Docker is a review signal, not an instruction to validate or support a speculative combination.

## Structured deltas

- Compose services added: none
- Compose services removed: none
- Compose interpolation keys added: none
- Compose interpolation keys removed: none
- Active template.env keys added: none
- Active template.env keys removed: none
- Commented template.env keys added: none
- Commented template.env keys removed: none

## Classification

- **A:** an official component release or component/runtime image tag default changed.
- **B:** Compose structure or runtime/configuration behavior changed, including service blocks, ports, volumes, dependencies, profiles, healthchecks, entrypoint/configuration scripts, or critical/minimum environment definitions.
- **C:** template environment inventory or selected operator guidance changed.

## Review checklist

- [x] Inspected the upstream release and compare information; the release contains broad core changes.
- [x] Checked upstream component release notes for core `v2.5.45`.
- [x] Confirmed core `v2.5.45` is not adopted by official MISP Docker.
- [x] Confirmed Compose services, images, interpolation contracts, and environment-key inventories are unchanged.
- [x] Confirmed watched entrypoint, configuration, migration, startup, readiness, and operator-guidance inputs are unchanged.
- [x] Decided that no manager code or documentation change is needed before official adoption.
- [x] Ran repository validation before merge: 177 tests passed with one expected skip, plus Bash syntax, Python compilation, whitespace, and public-safety checks.
- [x] Deferred compatibility validation because the new core release is not an official Docker-adopted component set.
- [x] Kept compatibility documentation unchanged; current evidence remains scoped to manager `v1.4.1` with core `v2.5.44`, modules `v3.0.9`, and guard `v1.2`.

## Compatibility note

This upstream-review report is a drift-detection prompt, not compatibility proof by itself. A listed manager release/ref and component set becomes **validated compatible** only after the documented compatibility scenarios pass and [public compatibility evidence](../../docs/compatibility.md) is updated.

## Validation command

```bash
python3 scripts/check-upstream-misp-docker.py --check
```
