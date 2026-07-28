#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

usage() {
  cat <<'EOF'
Install a production-oriented MISP Docker deployment.

Usage:
  ./lifecycle/install.sh [options]

What this script does:
  1. Optionally prepares a Rocky Linux host for Docker.
  2. Clones or updates the official MISP/misp-docker upstream checkout.
  3. Generates a secret-bearing .env from upstream template.env.
  4. Renders docker-compose.override.yml for the selected exposure mode.
  5. Optionally creates a bootstrap self-signed TLS certificate.
  6. Validates Compose config, starts containers, runs MISP DB updates,
     checks schema readiness, and runs doctor.

Options:
  --install-dir PATH      Deployment directory for official misp-docker checkout
                          (default: /opt/misp-docker)
  --upstream-repo URL     Upstream git repository (default: official MISP/misp-docker)
  --upstream-ref REF      Upstream branch, tag, or commit (default: master)
  --core-tag TAG          Explicit misp-core image/component tag override
  --modules-tag TAG       Explicit misp-modules image/component tag override
  --guard-tag TAG         Explicit misp-guard image/component tag override
  --base-url URL          Public MISP URL (required), e.g. https://misp.example.com
  --admin-email EMAIL     Initial MISP admin email (required)
  --admin-org NAME        Initial MISP organization name (required)
  --timezone TZ           Container timezone (default: Europe/Zurich)
  --exposure MODE         reverse-proxy or direct-qa (default: reverse-proxy)
  --proxy-bind-address IP IPv4 host bind for reverse-proxy mode
                          (default: 127.0.0.1; use 0.0.0.0 only with a source-restricted firewall)
  --prepare-host          Install Docker packages on Rocky Linux first
  --bootstrap-tls         Generate a bootstrap self-signed certificate
  --no-start              Generate files only; do not pull/start containers
  -h, --help              Show this help
  --version               Show manager version

Exposure modes:
  reverse-proxy  Binds MISP to 127.0.0.1 ports 8080/8443 by default.
  direct-qa      Binds MISP directly to host ports 80/443 for lab testing only.
EOF
}

UPSTREAM_REPO="https://github.com/MISP/misp-docker.git"
UPSTREAM_REF="master"
CORE_TAG_OVERRIDE=""
MODULES_TAG_OVERRIDE=""
GUARD_TAG_OVERRIDE=""
INSTALL_DIR="/opt/misp-docker"
BASE_URL=""
ADMIN_EMAIL=""
ADMIN_ORG=""
TIMEZONE="Europe/Zurich"
EXPOSURE="reverse-proxy"
PROXY_BIND_ADDRESS="127.0.0.1"
PROXY_BIND_EXPLICIT="false"
PREPARE_HOST="false"
BOOTSTRAP_TLS="false"
START="true"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --upstream-repo) UPSTREAM_REPO="$2"; shift 2;;
    --upstream-ref) UPSTREAM_REF="$2"; shift 2;;
    --core-tag) CORE_TAG_OVERRIDE="$2"; shift 2;;
    --modules-tag) MODULES_TAG_OVERRIDE="$2"; shift 2;;
    --guard-tag) GUARD_TAG_OVERRIDE="$2"; shift 2;;
    --install-dir) INSTALL_DIR="$2"; shift 2;;
    --base-url) BASE_URL="$2"; shift 2;;
    --admin-email) ADMIN_EMAIL="$2"; shift 2;;
    --admin-org) ADMIN_ORG="$2"; shift 2;;
    --timezone) TIMEZONE="$2"; shift 2;;
    --exposure) EXPOSURE="$2"; shift 2;;
    --proxy-bind-address) PROXY_BIND_ADDRESS="$2"; PROXY_BIND_EXPLICIT="true"; shift 2;;
    --prepare-host) PREPARE_HOST="true"; shift;;
    --bootstrap-tls) BOOTSTRAP_TLS="true"; shift;;
    --no-start) START="false"; shift;;
    -h|--help) usage; exit 0;;
    --version) print_version; exit 0;;
    *) fatal "Unknown argument: $1";;
  esac
done

[[ -n "$BASE_URL" ]] || fatal "--base-url is required"
[[ -n "$ADMIN_EMAIL" ]] || fatal "--admin-email is required"
[[ -n "$ADMIN_ORG" ]] || fatal "--admin-org is required"
[[ "$EXPOSURE" =~ ^(reverse-proxy|direct-qa)$ ]] || fatal "--exposure must be reverse-proxy or direct-qa"
validate_public_base_url "$BASE_URL" "$EXPOSURE"
if [[ "$EXPOSURE" == reverse-proxy ]]; then
  PROXY_BIND_ADDRESS="$(validate_proxy_bind_address "$PROXY_BIND_ADDRESS")"
