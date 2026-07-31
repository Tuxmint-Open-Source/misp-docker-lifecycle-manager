# Project origin and transparency

MISP Docker Lifecycle Manager is an independent community project and lifecycle wrapper for deployments based on the official [`MISP/misp-docker`](https://github.com/MISP/misp-docker) project.

This page explains what the project is, what it is not, how it was built, and how compatibility claims are supported.

## Independence from the MISP project

This repository is an independent community project. It is not part of, endorsed by, certified by, sponsored by, or supported by the MISP project, CIRCL, or the upstream MISP maintainers.

The project uses the word **MISP** descriptively because it operates deployments that are based on the official `MISP/misp-docker` repository. It does not claim ownership of the MISP name, logo, software, standards, communities, or support channels. Third-party names and marks remain the property of their respective owners.

The project deliberately uses its own **MISP DLM** visual identity and does not use the upstream MISP logo to identify this repository.

## Relationship to upstream software

The lifecycle manager does not vendor, fork, or rewrite MISP itself. It keeps the generated deployment as a normal official `MISP/misp-docker` checkout that can still be operated manually with Docker Compose if this manager is removed.

The manager adds operational helpers around the upstream deployment, including host preparation, deterministic environment generation, install verification, update, backup, restore, rollback, health checks, login checks, and sanitized support reporting.

Upstream MISP components keep their own licenses and governance. This repository's software is GPL-3.0; MISP core is separately licensed by the upstream MISP project; `MISP/misp-docker` is separately licensed by its upstream repository.

## AI-assisted development model

This project was built with AI-assisted engineering under maintainer review.

The `hermes-archham <hermes@tuxmint.com>` Git author represents the archham/Tuxmint AI-assisted development workflow for this repository. archham is the project maintainer and reviewed scope, architecture, pull requests, public wording, release gates, and validation evidence. archham also performed or approved manual testing where it was needed.

AI assistance does not replace maintainership or validation. Compatibility claims in this repository are based on exact release tags, published release artifacts, documented component tuples, automated gates, and sanitized validation evidence.

## Validation-first trust model

The project distinguishes three states:

| State | Meaning |
| --- | --- |
| Latest published | Newest normal SemVer release. |
| Latest validated | Newest immutable release tag and component tuple that passed the documented compatibility validation. |
| Pending validation | Published release or candidate that has not yet passed exact-tag compatibility validation. |

Do not treat a release as validated-compatible until the release/channel files, compatibility pages, and validation report say so explicitly.

## Naming and support boundaries

Use this project for what it claims to be: a non-invasive lifecycle manager for a supported single-server MISP Docker deployment shape.

Do not describe it as:

- official MISP software;
- a MISP project release;
- certified, endorsed, or supported by CIRCL or the upstream MISP maintainers;
- a replacement for upstream `MISP/misp-docker` documentation;
- a support contract or service-level agreement.

If a problem is in MISP core or upstream `MISP/misp-docker`, report it to the relevant upstream project. If a problem is in this lifecycle manager, use this repository's issue tracker or private vulnerability reporting path.

## Sources reviewed for this policy

This wording is intentionally conservative. It is based on:

- the MISP project website, governance, license, professional-services, and commercial-support pages;
- the upstream `MISP/MISP` and `MISP/misp-docker` repositories and licenses;
- common open-source trademark and naming practices: use third-party names truthfully and descriptively, keep your own branding distinct, and avoid confusion about endorsement, certification, sponsorship, or support.

No dedicated public MISP trademark policy was found during this review. If the MISP project publishes one later, this page should be updated to follow it.

## What to read next

- [Support matrix](support-matrix.md)
- [Compatibility](compatibility.md)
- [Validation matrix](validation/matrix.md)
- [Brand assets](brand-assets.md)
- [Security policy](../SECURITY.md)
