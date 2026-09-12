# Maintenance and release preparation — 2026-09-12

## Changes

- Prepare core `0.4.1`: validate Buddhist dates using Gregorian leap-year rules
  and isolate automatic parsing from explicit-era result caches.
- Add six regression tests, including a complete 400-year leap-year cycle,
  localized digits, quoted numeric literals, two-digit years, and both cache
  call orders. The four initial regression tests failed before the fixes.
- Keep the deprecated `ListEquality` API available while using its private
  implementation internally, avoiding diagnostics on older Dart analyzers.
- Upgrade demo `flutter_lints` from 5.0.0 to 6.0.0. Refresh its lockfile,
  including `intl` 0.20.3 and compatible development dependencies. The picker
  example lockfile records the local core version 0.4.1.
- Picker 0.3.0 remains prepared with its existing API and dependency constraints.
  Its standalone checks exercise published core releases; the demo uses the
  local core and picker sources.

## Validation

| SDK | Demo | Core | Pickers |
| --- | --- | --- | --- |
| Flutter 3.44.2 / Dart 3.12.2 | Format, analyze, 1 test passed | Format, analyze, 23 tests passed | Format, analyze, 11 tests passed |
| Flutter 3.47.4 / Dart 3.13.3 | Format, analyze, 1 test passed | Format, analyze, 23 tests and example passed | Format, analyze, 11 tests passed |
| Flutter 3.19.6 / bundled Dart | Not targeted | Format, analyze, 23 tests passed | Format, analyze, 11 tests passed |

Picker tests also passed (11 tests) on Flutter 3.47.4 with a temporary path
override to the patched local core 0.4.1. That override was used only in the
verification snapshot.

Both package publish dry-runs passed without warnings in an isolated source
snapshot. In the working repository, core's dry-run reports the expected
uncommitted-file warning; this is not a publish authorization. Flutter 3.47.4
was installed separately for verification. The default SDK was not upgraded.
Application lockfiles remain resolved using Flutter 3.44.2; the new SDK's
dependency resolutions stayed in the snapshot. Picker's generated build-output
exclusion is tracked explicitly because Flutter's automatic migration otherwise
causes a dirty-worktree warning and fails the CI publish dry-run.
No platform release builds or device tests were run.

## Release status and compatibility

Invalid Buddhist dates that previously rolled forward now return `null`; valid
Buddhist leap days are accepted. Automatic year heuristics and public signatures
remain unchanged. Remove workarounds that compensated for these parser bugs.

Core 0.4.1 and picker 0.3.0 are ready for maintainer review. Follow RELEASING.md
for reviewed changes, fresh CI on main, and package-specific release tags.
Publish core first so users can resolve the corrected version. Picker's existing
constraint also permits earlier core versions; consumers needing the parsing
fix must resolve core 0.4.1 or later. This report records local verification. The pull request, CI runs, and release
workflows record subsequent review and delivery status.
