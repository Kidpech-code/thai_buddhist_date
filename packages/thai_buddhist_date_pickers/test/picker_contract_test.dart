import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;
import 'package:thai_buddhist_date_pickers/thai_buddhist_date_pickers.dart';

void main() {
  testWidgets('rejects reversed bounds and out-of-range initial values', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (builderContext) {
            context = builderContext;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(
      () => showThaiDatePicker(
        context,
        firstDate: DateTime(2025, 8, 20),
        lastDate: DateTime(2025, 8, 10),
      ),
      throwsArgumentError,
    );

    final firstDate = DateTime(2025, 8, 10);
    final lastDate = DateTime(2025, 8, 20);
    final outside = DateTime(2025, 8, 9);
    expect(
      () => showThaiDateTimePicker(
        context,
        initialDateTime: outside,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
      throwsArgumentError,
    );
    expect(
      () => showThaiDateRangePicker(
        context,
        initialStart: DateTime(2025, 8, 15),
        initialEnd: DateTime(2025, 8, 14),
        firstDate: firstDate,
        lastDate: lastDate,
      ),
      throwsArgumentError,
    );
    expect(
      () => showThaiMultiDatePicker(
        context,
        initialDates: {outside},
        firstDate: firstDate,
        lastDate: lastDate,
      ),
      throwsArgumentError,
    );
    expect(
      () => showThaiDatePickerFullscreen(
        context,
        initialDate: outside,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
      throwsArgumentError,
    );
    await expectLater(
      showThaiDatePickerFormatted(
        context,
        initialDate: outside,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
      throwsArgumentError,
    );
    await expectLater(
      showThaiDateTimePickerFormatted(
        context,
        initialDateTime: outside,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
      throwsArgumentError,
    );
    expect(
      () => showThaiDatePicker(
        context,
        initialDate: DateTime(2025, 8, 9),
        firstDate: DateTime(2025, 8, 10),
        lastDate: DateTime(2025, 8, 20),
      ),
      throwsArgumentError,
    );
  });

  testWidgets('opens within bounds when initialDate is omitted', (
    tester,
  ) async {
    await _pumpLauncher(
      tester,
      onPressed: (context) => showThaiDatePicker(
        context,
        firstDate: DateTime(2200, 1, 10),
        lastDate: DateTime(2200, 1, 20),
        era: tbd.Era.ce,
        locale: 'en_US',
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.textContaining('January 2200'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('updates era and locale when widget properties change', (
    tester,
  ) async {
    Widget calendar(tbd.Era era, String locale, [int month = 8]) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 420,
              child: BuddhistGregorianCalendar(
                initialMonth: DateTime(2025, month),
                era: era,
                locale: locale,
                showWeekdayHeaders: false,
              ),
            ),
          ),
        );

    await tester.pumpWidget(calendar(tbd.Era.be, 'th_TH'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2568'), findsOneWidget);

    await tester.pumpWidget(calendar(tbd.Era.ce, 'en_US'));
    await tester.pumpAndSettle();
    expect(find.textContaining('August 2025'), findsOneWidget);
    expect(find.textContaining('2568'), findsNothing);

    await tester.pumpWidget(calendar(tbd.Era.ce, 'en_US', 9));
    await tester.pumpAndSettle();
    expect(find.textContaining('September 2025'), findsOneWidget);
  });

  testWidgets('exposes meaningful semantics, focus and bounded navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            child: BuddhistGregorianCalendar(
              initialMonth: DateTime(2025, 8),
              selectedDate: DateTime(2025, 8, 15),
              firstDate: DateTime(2025, 8, 10),
              lastDate: DateTime(2025, 8, 20),
              era: tbd.Era.be,
              locale: 'en_US',
              showWeekdayHeaders: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.text('15')).label, '15 August 2568');
    final daySemantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '15 August 2568',
      ),
    );
    expect(daySemantics.properties.button, isTrue);
    expect(daySemantics.properties.selected, isTrue);
    expect(daySemantics.properties.enabled, isTrue);

    final disabledDaySemantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == '9 August 2568',
      ),
    );
    expect(disabledDaySemantics.properties.enabled, isFalse);

    final dayInkWell = tester.widget<InkWell>(
      find.ancestor(of: find.text('15'), matching: find.byType(InkWell)),
    );
    expect(dayInkWell.canRequestFocus, isTrue);

    final navigationButtons = tester.widgetList<IconButton>(
      find.byType(IconButton),
    );
    expect(navigationButtons.first.onPressed, isNull);
    expect(navigationButtons.last.onPressed, isNull);
  });

  testWidgets('single picker returns the selected date', (tester) async {
    DateTime? result;
    await _pumpLauncher(
      tester,
      onPressed: (context) async {
        result = await showThaiDatePicker(
          context,
          initialDate: DateTime(2025, 8, 15),
          locale: 'en_US',
        );
      },
    );

    await tester.tap(find.text('16'));
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();
    expect(result, DateTime(2025, 8, 16));
  });

  testWidgets('cancel returns null without changing the selection', (
    tester,
  ) async {
    var completed = false;
    DateTime? result = DateTime(2000);
    await _pumpLauncher(
      tester,
      onPressed: (context) async {
        result = await showThaiDatePicker(
          context,
          initialDate: DateTime(2025, 8, 15),
          locale: 'en_US',
        );
        completed = true;
      },
    );

    await tester.tap(find.text('ยกเลิก'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(result, isNull);
  });

  testWidgets('date-time, range and multi pickers return initial selections', (
    tester,
  ) async {
    DateTime? dateTimeResult;
    await _pumpLauncher(
      tester,
      onPressed: (context) async {
        dateTimeResult = await showThaiDateTimePicker(
          context,
          initialDateTime: DateTime(2025, 8, 15, 14, 30),
          locale: 'en_US',
        );
      },
    );
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();
    expect(dateTimeResult, DateTime(2025, 8, 15, 14, 30));

    DateTimeRange? rangeResult;
    await _pumpLauncher(
      tester,
      onPressed: (context) async {
        rangeResult = await showThaiDateRangePicker(
          context,
          initialStart: DateTime(2025, 8, 10),
          initialEnd: DateTime(2025, 8, 12),
          locale: 'en_US',
        );
      },
    );
    for (final label in ['10 August 2568', '12 August 2568']) {
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == label,
        ),
      );
      expect(semantics.properties.selected, isTrue);
    }
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();
    expect(rangeResult?.start, DateTime(2025, 8, 10));
    expect(rangeResult?.end, DateTime(2025, 8, 12));

    Set<DateTime>? multiResult;
    await _pumpLauncher(
      tester,
      onPressed: (context) async {
        multiResult = await showThaiMultiDatePicker(
          context,
          initialDates: {DateTime(2025, 8, 10), DateTime(2025, 8, 12)},
          locale: 'en_US',
        );
      },
    );
    for (final label in ['10 August 2568', '12 August 2568']) {
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == label,
        ),
      );
      expect(semantics.properties.selected, isTrue);
    }
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();
    expect(multiResult, {DateTime(2025, 8, 10), DateTime(2025, 8, 12)});
  });

  testWidgets('formatted and fullscreen variants preserve their contracts', (
    tester,
  ) async {
    String? formatted;
    await _pumpLauncher(
      tester,
      onPressed: (context) async {
        formatted = await showThaiDatePickerFormatted(
          context,
          initialDate: DateTime(2025, 8, 15),
          formatString: 'yyyy-MM-dd',
          era: tbd.Era.ce,
          locale: 'en_US',
        );
      },
    );
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();
    expect(formatted, '2025-08-15');

    DateTime? fullscreen;
    await _pumpLauncher(
      tester,
      onPressed: (context) async {
        fullscreen = await showThaiDatePickerFullscreen(
          context,
          initialDate: DateTime(2025, 8, 15),
          locale: 'en_US',
        );
      },
    );
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();
    expect(fullscreen, DateTime(2025, 8, 15));
  });

  testWidgets('formatted date-time wrapper forwards dialog presentation', (
    tester,
  ) async {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(18)),
    );
    const titlePadding = EdgeInsets.all(11);
    const contentPadding = EdgeInsets.all(12);
    const actionsPadding = EdgeInsets.all(13);
    const insetPadding = EdgeInsets.all(14);

    await _pumpLauncher(
      tester,
      onPressed: (context) => showThaiDateTimePickerFormatted(
        context,
        initialDateTime: DateTime(2025, 8, 15, 14, 30),
        locale: 'en_US',
        shape: shape,
        titlePadding: titlePadding,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        insetPadding: insetPadding,
      ),
    );

    final dialog = tester.widget<ThaiDateTimePickerDialog>(
      find.byType(ThaiDateTimePickerDialog),
    );
    expect(dialog.shape, shape);
    expect(dialog.titlePadding, titlePadding);
    expect(dialog.contentPadding, contentPadding);
    expect(dialog.actionsPadding, actionsPadding);
    expect(dialog.insetPadding, insetPadding);

    await tester.tap(find.text('ยกเลิก'));
    await tester.pumpAndSettle();
  });

  testWidgets('dialogs remain usable on a small screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
          ),
          child: child!,
        ),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showThaiDatePicker(
              context,
              initialDate: DateTime(2025, 8, 15),
              locale: 'en_US',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ThaiDatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  });
}

Future<void> _pumpLauncher(
  WidgetTester tester, {
  required Future<void> Function(BuildContext context) onPressed,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => onPressed(context),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
