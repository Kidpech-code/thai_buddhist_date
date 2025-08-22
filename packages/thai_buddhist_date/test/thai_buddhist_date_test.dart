import 'package:test/test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  test('parse BE year string', () {
    final dt = parse('2568-08-22');
    expect(dt.year, equals(2025));
    expect(dt.month, equals(8));
    expect(dt.day, equals(22));
  });

  test('parse CE year string', () {
    final dt = parse('2025-08-22');
    expect(dt.year, equals(2025));
    expect(dt.month, equals(8));
    expect(dt.day, equals(22));
  });

  test('format returns BE year', () {
    final dt = DateTime(2025, 8, 22);
    final out = format(dt);
    expect(out.startsWith('2568'), isTrue);
  });
}
