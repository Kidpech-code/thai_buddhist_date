// ignore_for_file: avoid_print

import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  final dt = parse('2568-08-22');
  print(format(dt)); // BE default -> 2568-08-22
  print(format(dt, era: Era.ce)); // CE -> 2025-08-22

  await ThaiCalendar.ensureInitialized();
  final fullBE = ThaiCalendar.format(dt, pattern: 'fullText', era: Era.be);
  final fullCE = ThaiCalendar.format(dt, pattern: 'fullText', era: Era.ce);
  print(fullBE);
  print(fullCE);
}
