import 'package:test/test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  test('ThaiDateService singleton returns same instance', () {
    expect(identical(ThaiDateService(), ThaiDateService()), isTrue);
  });

  test('ThaiDateService.create returns isolated instance', () {
    final a = ThaiDateService.create();
    final b = ThaiDateService.create();
    expect(identical(a, b), isFalse);
  });

  test('formatSync returns BE year for default config', () {
    final svc = ThaiDateService();
    final result =
        svc.formatSync(ThaiDate(year: 2568, month: 5, day: 1), pattern: 'iso');
    expect(result, contains('2568'));
  });

  test('Era conversion round-trip', () {
    expect(Era.be.fromCE(2025), 2568);
    expect(Era.be.toCE(2568), 2025);
  });

  test('int extension toCE converts BE to CE', () {
    expect(2568.toCE, 2025);
  });

  test('int extension toBE converts CE to BE', () {
    expect(2025.toBE, 2568);
  });
}
