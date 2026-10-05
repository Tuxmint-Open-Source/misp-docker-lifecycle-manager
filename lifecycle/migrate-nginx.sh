#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
Convert a standard legacy CORE_* deployment to separated NGINX_* generated config.

Usage:
  ./lifecycle/migrate-nginx.sh [options]

Options:
  --install-dir PATH      Deployment directory to convert (default: /opt/misp-docker)
  --backup-root PATH      Backup output directory passed through to backup.sh
  --apply                 Perform the conversion after a validated backup exists
  -h, --help              Show this help
  --version               Show manager version

Default behavior is a dry run: the command runs plan-nginx-migration.sh and
prints the non-mutating readiness plan. It changes files only when --apply is
provided. Apply mode fails closed on any planner blocker, requires the checked
out upstream template.env to use the separated NGINX contract, runs backup.sh
first, and only then atomically replaces .env, docker-compose.override.yml, and
.installer-state.json.

This first conversion slice supports only recognized standard legacy layouts.
Custom overrides, mixed/incomplete port families, nonstandard port mappings,
renamed-variable conflicts, and DISABLE_SSL_REDIRECT require manual review.
EOF
}

INSTALL_DIR="/opt/misp-docker"
BACKUP_ROOT=""
APPLY="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --install-dir) INSTALL_DIR="${2:-}"; shift 2;;
    --backup-root) BACKUP_ROOT="${2:-}"; shift 2;;
    --apply) APPLY="true"; shift;;
    -h|--help) usage; exit 0;;
    --version) print_version; exit 0;;
    *) fatal "Unknown argument: $1";;
  esac
done

[[ -n "$INSTALL_DIR" ]] || fatal "--install-dir requires a path"

if [[ "$APPLY" != true ]]; then
  dry_run_status=0
  "$SCRIPT_DIR/plan-nginx-migration.sh" --install-dir "$INSTALL_DIR" || dry_run_status=$?
  warn "Dry-run only: no files changed. Re-run with --apply only after reviewing the plan and rollback path."
  exit "$dry_run_status"
fi

acquire_operation_lock "$INSTALL_DIR"
[[ -d "$INSTALL_DIR" ]] || fatal "Install dir missing: $INSTALL_DIR"
[[ -f "$INSTALL_DIR/template.env" ]] || fatal "Official upstream template.env missing in $INSTALL_DIR"
[[ -f "$INSTALL_DIR/.env" ]] || fatal "$INSTALL_DIR/.env missing"
[[ -f "$INSTALL_DIR/.installer-state.json" ]] || fatal "$INSTALL_DIR/.installer-state.json missing"
[[ -f "$INSTALL_DIR/docker-compose.override.yml" ]] || fatal "$INSTALL_DIR/docker-compose.override.yml missing"
[[ -d "$INSTALL_DIR/.git" ]] || fatal "$INSTALL_DIR is not an upstream git checkout"

plan_json="$("$SCRIPT_DIR/plan-nginx-migration.sh" --install-dir "$INSTALL_DIR" --format json)" || {
  printf '%s\n' "$plan_json" >&2
  fatal "NGINX migration planner reported blockers; no backup or mutation was attempted."
}

python3 - "$plan_json" <<'PY'
import json
import sys
try:
    plan = json.loads(sys.argv[1])
except Exception as exc:
    raise SystemExit(f'unable to parse migration plan: {exc}')
blockers = plan.get('blockers')
if blockers:
    raise SystemExit('migration plan has blockers; refusing to apply')
if plan.get('classification') != 'legacy_complete':
    raise SystemExit('deployment is not a legacy integrated-core layout requiring conversion')
if plan.get('disposition') != 'ready_for_future_migration':
    raise SystemExit('migration plan is not ready for conversion')
if plan.get('compose_override') != 'managed_legacy':
    raise SystemExit('only the managed legacy Compose override can be converted automatically')
if plan.get('port_mapping') not in {'standard_reverse_proxy_loopback', 'standard_direct_qa'}:
    raise SystemExit('only standard legacy port mappings can be converted automatically')
