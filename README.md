# thai_buddhist_date repository

Monorepo สำหรับไลบรารีวันที่ไทยและ Flutter demo:

- [`thai_buddhist_date`](packages/thai_buddhist_date) — pure Dart สำหรับ parse, format และแปลงปี พ.ศ./ค.ศ.
- [`thai_buddhist_date_pickers`](packages/thai_buddhist_date_pickers) — calendar และ picker UI สำหรับ Flutter
- แอปที่ root — integration demo ของทั้งสอง package

ตัว demo ใช้ implementation จาก picker package โดยตรง ไม่มีสำเนา widget แยกในแอป

## Run demo

ต้องใช้ Flutter 3.19 ขึ้นไป โดย release นี้ตรวจจริงด้วย Flutter 3.19.6 และ
Flutter 3.44.2

```bash
flutter pub get
flutter run
```

## Quality checks

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

## Project policies

- [Engineering policy](docs/ENGINEERING_POLICY.md)
- [Contributing](CONTRIBUTING.md)
- [Security](SECURITY.md)
- [Releasing](RELEASING.md)
