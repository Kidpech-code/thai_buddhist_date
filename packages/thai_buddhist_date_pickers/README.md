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
  thai_buddhist_date_pickers: ^0.1.5
  thai_buddhist_date: ^0.2.5
```

## Usage

```dart
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

final picked = await showThaiDatePicker(context, era: tbd.Era.be, locale: 'th_TH');
```

Initialize Thai locale once if you want localized month/weekday names:

```dart
await tbd.ThaiDateService().initializeLocale('th_TH');
```

## Picker variants

### Range picker

```dart
final range = await showThaiDateRangePicker(
  context,
  era: tbd.Era.be,
  locale: 'th_TH',
);
// range?.start, range?.end
```

### Multi-date picker

```dart
final days = await showThaiMultiDatePicker(
  context,
  era: tbd.Era.be,
  locale: 'th_TH',
);
// days is Set<DateTime>
```

### Fullscreen picker

```dart
final d = await showThaiDatePickerFullscreen(
  context,
  initialDate: DateTime.now(),
  era: tbd.Era.be,
  locale: 'th_TH',
);
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
  await tbd.ThaiDateService().initializeLocale('th_TH');
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () async {
                    final d = await showThaiDatePicker(
                      ctx,
                      initialDate: DateTime.now(),
                      era: tbd.Era.be,
                      locale: 'th_TH',
                    );
                    final label = d == null ? '-' : tbd.format(d, pattern: 'dmy', era: tbd.Era.be);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Picked date (พ.ศ.): $label')),
                    );
                  },
                  child: const Text('Pick a date (พ.ศ.)'),
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () async {
                    final dt = await showThaiDateTimePicker(
                      ctx,
                      initialDateTime: DateTime.now(),
                      era: tbd.Era.ce,
                      locale: 'th_TH',
                      formatString: 'dd/MM/yyyy HH:mm',
                    );
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Picked date-time (ค.ศ.): ${dt ?? '-'}')),
                    );
                  },
                  child: const Text('Pick date-time (ค.ศ.)'),
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () async {
                    final range = await showThaiDateRangePicker(
                      ctx,
                      era: tbd.Era.be,
                      locale: 'th_TH',
                    );
                    final text = range == null
                        ? '-'
                        : '${tbd.format(range.start, pattern: 'dmy')} → ${tbd.format(range.end, pattern: 'dmy')}';
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Picked range: $text')),
                    );
                  },
                  child: const Text('Pick range (พ.ศ.)'),
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () async {
                    final multiple = await showThaiMultiDatePicker(
                      ctx,
                      era: tbd.Era.be,
                      locale: 'th_TH',
                    );
                    final list = (multiple ?? const <DateTime>{})
                        .map((d) => tbd.format(d, pattern: 'dd/MM/yyyy'))
                        .join(', ');
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Picked multiple: ${list.isEmpty ? '-' : list}')),
                    );
                  },
                  child: const Text('Pick multiple (พ.ศ.)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```
