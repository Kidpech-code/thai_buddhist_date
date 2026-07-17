// ignore_for_file: avoid_print

import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  final service = ThaiDateService();
  await service.initializeLocale('th_TH');

  final date = DateTime(2025, 8, 22);
  print(format(date, pattern: 'dd/MM/yyyy')); // 22/08/2568
  print(format(date, pattern: 'd MMMM yyyy')); // 22 สิงหาคม 2568
  print(format(date, pattern: 'yyyy-MM-dd', era: Era.ce)); // 2025-08-22

  final parsed = parse('2568-08-22');
  print(parsed); // 2025-08-22 00:00:00.000

  final converted = await service.convert(
    '22 août 2568',
    fromPattern: 'd MMMM yyyy',
    toPattern: 'yyyy-MM-dd',
    inputEra: Era.be,
    toEra: Era.ce,
    locale: 'fr',
  );
  print(converted); // 2025-08-22
}
