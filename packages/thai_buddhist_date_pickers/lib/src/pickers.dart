import 'package:flutter/material.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

import 'buddhist_gregorian_calendar.dart';
import 'date_picker_validation.dart';

const _defaultDialogInsetPadding = EdgeInsets.symmetric(
  horizontal: 40,
  vertical: 24,
);

Widget _calendarViewport(Widget calendar, double? height) {
  final constrained = ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 420),
    child: calendar,
  );
  if (height == null) return constrained;
  return SizedBox(
    height: height,
    child: SingleChildScrollView(child: constrained),
  );
}

void _validateRangeOrder(DateTime? start, DateTime? end) {
  if (start != null && end != null && dateOnly(start).isAfter(dateOnly(end))) {
    throw ArgumentError.value(
        end, 'initialEnd', 'must not precede initialStart');
  }
}

// Exported API: showThaiDatePicker, showThaiDateTimePicker, showThaiMultiDatePicker, showThaiDatePickerFullscreen,
// showThaiDatePickerFormatted, showThaiDateTimePickerFormatted

/// A dialog that lets the user pick a single calendar date.
///
/// The header/month/weekday strings are formatted using the
/// thai_buddhist_date package with the provided [era] and [locale].
/// Use [firstDate]/[lastDate] to restrict the selectable range.
class ThaiDatePickerDialog extends StatefulWidget {
  const ThaiDatePickerDialog({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.era = tbd.Era.be,
    this.locale = 'th_TH',
    this.title,
    this.confirmText,
    this.cancelText,
    this.width,
    this.height,
    this.headerBuilder,
    this.dayBuilder,
    this.shape,
    this.titlePadding,
    this.contentPadding,
    this.actionsPadding,
    this.insetPadding,
  });

  /// The initially selected date.
  final DateTime? initialDate;

  /// First selectable date (inclusive).
  final DateTime? firstDate;

  /// Last selectable date (inclusive).
  final DateTime? lastDate;

  /// Era used for formatting (BE/CE).
  final tbd.Era era;

  /// Locale used for month/weekday names (e.g. `th_TH`).
  final String? locale;

  /// Optional dialog title.
  final String? title;

  /// Confirm button label.
  final String? confirmText;

  /// Cancel button label.
  final String? cancelText;

  /// Dialog width override.
  final double? width;

  /// Calendar area height.
  final double? height;

  /// Custom header builder (receives prev/next callbacks).
  final Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder;

  /// Custom day cell builder.
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;

  /// Dialog shape.
  final ShapeBorder? shape;

  /// Padding around title/content/actions/insets.
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  @override
  State<ThaiDatePickerDialog> createState() => _ThaiDatePickerDialogState();
}

class _ThaiDatePickerDialogState extends State<ThaiDatePickerDialog> {
  DateTime? _selected;
  @override
  void initState() {
    super.initState();
    validateDatePickerArguments(
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialDates: [widget.initialDate],
    );
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกวันที่';
    return AlertDialog(
      scrollable: true,
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding ?? _defaultDialogInsetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? 420,
        child: _calendarViewport(
          BuddhistGregorianCalendar(
            era: widget.era,
            locale: widget.locale,
            initialMonth: (_selected ?? widget.initialDate) ?? DateTime.now(),
            selectedDate: _selected,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            headerBuilder: widget.headerBuilder,
            dayBuilder: widget.dayBuilder,
            onDateSelected: (d) => setState(() => _selected = d),
          ),
          widget.height,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop<DateTime?>(null),
            child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop<DateTime?>(_selected),
          child: Text(widget.confirmText ?? 'ตกลง'),
        ),
      ],
    );
  }
}

/// A dialog that lets the user pick a calendar date and a time of day.
///
/// The date portion is rendered with [ThaiDatePickerDialog]-like calendar and
/// preview is formatted using the provided [formatString].
class ThaiDateTimePickerDialog extends StatefulWidget {
  const ThaiDateTimePickerDialog({
    super.key,
    this.initialDateTime,
    this.firstDate,
    this.lastDate,
    this.era = tbd.Era.be,
    this.locale = 'th_TH',
    this.title,
    this.confirmText,
    this.cancelText,
    this.width,
    this.height,
    this.headerBuilder,
    this.dayBuilder,
    this.formatString = 'dd/MM/yyyy HH:mm',
    this.shape,
    this.titlePadding,
    this.contentPadding,
    this.actionsPadding,
    this.insetPadding,
  });

