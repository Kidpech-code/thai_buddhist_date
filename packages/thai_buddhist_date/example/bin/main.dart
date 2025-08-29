// ignore_for_file: avoid_print

import 'package:thai_buddhist_date/thai_buddhist_date.dart';

Future<void> main() async {
  final dt = parse('2568-08-22');
  print(format(dt, format: 'yyyy-MM-dd')); // BE default -> 2568-08-22
  print(format(dt, era: Era.ce, format: 'yyyy-MM-dd')); // CE -> 2025-08-22

  final fullBE = format(dt, format: 'fullText', era: Era.be);
  final fullCE = format(dt, format: 'fullText', era: Era.ce);
  print(fullBE);
  print(fullCE);
}
