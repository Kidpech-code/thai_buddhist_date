import 'package:test/test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';
import 'package:intl/intl.dart';

void main() {
  test('token-aware yyyy -> BE', () {
    final dt = DateTime(2025, 8, 22);
    final out = ThaiCalendar.formatSync(dt, pattern: 'yyyy-MM-dd');
    expect(out, equals('2568-08-22'));
  });

  test('token-aware yy -> BE truncated', () {
    final dt = DateTime(2025, 8, 22);
    final out = ThaiCalendar.formatSync(dt, pattern: 'yy');
    expect(out, equals('68'));
  });

  test('parse Thai month full', () async {
    await ThaiCalendar.ensureInitialized();
    final parsed = ThaiCalendar.parse('22 สิงหาคม 2568');
    expect(parsed?.year, equals(2025));
    expect(parsed?.month, equals(8));
    expect(parsed?.day, equals(22));
  });

  test('parse Thai month short', () async {
    await ThaiCalendar.ensureInitialized();
    final parsed = ThaiCalendar.parse('22 ส.ค. 2568');
    expect(parsed?.year, equals(2025));
    expect(parsed?.month, equals(8));
    expect(parsed?.day, equals(22));
  });

  test('formatInitialized returns BE', () async {
    final dt = DateTime(2025, 8, 22);
    final out = await ThaiCalendar.formatInitialized(dt, pattern: 'fullText');
    expect(out.contains('2568'), isTrue);
  });

  test('DateFormat skeleton yMMMEd via formatWith', () async {
    await ThaiCalendar.ensureInitialized();
    final dt = DateTime(2025, 8, 22);
    final df = DateFormat.yMMMEd('th');
    final out = ThaiCalendar.formatWith(df, dt);
    // should contain BE year
    expect(out.contains('2568'), isTrue);
  });

  test('DateFormat skeleton yMMMMEEEEd parseWith', () async {
    await ThaiCalendar.ensureInitialized();
    final df = DateFormat.yMMMMEEEEd('th');
    final sample = df.format(DateTime(2025, 8, 22)).replaceFirst('2025', '2568');
    final parsed = ThaiCalendar.parseWith(df, sample);
    expect(parsed?.year, equals(2025));
    expect(parsed?.month, equals(8));
    expect(parsed?.day, equals(22));
  });
}
