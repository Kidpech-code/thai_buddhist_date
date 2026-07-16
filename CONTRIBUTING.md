# Contributing

Thank you for improving `thai_buddhist_date`. By contributing, you agree to
follow the repository's [engineering policy](docs/ENGINEERING_POLICY.md).

## Choose the correct scope

- Pure Dart parsing, formatting, locales, entities, and era conversion belong in
  `packages/thai_buddhist_date`.
- Reusable Flutter calendar and picker behavior belongs in
  `packages/thai_buddhist_date_pickers`.
- The root application demonstrates and integration-tests the packages; it is
  not a third implementation of package behavior.

For a bug, include the affected package version, Dart/Flutter version, input,
expected output, actual output, and a minimal reproduction. Remove secrets and
personal data from logs.

## Development workflow

1. Create a focused branch from the latest `main`.
2. Reproduce the problem or define the new behavior in a test.
3. Make the smallest compatible change in the authoritative package.
4. Update dartdoc, README examples, and the affected changelog when behavior is
   user-visible.
5. Run the checks below and open a pull request using the repository template.

### Root demo

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test
```

### Core Dart package

```bash
cd packages/thai_buddhist_date
dart pub get
dart format --output=none --set-exit-if-changed lib test tool example
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
```

### Flutter picker package

```bash
cd packages/thai_buddhist_date_pickers
flutter pub get
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze --fatal-infos
flutter test
flutter pub publish --dry-run
```

Run `dart format` without `--output=none` to apply formatting before the final
check.

## Commits and pull requests

Use Conventional Commits in English:

```text
feat(pickers): add keyboard date navigation
fix(core): reject invalid Buddhist leap dates
docs: clarify locale initialization
```

Keep dependency upgrades, generated files, and lockfile refreshes out of an
unrelated change. Pull requests must state which commands were actually run and
must call out API, dependency, security, or release impact.

Maintainers may request changes when a contribution lacks regression coverage,
changes an undocumented public contract, or duplicates logic between the demo
and a published package.
