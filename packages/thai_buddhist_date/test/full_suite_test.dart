import 'package:test/test.dart';
import 'package:thai_buddhist_date/src/domain/entities/thai_date.dart'
    show ThaiDate;
import 'package:thai_buddhist_date/src/domain/value_objects/era.dart' show Era;
import 'package:thai_buddhist_date/thai_buddhist_date.dart'
    show
        ThaiDateService,
        parse,
        format,
        convertCEToBE,
        convertBEToCE,
        formatDateTime,
        parseThaiDate;

void main() {
  group('Era', () {
    test('BE<->CE', () {
      expect(Era.be.toCE(2567), 2024);
      expect(Era.be.fromCE(2024), 2567);
    });
  });

  group('ThaiDate', () {
    test('from/to DateTime', () {
      final t = ThaiDate.fromDateTime(DateTime(2024, 8, 22));
      expect(t.year, 2567);
      expect(t.toDateTime().year, 2024);
    });
  });

  group('Service', () {
    test('formatSync + parse', () {
      final svc = ThaiDateService();
      final s = svc.formatSync(ThaiDate(year: 2567, month: 8, day: 22),
          pattern: 'iso');
      expect(s.contains('2567'), isTrue);

      final p = svc.parse('2567-08-22', pattern: 'yyyy-MM-dd');
      expect(p, isNotNull);
      expect(p!.year, 2567);
    });
  });

  group('Compat API', () {
    test('parse/format helpers', () async {
      final p = parse('2567-08-22');
      expect(p.year, 2024);
      final out = format(DateTime(2024, 8, 22));
      expect(out.isNotEmpty, isTrue);
      expect(convertCEToBE(2024), 2567);
      expect(convertBEToCE(2567), 2024);
      expect(await formatDateTime(DateTime(2024, 8, 22)), isNotEmpty);
      expect(parseThaiDate('2567-08-22')?.year, 2567);
    });
  });

  test('Performance smoke', () {
    final svc = ThaiDateService();
    final t = ThaiDate(year: 2567, month: 8, day: 22);
    final sw = Stopwatch()..start();
    for (var i = 0; i < 50; i++) {
      svc.formatSync(t, pattern: 'iso');
    }
    sw.stop();
    expect(sw.elapsedMilliseconds, lessThan(1000));
  });
}
