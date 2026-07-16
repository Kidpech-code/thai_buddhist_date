# thai_buddhist_date (demo app)

This repository contains two published packages and a Flutter demo app that
exercises them together:

- A month calendar widget that can display years in พ.ศ. or ค.ศ.
- Dialog pickers for single date and date‑time (with live preview format),
- Range and multi‑date pickers,
- Fullscreen variant,
- Theming and spacing customization for dialogs.
  - Dialogs: shape, title/content/actions padding, insetPadding

The reusable libraries live under `packages/`. The application at the repository
root is a demo and integration harness; it is not published.

## Related packages

- Core library: `packages/thai_buddhist_date` — pub: https://pub.dev/packages/thai_buddhist_date
- Pickers & calendar UI: `packages/thai_buddhist_date_pickers` — pub: https://pub.dev/packages/thai_buddhist_date_pickers

## Running

1. Ensure you have Flutter installed and a device/simulator available.
2. Fetch dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

The app initializes Thai locale data on startup (`ThaiCalendar.ensureInitialized()`) so month/weekday names appear correctly when using locale‑aware patterns.

## What’s inside

- `lib/widgets/buddhist_gregorian_calendar.dart` — Month calendar that formats header via the package’s BE/CE formatter.
- `lib/widgets/pickers.dart` — Dialogs and fullscreen:
  - Single date and date‑time (with `formatString` preview),
  - Range (`DateTimeRange`) and multi‑date (`Set<DateTime>`),
  - A fullscreen page,
  - Theming hooks: `shape`, paddings, `insetPadding`.
- `packages/thai_buddhist_date` — The core library with token‑aware formatting/parsing and helper APIs.
- `packages/thai_buddhist_date_pickers` — Extracted Flutter UI package (calendar and dialog pickers) published separately.

## Quality checks

The root command tests only the demo application:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test -r compact
```

Run package checks from each package directory:

```bash
cd packages/thai_buddhist_date
dart analyze --fatal-infos
dart test
dart pub publish --dry-run

cd ../thai_buddhist_date_pickers
flutter analyze --fatal-infos
flutter test
flutter pub publish --dry-run
```

The GitHub Actions CI workflow runs the demo, core package, and picker package as
separate jobs.

## Contributing and governance

- [Engineering policy](docs/ENGINEERING_POLICY.md)
- [Contribution guide](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Release guide](RELEASING.md)

## Notes

- For localized month/weekday names, initialize Thai locale once on app startup with `await ThaiCalendar.ensureInitialized()`.