  final DateTime? initialDateTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final tbd.Era era;
  final String? locale;
  final String? title;
  final String? confirmText;
  final String? cancelText;
  final double? width;
  final double? height;
  final Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;
  final String formatString;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  @override
  State<ThaiDateTimePickerDialog> createState() =>
      _ThaiDateTimePickerDialogState();
}

/// A dialog that lets the user pick a start and end date (a range).
class ThaiDateRangePickerDialog extends StatefulWidget {
  const ThaiDateRangePickerDialog({
    super.key,
    this.initialStart,
    this.initialEnd,
    this.firstDate,
    this.lastDate,
    this.era = tbd.Era.be,
    this.locale = 'th_TH',
    this.title,
    this.confirmText,
    this.cancelText,
    this.width,
    this.height,
    this.headerBuilder,
    this.dayBuilder,
    this.shape,
    this.titlePadding,
    this.contentPadding,
    this.actionsPadding,
    this.insetPadding,
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final tbd.Era era;
  final String? locale;
  final String? title;
  final String? confirmText;
  final String? cancelText;
  final double? width;
  final double? height;
  final Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  @override
  State<ThaiDateRangePickerDialog> createState() =>
      _ThaiDateRangePickerDialogState();
}

class _ThaiDateRangePickerDialogState extends State<ThaiDateRangePickerDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    validateDatePickerArguments(
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialDates: [widget.initialStart, widget.initialEnd],
      initialArgumentName: 'initial range',
    );
    _validateRangeOrder(widget.initialStart, widget.initialEnd);
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  bool _inRange(DateTime d) {
    if (_start == null || _end == null) return false;
    final s = DateTime(_start!.year, _start!.month, _start!.day);
    final e = DateTime(_end!.year, _end!.month, _end!.day);
    final x = DateTime(d.year, d.month, d.day);
    return !x.isBefore(s) && !x.isAfter(e);
  }

  bool _isRangeSelected(DateTime date) =>
      _inRange(date) ||
      (_start != null && _end == null && isSameDate(date, _start!));

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกช่วงวันที่';
    Widget dayBuilder(
        BuildContext ctx, DateTime date, bool selected, bool disabled) {
      final inRange = _isRangeSelected(date);
      final bg = disabled
          ? Theme.of(ctx).disabledColor.withAlpha(26)
          : (inRange ? Theme.of(ctx).colorScheme.primary.withAlpha(46) : null);
      final fg = disabled
          ? Theme.of(ctx).disabledColor
          : ((_start != null && isSameDate(date, _start!)) ||
                  (_end != null && isSameDate(date, _end!))
              ? Theme.of(ctx).colorScheme.primary
              : null);
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          '${date.day}',
          style: TextStyle(
              color: fg,
              fontWeight: ((_start != null && isSameDate(date, _start!)) ||
                      (_end != null && isSameDate(date, _end!)))
                  ? FontWeight.w700
                  : FontWeight.w500),
        ),
      );
    }

    void onTap(DateTime d) {
      final x = DateTime(d.year, d.month, d.day);
      setState(() {
        if (_start == null || (_start != null && _end != null)) {
          _start = x;
          _end = null;
        } else {
          if (x.isBefore(_start!)) {
            _end = _start;
            _start = x;
          } else {
            _end = x;
          }
        }
      });
    }

    return AlertDialog(
      scrollable: true,
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding ?? _defaultDialogInsetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? 420,
        child: _calendarViewport(
          BuddhistGregorianCalendar(
            era: widget.era,
            locale: widget.locale,
            initialMonth: (_start ?? widget.initialStart) ?? DateTime.now(),
            selectedDate: _start,
            isDateSelected: _isRangeSelected,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            headerBuilder: widget.headerBuilder,
            dayBuilder: widget.dayBuilder ?? dayBuilder,
            onDateSelected: onTap,
          ),
          widget.height,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop<DateTimeRange?>(null),
            child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed: (_start != null && _end != null)
              ? () => Navigator.of(context).pop<DateTimeRange?>(
                  DateTimeRange(start: _start!, end: _end!))
              : null,
          child: Text(widget.confirmText ?? 'ตกลง'),
        ),
      ],
    );
  }
}

