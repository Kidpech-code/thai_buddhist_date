import 'dart:io';

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
