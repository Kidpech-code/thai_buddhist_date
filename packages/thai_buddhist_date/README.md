# thai_buddhist_date

[![pub package](https://img.shields.io/pub/v/thai_buddhist_date.svg)](https://pub.dev/packages/thai_buddhist_date)
[![CI](https://github.com/Kidpech-code/thai_buddhist_date/actions/workflows/ci.yml/badge.svg)](https://github.com/Kidpech-code/thai_buddhist_date/actions)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A tiny Dart library for working with Thai Buddhist Era dates (พ.ศ.), with selectable output era (พ.ศ./ค.ศ.), safe token‑aware formatting, flexible parsing, and optional Flutter widgets.

Looking for calendar and dialog pickers? See the companion UI package:

- thai_buddhist_date_pickers — https://pub.dev/packages/thai_buddhist_date_pickers

## Highlights

- Format with BE or CE: `format(DateTime, era: ...)` outputs the year in พ.ศ. (BE) or ค.ศ. (CE).
- Parse both BE and CE seamlessly: `parse(String)` detects BE years (>= 2400) and normalizes to a CE `DateTime` internally.
- Token‑aware formatter: Only the year tokens are replaced when outputting BE, so patterns like `yyyy-MM-dd` or `MMMM yyyy` remain safe.
- Clean Architecture service: High‑level `ThaiDateService` with caching and sync formatting for numeric patterns.
- Flutter extras (optional): A lightweight month calendar and a set of date pickers (single, date‑time with preview, range, multi‑date, and fullscreen) with theming hooks.

## Install

Add to your pubspec.yaml:

```yaml
dependencies:
  thai_buddhist_date: ^0.2.6
```

Then run `dart pub get` or `flutter pub get`.

## Quick start

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  // Parse either BE or CE and get a DateTime (internally CE)
  final dt = parse('2568-08-22'); // BE input -> CE internally (2025-08-22)

  // Top-level format is synchronous
  print(format(dt, pattern: 'yyyy-MM-dd', era: Era.ce)); // 2025-08-22
}
```

## Locale initialization for Flutter

If you need localized month/weekday names (e.g., `MMMM yyyy`), initialize the Thai locale before building the UI:

```dart
import 'package:flutter/material.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load date symbols for Thai before using patterns like 'MMMM' or 'EEE'
  await ThaiDateService().initializeLocale('th_TH');
  runApp(const MyApp());
}
```

## Service cheatsheet (Clean Architecture)

```dart
final service = ThaiDateService();

// Format
final be = await service.format(ThaiDate.fromDateTime(DateTime(2025, 8, 22)), pattern: 'fullText');
final iso = service.formatSync(ThaiDate.fromDateTime(DateTime(2025, 8, 22)), pattern: 'iso');

// Parse (accepts BE or CE) – returns ThaiDate (BE year)
final t = service.parse('2568-08-22', pattern: 'yyyy-MM-dd');

// Now helper
final label = await service.formatNow(pattern: 'fullText');

// Global config
service.setEra(Era.be);
service.setLanguage(ThaiLanguage.thai); // sets locale to 'th_TH'
await service.initializeLocale('th_TH');
```

### Multi-language date/time/date&time

- Pick any locale via the `locale:` parameter or set language globally on the service.
- Use the same API for date (yyyy-MM-dd), time (HH:mm), or combined (dd/MM/yyyy HH:mm).

```dart
final svc = ThaiDateService();
// Date only
final frDate = await svc.formatNow(pattern: 'yyyy-MM-dd', locale: 'fr');
// Time only
final frTime = await svc.formatNow(pattern: 'HH:mm', locale: 'fr');
// Date & Time
final frDateTime = await svc.formatNow(pattern: 'dd/MM/yyyy HH:mm', locale: 'fr');

// Override per call with another language
final esFull = await svc.formatNow(pattern: 'fullText', locale: 'es');
```

### Thai full date format (วัน เดือน ปี)

Using a preset pattern, with BE or CE:

```dart
final d = DateTime(2025, 8, 25);
print(format(d, pattern: 'dmy', era: Era.be)); // 25 สิงหาคม 2568
print(format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025
```

### Custom patterns

Use any `intl`-style pattern: `yyyy-MM-dd`, `dd/MM/yyyy`, `HH:mm`, `d MMMM yyyy`, etc.

```dart
final d = DateTime(2025, 8, 25);
print(format(d, pattern: 'dd/MM/yyyy'));       // 25/08/2568 (BE)
print(format(d, pattern: 'MMMM yyyy'));        // สิงหาคม 2568 (BE)
print(format(d, pattern: 'MMMM yyyy', era: Era.ce)); // สิงหาคม 2025 (CE)
```

### Creative parse/format helpers (BE/CE, all common formats)

You can use `parseThaiDate` and `formatThaiDate` for flexible, ergonomic conversion between String and DateTime, supporting BE/CE and many formats:

```dart
// Parsing (String to DateTime)
parseThaiDate('03092568');         // BE, compact
parseThaiDate('03-09-2568');       // BE, dash
parseThaiDate('03/09/2568');       // BE, slash
parseThaiDate('03.09.2568');       // BE, dot
parseThaiDate('2568-09-03');       // BE, ISO
parseThaiDate('2568.09.03');       // BE, ISO dot
parseThaiDate('2568/09/03');       // BE, ISO slash
parseThaiDate('3/9/2568');         // BE, single-digit
parseThaiDate('3-9-2568');         // BE, single-digit dash
parseThaiDate('3.9.2568');         // BE, single-digit dot

// Parsing CE
parseThaiDate('03092025', era: Era.ce); // CE, compact
parseThaiDate('03-09-2025', era: Era.ce); // CE, dash
parseThaiDate('03/09/2025', era: Era.ce); // CE, slash
parseThaiDate('03.09.2025', era: Era.ce); // CE, dot
parseThaiDate('2025-09-03', era: Era.ce); // CE, ISO
parseThaiDate('2025.09.03', era: Era.ce); // CE, ISO dot
parseThaiDate('2025/09/03', era: Era.ce); // CE, ISO slash
parseThaiDate('3/9/2025', era: Era.ce);   // CE, single-digit
parseThaiDate('3-9-2025', era: Era.ce);   // CE, single-digit dash
parseThaiDate('3.9.2025', era: Era.ce);   // CE, single-digit dot

// Formatting (DateTime to String)
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'dd/MM/yyyy'); // '03/09/2568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'dd/MM/yyyy'); // '03/09/2025'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'dd-MM-yyyy'); // '03-09-2568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'dd-MM-yyyy'); // '03-09-2025'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'dd.MM.yyyy'); // '03.09.2568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'dd.MM.yyyy'); // '03.09.2025'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'yyyy-MM-dd'); // '2568-09-03'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'yyyy-MM-dd'); // '2025-09-03'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'yyyy.MM.dd'); // '2568.09.03'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'yyyy.MM.dd'); // '2025.09.03'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'yyyy/MM/dd'); // '2568/09/03'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'yyyy/MM/dd'); // '2025/09/03'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'd/M/yyyy');   // '3/9/2568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'd/M/yyyy');   // '3/9/2025'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'd-M-yyyy');   // '3-9-2568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'd-M-yyyy');   // '3-9-2025'
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'd.M.yyyy');   // '3.9.2568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'd.M.yyyy');   // '3.9.2025'

// Custom formats
formatThaiDate(DateTime(2568,9,3), era: Era.be, format: 'ddMMyyyy'); // '03092568'
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'ddMMyyyy'); // '03092025'