class _ThaiDateTimePickerDialogState extends State<ThaiDateTimePickerDialog> {
  DateTime? _selected;
  TimeOfDay _time = const TimeOfDay(hour: 0, minute: 0);
  @override
  void initState() {
    super.initState();
    validateDatePickerArguments(
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialDates: [widget.initialDateTime],
      initialArgumentName: 'initialDateTime',
    );
    final init = clampDateToBounds(
      widget.initialDateTime ?? DateTime.now(),
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );
    _selected = DateTime(init.year, init.month, init.day);
    _time = TimeOfDay(hour: init.hour, minute: init.minute);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกวันและเวลา';
    final preview = _selected == null
        ? '-'
        : tbd.format(
            DateTime(_selected!.year, _selected!.month, _selected!.day,
                _time.hour, _time.minute),
            format: widget.formatString,
            era: widget.era,
            locale: widget.locale,
          );
    return AlertDialog(
      scrollable: true,
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding ?? _defaultDialogInsetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _calendarViewport(
              BuddhistGregorianCalendar(
                era: widget.era,
                locale: widget.locale,
                initialMonth:
                    (_selected ?? widget.initialDateTime) ?? DateTime.now(),
                selectedDate: _selected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                headerBuilder: widget.headerBuilder,
                dayBuilder: widget.dayBuilder,
                onDateSelected: (d) => setState(() => _selected = d),
              ),
              widget.height,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: Text('ตัวอย่าง: $preview',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false)),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: _time);
                    if (!mounted) return;
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: const Text('เลือกเวลา'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop<DateTime?>(null),
            child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () {
                  final dt = DateTime(_selected!.year, _selected!.month,
                      _selected!.day, _time.hour, _time.minute);
                  Navigator.of(context).pop<DateTime?>(dt);
                },
          child: Text(widget.confirmText ?? 'ตกลง'),
        ),
      ],
    );
  }
}

/// Shows a single-date picker dialog and returns a formatted string.
///
/// Convenience wrapper over [showThaiDatePicker] that applies
/// thai_buddhist_date formatting with [formatString].
Future<String?> showThaiDatePickerFormatted(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  tbd.Era era = tbd.Era.be,
  String? locale = 'th_TH',
  String formatString = 'dd/MM/yyyy',
  String? title,
  String? confirmText,
  String? cancelText,
  double? width,
  double? height,
  Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) async {
  final dt = await showThaiDatePicker(
    context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    era: era,
    locale: locale,
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    width: width,
    height: height,
    headerBuilder: headerBuilder,
    dayBuilder: dayBuilder,
    shape: shape,
    titlePadding: titlePadding,
    contentPadding: contentPadding,
    actionsPadding: actionsPadding,
    insetPadding: insetPadding,
  );
  if (dt == null) return null;
  return tbd.format(dt, format: formatString, era: era, locale: locale);
}

/// Shows a date-time picker dialog and returns a formatted string.
///
/// Convenience wrapper over [showThaiDateTimePicker] that applies
/// thai_buddhist_date formatting with [formatString].
Future<String?> showThaiDateTimePickerFormatted(
  BuildContext context, {
  DateTime? initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
  tbd.Era era = tbd.Era.be,
  String? locale = 'th_TH',
  String formatString = 'dd/MM/yyyy HH:mm',
  String? title,
  String? confirmText,
  String? cancelText,
  double? width,
  double? height,
  Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) async {
  final dt = await showThaiDateTimePicker(
    context,
    initialDateTime: initialDateTime,
    firstDate: firstDate,
    lastDate: lastDate,
    era: era,
    locale: locale,
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    width: width,
    height: height,
    headerBuilder: headerBuilder,
    dayBuilder: dayBuilder,
    shape: shape,
    titlePadding: titlePadding,
    contentPadding: contentPadding,
    actionsPadding: actionsPadding,
    insetPadding: insetPadding,
  );
  if (dt == null) return null;
  return tbd.format(dt, format: formatString, era: era, locale: locale);
}

/// Shows a dialog to pick a single date. Returns the picked [DateTime] or null.
Future<DateTime?> showThaiDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  tbd.Era era = tbd.Era.be,
  String? locale = 'th_TH',
  String? title,
  String? confirmText,
  String? cancelText,
  double? width,
  double? height,
  Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) {
  validateDatePickerArguments(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDates: [initialDate],
  );
  return showDialog<DateTime?>(
    context: context,
    builder: (_) => ThaiDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      era: era,
      locale: locale,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      width: width,
      height: height,
      headerBuilder: headerBuilder,
      dayBuilder: dayBuilder,
      shape: shape,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      insetPadding: insetPadding,
    ),
  );
}

