# thai_buddhist_date_pickers

Flutter calendar and pickers for Thai Buddhist (พ.ศ.) and Gregorian (ค.ศ.), distributed separately from the core `thai_buddhist_date` package.

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

See examples in the main repository.