// Extensible: add your own formats
final customFormats = {'myCustom': 'yyyyMMdd'};
parseThaiDate('20250903', format: 'yyyyMMdd', era: Era.ce, customFormats: customFormats);
formatThaiDate(DateTime(2025,9,3), era: Era.ce, format: 'yyyyMMdd'); // '20250903'
```

### Explicit-era parsing for BE inputs

When your input is known to be พ.ศ., parse with an explicit era:

```dart
final parsed = ThaiDateService().parseWithEra(
  '25 สิงหาคม 2568',
  era: Era.be,
  pattern: 'd MMMM yyyy',
);
print(parsed?.toDateTime()); // 2025-08-25 00:00:00.000
```

### Common recipes

```dart
// 1) Today in BE and CE (compat functions)
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.be));
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.ce));

// 2) Localized full text (ensure locale first)
await ThaiDateService().initializeLocale('th_TH');
print(formatNow(pattern: 'fullText'));
print(formatNow(pattern: 'fullText', locale: 'en_US'));

// 3) Extensions
print(DateTime(2025, 8, 22).toThaiStringSync(pattern: 'yyyy-MM-dd'));

// 4) Parsing
print(parse('22/08/2568', format: 'dd/MM/yyyy'));
print(parse('2025-08-22', format: 'yyyy-MM-dd'));
```

### Example: Thai date picker (output พ.ศ. ภาษาไทย)

```dart
import 'package:flutter/material.dart';
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

