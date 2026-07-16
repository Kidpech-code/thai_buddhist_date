# Release Guide

This guide is for maintainers. The rules in
[`docs/ENGINEERING_POLICY.md`](docs/ENGINEERING_POLICY.md) remain authoritative.

## One-time trusted-publishing setup

1. In the pub.dev Admin tab for `thai_buddhist_date`, enable publishing from
   GitHub Actions for repository `Kidpech-code/thai_buddhist_date` with tag
   pattern `thai_buddhist_date-v{{version}}`.
2. Repeat for `thai_buddhist_date_pickers` with tag pattern
   `thai_buddhist_date_pickers-v{{version}}`.
3. In GitHub, create an environment named `pub.dev`, add a required reviewer,
   and protect the two release-tag patterns.
4. Remove any legacy `PUB_CREDENTIALS` repository secret after confirming that
   OIDC publishing works.

## Prepare a release

1. Update the affected package's `version` in `pubspec.yaml`.
2. Add a dated changelog entry with compatibility and migration notes.
3. Update README examples that mention a package version or changed behavior.
4. Run the complete checks from `CONTRIBUTING.md`, including publish dry-run.
5. Merge the reviewed release-preparation pull request and confirm CI on `main`.

If the picker release requires a new core version, publish and verify the core
package on pub.dev before preparing the picker tag.

## Tag and publish

Create an annotated, package-specific tag whose version exactly matches the
package pubspec:

```bash
git switch main
git pull --ff-only

# Core example
git tag -a thai_buddhist_date-v0.3.1 -m "Release thai_buddhist_date 0.3.1"
git push origin thai_buddhist_date-v0.3.1

# Picker example
git tag -a thai_buddhist_date_pickers-v0.2.1 -m "Release thai_buddhist_date_pickers 0.2.1"
git push origin thai_buddhist_date_pickers-v0.2.1
```

The tag starts the OIDC workflow. Approve the protected `pub.dev` environment,
then verify the published version, README, changelog, and API documentation on
pub.dev.

Never force-move a release tag. If a tag is wrong and publishing has not begun,
stop and investigate before deleting it. If a version was already published,
fix the problem in a new version because pub.dev releases are immutable.
