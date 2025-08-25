// Copied from app demo pickers; depends on thai_buddhist_date.
import 'package:flutter/material.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

import 'buddhist_gregorian_calendar.dart';

// Exported API: showThaiDatePicker, showThaiDateTimePicker, showThaiMultiDatePicker, showThaiDatePickerFullscreen,
// showThaiDatePickerFormatted, showThaiDateTimePickerFormatted

// Single date dialog
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

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final tbd.Era era;
  final String? locale;
  final String? title;
  final String? confirmText;
  final String? cancelText;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;
  final ShapeBorder? shape;
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
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกวันที่';
    final screenH = MediaQuery.of(context).size.height;
    double calHeight = widget.height ?? screenH * 0.5;
    if (calHeight < 320) calHeight = 320;
    if (calHeight > 520) calHeight = 520;
    return AlertDialog(
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? double.maxFinite,
        child: SizedBox(
          height: calHeight,
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
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop<DateTime?>(null), child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed: _selected == null ? null : () => Navigator.of(context).pop<DateTime?>(_selected),
          child: Text(widget.confirmText ?? 'ตกลง'),
        ),
      ],
    );
  }
}

// DateTime dialog
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
  final Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;
  final String formatString;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  @override
  State<ThaiDateTimePickerDialog> createState() => _ThaiDateTimePickerDialogState();
}

// Range dialog
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
  final Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  @override
  State<ThaiDateRangePickerDialog> createState() => _ThaiDateRangePickerDialogState();
}

class _ThaiDateRangePickerDialogState extends State<ThaiDateRangePickerDialog> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกช่วงวันที่';
    final screenH = MediaQuery.of(context).size.height;
    double calHeight = widget.height ?? screenH * 0.5;
    if (calHeight < 320) calHeight = 320;
    if (calHeight > 520) calHeight = 520;

    Widget dayBuilder(BuildContext ctx, DateTime date, bool selected, bool disabled) {
      final inRange = _inRange(date) || (_start != null && _end == null && date == _start);
      final bg = disabled
          ? Theme.of(ctx).disabledColor.withValues(alpha: 0.1)
          : (inRange ? Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.18) : null);
      final fg = disabled ? Theme.of(ctx).disabledColor : (date == _start || date == _end ? Theme.of(ctx).colorScheme.primary : null);
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          '${date.day}',
          style: TextStyle(color: fg, fontWeight: (date == _start || date == _end) ? FontWeight.w700 : FontWeight.w500),
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
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? double.maxFinite,
        child: SizedBox(
          height: calHeight,
          child: BuddhistGregorianCalendar(
            era: widget.era,
            locale: widget.locale,
            initialMonth: (_start ?? widget.initialStart) ?? DateTime.now(),
            selectedDate: _start,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            headerBuilder: widget.headerBuilder,
            dayBuilder: widget.dayBuilder ?? dayBuilder,
            onDateSelected: onTap,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop<DateTimeRange?>(null), child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed:
              (_start != null && _end != null) ? () => Navigator.of(context).pop<DateTimeRange?>(DateTimeRange(start: _start!, end: _end!)) : null,
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
    final init = widget.initialDateTime ?? DateTime.now();
    _selected = DateTime(init.year, init.month, init.day);
    _time = TimeOfDay(hour: init.hour, minute: init.minute);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกวันและเวลา';
    final preview = _selected == null
        ? '-'
        : tbd.format(
            DateTime(_selected!.year, _selected!.month, _selected!.day, _time.hour, _time.minute),
            format: widget.formatString,
            era: widget.era,
            locale: widget.locale,
          );
    final screenH = MediaQuery.of(context).size.height;
    double calHeight = widget.height ?? screenH * 0.5;
    if (calHeight < 320) calHeight = 320;
    if (calHeight > 520) calHeight = 520;
    return AlertDialog(
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: calHeight,
              child: BuddhistGregorianCalendar(
                era: widget.era,
                locale: widget.locale,
                initialMonth: (_selected ?? widget.initialDateTime) ?? DateTime.now(),
                selectedDate: _selected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                headerBuilder: widget.headerBuilder,
                dayBuilder: widget.dayBuilder,
                onDateSelected: (d) => setState(() => _selected = d),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text('ตัวอย่าง: $preview', overflow: TextOverflow.ellipsis, maxLines: 1, softWrap: false)),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(context: context, initialTime: _time);
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
        TextButton(onPressed: () => Navigator.of(context).pop<DateTime?>(null), child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed: _selected == null
              ? null
              : () {
                  final dt = DateTime(_selected!.year, _selected!.month, _selected!.day, _time.hour, _time.minute);
                  Navigator.of(context).pop<DateTime?>(dt);
                },
          child: Text(widget.confirmText ?? 'ตกลง'),
        ),
      ],
    );
  }
}

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
  Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder,
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
  Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
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
  );
  if (dt == null) return null;
  return tbd.format(dt, format: formatString, era: era, locale: locale);
}

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
  Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) {
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
  Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
  String formatString = 'dd/MM/yyyy HH:mm',
}) {
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
  Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) {
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
  final Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

  @override
  State<ThaiMultiDatePickerDialog> createState() => _ThaiMultiDatePickerDialogState();
}

