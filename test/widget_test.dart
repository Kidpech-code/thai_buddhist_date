import 'package:flutter_test/flutter_test.dart';
import 'package:thai_buddhist_date_app/main.dart';

void main() {
  testWidgets('App boots and shows calendar page title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Calendar (พ.ศ./ค.ศ.)'), findsOneWidget);
  });
}
