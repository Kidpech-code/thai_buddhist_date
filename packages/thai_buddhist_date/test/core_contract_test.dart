import 'dart:io';

import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  setUp(() {
    ThaiDateService.resetInstance();
  });

  group('ThaiDate validation', () {
    test('safe rejects impossible calendar dates', () {
      expect(
        () => ThaiDate.safe(year: 2568, month: 2, day: 30),
        throwsArgumentError,
      );
      expect(
        ThaiDate.safe(year: 2567, month: 2, day: 29).isValid,
        isTrue,
      );
      expect(
        () => ThaiDate.safe(year: 2568, month: 2, day: 29),
        throwsArgumentError,
      );
    });

    test('isValid detects normalization from an unchecked const value', () {
      const invalid = ThaiDate(year: 2568, month: 2, day: 30);
      expect(invalid.isValid, isFalse);
    });
  });

  group('parser regression coverage', () {
    setUp(() async => ThaiDateService().initializeLocale());

    test('accepts Buddhist leap days in automatic and explicit modes', () {
      final service = ThaiDateService();
      for (final entry in {
        'slash': '29/02/2567',
        'iso': '2567-02-29',
        'dmy': '29 กุมภาพันธ์ 2567',
        "'2567' dd/MM/yyyy HH:mm:ss": '2567 29/02/2567 12:34:56',
      }.entries) {
        expect(
            service.parse(entry.value, pattern: entry.key)?.toDateTime(),
            entry.key.contains('HH')
                ? DateTime(2024, 2, 29, 12, 34, 56)
                : DateTime(2024, 2, 29));
        service.clearCache();
        expect(
            service
                .parseWithEra(entry.value, pattern: entry.key, era: Era.be)
                ?.toDateTime(),
            entry.key.contains('HH')
                ? DateTime(2024, 2, 29, 12, 34, 56)
                : DateTime(2024, 2, 29));
      }
    });

    test('rejects invalid Buddhist dates and trailing input', () {
      final service = ThaiDateService();
      for (final input in [
        '29/02/2568',
        '29/02/2643',
        '30/02/2567',
        '31/04/2567',
        '29/02/2567x'
      ]) {
        expect(service.parse(input, pattern: 'slash'), isNull, reason: input);
        expect(
            service.parseWithEra(input, pattern: 'slash', era: Era.be), isNull,
            reason: input);
      }
      expect(service.parse('29/02/2543', pattern: 'slash')?.toDateTime(),
          DateTime(2000, 2, 29));
      expect(service.parse('29/02/2567')?.toDateTime(), DateTime(2024, 2, 29));
    });

    test('Buddhist February follows a complete Gregorian leap-year cycle', () {
      final service = ThaiDateService();
      for (var year = 2000; year < 2400; year++) {
        final input = '29/02/${year + 543}';
        final expected =
            DateTime(year, 2, 29).month == 2 ? DateTime(year, 2, 29) : null;
        expect(service.parse(input, pattern: 'slash')?.toDateTime(), expected,
            reason: input);
        expect(
            service
                .parseWithEra(input, pattern: 'slash', era: Era.be)
                ?.toDateTime(),
            expected,
            reason: input);
      }
    });

    test('preserves native digits and two-digit year interpretation', () async {
      final service = ThaiDateService();
      await service.initializeLocale('ar');
      final input =
          '${DateFormat('dd/MM', 'ar').format(DateTime(2024, 2, 29))}/${DateFormat('yyyy', 'ar').format(DateTime(2567))}';
      expect(
          service
              .parseWithEra(input,
                  pattern: 'dd/MM/yyyy', era: Era.be, locale: 'ar')
              ?.toDateTime(),
          DateTime(2024, 2, 29));
      final shortYear = DateFormat('dd/MM/yy', 'en_US').parse('28/02/67').year;
      expect(
          service
              .parseWithEra('28/02/67',
                  pattern: 'dd/MM/yy', era: Era.be, locale: 'en_US')
              ?.toDateTime(),
          DateTime(shortYear - 543, 2, 28));
      expect(
          service
              .parseWithEra('29/02/0543', pattern: 'slash', era: Era.be)
              ?.toDateTime(),
          DateTime(0, 2, 29));
    });

    for (final explicitFirst in [false, true]) {
      test('parse modes do not share cache (explicit first: $explicitFirst)',
          () {
        final service = ThaiDateService();
        ThaiDate? automatic() =>
            service.parse('2568-08-25', pattern: 'iso', era: Era.ce);
        ThaiDate? explicit() =>
            service.parseWithEra('2568-08-25', pattern: 'iso', era: Era.ce);
        if (explicitFirst) {
          expect(explicit()?.year, 2568);
          expect(automatic()?.year, 2025);
        } else {
          expect(automatic()?.year, 2025);
          expect(explicit()?.year, 2568);
        }
        expect(automatic()?.year, 2025);
        expect(explicit()?.year, 2568);
      });
    }
  });

  test('double era conversion matches integer conversion', () {
    expect(2568.0.toCE, 2025);
    expect(2025.0.toBE, 2568);
  });

  test('published version matches pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match =
        RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(version, match!.group(1));
  });

  test('public entry point exposes repository interfaces for DI', () async {
    final service = ThaiDateService.create(
      formatterRepository: _FakeFormatterRepository(),
      parserRepository: _FakeParserRepository(),
    );

    final output = await service.format(
      ThaiDate.fromDateTime(DateTime(2025, 8, 25)),
      pattern: 'iso',
    );
    expect(output, 'fake-format');
    expect(service.parse('2568-08-25', pattern: 'iso'), isNotNull);
  });

  group('formatting contract', () {
    test('shortDate is a supported alias instead of an intl token accident',
        () async {
      final output = await ThaiDateService().format(
        ThaiDate.fromDateTime(DateTime(2025, 8, 25)),
        pattern: 'shortDate',
      );
      expect(output, '25/08/2568');
    });

    test('accepts short intl locale identifiers', () async {
      final output = await ThaiDateService().format(
        ThaiDate.fromDateTime(DateTime(2025, 8, 25)),
        pattern: 'MMMM yyyy',
        locale: 'fr',
      );
      expect(output, contains('août'));
      expect(output, contains('2568'));
    });

    test('falls back to configured locale when locale is unavailable',
        () async {
      final service = ThaiDateService()..setLocale('fr');
      final output = await service.format(
        ThaiDate.fromDateTime(DateTime(2025, 8, 25)),
        pattern: 'MMMM yyyy',
        locale: 'not_a_real_locale',
      );
      expect(output, contains('août'));
      expect(output, contains('2568'));

      final parsed = service.parseWithEra(
        '25 août 2568',
        pattern: 'd MMMM yyyy',
        era: Era.be,
        locale: 'not_a_real_locale',
      );
      expect(parsed?.toDateTime(), DateTime(2025, 8, 25));
    });

    test('invalid-locale fallback follows a changed service locale', () async {
      final service = ThaiDateService.create()..setLocale('en_US');
      final date = ThaiDate.fromDateTime(DateTime(2025, 8, 25));

      final english = await service.format(
        date,
        pattern: 'MMMM yyyy',
        locale: 'not_a_real_locale',
      );
      expect(english, contains('August'));

      service.setLocale('th_TH');
      final thai = await service.format(
        date,
        pattern: 'MMMM yyyy',
        locale: 'not_a_real_locale',
      );
      expect(thai, contains('สิงหาคม'));
      expect(thai, isNot(english));
    });
  });

  test('explicit input era overrides automatic year heuristics', () {
    final service = ThaiDateService.create();

    final buddhist = service.parseWithEra(
      '25/08/2025',
      pattern: 'dd/MM/yyyy',
      era: Era.be,
      locale: 'en_US',
    );
    expect(buddhist?.year, 2025);
    expect(buddhist?.era, Era.be);
    expect(buddhist?.toDateTime(), DateTime(1482, 8, 25));

    final common = service.parseWithEra(
      '25/08/2568',
      pattern: 'dd/MM/yyyy',
      era: Era.ce,
      locale: 'en_US',
    );
    expect(common?.year, 2568);
    expect(common?.era, Era.ce);
    expect(common?.toDateTime(), DateTime(2568, 8, 25));
  });

  test('service converts between input and output patterns', () async {
    final service = ThaiDateService();
    final output = await service.convert(
      '25/08/2568',
      fromPattern: 'dd/MM/yyyy',
      toPattern: 'yyyy-MM-dd',
      inputEra: Era.be,
      toEra: Era.ce,
    );
    expect(output, '2025-08-25');

    final explicitBuddhist = await service.convert(
      '25/08/2025',
      fromPattern: 'dd/MM/yyyy',
      toPattern: 'yyyy-MM-dd',
      inputEra: Era.be,
      toEra: Era.ce,
    );
    expect(explicitBuddhist, '1482-08-25');

    final explicitCommon = await service.convert(
      '25/08/2568',
      fromPattern: 'dd/MM/yyyy',
      toPattern: 'yyyy-MM-dd',
      inputEra: Era.ce,
      toEra: Era.be,
    );
    expect(explicitCommon, '3111-08-25');
  });
}

class _FakeFormatterRepository implements IDateFormatterRepository {
  @override
  Future<String> format(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  ) async =>
      'fake-format';

  @override
  String formatSync(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  ) =>
      'fake-format';

  @override
  Future<void> initializeLocale(String locale) async {}

  @override
  bool isLocaleInitialized(String locale) => true;
}

class _FakeParserRepository implements IDateParserRepository {
  @override
  bool isValid(String input, ThaiDatePattern pattern, ThaiDateConfig config) =>
      true;

  @override
  ThaiDate? parse(
    String input,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  ) =>
      const ThaiDate(year: 2568, month: 8, day: 25);

  @override
  ThaiDate? parseWithEra(
    String input,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  ) =>
      const ThaiDate(year: 2568, month: 8, day: 25);
}
