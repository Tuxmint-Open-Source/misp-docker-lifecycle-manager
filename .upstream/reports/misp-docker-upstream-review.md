# Upstream MISP Docker review

## Summary

The scheduled upstream monitor detected lifecycle-sensitive changes in official `MISP/misp-docker` inputs or a new official MISP component release. Upstream commit movement without a watched-file, extracted-fact, or component-release change does not create a review.

Detected classes: **A**

Validation status: **reviewed / no adopted component change**

## Reviewed disposition

MISP core `v2.5.46` is a new official release containing security hardening, performance improvements, user-interface work, and other fixes. Official MISP Docker still selects core `v2.5.45`; its source commit and the complete watched-input fingerprints are unchanged. Modules `v3.0.10` and guard `v1.3` also remain unadopted.

The currently adopted and validated tuple therefore remains manager `v1.4.1` with core `v2.5.45`, modules `v3.0.9`, and guard `v1.2`. No manager code, documentation, or compatibility-validation change is required unless official MISP Docker adopts a different component set or another watched input changes.

## Lifecycle-manager context

- `VERSION` value: `1.4.1`
- Source commit at detection time: `c063fdc035e7be72640407f61e9aa481843a5da7`

## Upstream

- Repository: `https://github.com/MISP/misp-docker.git`
- Ref: `master`
- Previous reviewed commit: `9bf1372d76d82e08fc4ca121cb47a3913e7cbf53`
- Current commit: `9bf1372d76d82e08fc4ca121cb47a3913e7cbf53`
- Compare: https://github.com/MISP/misp-docker/compare/9bf1372d76d82e08fc4ca121cb47a3913e7cbf53...9bf1372d76d82e08fc4ca121cb47a3913e7cbf53

## Detected changes

- **Class A** — Official component release tags changed.

## Component tags

| Component | Previous | Current |
|---|---:|---:|
| `CORE_TAG` | `v2.5.45` | `v2.5.45` |
| `MODULES_TAG` | `v3.0.9` | `v3.0.9` |
| `GUARD_TAG` | `v1.2` | `v1.2` |

## Latest official component releases

| Component | Official Docker default | Latest official release | Adopted by Docker default? |
|---|---:|---:|---|
| `CORE_TAG` | `v2.5.45` | `v2.5.46` | no — review before validation |
| `MODULES_TAG` | `v3.0.9` | `v3.0.10` | no — review before validation |
| `GUARD_TAG` | `v1.2` | `v1.3` | no — review before validation |

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

- [x] Inspected the upstream comparison; the official MISP Docker commit did not move.
- [x] Checked the core `v2.5.46` release notes and the existing modules `v3.0.10` and guard `v1.3` release signals.
- [x] Confirmed none of the newer component releases is adopted by official MISP Docker.
- [x] Confirmed Compose services, image expressions, ports, volumes, dependencies, profiles, healthchecks, and interpolation variables are unchanged.
- [x] Confirmed template environment and critical/minimum environment inventories are unchanged.
- [x] Confirmed watched initialization, configuration, migration, startup, and readiness inputs are unchanged.
- [x] Confirmed watched operator guidance is unchanged.
- [x] Decided that no manager code or documentation change is required.
- [x] Ran repository validation: unit tests, Bash syntax, Python compilation, workflow-YAML parsing, whitespace, and public-safety checks passed.
- [x] Confirmed compatibility validation is not triggered because the adopted component tuple is unchanged.
- [x] Kept compatibility documentation scoped to the existing validated tuple.

## Compatibility note

This upstream-review report is a drift-detection prompt, not compatibility proof by itself. A listed manager release/ref and component set becomes **validated compatible** only after the documented compatibility scenarios pass and [public compatibility evidence](../../docs/compatibility.md) is updated.

## Validation command

```bash
python3 scripts/check-upstream-misp-docker.py --check
```
