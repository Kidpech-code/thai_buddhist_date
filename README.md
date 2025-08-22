# thai_buddhist_date (demo app)

This repository contains a Flutter demo app that exercises the `thai_buddhist_date` package and showcases:

- A month calendar widget that can display years in พ.ศ. or ค.ศ.
- Dialog pickers for single date and date‑time (with live preview format),
- Range and multi‑date pickers,
- Fullscreen variant,
- Theming and spacing customization for dialogs.
  - Dialogs: shape, title/content/actions padding, insetPadding

The reusable library lives under `packages/thai_buddhist_date`. The app in the repository root depends on that package via a path dependency and presents the widgets/features in a simple UI with an era switcher.

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

## Tests

Run the demo test suite:

```bash
flutter test -r compact
```

Library tests are under `packages/thai_buddhist_date/test` and run via the workspace‑level `flutter test` as well.

## Notes

- For localized month/weekday names, initialize Thai locale once on app startup with `await ThaiCalendar.ensureInitialized()`.
