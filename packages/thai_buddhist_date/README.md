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
- ThaiCalendar helpers: Locale‑aware utilities with `ensureInitialized()`, `format()`, `formatWith(DateFormat)`, `formatInitialized()`, and more.
- Flutter extras (optional): A lightweight month calendar and a set of date pickers (single, date‑time with preview, range, multi‑date, and fullscreen) with theming hooks.

## Install

Add to your pubspec.yaml:

```yaml
dependencies:
  thai_buddhist_date: ^0.2.2
```

Then run `dart pub get` or `flutter pub get`.

## Quick start

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  // Parse either BE or CE and get a DateTime (internally CE).
  final dt = parse('2568-08-22');

  // Format in BE (default) or CE.
  print(format(dt));                 // 2568-08-22
  print(format(dt, era: Era.ce));    // 2025-08-22
}
```

## Locale initialization for Flutter

If you need localized month/weekday names (e.g., `MMMM yyyy`), initialize the Thai locale before building the UI:

```dart
import 'package:flutter/material.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThaiCalendar.ensureInitialized();
  runApp(const MyApp());
}
```

## ThaiCalendar helpers

Convenience APIs for common tasks:

- `ThaiCalendar.ensureInitialized()` — loads `th_TH` locale data for `intl`.
- `ThaiCalendar.format(date, pattern: 'fullText', era: Era.be)` — localized formatting using pre‑defined patterns.
- `ThaiCalendar.formatNow(pattern: 'fullText', era: Era.be)` — like above, but uses `DateTime.now()` for you.
- `ThaiCalendar.formatWith(DateFormat df, date, {era})` — use your own `DateFormat` and still get BE output safely.
- `ThaiCalendar.formatInitialized(...)` — await locale init and then format.
- `ThaiCalendar.formatSync(...)` — fast numeric‑only formatting without locale cost.

Examples:

```dart
await ThaiCalendar.ensureInitialized();
final d = DateTime(2025, 8, 22);
print(ThaiCalendar.format(d, pattern: 'fullText', era: Era.be)); // วันศุกร์ที่ 22 สิงหาคม 2568
print(ThaiCalendar.format(d, pattern: 'fullText', era: Era.ce)); // Friday, 22 สิงหาคม 2025 (localized)

// No need to create `now` yourself
final label = ThaiCalendar.formatNow(pattern: 'fullText');
final labelCE = ThaiCalendar.formatNow(pattern: 'fullText', era: Era.ce);

// Async version that ensures locale data first
final asyncLabel = await ThaiCalendar.formatInitializedNow(pattern: 'fullText');
```

### Multi-language date/time/date&time

- Pick any locale via the `locale:` parameter or set a default with `ThaiDateSettings.useLocale('fr')`.
- Use the same API for date (yyyy-MM-dd), time (HH:mm), or combined (dd/MM/yyyy HH:mm).

```dart
// Set default locale globally (optional)
ThaiDateSettings.useLocale('fr'); // French

// Date only
final frDate = ThaiCalendar.formatNow(pattern: 'yyyy-MM-dd');
// Time only
final frTime = ThaiCalendar.formatNow(pattern: 'HH:mm');
// Date & Time
final frDateTime = ThaiCalendar.formatNow(pattern: 'dd/MM/yyyy HH:mm');

// Override per call with another language
final esFull = ThaiCalendar.formatNow(pattern: 'fullText', locale: 'es');
final deShort = ThaiCalendar.formatNow(pattern: 'dd.MM.yyyy', locale: 'de');

// Ensure localized month/day names when needed
await ThaiCalendar.ensureInitialized('ja');
final jaFull = ThaiCalendar.formatNow(pattern: 'fullText', locale: 'ja');
```

### Thai full date format (วัน เดือน ปี)

Output like 25 สิงหาคม 2568 using a preset pattern, with BE or CE:

```dart
final d = DateTime(2025, 8, 25);
// BE (default): 25 สิงหาคม 2568
final thBE = ThaiCalendar.format(d, pattern: 'dmy', era: Era.be);
// CE: 25 สิงหาคม 2025
final thCE = ThaiCalendar.format(d, pattern: 'dmy', era: Era.ce);
```

### Custom ordering or omitting parts

Build your own strings by reordering or omitting components (day, month, year).

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

final d = DateTime(2025, 8, 25);

// Default order: day month year → "25 สิงหาคม 2568"
final def = ThaiCalendar.formatThaiDateParts(d, era: Era.be);

// Swap to month day: "สิงหาคม 25"
final monthDay = ThaiCalendar.formatThaiDateParts(
  d,
  order: const [ThaiDatePart.month, ThaiDatePart.day],
  era: Era.be,
);

// Omit year: "25 สิงหาคม"
final dayMonth = ThaiCalendar.formatThaiDateParts(
  d,
  order: const [ThaiDatePart.day, ThaiDatePart.month],
  era: Era.be,
);

// Short month name: "25 ส.ค. 2568"
final shortMonth = ThaiCalendar.formatThaiDateParts(
  d,
  era: Era.be,
  monthShort: true,
);
```

