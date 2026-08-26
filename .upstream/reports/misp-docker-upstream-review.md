# Upstream MISP Docker review

## Summary

The scheduled upstream monitor detected lifecycle-sensitive changes in official `MISP/misp-docker` inputs or a new official MISP component release. Upstream commit movement without a watched-file, extracted-fact, or component-release change does not create a review.

Detected classes: **A**

Validation status: **review required / not validated**

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

- [ ] Inspect the upstream compare link; hashes and extracted facts summarize drift but do not replace review.
- [ ] Check upstream component tag changes and release notes.
- [ ] Check whether each new component release is adopted by official MISP Docker before choosing a validation combination.
- [ ] Check Compose service names, image expressions, ports, volumes, dependencies, profiles, healthchecks, and interpolation variables.
- [ ] Check new, removed, or changed required/default variables in `template.env` and the critical/minimum environment definitions.
- [ ] Check entrypoint, configuration, migration, startup, and readiness behavior.
- [ ] Check install, production, backup/restore, troubleshooting, and versioning guidance.
- [ ] Decide whether manager code, docs, or validation changes are needed.
- [ ] Run repository validation before merge.
- [ ] Run compatibility validation for the affected manager release/ref and official MISP component set when runtime or component behavior is affected.
- [ ] Update compatibility docs only after the documented compatibility scenarios pass.

## Compatibility note

This upstream-review report is a drift-detection prompt, not compatibility proof by itself. A listed manager release/ref and component set becomes **validated compatible** only after the documented compatibility scenarios pass and public compatibility evidence is updated.

## Validation command

```bash
python3 scripts/check-upstream-misp-docker.py --check
```
