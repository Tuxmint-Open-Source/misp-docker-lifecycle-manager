# Upstream MISP Docker review

## Summary

The scheduled upstream monitor detected lifecycle-sensitive changes in official `MISP/misp-docker` inputs or a new official MISP component release. Upstream commit movement without a watched-file, extracted-fact, or component-release change does not create a review.

Detected classes: **A+C**

Validation status: **reviewed / compatibility validation passed / public evidence pending**

## Reviewed disposition

Official MISP Docker now adopts core `v2.5.45` with modules `v3.0.9` and guard `v1.2`. Across the three upstream commits, the watched single-server Docker input change is the `CORE_TAG` default moving from `v2.5.44` to `v2.5.45`. The other changes update an image-build dependency and Kubernetes packaging; they do not change the Compose, environment-key inventory, initialization, migration, readiness, settings-enforcement, or watched operator-guidance contracts consumed by this manager.

The complete published-artifact compatibility matrix passed for manager `v1.4.1` with core `v2.5.45`, modules `v3.0.9`, and guard `v1.2`, including all ten baseline scenarios and the release-specific remote-proxy gate. No manager code change is required for this upstream adoption. Public compatibility claims remain unchanged until a focused evidence PR publishes the sanitized report. Guard `v1.3` remains an early review signal because official MISP Docker has not adopted it.

## Lifecycle-manager context

- `VERSION` value: `1.4.1`
- Source commit at detection time: `aed924814dd5749c248c4702641035c20d42291e`

## Upstream

- Repository: `https://github.com/MISP/misp-docker.git`
- Ref: `master`
- Previous reviewed commit: `223b675c4480730832f928e113b6f2e5260b450d`
- Current commit: `9bf1372d76d82e08fc4ca121cb47a3913e7cbf53`
- Compare: https://github.com/MISP/misp-docker/compare/223b675c4480730832f928e113b6f2e5260b450d...9bf1372d76d82e08fc4ca121cb47a3913e7cbf53

## Detected changes

- **Class A** — Official component tag defaults changed.
- **Class A** — Official component release tags changed.
- **Class C** — Watched file changed: `template.env`

## Component tags

| Component | Previous | Current |
|---|---:|---:|
| `CORE_TAG` | `v2.5.44` | `v2.5.45` |
| `MODULES_TAG` | `v3.0.9` | `v3.0.9` |
| `GUARD_TAG` | `v1.2` | `v1.2` |

## Latest official component releases

| Component | Official Docker default | Latest official release | Adopted by Docker default? |
|---|---:|---:|---|
| `CORE_TAG` | `v2.5.45` | `v2.5.45` | yes |
| `MODULES_TAG` | `v3.0.9` | `v3.0.9` | yes |
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

- [x] Inspected all three upstream commits; the watched single-server Docker change is the `CORE_TAG` default update.
- [x] Checked the core `v2.5.45` and guard `v1.3` release notes.
- [x] Confirmed core `v2.5.45` is adopted by official MISP Docker and guard `v1.3` is not.
- [x] Confirmed Compose services, image expressions, interpolation contracts, and environment-key inventories are unchanged.
- [x] Confirmed watched initialization, migration, readiness, settings-enforcement, and operator-guidance inputs are unchanged.
- [x] Confirmed the additional upstream changes are limited to an image-build dependency and Kubernetes packaging outside the manager's consumed contract.
- [x] Decided that the upstream diff requires no manager code change.
- [x] Ran repository validation before merge: 177 tests passed with one expected skip, plus Bash syntax, Python compilation, YAML parsing, whitespace, and public-safety checks.
- [x] Ran the complete published-artifact compatibility matrix for manager `v1.4.1` with core `v2.5.45`, modules `v3.0.9`, and guard `v1.2`; all ten baseline scenarios and the release-specific remote-proxy gate passed.
- [ ] Publish the sanitized compatibility report and update public compatibility docs in a focused evidence PR.

## Compatibility note

This upstream-review report is a drift-detection prompt, not compatibility proof by itself. A listed manager release/ref and component set becomes **validated compatible** only after the documented compatibility scenarios pass and [public compatibility evidence](../../docs/compatibility.md) is updated.

## Validation command

```bash
python3 scripts/check-upstream-misp-docker.py --check
```
