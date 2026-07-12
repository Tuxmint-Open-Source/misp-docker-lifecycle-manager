#!/usr/bin/env python3
"""Check official MISP/misp-docker upstream drift.

This script records public upstream facts that this installer depends on:
- template.env component tags
- docker-compose.yml service names and MISP image tag expressions
- hashes of selected upstream files

When upstream changes, it writes an updated lock file and a public-safe review
report that a scheduled GitHub Action can turn into a Pull Request.
"""
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REPO = "https://github.com/MISP/misp-docker.git"
DEFAULT_REF = "master"
LOCK_PATH = ROOT / ".upstream" / "misp-docker.lock.json"
REPORT_PATH = ROOT / ".upstream" / "reports" / "misp-docker-upstream-review.md"
WATCHED_FILES = ["template.env", "docker-compose.yml", "README.md"]
COMPONENT_KEYS = ["CORE_TAG", "MODULES_TAG", "GUARD_TAG"]
RUNNING_KEYS = ["CORE_RUNNING_TAG", "MODULES_RUNNING_TAG", "GUARD_RUNNING_TAG"]


def run(cmd: list[str], cwd: Path | None = None) -> str:
    return subprocess.check_output(cmd, cwd=cwd, text=True, stderr=subprocess.STDOUT)


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8", errors="replace")).hexdigest()


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def parse_active_env(text: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in stripped:
            continue
        key, value = stripped.split("=", 1)
        values[key.strip()] = value.strip()
    return values


def parse_compose_facts(text: str) -> dict[str, object]:
    services: list[str] = []
    images: dict[str, str] = {}
    current_service: str | None = None
    in_services = False

    for line in text.splitlines():
        if re.match(r"^services:\s*$", line):
            in_services = True
            current_service = None
            continue
        if in_services and re.match(r"^[A-Za-z0-9_.-]+:\s*$", line):
            in_services = False
            current_service = None
        if not in_services:
            continue
        service_match = re.match(r"^  ([A-Za-z0-9_.-]+):\s*$", line)
        if service_match:
            current_service = service_match.group(1)
            services.append(current_service)
            continue
        image_match = re.match(r"^    image:\s*(.+?)\s*$", line)
        if image_match and current_service:
            images[current_service] = image_match.group(1).strip().strip('"')

    interesting_images = {
        service: image
        for service, image in images.items()
        if service in {"misp-core", "misp-modules", "misp-guard"}
        or "misp-docker" in image
    }
    return {"services": sorted(services), "misp_images": interesting_images}


def extract_readme_versioning(text: str) -> str:
    lines = text.splitlines()
    start = None
    for idx, line in enumerate(lines):
        if line.strip().lower() == "## versioning":
            start = idx
            break
    if start is None:
        return ""
    end = len(lines)
    for idx in range(start + 1, len(lines)):
        if lines[idx].startswith("## "):
            end = idx
            break
    return "\n".join(lines[start:end]).strip()


def clone_upstream(repo: str, ref: str, target: Path) -> str:
    run(["git", "clone", "--filter=blob:none", "--no-checkout", repo, str(target)])
    # Fetch the requested ref if it is not already available from the default clone.
    try:
        run(["git", "fetch", "--depth", "1", "origin", ref], cwd=target)
    except subprocess.CalledProcessError:
        pass
    try:
        run(["git", "checkout", "--quiet", ref], cwd=target)
    except subprocess.CalledProcessError:
        run(["git", "checkout", "--quiet", "FETCH_HEAD"], cwd=target)
    return run(["git", "rev-parse", "HEAD"], cwd=target).strip()


def collect_state(repo: str, ref: str) -> dict[str, object]:
    with tempfile.TemporaryDirectory(prefix="misp-docker-upstream-") as tmp:
        upstream = Path(tmp) / "misp-docker"
        commit = clone_upstream(repo, ref, upstream)

        file_hashes: dict[str, dict[str, str | bool]] = {}
        file_text: dict[str, str] = {}
        for rel in WATCHED_FILES:
            path = upstream / rel
            if path.exists():
                text = read_text(path)
                file_text[rel] = text
                file_hashes[rel] = {"exists": True, "sha256": sha256_text(text)}
            else:
                file_hashes[rel] = {"exists": False, "sha256": ""}

        template_values = parse_active_env(file_text.get("template.env", ""))
        component_tags = {key: template_values.get(key, "") for key in COMPONENT_KEYS}
        running_defaults = {key: template_values.get(key, "(commented or unset)") for key in RUNNING_KEYS}
        compose_facts = parse_compose_facts(file_text.get("docker-compose.yml", ""))
        readme_versioning_sha = sha256_text(extract_readme_versioning(file_text.get("README.md", "")))

        return {
            "schema": 1,
            "repo": repo,
            "ref": ref,
            "upstream_commit": commit,
            "checked_at_utc": dt.datetime.now(dt.UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
            "watched_files": file_hashes,
            "component_tags": component_tags,
            "running_tag_defaults_in_template_env": running_defaults,
            "compose": compose_facts,
            "readme_versioning_section_sha256": readme_versioning_sha,
        }


def load_lock(path: Path) -> dict[str, object] | None:
    if not path.exists():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def diff_state(old: dict[str, object] | None, new: dict[str, object]) -> list[str]:
    if old is None:
        return ["No previous upstream baseline existed."]
    changes: list[str] = []
    if old.get("upstream_commit") != new.get("upstream_commit"):
        changes.append(f"Upstream commit changed: `{old.get('upstream_commit')}` -> `{new.get('upstream_commit')}`")
    for key in ["component_tags", "running_tag_defaults_in_template_env", "compose", "readme_versioning_section_sha256"]:
        if old.get(key) != new.get(key):
            changes.append(f"`{key}` changed.")
    old_files = old.get("watched_files", {}) if isinstance(old.get("watched_files"), dict) else {}
    new_files = new.get("watched_files", {}) if isinstance(new.get("watched_files"), dict) else {}
    for rel in WATCHED_FILES:
        if old_files.get(rel) != new_files.get(rel):
            changes.append(f"Watched file changed: `{rel}`")
    return changes


def component_table(old: dict[str, object] | None, new: dict[str, object]) -> str:
    old_tags = old.get("component_tags", {}) if old else {}
    new_tags = new.get("component_tags", {})
    rows = ["| Component | Previous | Current |", "|---|---:|---:|"]
    for key in COMPONENT_KEYS:
        rows.append(f"| `{key}` | `{old_tags.get(key, '(none)')}` | `{new_tags.get(key, '')}` |")
    return "\n".join(rows)


def compare_url(old: dict[str, object] | None, new: dict[str, object]) -> str:
    repo = str(new["repo"])
    if repo.endswith(".git"):
        repo = repo[:-4]
    if repo.startswith("https://github.com/") and old and old.get("upstream_commit"):
        return f"{repo}/compare/{old['upstream_commit']}...{new['upstream_commit']}"
    if repo.startswith("https://github.com/"):
        return f"{repo}/commit/{new['upstream_commit']}"
    return ""


def render_report(old: dict[str, object] | None, new: dict[str, object], changes: list[str]) -> str:
    changed_files = []
    old_files = old.get("watched_files", {}) if old else {}
    new_files = new.get("watched_files", {})
    for rel in WATCHED_FILES:
        if not old or old_files.get(rel) != new_files.get(rel):
            changed_files.append(f"- `{rel}`")
    if not changed_files:
        changed_files.append("- No watched file hash changes detected.")

    changes_text = "\n".join(f"- {item}" for item in changes) if changes else "- No relevant upstream drift detected."
    return f"""# Upstream MISP Docker review

## Summary

The scheduled upstream monitor detected changes in official `MISP/misp-docker` inputs that this installer depends on.

## Upstream

- Repository: `{new['repo']}`
- Ref: `{new['ref']}`
- Previous reviewed commit: `{old.get('upstream_commit') if old else '(none)'}`
- Current commit: `{new['upstream_commit']}`
- Compare: {compare_url(old, new)}

## Detected changes

{changes_text}

## Component tags

{component_table(old, new)}

## Watched files

{chr(10).join(changed_files)}

## Review checklist

- [ ] Check upstream component tag changes.
- [ ] Check `docker-compose.yml` service names used by installer scripts.
- [ ] Check MISP image expressions and runtime tag variables.
- [ ] Check new or changed required variables in `template.env`.
- [ ] Check health/readiness assumptions.
- [ ] Decide whether installer code changes are needed.
- [ ] Run repository validation before merge.
- [ ] Run compatibility validation for the affected installer release/ref and official MISP component set.
- [ ] Update `docs/compatibility.md` and the matching `docs/validation/compatibility-*.md` report before marking the combination validated compatible.

## Compatibility note

This upstream-review report is a drift-detection prompt, not compatibility proof by itself. A listed component set becomes **validated compatible** only after the documented compatibility scenarios pass and the public compatibility docs are updated.

## Validation command

```bash
python3 scripts/check-upstream-misp-docker.py --check
```
"""


def write_json(path: Path, data: dict[str, object]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def set_github_output(name: str, value: str) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if output_path:
        with open(output_path, "a", encoding="utf-8") as fh:
            fh.write(f"{name}={value}\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=DEFAULT_REPO)
    parser.add_argument("--ref", default=DEFAULT_REF)
    parser.add_argument("--lock", default=str(LOCK_PATH))
    parser.add_argument("--report", default=str(REPORT_PATH))
    parser.add_argument("--write", action="store_true", help="write updated lock/report files")
    parser.add_argument("--check", action="store_true", help="fail if upstream drift is detected")
    args = parser.parse_args()

    lock_path = Path(args.lock)
    report_path = Path(args.report)
    old = load_lock(lock_path)
    new = collect_state(args.repo, args.ref)
    changes = diff_state(old, new)
    drift = bool(changes)

    print(f"upstream_commit={new['upstream_commit']}")
    print(f"drift={'true' if drift else 'false'}")
    for change in changes:
        print(f"- {change}")

    set_github_output("drift", "true" if drift else "false")
    set_github_output("upstream_commit", str(new["upstream_commit"]))

    if args.write:
        write_json(lock_path, new)
        if drift:
            report_path.parent.mkdir(parents=True, exist_ok=True)
            report_path.write_text(render_report(old, new, changes), encoding="utf-8")
        elif report_path.exists():
            report_path.unlink()

    if args.check and drift:
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
