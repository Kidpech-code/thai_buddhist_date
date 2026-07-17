# Engineering Policy

This document is the authoritative engineering policy for this repository. It
applies to maintainers, contributors, automation, and coding agents.

## 1. Repository boundaries

- `packages/thai_buddhist_date` is the source of truth for the pure Dart date
  model, parsing, formatting, locale handling, and era conversion.
- `packages/thai_buddhist_date_pickers` is the source of truth for reusable
  Flutter calendar and picker UI. It may depend on the core package; the core
  package must never depend on Flutter or the picker package.
- The application at the repository root is a demo and integration harness. New
  reusable behavior belongs in a package, not in the demo.
- The root demo imports picker behavior from the published picker package.
  Do not reintroduce reusable calendar or picker implementations under the
  demo's `lib/` directory.
- Public APIs must be exported through each package entry point. Files under
  `lib/src` are implementation details unless explicitly exported.

## 2. Compatibility and API contracts

- Preserve existing behavior unless a change is intentionally documented and
  versioned.
- Treat public names, signatures, return values, default values, thrown errors,
  accepted input formats, era detection, the 543-year conversion, locale codes,
  date-only semantics, and picker interaction behavior as API contracts.
- Do not silently convert a calendar date to UTC or otherwise shift its day.
- Every bug fix needs a regression test. Every new public API needs dartdoc,
  tests, a README example, and a changelog entry.
- Deprecate before removal whenever practical. A deprecation message must point
  to the replacement and the planned removal release.
- Accessibility is part of the picker contract. Interactive UI must retain
  keyboard, screen-reader, text-scaling, contrast, and minimum touch-target
  usability.

## 3. Versioning and changelogs

The two published packages are versioned independently using Semantic
Versioning.

- Before `1.0.0`, breaking changes increment the minor version.
- From `1.0.0`, breaking changes increment the major version.
- Backward-compatible features increment the minor version.
- Backward-compatible fixes and documentation corrections increment the patch
  version.
- Update the affected package's `CHANGELOG.md` in the same pull request as a
  user-visible change. Describe migration steps for breaking or behavior-changing
  releases.
- Use immutable, package-specific release tags:
  `thai_buddhist_date-vX.Y.Z` and
  `thai_buddhist_date_pickers-vX.Y.Z`.

## 4. Required quality gates

Before merge, all checks relevant to the changed scope must pass:

| Scope | Required checks |
| --- | --- |
| Root demo | format check, `flutter analyze --fatal-infos`, `flutter test` |
| Core package | format check, `dart analyze --fatal-infos`, `dart test`, publish dry-run |
| Picker package | format check, `flutter analyze --fatal-infos`, `flutter test`, publish dry-run |

Tests must cover relevant boundaries, including invalid dates, leap years,
BE/CE conversion, locale behavior, date ranges, disabled dates, cancellation,
and UI selection. Performance tests must use generous, documented thresholds
and must not replace correctness tests.

CI is the merge gate. A local pass does not justify bypassing a failing CI job.
Flaky tests must be fixed or quarantined with an issue, owner, and expiry date;
they must not be retried indefinitely until green.

## 5. Code and dependency policy

- Prefer the smallest maintainable change that solves the verified problem.
- Keep the core package platform-independent and deterministic. Network access,
  storage, analytics, and UI dependencies do not belong in it.
- Keep runtime dependencies minimal. Explain every new dependency in the pull
  request and review its maintenance, license, and security posture.
- Dependency and SDK upgrades are intentional changes. Do not include incidental
  `pubspec.lock` refreshes in unrelated work.
- Library lockfiles under `packages/*/pubspec.lock` are not tracked. Keep the
  root demo and example-app lockfiles tracked; refresh them only when a
  dependency, SDK baseline, or example environment is deliberately updated.
  Keep such changes reviewable and mention them in the pull request.
- Do not suppress analyzer rules repository-wide to hide a local issue. A
  suppression requires a narrow scope and an explanatory comment.
- Do not commit generated build output, editor state, backup files, credentials,
  or copied package caches.

## 6. Security and privacy

- Never commit tokens, API keys, credential files, signing material, private
  keys, or personal data. Revoke and rotate any credential that reaches Git
  history.
- GitHub Actions use least-privilege permissions and immutable action revisions.
- Publishing uses pub.dev trusted publishing with short-lived OIDC credentials.
  Long-lived `PUB_CREDENTIALS` secrets are not allowed.
- Release tags are immutable. Never force-move or overwrite a published tag.
- Report vulnerabilities privately according to `SECURITY.md`; do not disclose
  exploit details in a public issue before a fix is available.

## 7. Git and review policy

- Work in a focused branch and keep unrelated changes out of the pull request.
- Use Conventional Commits in English, for example
  `fix(core): preserve day when formatting BE dates`.
- Pull requests must explain the problem, root cause, important changes, tests
  actually run, compatibility impact, and release risk.
- Changes to public APIs, dependency constraints, security policy, or publishing
  workflows require maintainer review.
- Never rewrite `main` or release-tag history. Do not merge with unresolved CI,
  review, security, or compatibility concerns.

## 8. Release policy

- Prepare version and changelog changes in a reviewed pull request. Release
  automation must not edit or commit source files.
- Verify that the tag version exactly matches the affected `pubspec.yaml`.
- Run the complete package quality gates and publish dry-run before tagging.
- Publish the core package before the picker package when the picker requires a
  new core version.
- Publishing requires the protected GitHub `pub.dev` environment and pub.dev
  trusted-publishing configuration described in `RELEASING.md`.
- If any publish step fails, diagnose and create a new commit/tag as appropriate;
  never force-replace the failed tag.

## 9. Definition of done

A change is complete only when its implementation, tests, documentation,
changelog/version impact, security impact, and CI result agree. A passing build
alone is not sufficient when the public contract or release documentation is
stale.