class _ThaiMultiDatePickerDialogState extends State<ThaiMultiDatePickerDialog> {
  late Set<DateTime> _selected;
  @override
  void initState() {
    super.initState();
    _selected = {...(widget.initialDates?.map((d) => DateTime(d.year, d.month, d.day)) ?? const <DateTime>{})};
  }

  bool _contains(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return _selected.any((e) => e.year == x.year && e.month == x.month && e.day == x.day);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? 'เลือกหลายวันที่';
    final screenH = MediaQuery.of(context).size.height;
    double calHeight = widget.height ?? screenH * 0.5;
    if (calHeight < 320) calHeight = 320;
    if (calHeight > 520) calHeight = 520;

    Widget dayBuilder(BuildContext ctx, DateTime date, bool selected, bool disabled) {
      final picked = _contains(date);
      final bg =
          disabled ? Theme.of(ctx).disabledColor.withValues(alpha: 0.1) : (picked ? Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.18) : null);
      final fg = disabled ? Theme.of(ctx).disabledColor : (picked ? Theme.of(ctx).colorScheme.primary : null);
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(
          '${date.day}',
          style: TextStyle(color: fg, fontWeight: picked ? FontWeight.w700 : FontWeight.w500),
        ),
      );
    }

    void onTap(DateTime d) {
      final x = DateTime(d.year, d.month, d.day);
      setState(() {
        if (_contains(x)) {
          _selected.removeWhere((e) => e.year == x.year && e.month == x.month && e.day == x.day);
        } else {
          _selected.add(x);
        }
      });
    }

    return AlertDialog(
      shape: widget.shape,
      titlePadding: widget.titlePadding,
      contentPadding: widget.contentPadding,
      actionsPadding: widget.actionsPadding,
      insetPadding: widget.insetPadding,
      title: Text(title),
      content: SizedBox(
        width: widget.width ?? double.maxFinite,
        child: SizedBox(
          height: calHeight,
          child: BuddhistGregorianCalendar(
            era: widget.era,
            locale: widget.locale,
            initialMonth: (_selected.isNotEmpty ? _selected.first : null) ?? DateTime.now(),
            selectedDate: _selected.isNotEmpty ? _selected.first : null,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            headerBuilder: widget.headerBuilder,
            dayBuilder: widget.dayBuilder ?? dayBuilder,
            onDateSelected: onTap,
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop<Set<DateTime>?>(null), child: Text(widget.cancelText ?? 'ยกเลิก')),
        FilledButton(
          onPressed: _selected.isEmpty ? null : () => Navigator.of(context).pop<Set<DateTime>?>(_selected),
          child: Text(widget.confirmText ?? 'ตกลง'),
        ),
      ],
    );
  }
}

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
  Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
  ShapeBorder? shape,
  EdgeInsetsGeometry? titlePadding,
  EdgeInsetsGeometry? contentPadding,
  EdgeInsetsGeometry? actionsPadding,
  EdgeInsets? insetPadding,
}) {
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
  Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder,
  Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder,
}) {
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
  final Widget Function(BuildContext, DateTime, tbd.Era, String?, VoidCallback, VoidCallback)? headerBuilder;
  final Widget Function(BuildContext, DateTime, bool, bool)? dayBuilder;

  @override
  State<_FullscreenPickerPage> createState() => _FullscreenPickerPageState();
}

class _FullscreenPickerPageState extends State<_FullscreenPickerPage> {
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
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
            onPressed: _selected == null ? null : () => Navigator.of(context).pop<DateTime>(_selected),
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