### Explicit-era parsing for BE inputs

When your input string is known to be พ.ศ. (Buddhist Era), parse with an explicit era hint:

```dart
// Input is in BE: "25 สิงหาคม 2568"
final parsed = ThaiCalendar.parseWithEra(
  '25 สิงหาคม 2568',
  pattern: 'd MMMM yyyy',
  era: Era.be,   // treat input year as BE and convert to CE internally
);

// If input is CE, specify Era.ce (or use ThaiCalendar.parse with heuristics)
final parsedCE = ThaiCalendar.parseWithEra(
  '25 August 2025',
  pattern: 'd MMMM yyyy',
  era: Era.ce,
  locale: 'en_US',
);
```

### Common recipes

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

// 1) Today in BE and CE
final todayBE = ThaiCalendar.formatNow(pattern: 'dd/MM/yyyy', era: Era.be); // e.g. 25/08/2568
final todayCE = ThaiCalendar.formatNow(pattern: 'dd/MM/yyyy', era: Era.ce); // e.g. 25/08/2025

// 2) Localized full text (ensure locale first)
await ThaiCalendar.ensureInitialized();
final fullTh = ThaiCalendar.formatNow(pattern: 'fullText');          // วันจันทร์ที่ 25 สิงหาคม 2568
final fullEn = ThaiCalendar.formatNow(pattern: 'fullText', locale: 'en_US'); // Monday, August 25, 2025

// 3) Switch defaults globally
ThaiDateSettings.set(era: Era.be, language: ThaiLanguage.thai);
final s1 = DateTime(2025, 8, 22).toThaiString(pattern: 'yyyy-MM-dd'); // 2568-08-22

// 4) Numeric formatting (no locale cost)
final fast = ThaiCalendar.formatSync(DateTime(2025, 8, 22), pattern: 'yyyy-MM-dd', era: Era.be); // 2568-08-22

// 5) Parsing
final d1 = ThaiCalendar.parse('22/08/2568', customPattern: 'dd/MM/yyyy'); // -> 2025-08-22
final d2 = ThaiCalendar.parse('2025-08-22', customPattern: 'yyyy-MM-dd'); // -> 2025-08-22

// 6) Convert patterns and eras
final out = ThaiCalendar.convert('22/08/2568', fromPattern: 'dd/MM/yyyy', toPattern: 'yyyy-MM-dd', toEra: Era.ce); // 2025-08-22
```

## Ergonomic API (pro)

- Global settings:

```dart
// Choose defaults across your app
ThaiDateSettings.set(era: Era.be, language: ThaiLanguage.thai); // or locale: 'en_US'
```

- Quick language switch:

```dart
ThaiDateSettings.useThai();      // 'th_TH'
ThaiDateSettings.useEnglishUS(); // 'en_US'
```

- Reusable formatter:

```dart
final f = ThaiFormatter(pattern: 'dd MMM yyyy', era: Era.be, language: ThaiLanguage.thai);
print(f.format(DateTime(2025, 8, 22))); // 22 ส.ค. 2568
```

- Extensions:

```dart
// DateTime -> String
final s = DateTime(2025, 8, 22).toThaiString(pattern: 'yyyy-MM-dd', era: Era.ce, language: ThaiLanguage.english);

// String -> DateTime?
final dt = '22/08/2568'.toThaiDate(pattern: 'dd/MM/yyyy');
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
- For localized month/weekday names, call `await ThaiCalendar.ensureInitialized()` before rendering UI.

### Error handling and edge cases

- Parsing uses a simple heuristic for BE years (>= 2400). If your input is ambiguous or uses a custom pattern, prefer `ThaiCalendar.parseWith(DateFormat, input)` or specify an explicit format.
- All UI pickers are timezone-agnostic and operate on `DateTime` values you provide; be mindful of UTC vs local when storing or comparing.
- The token‑aware formatter replaces only year tokens; other tokens are left to `intl` for correct localization.

