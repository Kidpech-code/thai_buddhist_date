import 'package:test/test.dart';
import 'package:thai_buddhist_date/src/domain/entities/thai_date.dart'
    show ThaiDate;
import 'package:thai_buddhist_date/src/domain/value_objects/era.dart' show Era;
import 'package:thai_buddhist_date/thai_buddhist_date.dart'
    show ThaiDateService;

void main() {
  group('Performance (controlled iterations)', () {
    final service = ThaiDateService();

    test('formatSync 300 iters under 2000ms', () {
      final date = ThaiDate(year: Era.be.fromCE(2025), month: 8, day: 25);
      // Warmup
      for (var i = 0; i < 50; i++) {
        service.formatSync(date, pattern: 'iso');
      }
      final sw = Stopwatch()..start();
      for (var i = 0; i < 300; i++) {
        service.formatSync(date, pattern: 'iso');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });

    test('parse 300 iters under 2000ms', () {
      // Warmup
      for (var i = 0; i < 50; i++) {
        service.parse('2568-08-25', pattern: 'yyyy-MM-dd');
      }
      final sw = Stopwatch()..start();
      for (var i = 0; i < 300; i++) {
        service.parse('2568-08-25', pattern: 'yyyy-MM-dd');
      }
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });
  });
}