/// Shows a dialog to pick a date and time. Returns the picked [DateTime] or null.
Future<DateTime?> showThaiDateTimePicker(
  BuildContext context, {
  DateTime? initialDateTime,
  DateTime? firstDate,
  DateTime? lastDate,
  tbd.Era era = tbd.Era.be,
  String? locale = 'th_TH',
  String? title,
  String? confirmText,
  String? cancelText,
  double? width,
  double? height,
  Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
  String formatString = 'dd/MM/yyyy HH:mm',
}) {
  validateDatePickerArguments(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDates: [initialDateTime],
    initialArgumentName: 'initialDateTime',
  );
  return showDialog<DateTime?>(
    context: context,
    builder: (_) => ThaiDateTimePickerDialog(
      initialDateTime: initialDateTime,
      firstDate: firstDate,
      lastDate: lastDate,
      era: era,
      locale: locale,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      width: width,
      height: height,
      headerBuilder: headerBuilder,
      dayBuilder: dayBuilder,
      formatString: formatString,
      shape: shape,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      insetPadding: insetPadding,
    ),
  );
}

/// Shows a dialog to pick a date range. Returns the picked [DateTimeRange] or null.
Future<DateTimeRange?> showThaiDateRangePicker(
  BuildContext context, {
  DateTime? initialStart,
  DateTime? initialEnd,
  DateTime? firstDate,
  DateTime? lastDate,
  tbd.Era era = tbd.Era.be,
  String? locale = 'th_TH',
  String? title,
  String? confirmText,
  String? cancelText,
  double? width,
  double? height,
  Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) {
  validateDatePickerArguments(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDates: [initialStart, initialEnd],
    initialArgumentName: 'initial range',
  );
  _validateRangeOrder(initialStart, initialEnd);
  return showDialog<DateTimeRange?>(
    context: context,
    builder: (_) => ThaiDateRangePickerDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
      firstDate: firstDate,
      lastDate: lastDate,
      era: era,
      locale: locale,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      width: width,
      height: height,
      headerBuilder: headerBuilder,
      dayBuilder: dayBuilder,
      shape: shape,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      insetPadding: insetPadding,
    ),
  );
}

// Multi-date dialog
/// A dialog that lets the user pick multiple dates.
class ThaiMultiDatePickerDialog extends StatefulWidget {
  const ThaiMultiDatePickerDialog({
    super.key,
    this.initialDates,
    this.firstDate,
    this.lastDate,
    this.era = tbd.Era.be,
    this.locale = 'th_TH',
    this.title,
    this.confirmText,
    this.cancelText,
    this.width,
    this.height,
    this.headerBuilder,
    this.dayBuilder,
    this.shape,
    this.titlePadding,
    this.contentPadding,
    this.actionsPadding,
    this.insetPadding,
  });

  final Set<DateTime>? initialDates;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final tbd.Era era;
  final String? locale;
  final String? title;
  final String? confirmText;
  final String? cancelText;
  final double? width;
  final double? height;
  final Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  @override
  State<ThaiMultiDatePickerDialog> createState() =>
      _ThaiMultiDatePickerDialogState();
}

class _ThaiMultiDatePickerDialogState extends State<ThaiMultiDatePickerDialog> {
  late Set<DateTime> _selected;
  @override
  void initState() {
    super.initState();
    validateDatePickerArguments(
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialDates: widget.initialDates ?? const <DateTime>{},
      initialArgumentName: 'initialDates',
    );
    _selected = {
      ...(widget.initialDates?.map((d) => DateTime(d.year, d.month, d.day)) ??
          const <DateTime>{})
    };
  }

