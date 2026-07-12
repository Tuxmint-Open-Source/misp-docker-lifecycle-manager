# Backup, restore, and rollback

This document describes the intended backup, restore, and rollback contract for `misp-production-installer`.

The current installer has backup and reset helpers. Before `v1.0.0`, the project must also document and validate a real restore drill.

## Backup creation

Create a backup with:

```bash
sudo ./installer/backup.sh --install-dir /opt/misp-docker
```

A backup should include:

- database dump
- relevant host-data archive
- checksums

Backups are sensitive and should be protected accordingly.

## Backup verification

After backup creation, operators should verify:

- the command completed successfully
- expected backup files exist
- checksum files exist
- backup files have restrictive permissions
- backup files are copied to the intended retention location

The exact checksum verification command depends on where the backup output is stored. Keep verification local and do not paste backup contents into public issues.

## Restore expectation for `v1.0.0`

For the first production-ready release, restore must be more than a documented idea. It should be validated as a scenario:

1. create a fresh deployment
2. verify login works
3. create or verify meaningful MISP state
4. run `backup.sh`
5. reset or recreate the deployment scope
6. restore the backup
7. start the stack
8. run `doctor.sh`
9. run `login-check.sh`
10. verify the expected state exists after restore

Until that scenario passes for an exact release tag, the project should not claim complete disaster-recovery readiness.

## Restore procedure placeholder

The final `v1.0.0` restore procedure should document the exact tested steps.

At minimum, it must state:

- how to stop the stack safely
- which files/directories are restored
- how database restore is performed
- how ownership and permissions are restored
- how checksums are verified
- how to start the stack after restore
- which validation commands prove success

This placeholder should be replaced by the validated restore procedure before `v1.0.0`.

## Rollback after failed update

`update.sh` creates a backup before applying changes. A production-ready rollback story should explain what to do if an update fails after that backup.

The documented rollback path should cover:

- when to stop and avoid repeated retries
- how to preserve logs privately for diagnosis
- how to identify the pre-update backup
- how to restore from that backup
- how to verify the restored deployment
- when to report an issue upstream or in this installer project

Until rollback is validated, docs should describe rollback as restore-based and not automatic.

## Reset behavior

Reset is intentionally conservative:

- dry-run by default
- explicit destructive confirmation required
- install directory safety checks required
- deployment-scoped Compose resources only
- Docker Engine remains installed

Example dry run:

```bash
sudo ./installer/reset-installation.sh --install-dir /opt/misp-docker
```

Use destructive reset only after reading the command output and confirming it targets the intended deployment.

## Failure evidence handling

If backup, restore, update, or rollback fails:

- keep raw logs private
- do not paste credentials, `.env`, database dumps, or full logs into public issues
- summarize command shapes, versions, expected result, and failure class
- redact secrets before sharing any snippets

## v1.0.0 gate

Before `v1.0.0`, this document should be updated from expectations/placeholders into a validated runbook. The validation matrix should include a restore scenario result for the exact release tag.
