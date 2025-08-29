// Comprehensive tests for the Clean Architecture Thai Buddhist Date library

import 'package:test/test.dart' as t;
import 'package:thai_buddhist_date/src/domain/entities/thai_date.dart'
    show ThaiDate;
import 'package:thai_buddhist_date/src/domain/value_objects/era.dart' show Era;
import 'package:thai_buddhist_date/src/domain/value_objects/locale_config.dart'
    show ThaiLanguage;
import 'package:thai_buddhist_date/thai_buddhist_date.dart'
    show
        ThaiDateService,
        DateTimeThaiExtensions,
        IntThaiExtensions,
        parse,
        format,
        convertCEToBE,
        convertBEToCE,
        formatDateTime,
        parseThaiDate;

void main() {
  t.group('Clean Architecture Thai Date Tests', () {
    late ThaiDateService service;

    t.setUp(() {
      service = ThaiDateService();
    });

    t.group('Era Conversion Tests', () {
      t.test('BE to CE conversion', () {
        t.expect(Era.be.toCE(2567), t.equals(2024));
        t.expect(Era.be.toCE(2500), t.equals(1957));
      });

      t.test('CE to BE conversion', () {
        t.expect(Era.be.fromCE(2024), t.equals(2567));
        t.expect(Era.be.fromCE(1957), t.equals(2500));
      });

      t.test('Era detection', () {
        t.expect(Era.be.isLikelyYear(2567), t.isTrue);
        t.expect(Era.ce.isLikelyYear(2024), t.isTrue);
        t.expect(Era.be.isLikelyYear(2024), t.isFalse);
        t.expect(Era.ce.isLikelyYear(2567), t.isFalse);
      });
    });

    t.group('ThaiDate Entity Tests', () {
      t.test('Create ThaiDate', () {
        final date = ThaiDate(year: 2567, month: 8, day: 22);
        t.expect(date.year, t.equals(2567));
        t.expect(date.month, t.equals(8));
        t.expect(date.day, t.equals(22));
        t.expect(date.era, t.equals(Era.be));
      });

      t.test('Create from DateTime', () {
        final dateTime = DateTime(2024, 8, 22);
        final thaiDate = ThaiDate.fromDateTime(dateTime);
        t.expect(thaiDate.year, t.equals(2567)); // BE year
        t.expect(thaiDate.month, t.equals(8));
        t.expect(thaiDate.day, t.equals(22));
      });

      t.test('Convert to DateTime', () {
        final thaiDate = ThaiDate(year: 2567, month: 8, day: 22);
        final dateTime = thaiDate.toDateTime();
        t.expect(dateTime.year, t.equals(2024)); // CE year
        t.expect(dateTime.month, t.equals(8));
        t.expect(dateTime.day, t.equals(22));
      });

      t.test('Add days', () {
        final thaiDate = ThaiDate(year: 2567, month: 8, day: 20);
        final newDate = thaiDate.addDays(2);
        t.expect(newDate.day, t.equals(22));
      });

      t.test('Equality', () {
        final date1 = ThaiDate(year: 2567, month: 8, day: 22);
        final date2 = ThaiDate(year: 2567, month: 8, day: 22);
        final date3 = ThaiDate(year: 2567, month: 8, day: 23);

        t.expect(date1, t.equals(date2));
        t.expect(date1, t.isNot(t.equals(date3)));
      });
    });

    t.group('Service Integration Tests', () {
      t.test('Format synchronous', () {
        final date = ThaiDate(year: 2567, month: 8, day: 22);
        final formatted = service.formatSync(date, pattern: 'iso');
        t.expect(formatted, t.isNotEmpty);
        t.expect(formatted, t.contains('2567'));
      });

      t.test('Parse date string', () {
        final parsed = service.parse('2567-08-22', pattern: 'yyyy-MM-dd');
        t.expect(parsed, t.isNotNull);
        t.expect(parsed!.year, t.equals(2567));
        t.expect(parsed.month, t.equals(8));
        t.expect(parsed.day, t.equals(22));
      });

      t.test('Configuration management', () {
        service.setEra(Era.be);
        service.setLanguage(ThaiLanguage.thai);

        t.expect(service.config.era, t.equals(Era.be));
        t.expect(service.config.language, t.equals(ThaiLanguage.thai));
      });
    });

    t.group('Extension Method Tests', () {
      t.test('DateTime extensions', () {
        final dateTime = DateTime(2024, 8, 22);
        final thaiDate = dateTime.toThaiDate();

        t.expect(thaiDate.year, t.equals(2567));
        t.expect(dateTime.beYear, t.equals(2567));
        t.expect(dateTime.ceYear, t.equals(2024));
      });

      t.test('Int extensions', () {
        t.expect(2024.toBE, t.equals(2567));
        t.expect(2567.toCE, t.equals(2024));
        t.expect(2567.isValidBE, t.isTrue);
        t.expect(2024.isValidCE, t.isTrue);
        t.expect(1000.isValidBE, t.isFalse);
      });
    });

    t.group('Backward Compatibility Tests', () {
      t.test('Legacy parse function', () {
        final parsed1 = parse('2567-08-22'); // BE year
        final parsed2 = parse('2024-08-22'); // CE year

        t.expect(parsed1.year, t.equals(2024)); // Should convert to CE
        t.expect(parsed2.year, t.equals(2024));
        t.expect(parsed1.month, t.equals(8));
        t.expect(parsed2.month, t.equals(8));
      });

      t.test('Legacy format functions', () async {
        final dateTime = DateTime(2024, 8, 22);
        final formatted = format(dateTime, era: Era.be);

        t.expect(formatted, t.isNotEmpty);
      });

      t.test('Convenience functions', () async {
        t.expect(convertCEToBE(2024), t.equals(2567));
        t.expect(convertBEToCE(2567), t.equals(2024));

        final formatted = await formatDateTime(DateTime(2024, 8, 22));
        t.expect(formatted, t.isNotEmpty);

        final parsed = parseThaiDate('2567-08-22');
        t.expect(parsed?.year, t.equals(2567));
      });
    });

    t.group('Error Handling Tests', () {
      t.test('Invalid date parsing', () {
        final parsed = service.parse('invalid-date');
        t.expect(parsed, t.isNull);
      });

      t.test('Invalid date creation', () {
        t.expect(() => ThaiDate(year: 2567, month: 13, day: 22),
            t.throwsA(t.isA<AssertionError>()));
        t.expect(() => ThaiDate(year: 2567, month: 8, day: 32),
            t.throwsA(t.isA<AssertionError>()));
      });
    });

    t.group('Performance Tests', () {
      t.test('Synchronous formatting performance', () {
        final date = ThaiDate(year: 2567, month: 8, day: 22);
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          // Reduced for testing
          service.formatSync(date, pattern: 'iso');
        }

        stopwatch.stop();
        t.expect(
            stopwatch.elapsedMilliseconds, t.lessThan(1000)); // Should be fast
      });

      t.test('Parsing performance', () {
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          // Reduced for testing
          service.parse('2567-08-22', pattern: 'yyyy-MM-dd');
        }

        stopwatch.stop();
        t.expect(
            stopwatch.elapsedMilliseconds, t.lessThan(1000)); // Should be fast
      });
    });
  });
}