// ... inside a widget method
final picked = await showThaiDatePicker(
  context,
  locale: 'th_TH',
);
if (picked != null) {
  final label = tbd.format(picked, pattern: 'dmy', era: tbd.Era.be);
  print(label); // เช่น 27 สิงหาคม 2568
}
```

## Ergonomics

- Global settings:

```dart
final svc = ThaiDateService();
svc.setEra(Era.be);
svc.setLanguage(ThaiLanguage.thai);
```

- Quick language switch:

```dart
// Use `setLanguage` or pass `locale:` per call
```

- Reusable formatter:

```dart
// Reusable: hold a service instance and reuse it
```

- Extensions:

```dart
// DateTime -> String
final s = await DateTime(2025, 8, 22).toThaiString(pattern: 'yyyy-MM-dd', era: Era.ce);
```

## Backward compatibility and sync vs async

- Top-level helpers `format(...)` and `formatNow(...)` are synchronous (String). They’re drop-in replacements for legacy usage and safe to call without `await`.
- The high-level `ThaiDateService` exposes both `format(...)` (async) and `formatSync(...)` (sync for numeric-only patterns). Use the service if you need explicit control, caching, and advanced parse/convert helpers.
- Legacy shims like `ThaiCalendar`, `ThaiDateSettings`, `ThaiFormatter`, and `TbdLocales` remain available for existing code; they map to the new internals.
- If you output localized month/weekday names (e.g., `MMMM`, `EEE`), call `await ThaiDateService().initializeLocale('th_TH')` once at startup.

## Flutter widgets (optional)

This package ships a simple calendar and multiple pickers. They’re intentionally lightweight so you can customize them freely.

### Month calendar

`BuddhistGregorianCalendar` renders a single‑month grid that formats the header with BE or CE.

```dart
BuddhistGregorianCalendar(
  era: Era.be,                 // or Era.ce
  dayBuilder: customDay?,       // optional: build your own day cells
)
```

### Pickers

- Single date dialog: `showThaiDatePicker(...)`
- Date‑time dialog with live preview and `formatString`: `showThaiDateTimePicker(...)`
- Convenience wrappers that return formatted strings: `showThaiDatePickerFormatted(...)`, `showThaiDateTimePickerFormatted(...)`
- Range selection dialog: `showThaiDateRangePicker(...)`
- Multi‑date selection dialog: `showThaiMultiDatePicker(...)`
- Fullscreen variant (single): `showThaiDatePickerFullscreen(...)`

All dialogs support theming/spacing parameters: `shape`, `titlePadding`, `contentPadding`, `actionsPadding`, `insetPadding`.

Basic usage:

```dart
// Single date
final picked = await showThaiDatePicker(
  context,
  locale: 'th_TH',
);

// Date-time with preview (custom preview format)
final dt = await showThaiDateTimePicker(
  context,
  formatString: 'dd/MM/yyyy HH:mm',
);

// Range (dialog)
final range = await showThaiDateRangePicker(context, era: Era.be, locale: 'th_TH');

// Multi-date
final multiple = await showThaiMultiDatePicker(context, era: Era.be, locale: 'th_TH');

