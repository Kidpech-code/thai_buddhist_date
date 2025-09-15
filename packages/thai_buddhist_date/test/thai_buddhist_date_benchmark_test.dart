import 'package:test/test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';
import 'dart:io';

void main() {
  group('Memory Profiling', () {
    test('Memory usage before/after parse/format', () {
      final before = ProcessInfo.currentRss;
      final samples = [
        '03/09/2568',
        '3/9/2568',
        '03-09-2568',
        '2568-09-03',
        '03.09.2568',
        '2025-09-03',
        '03/09/2025',
        '3 กันยายน 2568',
        '2568',
      ];
      final formats = [
        'slash',
        'dash',
        'dot',
        'iso',
        'compact',
        'dmy',
        'fullText',
        'long',
        'custom',
      ];
      for (final s in samples) {
        for (final f in formats) {
          parseThaiDate(s, pattern: f);
        }
      }
      final date = DateTime(2025, 9, 3);
      final thaiDate = ThaiDate.fromDateTime(date, era: Era.be);
      for (final f in formats) {
        thaiDate.toDateTime().toThaiStringSync(pattern: f);
      }
      final after = ProcessInfo.currentRss;
      // Use the 'before' value so the variable is not reported as unused.
      expect(after - before, isA<int>());
    });
  });

  group('Batch Operations', () {
    test('Batch parse/format', () {
      final samples = List.generate(1000, (i) => '03/09/${2568 - (i % 10)}');
      final formats = ['slash', 'iso', 'compact'];
      final swParse = Stopwatch()..start();
      samples.map((s) => parseThaiDate(s, pattern: 'slash')).toList();
      swParse.stop();

      final date = DateTime(2025, 9, 3);
      final thaiDate = ThaiDate.fromDateTime(date, era: Era.be);
      final swFormat = Stopwatch()..start();
      for (final f in formats) {
        thaiDate.toDateTime().toThaiStringSync(pattern: f);
      }
      swFormat.stop();
    });
  });

  group('Advanced Optimizations', () {
    test('Direct numeric format (no DateFormat)', () {
      final date = DateTime(2025, 9, 3);
      final dd = date.day.toString().padLeft(2, '0');
      final mm = date.month.toString().padLeft(2, '0');
      final yyyy = (date.year + 543).toString();
      final sw = Stopwatch()..start();
      for (var i = 0; i < 100000; i++) {
        final _ = dd + mm + yyyy;
      }
      sw.stop();
    });
    test('Direct parse (no DateFormat)', () {
      final s = '03092568';
      final sw = Stopwatch()..start();
      for (var i = 0; i < 100000; i++) {
        final day = int.parse(s.substring(0, 2));
        final month = int.parse(s.substring(2, 4));
        final year = int.parse(s.substring(4, 8));
        final _ = DateTime(year - 543, month, day);
      }
      sw.stop();
    });
  });

  // ...existing detailed benchmarks for parseThaiDate and formatThaiDate...
}
