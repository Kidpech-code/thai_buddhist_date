# Repository Instructions

These instructions apply to the entire repository.

## Policy order

1. `docs/ENGINEERING_POLICY.md` is the authoritative engineering policy.
2. `CONTRIBUTING.md` defines the contributor workflow and local commands.
3. `SECURITY.md` defines private vulnerability reporting.
4. `RELEASING.md` defines the maintainer-only release process.

If documents conflict, follow the order above and fix the stale document in the
same change when it is safe to do so.

## Working rules

- Inspect `git status --short --branch` before editing. Preserve unrelated and
  pre-existing worktree changes.
- Do not use blanket staging in a mixed worktree. Stage explicit paths only.
- Do not modify `.env`, credentials, signing material, or other secret files.
- Treat `packages/thai_buddhist_date` and
  `packages/thai_buddhist_date_pickers` as the published sources of truth. The
  root Flutter application is a demo.
- Keep the core package free from Flutter imports.
- Do not refresh lockfiles unless dependency or SDK maintenance is in scope.
- For behavior changes, write the failing regression test first when practical,
  then implement the smallest compatible fix.
- Run the quality gates for every changed scope. Do not claim a check passed
  unless it was actually run.
- Do not commit, push, tag, publish, or create a pull request unless the user
  explicitly asks for that Git operation.

## Fast verification

```bash
# Root demo
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test

# Core package
cd packages/thai_buddhist_date
dart format --output=none --set-exit-if-changed lib test tool example
dart analyze --fatal-infos
dart test
dart pub publish --dry-run

# Picker package
cd ../thai_buddhist_date_pickers
dart format --output=none --set-exit-if-changed lib test example/lib
flutter analyze --fatal-infos
flutter test
flutter pub publish --dry-run
```