```

API cheatsheet:

```dart
Future<DateTime?> showThaiDatePicker(...)
Future<DateTime?> showThaiDateTimePicker(..., { String formatString = 'dd/MM/yyyy HH:mm' })
Future<String?>  showThaiDatePickerFormatted(..., { String formatString = 'dd/MM/yyyy' })
Future<String?>  showThaiDateTimePickerFormatted(..., { String formatString = 'dd/MM/yyyy HH:mm' })
Future<DateTimeRange?> showThaiDateRangePicker(...)
Future<Set<DateTime>?> showThaiMultiDatePicker(...)
Future<DateTime?> showThaiDatePickerFullscreen(...)
```

### Customization and theming

All dialogs accept common parameters to match your app’s style:

- shape, titlePadding, contentPadding, actionsPadding, insetPadding
- width, height (where applicable)
- headerBuilder and dayBuilder for custom header/day cell UIs
- firstDate and lastDate to constrain selectable dates

The date‑time dialog also exposes `formatString` to control the live preview text (the returned value is still a `DateTime`).

### Behavior and notes

- All pickers support output in พ.ศ. or ค.ศ. via the `era` parameter.
- The calendar respects `firstDate` and `lastDate` and disables days outside this window.
- For localized month/weekday names, initialize locale once on startup via `ThaiDateService().initializeLocale('th_TH')`.

### Error handling and edge cases

- Parsing uses a simple heuristic for BE years (>= 2400). If your input is ambiguous or uses a custom pattern, prefer `ThaiDateService().parseWithEra(input, pattern: '...', era: Era.be|Era.ce)` or pass an explicit `format:` to `parse`.
- All UI pickers are timezone-agnostic and operate on `DateTime` values you provide; be mindful of UTC vs local when storing or comparing.
- The token‑aware formatter replaces only year tokens; other tokens are left to `intl` for correct localization.

## Notes

- Token‑aware: only year tokens (`y`, `yy`, `yyyy`) are swapped to BE; other tokens are left to `intl` for correct localization.
- Parsing heuristics treat years `>= 2400` as BE. If inputs are ambiguous, use `ThaiDateService().parseWithEra(..., era: ...)` with an explicit pattern.
- For Thai month/day names in Flutter, initialize locale via `ThaiDateService().initializeLocale('th_TH')` before rendering widgets.

## License

MIT

## วิธีใช้งาน (ภาษาไทย)

ด้านล่างนี้คือคู่มือการใช้งานแบบย่อพร้อมตัวอย่างโค้ดครอบคลุมกรณีทั่วไป และการตั้งค่าเพิ่มเติม

### 1) การเรียกใช้งานปกติ (Standard)

ใช้ `parse` อ่านสตริงวันที่เป็น BE/CE ได้อัตโนมัติ และ `format` เพื่อพิมพ์ผล โดยเลือกยุคปีด้วย `era: Era.be|Era.ce`

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

final dt1 = parse('2568-08-25');             // อินพุต พ.ศ. -> ภายในเป็น ค.ศ. (2025-08-25)
final dt2 = parse('2025-08-25');             // อินพุต ค.ศ.

final sBE = format(dt1);                      // ค่าเริ่มต้น Era.be -> 2568-08-25
final sCE = format(dt1, era: Era.ce);         // 2025-08-25
```

ใช้แพตเทิร์นเองได้ เช่น `MMMM yyyy`, `dd/MM/yyyy`, `HH:mm` เป็นต้น

```dart
final d = DateTime(2025, 8, 25);
print(format(d, format: 'dd/MM/yyyy'));       // 25/08/2568 (BE)
print(format(d, format: 'MMMM yyyy'));        // สิงหาคม 2568 (BE)
print(format(d, format: 'MMMM yyyy', era: Era.ce)); // สิงหาคม 2025 (CE)
// วันนี้แบบ formatNow (ไม่ต้อง await)
print(formatNow(pattern: 'MMMM yyyy'));
```

### 2) การเรียกใช้งานอย่างง่าย (Quick)

