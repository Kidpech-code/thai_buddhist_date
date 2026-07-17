// ignore_for_file: avoid_print

import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  const iterations = 10000;
  final date = DateTime(2025, 8, 22);
  final stopwatch = Stopwatch()..start();

  for (var index = 0; index < iterations; index++) {
    format(date, pattern: 'yyyy-MM-dd');
  }

  stopwatch.stop();
  print('$iterations formats: ${stopwatch.elapsedMicroseconds} microseconds');
}