## Notes

- The formatter is token‑aware: it only replaces year tokens (e.g., `y`, `yy`, `yyyy`) to BE values. Other fields (month/day/weekday) are left to `intl` so localized output stays correct.
- Parsing heuristics treat years `>= 2400` as BE. If your inputs are ambiguous or custom, prefer `ThaiCalendar.parseWith(DateFormat, input)` with an explicit pattern.
- For best results with Thai month/day names in Flutter, call `await ThaiCalendar.ensureInitialized()` before rendering widgets.

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
```

### 2) การเรียกใช้งานอย่างง่าย (Quick)

- ไม่อยากสร้าง `DateTime.now()` เอง ใช้ `ThaiCalendar.formatNow(...)`
- แบบ async ที่แน่ใจว่ามี locale พร้อม ใช้ `ThaiCalendar.formatInitializedNow(...)`
- ใช้ extension สำหรับ `DateTime`

```dart
// ป้ายข้อความตอนนี้
final label = ThaiCalendar.formatNow(pattern: 'fullText');

// แบบ async พร้อม ensure locale
final labelAsync = await ThaiCalendar.formatInitializedNow(pattern: 'fullText');

// Extension บน DateTime
final pretty = DateTime(2025, 8, 25).toThaiString(pattern: 'yyyy-MM-dd');
```

### 3) การเรียกใช้งานแบบ Custom (สลับ/ตัดส่วน, เดือนย่อ, ตัวคั่น)

ต้องการรูปแบบ “วัน เดือน ปี” เช่น `25 สิงหาคม 2568` ใช้พรีเซ็ต `pattern: 'dmy'`

```dart
final d = DateTime(2025, 8, 25);
print(ThaiCalendar.format(d, pattern: 'dmy'));           // 25 สิงหาคม 2568
print(ThaiCalendar.format(d, pattern: 'dmy', era: Era.ce)); // 25 สิงหาคม 2025
```

และถ้าต้องการสลับตำแหน่ง/ตัดบางส่วนออก หรือใช้เดือนแบบย่อ ให้ใช้ `ThaiCalendar.formatThaiDateParts(...)`

```dart
// เรียง วัน เดือน ปี (ดีฟอลต์)
final def = ThaiCalendar.formatThaiDateParts(d, era: Era.be); // 25 สิงหาคม 2568

// สลับเป็น เดือน วัน
final monthDay = ThaiCalendar.formatThaiDateParts(
  d,
  order: const [ThaiDatePart.month, ThaiDatePart.day],
  era: Era.be,
); // สิงหาคม 25

// ตัดปีออก (วัน เดือน)
final dayMonth = ThaiCalendar.formatThaiDateParts(
  d,
  order: const [ThaiDatePart.day, ThaiDatePart.month],
  era: Era.be,
); // 25 สิงหาคม

// ใช้เดือนย่อ และปรับคั่นด้วย "-"
final shortDash = ThaiCalendar.formatThaiDateParts(
  d,
  era: Era.be,
  monthShort: true,
  separator: '-',
); // 25-ส.ค.-2568
```

### 4) การเรียกใช้งานด้วย พ.ศ. หรือ ค.ศ. (Formatting & Parsing with Era)

- Formatting: กำหนดยุคปีที่ต้องการด้วย `era: Era.be|Era.ce` ใน `format(...)`, `ThaiCalendar.format(...)`, หรือ extension `toThaiString(...)`
- Parsing (อินพุตแน่ชัดว่าเป็น พ.ศ.): ใช้ `ThaiCalendar.parseWithEra(..., era: Era.be)` เพื่อบังคับแปลงปี พ.ศ. -> ค.ศ.

```dart
// Formatting เป็น พ.ศ. หรือ ค.ศ.
final d = DateTime(2025, 8, 25);
final be = format(d);                    // 2568-08-25
final ce = format(d, era: Era.ce);       // 2025-08-25

// Parsing เมื่ออินพุตเป็น พ.ศ. แน่นอน
final parsedBE = ThaiCalendar.parseWithEra(
  '25 สิงหาคม 2568',
  pattern: 'd MMMM yyyy',
  era: Era.be,
); // -> DateTime(2025, 8, 25)