  bool _contains(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return _selected
        .any((e) => e.year == x.year && e.month == x.month && e.day == x.day);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกหลายวันที่';
    Widget dayBuilder(
        BuildContext ctx, DateTime date, bool selected, bool disabled) {
      final picked = _contains(date);
      final bg = disabled
          ? Theme.of(ctx).disabledColor.withAlpha(26)
          : (picked ? Theme.of(ctx).colorScheme.primary.withAlpha(46) : null);
      final fg = disabled
          ? Theme.of(ctx).disabledColor
          : (picked ? Theme.of(ctx).colorScheme.primary : null);
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          '${date.day}',
          style: TextStyle(
              color: fg,
              fontWeight: picked ? FontWeight.w700 : FontWeight.w500),
        ),
      );
    }

    void onTap(DateTime d) {
      final x = DateTime(d.year, d.month, d.day);
      setState(() {
        if (_contains(x)) {
          _selected.removeWhere(
              (e) => e.year == x.year && e.month == x.month && e.day == x.day);
        } else {
          _selected.add(x);
        }
      });
    }

    return AlertDialog(
      scrollable: true,
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding ?? _defaultDialogInsetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? 420,
        child: _calendarViewport(
          BuddhistGregorianCalendar(
            era: widget.era,
            locale: widget.locale,
            initialMonth: (_selected.isNotEmpty ? _selected.first : null) ??
                DateTime.now(),
            selectedDate: _selected.isNotEmpty ? _selected.first : null,
            isDateSelected: _contains,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            headerBuilder: widget.headerBuilder,
            dayBuilder: widget.dayBuilder ?? dayBuilder,
            onDateSelected: onTap,
          ),
          widget.height,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop<Set<DateTime>?>(null),
            child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop<Set<DateTime>?>(_selected),
          child: Text(widget.confirmText ?? 'ตกลง'),
        ),
      ],
    );
  }
}

/// Shows a dialog to pick multiple dates. Returns the picked set or null.
Future<Set<DateTime>?> showThaiMultiDatePicker(
  BuildContext context, {
  Set<DateTime>? initialDates,
  DateTime? firstDate,
  DateTime? lastDate,
  tbd.Era era = tbd.Era.be,
  String? locale = 'th_TH',
  String? title,
  String? confirmText,
  String? cancelText,
  double? width,
  double? height,
  Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) {
  validateDatePickerArguments(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDates: initialDates ?? const <DateTime>{},
    initialArgumentName: 'initialDates',
  );
  return showDialog<Set<DateTime>?>(
    context: context,
    builder: (_) => ThaiMultiDatePickerDialog(
      initialDates: initialDates,
      firstDate: firstDate,
      lastDate: lastDate,
      era: era,
      locale: locale,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      width: width,
      height: height,
      headerBuilder: headerBuilder,
      dayBuilder: dayBuilder,
      shape: shape,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      insetPadding: insetPadding,
    ),
  );
}

/// Fullscreen single-date picker using a scaffolded page.
Future<DateTime?> showThaiDatePickerFullscreen(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  tbd.Era era = tbd.Era.be,
  String? locale = 'th_TH',
  String? title,
  Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
}) {
  validateDatePickerArguments(
    firstDate: firstDate,
    lastDate: lastDate,
    initialDates: [initialDate],
  );
  return Navigator.of(context).push<DateTime>(
    MaterialPageRoute(
      builder: (_) => _FullscreenPickerPage(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        era: era,
        locale: locale,
        title: title,
        headerBuilder: headerBuilder,
        dayBuilder: dayBuilder,
      ),
    ),
  );
}

class _FullscreenPickerPage extends StatefulWidget {
  const _FullscreenPickerPage({
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.era = tbd.Era.be,
    this.locale = 'th_TH',
    this.title,
    this.headerBuilder,
    this.dayBuilder,
  });

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final tbd.Era era;
  final String? locale;
  final String? title;
  final Widget Function(
          BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)?
      headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;

  @override
  State<_FullscreenPickerPage> createState() => _FullscreenPickerPageState();
}

class _FullscreenPickerPageState extends State<_FullscreenPickerPage> {
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    validateDatePickerArguments(
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialDates: [widget.initialDate],
    );
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกวันที่';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _selected == null
                ? null
                : () => Navigator.of(context).pop<DateTime>(_selected),
            child: const Text('ตกลง'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: BuddhistGregorianCalendar(
              era: widget.era,
              locale: widget.locale,
              initialMonth: (_selected ?? widget.initialDate) ?? DateTime.now(),
              selectedDate: _selected,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              headerBuilder: widget.headerBuilder,
              dayBuilder: widget.dayBuilder,
              onDateSelected: (d) => setState(() => _selected = d),
            ),
          ),
        ),
      ),
    );
  }
}
