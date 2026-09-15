# Upstream MISP Docker review

## Summary

The scheduled upstream monitor detected lifecycle-sensitive changes in official `MISP/misp-docker` inputs or a new official MISP component release. Upstream commit movement without a watched-file, extracted-fact, or component-release change does not create a review.

Detected classes: **A+B+C**

Validation status: **review required / not validated**

## Lifecycle-manager context

- `VERSION` value: `1.4.1`
- Source commit at detection time: `1e4f9eae8580ec03c33871c5eb2c8f71b7ea7602`

## Upstream

- Repository: `https://github.com/MISP/misp-docker.git`
- Ref: `master`
- Previous reviewed commit: `9bf1372d76d82e08fc4ca121cb47a3913e7cbf53`
- Current commit: `e8b11b9dd85c81deb6f41679f350b95b110a1d45`
- Compare: https://github.com/MISP/misp-docker/compare/9bf1372d76d82e08fc4ca121cb47a3913e7cbf53...e8b11b9dd85c81deb6f41679f350b95b110a1d45

## Detected changes

- **Class A** — Official component tag defaults changed.
- **Class C** — Watched file changed: `template.env`
- **Class B** — Watched file changed: `docker-compose.yml`
- **Class B** — Watched file changed: `core/files/entrypoint.sh`
- **Class B** — Watched file changed: `core/files/entrypoint_nginx.sh`
- **Class B** — Watched file changed: `core/files/configure_misp.sh`
- **Class B** — Watched file changed: `core/files/utilities.sh`
- **Class B** — Watched configuration tree changed: `core/files/etc/misp-docker/initialisation.envars.json`, `core/files/etc/misp-docker/minimum_config.defaults.json`
- **Class B** — Watched configuration tree changed: `core/files/etc/supervisor/conf.d/10-supervisor.conf`
- **Class B** — Watched configuration tree changed: `core/files/etc/nginx/.`, `core/files/etc/nginx/includes/misp`, `core/files/etc/nginx/sites-available/misp443`, `core/files/etc/nginx/sites-available/misp80`, `core/files/etc/nginx/sites-available/php-fpm-status`
- **Class B** — Compose service definitions changed: `misp-core`, `misp-nginx`
- **Class B** — Compose interpolation-key inventory changed.
- **Class B** — Compose interpolation required/default operator contract changed.
- **Class C** — `template.env` active/commented key inventory changed.
- **Class C** — Operator guidance changed: `Authentication`, `Getting Started`, `Production`, `Versioning`

## Component tags

| Component | Previous | Current |
|---|---:|---:|
| `CORE_TAG` | `v2.5.45` | `v2.5.46` |
| `MODULES_TAG` | `v3.0.9` | `v3.0.10` |
| `GUARD_TAG` | `v1.2` | `v1.2` |

## Latest official component releases

| Component | Official Docker default | Latest official release | Adopted by Docker default? |
|---|---:|---:|---|
| `CORE_TAG` | `v2.5.46` | `v2.5.46` | yes |
| `MODULES_TAG` | `v3.0.10` | `v3.0.10` | yes |
| `GUARD_TAG` | `v1.2` | `v1.3` | no — review before validation |

A component release that is not yet adopted by official MISP Docker is a review signal, not an instruction to validate or support a speculative combination.

## Structured deltas

- Compose services added: `misp-nginx`
- Compose services removed: none
- Compose interpolation keys added: `AUTH_ENFORCED`, `FASTCGI_LISTEN`, `FASTCGI_LISTEN_STATUS`, `NGINX_CONTENT_SECURITY_POLICY`, `NGINX_HSTS_MAX_AGE`, `NGINX_HTTPS_PORT`, `NGINX_HTTP_PORT`, `NGINX_X_FRAME_OPTIONS`, `PHP_LISTEN_FPM`
- Compose interpolation keys removed: `CONTENT_SECURITY_POLICY`, `CORE_HTTPS_PORT`, `CORE_HTTP_PORT`, `DISABLE_SSL_REDIRECT`, `FASTCGI_STATUS_LISTEN`, `HSTS_MAX_AGE`, `X_FRAME_OPTIONS`
- Active template.env keys added: none
- Active template.env keys removed: none
- Commented template.env keys added: `AUTH_ENFORCED`, `FASTCGI_LISTEN_STATUS`, `NGINX_CONTENT_SECURITY_POLICY`, `NGINX_HSTS_MAX_AGE`, `NGINX_HTTPS_PORT`, `NGINX_HTTP_PORT`, `NGINX_X_FRAME_OPTIONS`
- Commented template.env keys removed: `CONTENT_SECURITY_POLICY`, `CORE_HTTPS_PORT`, `CORE_HTTP_PORT`, `DISABLE_SSL_REDIRECT`, `FASTCGI_STATUS_LISTEN`, `HSTS_MAX_AGE`, `X_FRAME_OPTIONS`

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
