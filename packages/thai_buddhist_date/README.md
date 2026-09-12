# thai_buddhist_date

[![pub package](https://img.shields.io/pub/v/thai_buddhist_date.svg)](https://pub.dev/packages/thai_buddhist_date)
[![CI](https://github.com/Kidpech-code/thai_buddhist_date/actions/workflows/ci.yml/badge.svg)](https://github.com/Kidpech-code/thai_buddhist_date/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Pure Dart package สำหรับตรวจสอบ parse และ format วันที่แบบพุทธศักราช (พ.ศ.) หรือคริสต์ศักราช (ค.ศ.) โดยไม่พึ่ง Flutter

ต้องการ calendar/picker UI ให้ใช้ [`thai_buddhist_date_pickers`](https://pub.dev/packages/thai_buddhist_date_pickers)

![Thai Buddhist date demo](https://raw.githubusercontent.com/Kidpech-code/thai_buddhist_date/main/assets/images/thai_buddhist_date_photo_1.png)

## Install

```yaml
dependencies:
  thai_buddhist_date: ^0.4.1
```

## Format และ parse

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  await ThaiDateService().initializeLocale('th_TH');

  final date = DateTime(2025, 8, 22);
  print(format(date, pattern: 'dd/MM/yyyy')); // 22/08/2568
  print(format(date, pattern: 'd MMMM yyyy')); // 22 สิงหาคม 2568
  print(format(date, pattern: 'yyyy-MM-dd', era: Era.ce)); // 2025-08-22

  final parsed = parse('22/08/2568', format: 'dd/MM/yyyy');
  print(parsed); // 2025-08-22 00:00:00.000
}
```

`format` และ `ThaiCalendar.format` รองรับ preset เช่น `fullText`, `shortDate`, `longDate`, `dmy`, `iso` และ pattern ของ `intl` เช่น `yyyy-MM-dd`, `HH:mm`, `d MMMM yyyy`

## Validate วันที่

ใช้ `ThaiDate.safe` เมื่อต้องการ reject วันที่ไม่มีจริงในทุก build mode:

```dart
final leapDay = ThaiDate.safe(
  year: 2567,
  month: 2,
  day: 29,
  era: Era.be,
);

print(leapDay.isValid); // true
// ThaiDate.safe(year: 2568, month: 2, day: 29); throws ArgumentError
```

constructor `ThaiDate(...)` เดิมยังคงอยู่เพื่อ backward compatibility

## Parse แล้ว format แบบ async

`ThaiDateService.convert` ใช้ locale เดียวกันตลอด parse → format และคืน `null` เมื่อ parse ไม่สำเร็จ:

```dart
final output = await ThaiDateService().convert(
  '22/08/2568',
  fromPattern: 'dd/MM/yyyy',
  toPattern: 'd MMMM yyyy',
  inputEra: Era.be,
  toEra: Era.be,
  locale: 'fr',
);
// 22 août 2568
```

## Leap days and explicit input era

```dart
await ThaiDateService().initializeLocale('th_TH');
final leapDay = ThaiDateService().parseWithEra(
  '29/02/2567', pattern: 'dd/MM/yyyy', era: Era.be,
);
print(leapDay?.toDateTime()); // 2024-02-29 00:00:00.000
// '29/02/2568' is invalid and returns null; it is never shifted to March.
```

`parseWithEra` interprets the input year in the specified era independently of
previous automatic parsing calls.

## Extensions

```dart
final beYear = DateTime(2025, 8, 22).beYear; // 2568
final ceYear = 2568.toCE; // 2025
final fromDouble = 2568.0.toCE; // 2025.0
final label = DateTime(2025, 8, 22).toThaiStringSync(
  pattern: 'yyyy-MM-dd',
);
```

## Locale behavior

- ใช้ locale code ที่ `intl` รองรับ เช่น `th_TH`, `en_US`, `fr`
- เรียก `initializeLocale` ก่อนใช้ชื่อเดือนหรือวันใน locale นั้น
- locale ที่ใช้ไม่ได้จะ fallback ไปยัง locale ที่ตั้งค่าไว้ใน service โดยค่าเริ่มต้นคือ `th_TH`

## Dependency injection

repository interfaces ถูก export จาก package entry point จึงสร้าง service สำหรับ test หรือ integration เฉพาะทางได้:

```dart
final service = ThaiDateService.create(
  formatterRepository: customFormatterRepository,
  parserRepository: customParserRepository,
);
```

## Compatibility

public API เดิมยังคงอยู่ในรอบนี้ โดย `architectureType`, `ListEquality` และ `ParseThaiDateUseCase.convert` ถูก deprecate เพื่อเตรียมถอดใน release อนาคต ใช้ `ThaiDateService.convert` แทนสำหรับ parse → format

ดูตัวอย่างที่รันได้ใน [`example/main.dart`](example/main.dart) และประวัติการเปลี่ยนแปลงใน [`CHANGELOG.md`](CHANGELOG.md)
