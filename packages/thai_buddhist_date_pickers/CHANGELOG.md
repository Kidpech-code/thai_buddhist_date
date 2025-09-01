# Changelog

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
