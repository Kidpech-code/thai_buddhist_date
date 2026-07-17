import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() {
  setUpAll(() => ThaiDateService().initializeLocale('th_TH'));

  test('singleton and isolated service factories keep their contracts', () {
    expect(identical(ThaiDateService(), ThaiDateService()), isTrue);
    expect(
      identical(ThaiDateService.create(), ThaiDateService.create()),
      isFalse,
    );
  });

  test('ThaiDate converts to and from DateTime without shifting the day', () {
    final thaiDate = ThaiDate.fromDateTime(DateTime(2024, 8, 22));
    expect(thaiDate.year, 2567);
    expect(thaiDate.toDateTime(), DateTime(2024, 8, 22));
  });

  test('token-aware formatting preserves two-digit year behavior', () {
    expect(
      ThaiCalendar.formatSync(DateTime(2025, 8, 22), pattern: 'yy'),
      '68',
    );
  });

  test('Thai month names parse in long and abbreviated forms', () {
    final long = ThaiCalendar.parse('22 สิงหาคม 2568');
    final short = ThaiCalendar.parse(
      '22 ส.ค. 2568',
      customPattern: 'd MMM yyyy',
    );
    expect(long, DateTime(2025, 8, 22));
    expect(short, DateTime(2025, 8, 22));
  });

  test('DateFormat compatibility helpers preserve Buddhist years', () {
    final date = DateTime(2025, 8, 22);
    final formatter = DateFormat.yMMMEd('th');
    final output = ThaiCalendar.formatWith(formatter, date);
    expect(output, contains('2568'));

    final parser = DateFormat.yMMMMEEEEd('th');
    final sample = parser.format(date).replaceFirst('2025', '2568');
    expect(ThaiCalendar.parseWith(parser, sample), date);
  });

  test('top-level compatibility helpers remain available', () async {
    expect(parse('2567-08-22'), DateTime(2024, 8, 22));
    expect(format(DateTime(2024, 8, 22)), isNotEmpty);
    expect(convertCEToBE(2024), 2567);
    expect(convertBEToCE(2567), 2024);
    expect(await formatDateTime(DateTime(2024, 8, 22)), isNotEmpty);
    expect(parseThaiDate('2567-08-22')?.year, 2567);
  });
}
