import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  final dt = DateTime(2025, 8, 22);
  // Top-level format (no locale init)
  print('top-level format: ' + format(dt));

  ThaiCalendar.ensureInitialized().then((_) {
    print('ThaiCalendar.format fullText: ' + ThaiCalendar.format(dt));
    print('ThaiCalendar.format iso: ' + ThaiCalendar.format(dt, pattern: 'iso'));
  });
}