PY

upstream_contract="$(frontend_contract_from_template "$INSTALL_DIR/template.env")"
[[ "$upstream_contract" == nginx ]] || fatal "Checked-out upstream template.env is not the separated NGINX contract; update or select that upstream ref before applying migration."

backup_args=(--install-dir "$INSTALL_DIR")
[[ -n "$BACKUP_ROOT" ]] && backup_args+=(--backup-root "$BACKUP_ROOT")
backup_output="$("$SCRIPT_DIR/backup.sh" "${backup_args[@]}")" || fatal "backup.sh failed; no migration files were changed."
backup_dir=""
while IFS= read -r backup_line; do
  [[ -n "$backup_line" ]] && backup_dir="$backup_line"
done <<< "$backup_output"
[[ -n "$backup_dir" && -d "$backup_dir" ]] || fatal "backup.sh did not report a validated backup directory; no migration files were changed."
python3 "$PROJECT_ROOT/scripts/validate-backup.py" "$backup_dir" >/dev/null || fatal "validated backup re-check failed; no migration files were changed."

python3 - "$INSTALL_DIR" "$backup_dir" "$(installer_version)" <<'PY'
from __future__ import annotations

import datetime
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from urllib.parse import urlparse

install_dir = Path(sys.argv[1]).resolve()
backup_dir = Path(sys.argv[2]).resolve()
installer_version = sys.argv[3]

LEGACY_TO_NGINX = {
    'CORE_HTTP_PORT': 'NGINX_HTTP_PORT',
    'CORE_HTTPS_PORT': 'NGINX_HTTPS_PORT',
    'CONTENT_SECURITY_POLICY': 'NGINX_CONTENT_SECURITY_POLICY',
    'HSTS_MAX_AGE': 'NGINX_HSTS_MAX_AGE',
    'X_FRAME_OPTIONS': 'NGINX_X_FRAME_OPTIONS',
    'FASTCGI_STATUS_LISTEN': 'FASTCGI_LISTEN_STATUS',
}
NGINX_OVERRIDE = """# Generated by misp-docker-lifecycle-manager. Keep upstream docker-compose.yml unmodified.
# The separated upstream layout defines health checks for both misp-core and
# misp-nginx; do not overwrite those service-specific contracts here.
services: {}
"""
REQUIRED_ENV = {
    'BASE_URL', 'ADMIN_EMAIL', 'ADMIN_PASSWORD', 'ADMIN_KEY', 'MYSQL_PASSWORD',
    'MYSQL_ROOT_PASSWORD', 'REDIS_PASSWORD', 'ENCRYPTION_KEY', 'SALT', 'UUID',
}


def fail(message: str) -> None:
    raise SystemExit(message)


def parse_env(path: Path) -> tuple[list[str], dict[str, str], set[str]]:
    lines = path.read_text(errors='strict').splitlines()
    values: dict[str, str] = {}
    duplicates: set[str] = set()
    pattern = re.compile(r'^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=')
    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith('#'):
            continue
        match = pattern.match(line)
        if not match:
            continue
        key = match.group(1)
        if key in values:
            duplicates.add(key)
        values[key] = line.split('=', 1)[1].strip().strip('"').strip("'")
    return lines, values, duplicates


def env_text_from_legacy(lines: list[str], values: dict[str, str]) -> str:
    out: list[str] = []
    seen_targets: set[str] = set()
    assignment = re.compile(r'^(\s*)([A-Za-z_][A-Za-z0-9_]*)(\s*=.*)$')
    for line in lines:
        match = assignment.match(line)
        if not match or line.lstrip().startswith('#'):
            out.append(line)
            continue
        prefix, key, suffix = match.groups()
        replacement = LEGACY_TO_NGINX.get(key)
        if replacement:
            out.append(f'{prefix}{replacement}{suffix}')
            seen_targets.add(replacement)
        elif key not in {'NGINX_HTTP_PORT', 'NGINX_HTTPS_PORT'}:
            out.append(line)
            seen_targets.add(key)
    for source, target in LEGACY_TO_NGINX.items():
        if source in values and target not in seen_targets:
            out.append(f'{target}={values[source]}')
    return '\n'.join(out) + '\n'


