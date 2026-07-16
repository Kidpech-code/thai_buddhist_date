import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';

void main() {
  testWidgets('renders a Buddhist Era month and enforces date bounds', (
    tester,
  ) async {
    DateTime? selectedDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            child: BuddhistGregorianCalendar(
              initialMonth: DateTime(2025, 8),
              era: tbd.Era.be,
              locale: 'en_US',
              showWeekdayHeaders: false,
              firstDate: DateTime(2025, 8, 10),
              lastDate: DateTime(2025, 8, 20),
              onDateSelected: (date) => selectedDate = date,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('2568'), findsOneWidget);

    await tester.tap(find.text('15'));
    expect(selectedDate, DateTime(2025, 8, 15));

    final disabledDay = tester.widget<InkWell>(
      find.ancestor(of: find.text('9'), matching: find.byType(InkWell)),
    );
    expect(disabledDay.onTap, isNull);
  });
}
