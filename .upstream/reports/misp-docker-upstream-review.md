# Upstream MISP Docker review

## Summary

The scheduled upstream monitor detected lifecycle-sensitive changes in official `MISP/misp-docker` inputs or a new official MISP component release. Upstream commit movement without a watched-file, extracted-fact, or component-release change does not create a review.

Detected classes: **A+B+C**

Validation status: **review required / not validated**

## Lifecycle-manager context

- `VERSION` value: `1.4.1`
- Source commit at detection time: `37e4ddceeca04a55b82f2447b7a403938263cf90`

## Upstream

- Repository: `https://github.com/MISP/misp-docker.git`
- Ref: `master`
- Previous reviewed commit: `96e164e86d3ef1dd36797fc074b9e7e5544b3087`
- Current commit: `600eaec279c485cf9a7c10d2de4bc4e8b77e8c92`
- Compare: https://github.com/MISP/misp-docker/compare/96e164e86d3ef1dd36797fc074b9e7e5544b3087...600eaec279c485cf9a7c10d2de4bc4e8b77e8c92

## Detected changes

- **Class A** — Official component tag defaults changed.
- **Class A** — Official component release tags changed.
- **Class C** — Watched file changed: `template.env`
- **Class B** — Watched file changed: `docker-compose.yml`
- **Class B** — Watched file changed: `core/files/configure_misp.sh`
- **Class B** — Watched file changed: `core/files/utilities.sh`
- **Class B** — Watched configuration tree changed: `core/files/etc/misp-docker/proxy.envars.json`
- **Class B** — Watched configuration tree changed: `guard/files/entrypoint.sh`
- **Class B** — Compose service definitions changed: `misp-core`, `misp-guard`
- **Class B** — Compose interpolation-key inventory changed.
- **Class B** — Compose interpolation required/default operator contract changed.
- **Class C** — `template.env` active/commented key inventory changed.
- **Class C** — Operator guidance changed: `Production`

## Component tags

| Component | Previous | Current |
|---|---:|---:|
| `CORE_TAG` | `v2.5.48` | `v2.5.50` |
| `MODULES_TAG` | `v3.0.10` | `v3.0.12` |
| `GUARD_TAG` | `v1.2` | `v1.2` |

## Latest official component releases

| Component | Official Docker default | Latest official release | Adopted by Docker default? |
|---|---:|---:|---|
| `CORE_TAG` | `v2.5.50` | `v2.5.50` | yes |
| `MODULES_TAG` | `v3.0.12` | `v3.0.12` | yes |
| `GUARD_TAG` | `v1.2` | `v1.3` | no — review before validation |

A component release that is not yet adopted by official MISP Docker is a review signal, not an instruction to validate or support a speculative combination.

## Structured deltas

- Compose services added: none
- Compose services removed: none
- Compose interpolation keys added: `AAD_AUTH_PROPERTY_NAME`, `GUARD_PASSWORD`, `GUARD_USER`
- Compose interpolation keys removed: none
- Active template.env keys added: none
- Active template.env keys removed: none
- Commented template.env keys added: `AAD_AUTH_PROPERTY_NAME`, `GUARD_PASSWORD`, `GUARD_USER`
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
