# thai_buddhist_date

A small Dart package to parse and format Thai Buddhist (พ.ศ.) dates.

Features:

- format(DateTime) -> outputs year in พ.ศ. (adds +543)
- parse(String) -> accepts both ค.ศ. (e.g. 2025-08-22) and พ.ศ. (e.g. 2568-08-22)

Usage:

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  final dt = parse('2568-08-22'); // detects BE and returns 2025-08-22 in DateTime
  print(format(dt)); // prints '2568-08-22'
}
```

ตัวอย่าง (ภาษาไทย) — แนะนำให้เรียก `ensureInitialized()` ใน environment ที่ต้องการ locale-aware formatting:

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  // โหลดข้อมูล locale สำหรับการฟอร์แมตภาษาไทย (ต้องรอให้เสร็จ)
  await ThaiCalendar.ensureInitialized();

  final dt = DateTime(2025, 8, 22);
  // ฟอร์แมตเป็นข้อความที่มีปี พ.ศ.
  print(ThaiCalendar.format(dt, pattern: 'fullText')); // วันศุกร์ที่ 22 สิงหาคม 2568

  // แปลงจากสตริงที่อาจเป็น พ.ศ. หรือ ค.ศ.
  final parsed = ThaiCalendar.parse('2568-08-22');
  if (parsed != null) {
    print(parsed.toIso8601String()); // 2025-08-22T00:00:00.000
  }
}
```

Notes:

- The parser looks for a 4-digit year and treats years >= 2400 as BE (พ.ศ.).
- This is conservative and works for usual Thai BE dates.

รองรับแพลตฟอร์ม

- Dart/Flutter SDK (see environment in `pubspec.yaml`)
- Platforms: Android, iOS, Linux, macOS, Web, Windows

การเผยแพร่ (publish)

- ตรวจสอบ `pubspec.yaml` ให้ครบ (homepage, repository, version)
- ลบ `publish_to: none` หากต้องการปล่อยขึ้น pub.dev
- เพิ่ม LICENSE และ CHANGELOG (มีทั้งสองไฟล์ใน repo)

ตัวอย่าง helpers

```dart
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  // async: โหลด locale แล้วฟอร์แมต
  final out = await ThaiCalendar.formatInitialized(DateTime(2025,8,22));
  print(out); // วันศุกร์ที่ 22 สิงหาคม 2568

  // sync: ไม่ต้องใช้ locale (ตัวอย่างสำหรับ numeric patterns)
  final sync = ThaiCalendar.formatSync(DateTime(2025,8,22), pattern: 'yyyy-MM-dd');
  print(sync); // 2568-08-22
}
```

ข้อควรระวังสำหรับ Flutter

- ในแอป Flutter ให้เรียก `await ThaiCalendar.ensureInitialized()` ใน `main()` ก่อน `runApp(...)` เพื่อให้ DateFormat ที่ใช้ locale ภาษาไทยทำงานได้ถูกต้อง.

ตัวอย่างการใช้งานใน Flutter (เรียกใน main ก่อน runApp):

```dart
import 'package:flutter/material.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThaiCalendar.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime(2025, 8, 22);
    final label = ThaiCalendar.format(now, pattern: 'fullText');
    return MaterialApp(home: Scaffold(body: Center(child: Text(label))));
  }
}
```