// Parsing อินพุต ค.ศ.
final parsedCE = ThaiCalendar.parseWithEra(
  '25 August 2025',
  pattern: 'd MMMM yyyy',
  era: Era.ce,
  locale: 'en_US',
);
```

หมายเหตุ: หากอินพุตไม่แน่ใจว่าเป็น BE/CE ใช้ `ThaiCalendar.parse(input, customPattern: ...)` หรือ `parse(...)` ที่มี heuristic ตรวจปี >= 2400 เป็น พ.ศ.

### 5) การเรียกใช้งานแปลงรูปแบบ (Convert)

เปลี่ยนรูปแบบ/ยุคปีด้วย `ThaiCalendar.convert(...)`

```dart
final out1 = ThaiCalendar.convert(
  '22/08/2568',
  fromPattern: 'dd/MM/yyyy',
  toPattern: 'yyyy-MM-dd',
  toEra: Era.ce,
); // 2025-08-22

final out2 = ThaiCalendar.convert(
  '2025-08-22',
  fromPattern: 'yyyy-MM-dd',
  toPattern: 'd MMMM yyyy',
  toEra: Era.be,
); // 22 สิงหาคม 2568
```

### 6) การใช้งานหลายภาษา (Multi‑language)

- กำหนด locale เป็นรายครั้งผ่าน `locale: 'th_TH' | 'en_US' | 'ja' | ...`
- ตั้งค่าดีฟอลต์ทั้งระบบด้วย `ThaiDateSettings.useLocale('fr')`, `useThai()`, หรือ `useEnglishUS()`
- ชุดค่าคงที่ `TbdLocales` มีโค้ดภาษาที่พบบ่อย เช่น `TbdLocales.th`, `TbdLocales.en`, `TbdLocales.ja`
- สำหรับชื่อเดือน/วันแบบ localized อย่าลืม `await ThaiCalendar.ensureInitialized(locale)` ในแอป Flutter

```dart
ThaiDateSettings.useLocale('fr'); // ตั้งดีฟอลต์ภาษาฝรั่งเศส
final fr = ThaiCalendar.formatNow(pattern: 'fullText');

final ja = ThaiCalendar.formatNow(pattern: 'fullText', locale: 'ja');
await ThaiCalendar.ensureInitialized('ja');
final jaFull = ThaiCalendar.format(DateTime(2025,8,25), pattern: 'dmy', era: Era.ce, locale: 'ja');
```

### 7) ฟังก์ชันช่วยและทิปส์ (Helpers)

- `ThaiCalendar.formatWith(DateFormat df, date, {era})` ใช้คู่กับ `intl.DateFormat` ที่คุณสร้างเอง
- `ThaiCalendar.formatInitialized(...)` และ `formatInitializedNow(...)` ช่วย ensure locale อัตโนมัติ (Flutter)
- `ThaiCalendar.formatSync(...)` เร็วสำหรับแพตเทิร์นเชิงตัวเลขล้วน (ไม่มีชื่อเดือน)
- Extension: `DateTime.toThaiString(...)` และ `String.toThaiDate(...)`

```dart
// ใช้ DateFormat ของ intl โดยยังคง year เป็น พ.ศ.
final df = DateFormat.yMMMMd('th');
final s = ThaiCalendar.formatWith(df, DateTime(2025,8,25), era: Era.be);

// Sync formatting (ตัวเลขล้วน)
final fast = ThaiCalendar.formatSync(DateTime(2025,8,25), pattern: 'yyyy-MM-dd'); // 2568-08-25

// Extensions
final s1 = DateTime(2025,8,25).toThaiString(pattern: 'dd/MM/yyyy');
final dt = '22/08/2568'.toThaiDate(pattern: 'dd/MM/yyyy');
```

### 8) ข้อควรระวัง/กรณีขอบ (Edge cases)

- ถ้าอินพุตคลุมเครือ (เช่น ปี 2420 อาจเป็นทั้ง BE/CE ได้) ให้ระบุแพตเทิร์นและ era ให้ชัดด้วย `parseWithEra` หรือ `parseWith(DateFormat)`
- แพตเทิร์นที่มีชื่อเดือน/วัน ต้องเรียก `ensureInitialized(locale)` ใน Flutter ก่อนจึงจะแสดงชื่อที่ถูกต้อง
- `formatSync` ใช้กับแพตเทิร์นเชิงตัวเลขล้วนเท่านั้น (เช่น yyyy-MM-dd)
