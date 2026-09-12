# Changelog

## 0.3.0 - 2026-09-12

- Exclude generated build output explicitly so Flutter 3.47 does not rewrite
  analyzer configuration during CI or publishing.

- Validate date bounds and every initial selection across single, date-time,
  range, multi-date, formatted, and fullscreen variants.
- Clamp the automatically selected visible month/date into configured bounds
  when no explicit initial value is provided.
- Recompute calendar labels when era, locale, first weekday, or initial month
  changes and disable month navigation at configured bounds.
- Add full-date semantics, selected/disabled state, tooltips, and keyboard
  focus for calendar controls.
- Add `BuddhistGregorianCalendar.isDateSelected` for accessible range and
  multi-date selection state without replacing existing APIs.
- Make dialogs scrollable on small displays and with large text scaling.
- Preserve Material's default dialog inset padding with an API shape that
  compiles on Flutter 3.19.6 and current stable.
- Forward dialog shape and padding options through formatted date-time helpers.
- Add regression coverage for picker results, cancel/confirm behavior,
  validation, property updates, accessibility, and responsive layout.
- Support Flutter 3.19 and stable in CI with strict analyzer settings.
- Accept compatible core releases from `0.3.0` through `0.4.x`.
- Stop tracking this library package's `pubspec.lock`; the example app lockfile
  remains tracked and is refreshed with Flutter 3.44.2.

## 0.2.0 - 2026-05-22

- Require `thai_buddhist_date: ^0.3.0` (Clean Architecture edition).
- No API changes — all existing widget and function signatures are unchanged.
- Users on `thai_buddhist_date ^0.2.x` should stay on `thai_buddhist_date_pickers ^0.1.6`.
- The `int.toCE` bug fix and underscore-format locale constants (`th_TH`) from core 0.3.0 apply automatically; no changes needed in picker call sites.

## 0.1.6 - 2025-09-15

- Docs: Add screenshots and video demo to README.
- Version bump to 0.1.6.

## 0.1.5

- Docs-only: Add labeled subsections in README (Range, Multi-date, Fullscreen) and expand example usage.
- No code changes.

## 0.1.4

- Fix: Replace Color.withValues(...) with withOpacity(...) for wider Flutter SDK compatibility.
- Docs: Update README install versions.
- Chore: Bump dependency thai_buddhist_date to ^0.2.5.

## 0.1.3

- Docs-only: README updated to use `ThaiDateService().initializeLocale('th_TH')`.
- Bump dependency: thai_buddhist_date ^0.2.4.
- Remove dependency_overrides for publish.

## 0.1.2

- Fix issue tracker URL to be HEAD-reachable; add homepage pointing to package folder.
- Bump dependency: thai_buddhist_date ^0.2.2.
- README: switch locale init to `ThaiDateService().initializeLocale('th_TH')`.
- No code changes.

## 0.1.1

- Add dartdoc comments to all public APIs for better pub.dev documentation score.
- Ensure example/ app is included and referenced in README.
- Run dart format across lib/ sources.
- Update dependency constraint to thai_buddhist_date: ^0.2.1.

## 0.1.0

- Initial extract of calendar and dialog pickers from the demo app.
- Depends on thai_buddhist_date for formatting/era logic.
