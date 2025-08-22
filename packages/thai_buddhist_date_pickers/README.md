# thai_buddhist_date_pickers

[![pub package](https://img.shields.io/pub/v/thai_buddhist_date_pickers.svg)](https://pub.dev/packages/thai_buddhist_date_pickers)

Flutter calendar and pickers for Thai Buddhist (พ.ศ.) and Gregorian (ค.ศ.), distributed separately from the core [`thai_buddhist_date`](https://pub.dev/packages/thai_buddhist_date) package.

- Month calendar header formats with BE/CE.
- Dialog pickers: single date, date-time (with preview), range, multi-date.
- Fullscreen single-date picker.
- Theming knobs for dialog shape/padding.

## Install

```yaml
dependencies:
  thai_buddhist_date_pickers: ^0.1.0
  thai_buddhist_date: ^0.1.4
```

## Usage

```dart
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

final picked = await showThaiDatePicker(context, era: tbd.Era.be, locale: 'th_TH');
```

Initialize Thai locale once if you want localized month/weekday names:

```dart
await tbd.ThaiCalendar.ensureInitialized();
```

## Example

A minimal example app is included under `example/`.

```dart
// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await tbd.ThaiCalendar.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Thai Pickers Example')),
        body: Center(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                final d = await showThaiDatePicker(
                  ctx,
                  initialDate: DateTime.now(),
                  era: tbd.Era.be,
                  locale: 'th_TH',
                );
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Picked: \\${d ?? '-'}')),
                );
              },
              child: const Text('Pick a date (พ.ศ.)'),
            ),
          ),
        ),
      ),
    );
  }
}
```
