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
  thai_buddhist_date: ^0.2.3
```

Then run `dart pub get` or `flutter pub get`.

## Quick start

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  // Parse either BE or CE and get a DateTime (internally CE).
  final dt = parse('2568-08-22');

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
  // Load date symbols for Thai before using patterns like 'MMMM' or 'EEE'
  await ThaiDateService().initializeLocale('th_TH');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThaiDateService().initializeLocale('th_TH');
  runApp(const MyApp());
}
```

print(format(d, pattern: 'dmy', era: Era.be)); // 25 สิงหาคม 2568
print(format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025

```dart
final service = ThaiDateService();
print(format(d, pattern: 'dd/MM/yyyy'));       // 25/08/2568 (BE)
print(format(d, pattern: 'MMMM yyyy'));        // สิงหาคม 2568 (BE)
print(format(d, pattern: 'MMMM yyyy', era: Era.ce)); // สิงหาคม 2025 (CE)
final iso = service.formatSync(ThaiDate.fromDateTime(DateTime(2025, 8, 22)), pattern: 'iso');

// Parse (accepts BE or CE) – returns ThaiDate (BE year)
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.be));
print(formatNow(pattern: 'dd/MM/yyyy', era: Era.ce));
// Now helper
final label = await service.formatNow(pattern: 'fullText');

print(formatNow(pattern: 'fullText'));
print(formatNow(pattern: 'fullText', locale: 'en_US'));
service.setLanguage(ThaiLanguage.thai); // sets locale to 'th_TH'
await service.initializeLocale('th_TH');
```

### Multi-language date/time/date&time

- Pick any locale via the `locale:` parameter or set language globally on the service.
- Use the same API for date (yyyy-MM-dd), time (HH:mm), or combined (dd/MM/yyyy HH:mm).

  final label = tbd.format(picked, pattern: 'dmy', era: tbd.Era.be);
  final svc = ThaiDateService();
  // Date only
  final frDate = await svc.formatNow(pattern: 'yyyy-MM-dd', locale: 'fr');
  // Time only
  // Date & Time
  final frDateTime = await svc.formatNow(pattern: 'dd/MM/yyyy HH:mm', locale: 'fr');

// Override per call with another language
final esFull = await svc.formatNow(pattern: 'fullText', locale: 'es');

````

### Thai full date format (วัน เดือน ปี)

final sBE = format(dt1);                      // ค่าเริ่มต้น Era.be -> 2568-08-25
final sCE = format(dt1, era: Era.ce);         // 2025-08-25
```dart
final d = DateTime(2025, 8, 25);
print(await format(d, pattern: 'dmy', era: Era.be)); // 25 สิงหาคม 2568
print(await format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025
````

### Custom patterns

// ตัวอย่างวันนี้แบบ formatNow (ไม่ต้อง await)
print(formatNow(pattern: 'MMMM yyyy'));

```dart
final d = DateTime(2025, 8, 25);
print(await format(d, pattern: 'dd/MM/yyyy'));       // 25/08/2568 (BE)
print(await format(d, pattern: 'MMMM yyyy'));        // สิงหาคม 2568 (BE)
// ป้ายข้อความตอนนี้ (ไม่ต้อง await)
final label = formatNow(pattern: 'fullText');
```

// โหลด locale ก่อนแล้วค่อยใช้งาน

### Explicit-era parsing for BE inputs

final labelAfterInit = formatNow(pattern: 'fullText');
When your input is known to be พ.ศ., parse with an explicit era:

```dart
final parsed = ThaiDateService().parseWithEra(
final todayQuick = formatNow(pattern: 'yyyy-MM-dd');
  pattern: 'd MMMM yyyy',
  era: Era.be,
);
print(parsed?.toDateTime()); // 2025-08-25 00:00:00.000
```

print(format(d, pattern: 'dmy')); // 25 สิงหาคม 2568
print(format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025

print(formatNow(pattern: 'dmy'));
// 1) Today in BE and CE (compat functions)
print(await formatNow(pattern: 'dd/MM/yyyy', era: Era.be));
print(await formatNow(pattern: 'dd/MM/yyyy', era: Era.ce));
final def = format(d, pattern: 'd MMMM yyyy', era: Era.be); // 25 สิงหาคม 2568
// 2) Localized full text (ensure locale first)
await ThaiDateService().initializeLocale('th_TH');
final monthDay = format(d, pattern: 'MMMM d', era: Era.be); // สิงหาคม 25
print(await formatNow(pattern: 'fullText', locale: 'en_US'));

final dayMonth = format(d, pattern: 'd MMMM', era: Era.be); // 25 สิงหาคม
print(DateTime(2025, 8, 22).toThaiStringSync(pattern: 'yyyy-MM-dd'));

final shortDash = format(d, pattern: 'd MMM yyyy', era: Era.be); // 25 ส.ค. 2568
print(parse('22/08/2568', format: 'dd/MM/yyyy'));
print(parse('2025-08-22', format: 'yyyy-MM-dd'));

````

final be = format(d);                    // 2568-08-25
final ce = format(d, era: Era.ce);       // 2025-08-25
```dart
import 'package:flutter/material.dart';
## Backward compatibility and sync vs async

- Top-level helpers `format(...)` and `formatNow(...)` are synchronous (String). They’re drop-in replacements for legacy usage and safe to call without `await`.
- The high-level `ThaiDateService` exposes both `format(...)` (async) and `formatSync(...)` (sync for numeric-only patterns). Use the service if you need explicit control, caching, and advanced parse/convert helpers.
- Legacy shims like `ThaiCalendar`, `ThaiDateSettings`, `ThaiFormatter`, and `TbdLocales` remain available for existing code; they map to the new internals.
- If you output localized month/weekday names (e.g., `MMMM`, `EEE`), call `await ThaiDateService().initializeLocale('th_TH')` once at startup.
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

// ... inside a widget method
final picked = await showThaiDatePicker(
  context,
  initialDate: DateTime.now(),
  era: tbd.Era.be,
  locale: 'th_TH',
);
if (picked != null) {
  final label = await tbd.format(picked, pattern: 'dmy', era: tbd.Era.be);
  print(label); // เช่น 27 สิงหาคม 2568
}
````

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

## Flutter widgets (optional)

This package ships a simple calendar and multiple pickers. They’re intentionally lightweight so you can customize them freely.

### Month calendar

`BuddhistGregorianCalendar` renders a single‑month grid that formats the header with BE or CE.

```dart
BuddhistGregorianCalendar(
  era: Era.be,                 // or Era.ce
  selectedDate: _selected,
  onDateSelected: (d) => setState(() => _selected = d),
  locale: 'th_TH',
  firstDate: DateTime(1900,1,1),
  lastDate: DateTime(2100,12,31),
  headerBuilder: customHeader?, // optional: build your own header
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
  initialDate: DateTime.now(),
  era: Era.be,
  locale: 'th_TH',
);

// Date-time with preview (custom preview format)
final dt = await showThaiDateTimePicker(
  context,
  initialDateTime: DateTime.now(),
  era: Era.ce,
  locale: 'th_TH',
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

ด้านล่างนี้คือคู่มือการใช้งานแบบละเอียด แบ่งหัวข้อชัดเจน พร้อมตัวอย่างโค้ดใช้งานจริง ครอบคลุมรูปแบบทั่วไป, การใช้งานแบบง่าย, การปรับแต่ง (custom), การใช้งานกับพ.ศ./ค.ศ., การแปลงรูปแบบ และฟังก์ชันช่วยอื่นๆ ที่ควรรู้

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
// ตัวอย่างวันนี้แบบ formatNow
print(await formatNow(pattern: 'MMMM yyyy'));
```

### 2) การเรียกใช้งานอย่างง่าย (Quick)

- ไม่อยากสร้าง `DateTime.now()` เอง ใช้ `formatNow(...)`
- ต้องการ localized ชื่อเดือน/วัน ให้ init locale หนึ่งครั้งด้วย `ThaiDateService().initializeLocale('th_TH')`
- ใช้ extension สำหรับ `DateTime`

```dart
// ป้ายข้อความตอนนี้
final label = await formatNow(pattern: 'fullText');

// แบบ async พร้อม ensure locale
await ThaiDateService().initializeLocale('th_TH');
final labelAsync = await formatNow(pattern: 'fullText');

// Extension บน DateTime
final pretty = DateTime(2025, 8, 25).toThaiString(pattern: 'yyyy-MM-dd');
// วันนี้แบบเร็ว
final todayQuick = await formatNow(pattern: 'yyyy-MM-dd');
```

### 3) การเรียกใช้งานแบบ Custom (สลับ/ตัดส่วน, เดือนย่อ, ตัวคั่น)

ต้องการรูปแบบ “วัน เดือน ปี” เช่น `25 สิงหาคม 2568` ใช้พรีเซ็ต `pattern: 'dmy'`

```dart
final d = DateTime(2025, 8, 25);
print(await format(d, pattern: 'dmy'));           // 25 สิงหาคม 2568
print(await format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025
// วันนี้ด้วยพรีเซ็ตเดียวกัน
print(await formatNow(pattern: 'dmy'));
```

และถ้าต้องการสลับตำแหน่ง/ตัดบางส่วนออก ใช้แพตเทิร์นกำหนดเอง เช่น `MMMM d`, `d MMMM`, `d MMM yyyy`

```dart
// เรียง วัน เดือน ปี (ดีฟอลต์)
final def = await format(d, pattern: 'd MMMM yyyy', era: Era.be); // 25 สิงหาคม 2568

// สลับเป็น เดือน วัน
final monthDay = await format(d, pattern: 'MMMM d', era: Era.be); // สิงหาคม 25

// ตัดปีออก (วัน เดือน)
final dayMonth = await format(d, pattern: 'd MMMM', era: Era.be); // 25 สิงหาคม

// ใช้เดือนย่อ และปรับคั่นด้วย "-"
final shortDash = await format(d, pattern: 'd MMM yyyy', era: Era.be); // 25 ส.ค. 2568
```

### 4) การเรียกใช้งานด้วย พ.ศ. หรือ ค.ศ. (Formatting & Parsing with Era)

- Formatting: กำหนดยุคปีที่ต้องการด้วย `era: Era.be|Era.ce` ใน `format(...)` หรือ extension `toThaiString(...)`
- Parsing (อินพุตแน่ชัดว่าเป็น พ.ศ.): ใช้ `ThaiDateService().parseWithEra(..., era: Era.be)` เพื่อบังคับแปลงปี พ.ศ. -> ค.ศ.

```dart
// Formatting เป็น พ.ศ. หรือ ค.ศ.
final d = DateTime(2025, 8, 25);
final be = await format(d);                    // 2568-08-25
final ce = await format(d, era: Era.ce);       // 2025-08-25
// วันนี้ (BE/CE)
print(await formatNow(pattern: 'yyyy-MM-dd', era: Era.be));
print(await formatNow(pattern: 'yyyy-MM-dd', era: Era.ce));

// Parsing เมื่ออินพุตเป็น พ.ศ. แน่นอน
final parsedBE = ThaiDateService().parseWithEra(
  '25 สิงหาคม 2568',
  pattern: 'd MMMM yyyy',
  era: Era.be,
); // -> DateTime(2025, 8, 25)

// Parsing อินพุต ค.ศ.
final parsedCE = ThaiDateService().parseWithEra(
  '25 August 2025',
  pattern: 'd MMMM yyyy',
  era: Era.ce,
  locale: 'en_US',
);
```

หมายเหตุ: หากอินพุตไม่แน่ใจว่าเป็น BE/CE ใช้ `parse(input, format: ...)` ที่มี heuristic ตรวจปี >= 2400 เป็น พ.ศ. หรือ `ThaiDateService().parseWithEra(...)` ระบุ era ชัดเจน

### 5) การเรียกใช้งานแปลงรูปแบบ (Convert)

แปลงรูปแบบ/ยุคปีด้วยการ parse แล้ว format ใหม่ (เช่น `parse(..., format: ...)` แล้ว `format(..., pattern: ..., era: ...)`)

```dart
final dt = parse('22/08/2568', format: 'dd/MM/yyyy');
final out1 = await format(dt, pattern: 'yyyy-MM-dd', era: Era.ce); // 2025-08-22
final dt2 = parse('2025-08-22', format: 'yyyy-MM-dd');
final out2 = await format(dt2, pattern: 'd MMMM yyyy', era: Era.be); // 22 สิงหาคม 2568
```

### 6) การใช้งานหลายภาษา (Multi‑language)

- กำหนด locale เป็นรายครั้งผ่าน `locale: 'th_TH' | 'en_US' | 'ja' | ...`
- ตั้งค่าภาษา/locale ทั้งระบบด้วย `ThaiDateService().setLanguage(...)` หรือส่ง `locale:` รายครั้ง
- สำหรับชื่อเดือน/วันแบบ localized อย่าลืม `await ThaiDateService().initializeLocale(locale)` ในแอป Flutter

```dart
await ThaiDateService().initializeLocale('fr');
final fr = await formatNow(pattern: 'fullText', locale: 'fr');

await ThaiDateService().initializeLocale('ja');
final jaFull = await format(DateTime(2025,8,25), pattern: 'dmy', era: Era.ce, locale: 'ja');
final jaNowFull = await formatNow(pattern: 'fullText', locale: 'ja');
```

### 7) ฟังก์ชันช่วยและทิปส์ (Helpers)

- `ThaiDateService().formatSync(...)` เร็วสำหรับแพตเทิร์นเชิงตัวเลขล้วน (ไม่มีชื่อเดือน)
- Extension: `DateTime.toThaiString(...)` และ `String.toThaiDate(...)`

```dart
// ใช้ DateFormat ของ intl โดยยังคง year เป็น พ.ศ.
final df = DateFormat.yMMMMd('th');
// วันนี้ด้วยแพตเทิร์นเดียวกัน
final sNow = await formatNow(pattern: 'yMMMMd');

// Sync formatting (ตัวเลขล้วน)
final fast = ThaiDateService().formatSync(ThaiDate.fromDateTime(DateTime(2025,8,25)), pattern: 'yyyy-MM-dd'); // 2568-08-25
// วันนี้ (ผ่าน compat formatNow)
final todayFast = await formatNow(pattern: 'yyyy-MM-dd');

// Extensions
final s1 = DateTime(2025,8,25).toThaiString(pattern: 'dd/MM/yyyy');
final dt = '22/08/2568'.toThaiDate(pattern: 'dd/MM/yyyy');
// วันนี้เป็นสตริง
final sNow = await formatNow(pattern: 'dd/MM/yyyy');
```

### 8) ข้อควรระวัง/กรณีขอบ (Edge cases)

- ถ้าอินพุตคลุมเครือ (เช่น ปี 2420 อาจเป็นทั้ง BE/CE ได้) ให้ระบุแพตเทิร์นและ era ให้ชัดด้วย `parseWithEra` หรือ `parseWith(DateFormat)`
- แพตเทิร์นที่มีชื่อเดือน/วัน ต้องเรียก `ensureInitialized(locale)` ใน Flutter ก่อนจึงจะแสดงชื่อที่ถูกต้อง
- `formatSync` ใช้กับแพตเทิร์นเชิงตัวเลขล้วนเท่านั้น (เช่น yyyy-MM-dd)