- ไม่อยากสร้าง `DateTime.now()` เอง ใช้ `formatNow(...)`
- ต้องการชื่อเดือน/วันแบบ localized ให้เรียก `ThaiDateService().initializeLocale('th_TH')` หนึ่งครั้งก่อนใช้งาน
- ใช้ extension สำหรับ `DateTime`

```dart
// ป้ายข้อความตอนนี้ (ไม่ต้อง await)
final label = formatNow(pattern: 'fullText');

// โหลด locale ก่อนแล้วค่อยใช้งาน
await ThaiDateService().initializeLocale('th_TH');
final labelAfterInit = formatNow(pattern: 'fullText');

// Extension บน DateTime
final pretty = DateTime(2025, 8, 25).toThaiStringSync(pattern: 'yyyy-MM-dd');
// วันนี้แบบเร็ว
final todayQuick = formatNow(pattern: 'yyyy-MM-dd');
```

### 3) การเรียกใช้งานแบบ Custom (สลับ/ตัดส่วน, เดือนย่อ, ตัวคั่น)

ต้องการรูปแบบ “วัน เดือน ปี” เช่น `25 สิงหาคม 2568` ใช้พรีเซ็ต `pattern: 'dmy'`

```dart
final d = DateTime(2025, 8, 25);
print(format(d, pattern: 'dmy'));           // 25 สิงหาคม 2568
print(format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025
// วันนี้ด้วยพรีเซ็ตเดียวกัน
print(formatNow(pattern: 'dmy'));
```

หรือกำหนดแพตเทิร์นเอง เช่น `MMMM d`, `d MMMM`, `d MMM yyyy`

```dart
// เรียง วัน เดือน ปี (ดีฟอลต์)
final def = format(d, pattern: 'd MMMM yyyy', era: Era.be); // 25 สิงหาคม 2568

// สลับเป็น เดือน วัน
final monthDay = format(d, pattern: 'MMMM d', era: Era.be); // สิงหาคม 25

// ตัดปีออก (วัน เดือน)
final dayMonth = format(d, pattern: 'd MMMM', era: Era.be); // 25 สิงหาคม

// ใช้เดือนย่อ
final shortDash = format(d, pattern: 'd MMM yyyy', era: Era.be); // 25 ส.ค. 2568
```

### 4) ใช้งานด้วย พ.ศ. หรือ ค.ศ. (Formatting & Parsing with Era)

- Formatting: กำหนดยุคปีด้วย `era: Era.be|Era.ce` ใน `format(...)` หรือ extension `toThaiString(...)`
- Parsing (อินพุตแน่ชัดว่าเป็น พ.ศ.): ใช้ `ThaiDateService().parseWithEra(..., era: Era.be)` เพื่อบังคับแปลงปี พ.ศ. -> ค.ศ.

```dart
// Formatting เป็น พ.ศ. หรือ ค.ศ.
final be = format(d);                    // 2568-08-25
final ce = format(d, era: Era.ce);       // 2025-08-25
// วันนี้ (BE/CE)
print(formatNow(pattern: 'yyyy-MM-dd', era: Era.be));
print(formatNow(pattern: 'yyyy-MM-dd', era: Era.ce));

// Parsing เมื่ออินพุตเป็น พ.ศ. แน่นอน
final parsedBE = ThaiDateService().parseWithEra(
  '25 สิงหาคม 2568',
  pattern: 'd MMMM yyyy',
  era: Era.be,
); // -> DateTime(2025, 8, 25)
```

### 5) หลายภาษา (Multi‑language)

- กำหนด locale เป็นรายครั้งผ่าน `locale: 'th_TH' | 'en_US' | 'ja' | ...`
- ตั้งค่าภาษา/locale ทั้งระบบด้วย `ThaiDateService().setLanguage(...)` หรือ `initializeLocale(...)`

```dart
await ThaiDateService().initializeLocale('ja');
final jaNow = await ThaiDateService().formatNow(pattern: 'fullText', locale: 'ja');
```

### 6) ทิปส์ (Tips)

- `ThaiDateService().formatSync(...)` เร็วสำหรับแพตเทิร์นเชิงตัวเลขล้วน
- Extensions: `DateTime.toThaiString()`, `String.toThaiDate()`