def active_keys(text: str) -> dict[str, str]:
    env: dict[str, str] = {}
    for line in text.splitlines():
        stripped = line.strip()
        if stripped and not stripped.startswith('#') and '=' in stripped:
            key, value = stripped.split('=', 1)
            env[key.strip()] = value.strip().strip('"').strip("'")
    return env


def infer_exposure(env: dict[str, str]) -> tuple[str, str]:
    http = env.get('NGINX_HTTP_PORT', '')
    https = env.get('NGINX_HTTPS_PORT', '')
    if http == '80' and https == '443':
        return 'direct-qa', ''
    if http == '127.0.0.1:8080' and https == '127.0.0.1:8443':
        return 'reverse-proxy', '127.0.0.1'
    fail('converted .env does not match a supported standard NGINX port mapping')


def validate_result(env: dict[str, str], override_text: str, state: dict[str, object]) -> tuple[str, str]:
    missing = sorted(key for key in REQUIRED_ENV if not env.get(key))
    if missing:
        fail('converted .env is missing required generated values: ' + ', '.join(missing))
    if any(key in env for key in ('CORE_HTTP_PORT', 'CORE_HTTPS_PORT')):
        fail('converted .env still contains legacy CORE_* port keys')
    if not env.get('NGINX_HTTP_PORT') or not env.get('NGINX_HTTPS_PORT'):
        fail('converted .env lacks NGINX published-port keys')
    for source, target in LEGACY_TO_NGINX.items():
        if source in env:
            fail(f'converted .env still contains legacy variable {source}')
        if source in ('CORE_HTTP_PORT', 'CORE_HTTPS_PORT') or target in env:
            continue
    base_url = env.get('BASE_URL', '')
    parsed = urlparse(base_url)
    if parsed.scheme not in {'http', 'https'} or not parsed.hostname:
        fail('converted .env has invalid BASE_URL')
    exposure, proxy_bind = infer_exposure(env)
    if parsed.scheme == 'https':
        if not ((install_dir / 'ssl' / 'cert.pem').is_file() and (install_dir / 'ssl' / 'key.pem').is_file()):
            fail('HTTPS BASE_URL requires existing ssl/cert.pem and ssl/key.pem before separated NGINX migration')
    elif (install_dir / 'ssl' / 'cert.pem').exists() or (install_dir / 'ssl' / 'key.pem').exists():
        fail('HTTP BASE_URL must not be combined with existing separated-NGINX TLS files')
    if override_text != NGINX_OVERRIDE:
        fail('converted Compose override is not the managed separated-NGINX override')
    if state.get('installer') != 'misp-docker-lifecycle-manager':
        fail('state file has unexpected installer identity')
    for key in ('upstream_repo', 'upstream_ref', 'upstream_commit', 'install_dir', 'exposure', 'base_url', 'proxy_bind_address'):
        if not isinstance(state.get(key), str):
            fail(f'state field must be a string: {key}')
    if Path(str(state['install_dir'])).resolve() != install_dir:
        fail('state install directory does not match migration target')
    if state['base_url'] != base_url:
        fail('state BASE_URL would not match converted .env')
    if state['exposure'] != exposure:
        fail('state exposure would not match converted port mapping')
    if state['proxy_bind_address'] != proxy_bind:
        fail('state proxy bind would not match converted port mapping')
    if not re.fullmatch(r'[0-9a-f]{40}', str(state['upstream_commit'])):
        fail('state upstream commit is not a full Git commit ID')
    return exposure, proxy_bind


env_path = install_dir / '.env'
override_path = install_dir / 'docker-compose.override.yml'
state_path = install_dir / '.installer-state.json'
lines, old_env, duplicates = parse_env(env_path)
if duplicates & (set(LEGACY_TO_NGINX) | set(LEGACY_TO_NGINX.values()) | {'BASE_URL', 'DISABLE_SSL_REDIRECT'}):
    fail('duplicate migration-sensitive .env keys appeared after planning')
