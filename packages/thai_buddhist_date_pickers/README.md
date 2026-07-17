# thai_buddhist_date_pickers

[![pub package](https://img.shields.io/pub/v/thai_buddhist_date_pickers.svg)](https://pub.dev/packages/thai_buddhist_date_pickers)
[![CI](https://github.com/Kidpech-code/thai_buddhist_date/actions/workflows/ci.yml/badge.svg)](https://github.com/Kidpech-code/thai_buddhist_date/actions/workflows/ci.yml)

Flutter calendar และ date pickers สำหรับปี พ.ศ./ค.ศ. สร้างบน [`thai_buddhist_date`](https://pub.dev/packages/thai_buddhist_date) รองรับ Flutter 3.19 ขึ้นไป

release นี้ตรวจ compatibility ด้วย Flutter 3.19.6 และ Flutter 3.44.2

![Thai Buddhist picker demo](https://raw.githubusercontent.com/Kidpech-code/thai_buddhist_date/main/assets/images/thai_buddhist_date_pickers_photo_1.png)

## Install

```yaml
dependencies:
  thai_buddhist_date: ^0.4.0
  thai_buddhist_date_pickers: ^0.3.0
```

initialize locale ก่อนสร้าง app เมื่อใช้ชื่อเดือนหรือวันภาษาไทย:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tbd.ThaiDateService().initializeLocale('th_TH');
  runApp(const MyApp());
}
```

## Calendar widget

```dart
BuddhistGregorianCalendar(
  initialMonth: DateTime(2025, 8),
  selectedDate: selectedDate,
  firstDate: DateTime(2025, 1, 1),
  lastDate: DateTime(2025, 12, 31),
  era: tbd.Era.be,
  locale: 'th_TH',
  onDateSelected: (date) => setState(() => selectedDate = date),
)
```

`firstDate` และ `lastDate` เป็น inclusive bounds ปุ่มเปลี่ยนเดือนจะถูก disable ที่ขอบเขต ค่า selection ที่ส่งมาเองและอยู่นอกช่วงจะ throw `ArgumentError` ส่วนเดือนเริ่มต้นที่ระบบเลือกให้จะถูก clamp เข้ามาที่ขอบเขตโดยอัตโนมัติ

## Picker variants

### Single date

```dart
final date = await showThaiDatePicker(
  context,
  initialDate: DateTime.now(),
  era: tbd.Era.be,
  locale: 'th_TH',
);
```

### Date and time

```dart
final dateTime = await showThaiDateTimePicker(
  context,
  initialDateTime: DateTime.now(),
  formatString: 'dd/MM/yyyy HH:mm',
  era: tbd.Era.be,
  locale: 'th_TH',
);
```

### Range และ multi-date

```dart
final range = await showThaiDateRangePicker(
  context,
  initialStart: DateTime(2025, 8, 10),
  initialEnd: DateTime(2025, 8, 15),
  era: tbd.Era.be,
  locale: 'th_TH',
);

final dates = await showThaiMultiDatePicker(
  context,
  initialDates: {DateTime(2025, 8, 10)},
  era: tbd.Era.be,
  locale: 'th_TH',
);
```

### Formatted และ fullscreen

```dart
final output = await showThaiDatePickerFormatted(
  context,
  formatString: 'yyyy-MM-dd',
  era: tbd.Era.ce,
  locale: 'en_US',
);

final date = await showThaiDatePickerFullscreen(
  context,
  initialDate: DateTime.now(),
  era: tbd.Era.be,
  locale: 'th_TH',
);
```

formatted wrappers รองรับ `shape`, `titlePadding`, `contentPadding`, `actionsPadding` และ `insetPadding` เช่นเดียวกับ dialog หลัก

## Accessibility และ responsive layout

- day cells เปิดใช้ keyboard focus และ screen-reader semantics
- semantics ระบุวันที่เต็ม สถานะ selected และ disabled
- ปุ่มเปลี่ยนเดือนมี tooltip และปิดใช้งานเมื่อชน bounds
- dialog scroll ได้บนจอเล็กและเมื่อ text scaling สูง

ตัวอย่างเต็มอยู่ที่ [`example/lib/main.dart`](example/lib/main.dart)
