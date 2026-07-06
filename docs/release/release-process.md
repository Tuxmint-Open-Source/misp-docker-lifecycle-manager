# Release process

This project uses short-lived release Pull Requests and permanent Git tags/GitHub Releases.

## Standards used

The project combines three common release documentation practices:

- [Semantic Versioning](https://semver.org/) for deciding `MAJOR.MINOR.PATCH`.
- [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) categories for structured change history:
  - Added
  - Changed
  - Deprecated
  - Removed
  - Fixed
  - Security
- GitHub Releases for the user-facing release page attached to each Git tag.

`CHANGELOG.md` is the durable chronological change history. GitHub Release notes are the public user-facing summary for a specific tag.

## Release branch

Create a short-lived branch named after the release:

```bash
git switch main
git pull --ff-only origin main
git switch -c release/vX.Y.Z
```

The release branch is only a review vehicle. Delete it after the release PR is merged.
The permanent release record is the Git tag, GitHub Release, `CHANGELOG.md`, and commit history.

## Release PR contents

A release PR should normally change only:

```text
VERSION
README.md
CHANGELOG.md
```

The PR should:

- bump `VERSION`
- update the README current version text
- move `[Unreleased]` changelog entries into `## [X.Y.Z] - YYYY-MM-DD`
- update changelog compare links
- include validation evidence using public-safe generic wording

## GitHub Release notes

Use `.github/RELEASE_TEMPLATE.md` for every GitHub Release. Keep the structure consistent:

1. Summary
2. Highlights
3. Compatibility and upgrade notes
4. What's changed
5. Known issues
6. Validation
7. Links

Use Keep a Changelog categories in the "What's changed" section and omit empty categories.

Release notes should be short enough to scan, but complete enough for an operator to answer:

- Should I upgrade?
- Is this compatible with my existing install?
- Are there manual steps?
- What changed?
- Was the release validated?

Use short, public-safe wording. Do not include private validation infrastructure,
internal hostnames, IPs, private paths, topology, access methods, or security posture.

## Existing release notes

GitHub Release text is metadata, not repository content. It cannot be changed through a normal code PR.
If existing releases should be normalized to the current template, review and approve the exact text first,
then edit the release metadata with `gh release edit` and verify the result with `gh release view`.

## After merge

After the release PR is reviewed and merged into `main`:

```bash
git switch main
git pull --ff-only origin main
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
gh release create vX.Y.Z --title "vX.Y.Z" --notes-file /path/to/release-notes.md
```

Verify the release afterwards:

```bash
gh release view vX.Y.Z --json tagName,name,url,isDraft,isPrerelease,targetCommitish
```