if old_env.get('DISABLE_SSL_REDIRECT', ''):
    fail('DISABLE_SSL_REDIRECT requires manual TLS redirect review')
for source, target in LEGACY_TO_NGINX.items():
    if old_env.get(source, '') and old_env.get(target, ''):
        fail(f'conflicting legacy and NGINX variables: {source}/{target}')
if not old_env.get('CORE_HTTP_PORT') or not old_env.get('CORE_HTTPS_PORT'):
    fail('source .env is no longer a complete legacy layout')
new_env_text = env_text_from_legacy(lines, old_env)
new_env = active_keys(new_env_text)
state = json.loads(state_path.read_text(errors='strict'))
if not isinstance(state, dict):
    fail('state file must contain a JSON object')
state = dict(state)
exposure, proxy_bind = infer_exposure(new_env)
if state.get('base_url') not in {None, '', new_env.get('BASE_URL')}:
    fail('state BASE_URL changed after planning')
if state.get('proxy_bind_address') not in {None, '', proxy_bind}:
    fail('state proxy bind changed after planning')
state.update({
    'installer': 'misp-docker-lifecycle-manager',
    'installer_version': installer_version,
    'updated_at_utc': datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0).isoformat().replace('+00:00', 'Z'),
    'install_dir': str(install_dir),
    'exposure': exposure,
    'base_url': new_env['BASE_URL'],
    'proxy_bind_address': proxy_bind,
})
commit = subprocess.check_output(
    ['git', '-C', str(install_dir), 'rev-parse', 'HEAD'], text=True
).strip()
state['upstream_commit'] = commit
validate_result(new_env, NGINX_OVERRIDE, state)

staging = Path(tempfile.mkdtemp(prefix='.nginx-migration.', dir=install_dir))
try:
    env_tmp = staging / '.env'
    override_tmp = staging / 'docker-compose.override.yml'
    state_tmp = staging / '.installer-state.json'
    env_tmp.write_text(new_env_text)
    os.chmod(env_tmp, 0o600)
    override_tmp.write_text(NGINX_OVERRIDE)
    os.chmod(override_tmp, 0o600)
    state_tmp.write_text(json.dumps(state, indent=2, sort_keys=True) + '\n')
    os.chmod(state_tmp, 0o600)
    staged_env = active_keys(env_tmp.read_text(errors='strict'))
    staged_state = json.loads(state_tmp.read_text(errors='strict'))
    validate_result(staged_env, override_tmp.read_text(errors='strict'), staged_state)
    for path in (env_tmp, override_tmp, state_tmp):
        with path.open('r+b') as stream:
            os.fsync(stream.fileno())
    directory_fd = os.open(staging, os.O_RDONLY)
    try:
        os.fsync(directory_fd)
    finally:
        os.close(directory_fd)
    os.replace(env_tmp, env_path)
    os.chmod(env_path, 0o600)
    os.replace(override_tmp, override_path)
    os.chmod(override_path, 0o600)
    os.replace(state_tmp, state_path)
    os.chmod(state_path, 0o600)
finally:
    for item in staging.iterdir() if staging.exists() else []:
        item.unlink(missing_ok=True)
    try:
        staging.rmdir()
    except FileNotFoundError:
        pass

final_env = active_keys(env_path.read_text(errors='strict'))
final_state = json.loads(state_path.read_text(errors='strict'))
validate_result(final_env, override_path.read_text(errors='strict'), final_state)
print(str(backup_dir))
PY

cat <<EOF
NGINX migration complete.
Backup directory: $backup_dir
Rollback: sudo ./lifecycle/restore.sh --backup-dir "$backup_dir" --install-dir "$INSTALL_DIR" --yes
Next: run sudo ./lifecycle/doctor.sh --install-dir "$INSTALL_DIR" and sudo ./lifecycle/login-check.sh --install-dir "$INSTALL_DIR" after starting or updating the stack.
EOF