elif [[ "$PROXY_BIND_EXPLICIT" == true ]]; then
  fatal "--proxy-bind-address is only valid with --exposure reverse-proxy"
else
  PROXY_BIND_ADDRESS=""
fi
validate_env_inputs "$ADMIN_EMAIL" "$ADMIN_ORG" "$TIMEZONE" "$CORE_TAG_OVERRIDE" "$MODULES_TAG_OVERRIDE" "$GUARD_TAG_OVERRIDE"
validate_upstream_source "$UPSTREAM_REPO" "$UPSTREAM_REF"
acquire_operation_lock "$INSTALL_DIR"
[[ ! -e "$INSTALL_DIR/.env" && ! -e "$INSTALL_DIR/.installer-state.json" ]] || fatal "$INSTALL_DIR already contains a managed deployment; use update.sh instead of install.sh"

# Host preparation is optional so operators can manage Docker themselves.
[[ "$PREPARE_HOST" == true ]] && "$SCRIPT_DIR/prepare-host-rocky.sh"

# Keep upstream clean: fetch official files, then add generated config beside them.
"$SCRIPT_DIR/fetch-upstream.sh" --upstream-repo "$UPSTREAM_REPO" --upstream-ref "$UPSTREAM_REF" --install-dir "$INSTALL_DIR"
generate_env_args=(--install-dir "$INSTALL_DIR" --base-url "$BASE_URL" --admin-email "$ADMIN_EMAIL" --admin-org "$ADMIN_ORG" --timezone "$TIMEZONE" --exposure "$EXPOSURE" --core-tag "$CORE_TAG_OVERRIDE" --modules-tag "$MODULES_TAG_OVERRIDE" --guard-tag "$GUARD_TAG_OVERRIDE")
[[ "$EXPOSURE" == reverse-proxy ]] && generate_env_args+=(--proxy-bind-address "$PROXY_BIND_ADDRESS")
"$SCRIPT_DIR/generate-env.sh" "${generate_env_args[@]}"
"$SCRIPT_DIR/render-compose.sh" --install-dir "$INSTALL_DIR" --exposure "$EXPOSURE"

if [[ "$BOOTSTRAP_TLS" == true ]]; then
  fqdn="$(url_hostname "$BASE_URL" "misp.example.com")"
  "$SCRIPT_DIR/bootstrap-tls.sh" --install-dir "$INSTALL_DIR" --fqdn "$fqdn"
fi

"$SCRIPT_DIR/validate.sh" --install-dir "$INSTALL_DIR"

if [[ "$START" == true ]]; then
  check_docker_storage_capacity
  compose_cmd "$INSTALL_DIR" pull
  operation_started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  compose_cmd "$INSTALL_DIR" up -d
  wait_for_misp_core "$INSTALL_DIR" 600
  run_misp_db_updates "$INSTALL_DIR"
  check_misp_schema_ready "$INSTALL_DIR"
  wait_for_misp_live_marker "$INSTALL_DIR" 900 "$operation_started_at"
  "$SCRIPT_DIR/doctor.sh" --install-dir "$INSTALL_DIR"
  stack_status="started"
  login_status="ready (MISP live marker observed during this startup)"
else
  stack_status="skipped (--no-start)"
  login_status="not checked"
fi

resolved_commit="$(git -C "$INSTALL_DIR" rev-parse HEAD)"
write_state "$INSTALL_DIR/.installer-state.json" "$UPSTREAM_REPO" "$UPSTREAM_REF" "$resolved_commit" "$INSTALL_DIR" "$EXPOSURE" "$BASE_URL" "$PROXY_BIND_ADDRESS"
cat <<EOF

Installation complete.
MISP URL: $BASE_URL
Admin email: $ADMIN_EMAIL
Admin password: stored in $INSTALL_DIR/.env
Credentials helper: sudo ./lifecycle/admin-credentials.sh --install-dir $INSTALL_DIR
Install dir: $INSTALL_DIR
Exposure mode: $EXPOSURE
Proxy bind address: ${PROXY_BIND_ADDRESS:-not applicable}
Stack start: $stack_status
Interactive login: $login_status
Manager version: $(installer_version)
EOF
