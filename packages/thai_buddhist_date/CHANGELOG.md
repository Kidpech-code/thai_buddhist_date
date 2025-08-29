# Changelog

## 0.2.4 - Docs-only polish for publication

- README: clarify sync top-level helpers, locale initialization, and legacy shims.
- No code changes.

## 0.2.3 - Docs: sync top-level helpers, locale init guidance, compatibility

- README overhaul: top-level `format/formatNow` examples are synchronous; removed unnecessary `await`.
- Added "Backward compatibility and sync vs async" section and clarified `ThaiDateService.initializeLocale('th_TH')` usage.
- Cleaned Thai section examples to be consistent with current API.

## 0.2.2 - Thai full date preset, custom parts, explicit-era parsing, docs

- Add preset pattern 'dmy' for Thai full date output (e.g., 25 สิงหาคม 2568) with BE/CE.
- Add ThaiCalendar.formatThaiDateParts(...) to build custom strings by reordering/omitting day/month/year; supports short month names and custom separators.
- Add ThaiCalendar.parseWithEra(...) to parse inputs with an explicit era hint (treat input as BE or CE explicitly).
- Expand README with detailed Thai usage guide, multi-language examples, and recipes.
- General docs polish and Markdown fence fixes.

## 0.2.1 - Multi-language API and docs

- Add ThaiDateSettings.useLocale(String) for setting any locale code globally.
- Add TbdLocales class with constants for common language/region codes (e.g., 'fr', 'ar', 'ja', 'zh', etc.).
- Update documentation: professional multi-language date/time/date&time usage, clear examples for all major languages.

## 0.2.0 - API polish and ergonomics

- Clear separation between core date utilities and UI pickers (moved to thai_buddhist_date_pickers).
- Added ThaiLanguage (thai/english) convenience and locale-aware ensureInitialized.
- Introduced ThaiDateSettings for global defaults (default era/locale) and helpers to switch Thai/English.
- Added ThaiFormatter reusable formatter class.
- Added DateTime.toThaiString() and String.toThaiDate() extensions.
- Kept all existing APIs for backward compatibility.

## 0.1.4 - Docs cleanup and examples update

- Remove Bottom Sheet pickers from package features and examples to align with current scope.
- Update demo and package READMEs accordingly.
- No API or behavior changes in the core library.

## 0.1.2 - Lint/format cleanup

- Fix while-block lint and ensure package is dart formatted.
- No behavior changes.

## 0.1.3 - Metadata fix

- Update repository URL to non-.git form and fix repo verification by renaming root app. No code changes.

## 0.1.1 - Dependency update

- Widen intl constraint to support latest stable releases (up to <0.21.0). No code changes.

## 0.1.0 - Initial

- Initial implementation: parse/format Thai Buddhist (พ.ศ.) dates
- Token-aware formatting, parse BE/CE automatically
- Helpers: formatSync, formatInitialized, formatWith/parseWith
- Unit tests
