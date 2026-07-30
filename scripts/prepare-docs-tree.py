#!/usr/bin/env python3
"""Prepare a version-local MkDocs source tree without changing canonical files."""

from __future__ import annotations

import argparse
from pathlib import Path
import re
import shutil

ROOT = Path(__file__).resolve().parents[1]
DOCS_SOURCE = ROOT / "docs"
DEFAULT_OUTPUT = ROOT / ".generated-docs"
REPOSITORY_SECTION = "repository"
UPSTREAM_REPORT = ROOT / ".upstream" / "reports" / "misp-docker-upstream-review.md"


def replace_markdown_target(text: str, old: str, new: str) -> str:
    """Replace a Markdown link target while preserving its link label."""
    return text.replace(f"]({old})", f"]({new})")


def rewrite_github_alerts(text: str) -> str:
    """Render GitHub alert markers as portable labeled blockquotes."""
    return re.sub(
        r"(?m)^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]$",
        lambda match: f"> **{match.group(1).title()}**",
        text,
    )


def validate_output(output: Path) -> Path:
    resolved = output.resolve()
    if resolved == ROOT or ROOT not in resolved.parents:
        raise ValueError("output must be a directory below the repository root")
    if resolved == DOCS_SOURCE.resolve():
        raise ValueError("output must not overwrite the canonical docs directory")
    return resolved


def rewrite_docs_pages(output: Path, root_markdown: list[Path]) -> None:
    root_names = {path.name for path in root_markdown}
    repository_dir = output / REPOSITORY_SECTION

    for page in output.rglob("*.md"):
        if repository_dir in page.parents:
            continue
        text = page.read_text()
        relative = page.relative_to(output)

        if len(relative.parts) == 1:
            for name in sorted(root_names):
                text = replace_markdown_target(
                    text, f"../{name}", f"{REPOSITORY_SECTION}/{name}"
                )

        if relative.parts[0] == "validation":
            text = replace_markdown_target(
                text,
                "../../.upstream/reports/misp-docker-upstream-review.md",
                f"../{REPOSITORY_SECTION}/upstream-review.md",
            )

        page.write_text(rewrite_github_alerts(text))


def rewrite_repository_pages(output: Path) -> None:
    repository_dir = output / REPOSITORY_SECTION
    docs_link = re.compile(r"]\(docs/([^)]*)\)")
    docs_html_asset = re.compile(r'(?P<attribute>src|srcset)="docs/(?P<target>[^"]+)"')

    for page in repository_dir.glob("*.md"):
        text = docs_link.sub(r"](../\1)", page.read_text())
        text = docs_html_asset.sub(
            r'\g<attribute>="../\g<target>"',
            text,
        )
        text = replace_markdown_target(
            text, ".release-channels.json", "release-channels.json"
        )
        if page.name == "upstream-review.md":
            text = replace_markdown_target(
                text, "../../docs/compatibility.md", "../compatibility.md"
            )
        page.write_text(rewrite_github_alerts(text))


def prepare(output: Path) -> None:
    output = validate_output(output)
    if output.exists():
        shutil.rmtree(output)
    shutil.copytree(DOCS_SOURCE, output)

    repository_dir = output / REPOSITORY_SECTION
    repository_dir.mkdir()

    root_markdown = sorted(ROOT.glob("*.md"), key=lambda path: path.name)
    for source in root_markdown:
        shutil.copy2(source, repository_dir / source.name)

    if not UPSTREAM_REPORT.is_file():
        raise FileNotFoundError(UPSTREAM_REPORT)
    shutil.copy2(UPSTREAM_REPORT, repository_dir / "upstream-review.md")
    shutil.copy2(
        ROOT / ".release-channels.json", repository_dir / "release-channels.json"
    )

    rewrite_docs_pages(output, root_markdown)
    rewrite_repository_pages(output)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="generated directory below the repository root",
    )
    args = parser.parse_args()
    output = args.output if args.output.is_absolute() else ROOT / args.output
    prepare(output)
    print(f"Prepared MkDocs source tree at {output.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
