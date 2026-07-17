import 'package:flutter/material.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

import 'date_picker_validation.dart';

/// A reusable month calendar supporting Buddhist Era and Common Era output.
class BuddhistGregorianCalendar extends StatefulWidget {
  const BuddhistGregorianCalendar({
    super.key,
    this.initialMonth,
    this.selectedDate,
    this.onDateSelected,
    this.era = tbd.Era.be,
    this.locale,
    this.firstWeekday = DateTime.monday,
    this.showWeekdayHeaders = true,
    this.firstDate,
    this.lastDate,
    this.isDateSelected,
    this.headerBuilder,
    this.dayBuilder,
  });

  /// The month that should initially be visible.
  final DateTime? initialMonth;

  /// The selected date highlighted in the grid.
  final DateTime? selectedDate;

  /// Called when an enabled date is activated.
  final ValueChanged<DateTime>? onDateSelected;

  /// Era used to display the year.
  final tbd.Era era;

  /// Locale used for month and weekday names.
  final String? locale;

  /// First weekday, either [DateTime.monday] or [DateTime.sunday].
  final int firstWeekday;

  /// Whether weekday labels are visible.
  final bool showWeekdayHeaders;

  /// First selectable date, inclusive.
  final DateTime? firstDate;

  /// Last selectable date, inclusive.
  final DateTime? lastDate;

  /// Optional selection predicate for range or multi-date presentations.
  ///
  /// When omitted, [selectedDate] controls the selected state.
  final bool Function(DateTime date)? isDateSelected;

  /// Builds a custom header using the supplied navigation callbacks.
  final Widget Function(
    BuildContext context,
    DateTime visibleMonth,
    tbd.Era era,
    String? locale,
    VoidCallback onPrev,
    VoidCallback onNext,
  )? headerBuilder;

  /// Builds a custom day cell.
  final Widget Function(
    BuildContext context,
    DateTime date,
    bool selected,
    bool disabled,
  )? dayBuilder;

  @override
  State<BuddhistGregorianCalendar> createState() =>
      _BuddhistGregorianCalendarState();
}

class _BuddhistGregorianCalendarState extends State<BuddhistGregorianCalendar> {
  static const double _minimumGridWidth = 7 * 48;

  late DateTime _visibleMonth;
  bool _localeReady = false;
  String _monthTitle = '';
  List<String> _weekdayLabels = const [];
  int _localeRequest = 0;

  @override
  void initState() {
    super.initState();
    _validateConfiguration();
    final now = DateTime.now();
    final initial = widget.initialMonth ?? DateTime(now.year, now.month);
    _visibleMonth = _clampVisibleMonth(
      DateTime(initial.year, initial.month),
    );
    _loadLocale();
  }

  @override
  void didUpdateWidget(covariant BuddhistGregorianCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _validateConfiguration();

    final initialMonthChanged = widget.initialMonth != oldWidget.initialMonth;
    if (initialMonthChanged && widget.initialMonth != null) {
      final initial = widget.initialMonth!;
      _visibleMonth = DateTime(initial.year, initial.month);
    }
    _visibleMonth = _clampVisibleMonth(_visibleMonth);

    final localeConfigurationChanged = widget.locale != oldWidget.locale ||
        widget.era != oldWidget.era ||
        widget.firstWeekday != oldWidget.firstWeekday;
    if (localeConfigurationChanged) {
      _localeReady = false;
      _loadLocale();
    } else if (_localeReady &&
        (initialMonthChanged ||
            widget.firstDate != oldWidget.firstDate ||
            widget.lastDate != oldWidget.lastDate)) {
      _computeLocaleTexts();
    }
  }

  DateTime _clampVisibleMonth(DateTime month) {
    final firstDate = widget.firstDate;
    if (firstDate != null) {
      final firstMonth = DateTime(firstDate.year, firstDate.month);
      if (month.isBefore(firstMonth)) return firstMonth;
    }
    final lastDate = widget.lastDate;
    if (lastDate != null) {
      final lastMonth = DateTime(lastDate.year, lastDate.month);
      if (month.isAfter(lastMonth)) return lastMonth;
    }
    return month;
  }

  void _validateConfiguration() {
    if (widget.firstWeekday != DateTime.monday &&
        widget.firstWeekday != DateTime.sunday) {
      throw ArgumentError.value(
        widget.firstWeekday,
        'firstWeekday',
        'must be DateTime.monday or DateTime.sunday',
      );
    }
    validateDatePickerArguments(
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialDates: [widget.selectedDate],
    );
  }

  Future<void> _loadLocale() async {
    final request = ++_localeRequest;
    try {
      await tbd.ThaiDateService().initializeLocale(widget.locale);
    } on Object {
      // The formatter owns the documented locale fallback.
    }
    if (!mounted || request != _localeRequest) return;

    _computeLocaleTexts();
    setState(() => _localeReady = true);
  }

  void _computeLocaleTexts() {
    try {
      _monthTitle = tbd.format(
        _visibleMonth,
        pattern: 'MMMM yyyy',
        era: widget.era,
        locale: widget.locale,
      );
      final start = widget.firstWeekday;
      final order = List<int>.generate(7, (i) => ((start + i - 1) % 7) + 1);
      final monday = DateTime(2025, 8, 25);
      _weekdayLabels = [
        for (final weekday in order)
          tbd.format(
            monday.add(Duration(days: weekday - monday.weekday)),
            pattern: 'EEE',
            era: tbd.Era.ce,
            locale: widget.locale,
          ),
      ];
    } on Object {
      _monthTitle = '';
      _weekdayLabels = const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthTitle = _localeReady && _monthTitle.isNotEmpty
        ? _monthTitle
        : tbd.ThaiDateService().formatSync(
            tbd.ThaiDate.fromDateTime(_visibleMonth, era: widget.era),
            pattern: 'yyyy-MM',
            era: widget.era,
            locale: widget.locale,
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(monthTitle),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _minimumGridWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showWeekdayHeaders) _buildWeekdayHeader(),
                FocusTraversalGroup(child: _buildMonthGrid()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String monthTitle) {
    final previous = _canGoToPreviousMonth ? _previousMonth : () {};
    final next = _canGoToNextMonth ? _nextMonth : () {};
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(
        context,
        _visibleMonth,
        widget.era,
        widget.locale,
        previous,
        next,
      );
    }

    final thai = widget.locale == null || widget.locale!.startsWith('th');
    return Row(
      children: [
        IconButton(
          tooltip: thai ? 'เดือนก่อนหน้า' : 'Previous month',
          icon: const Icon(Icons.chevron_left),
          onPressed: _canGoToPreviousMonth ? _previousMonth : null,
        ),
        Expanded(
          child: Center(
            child: Semantics(
              header: true,
              child: Text(
                monthTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: thai ? 'เดือนถัดไป' : 'Next month',
          icon: const Icon(Icons.chevron_right),
          onPressed: _canGoToNextMonth ? _nextMonth : null,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final order = List<int>.generate(
      7,
      (index) => ((widget.firstWeekday + index - 1) % 7) + 1,
    );
    return Row(
      children: [
        for (var index = 0; index < order.length; index++)
          Expanded(
            child: Center(
              child: Text(
                _weekdayLabels.length == 7
                    ? _weekdayLabels[index]
                    : order[index].toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leading = (_visibleMonth.weekday - widget.firstWeekday + 7) % 7;
    final cells = <Widget>[
      for (var index = 0; index < leading; index++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++)
        _buildDayCell(
          DateTime(_visibleMonth.year, _visibleMonth.month, day),
        ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return Table(
      defaultColumnWidth: const FixedColumnWidth(48),
      children: [
        for (var index = 0; index < cells.length; index += 7)
          TableRow(
            children: [
              for (final cell in cells.sublist(index, index + 7))
                SizedBox.square(dimension: 48, child: cell),
            ],
          ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date) {
    final selected = widget.isDateSelected?.call(date) ??
        (widget.selectedDate != null && isSameDate(widget.selectedDate!, date));
    final first = widget.firstDate == null ? null : dateOnly(widget.firstDate!);
    final last = widget.lastDate == null ? null : dateOnly(widget.lastDate!);
    final disabled = first != null && date.isBefore(first) ||
        last != null && date.isAfter(last);
    final label = _semanticDateLabel(date);
    final child = widget.dayBuilder?.call(
          context,
          date,
          selected,
          disabled,
        ) ??
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withAlpha(38)
                : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: disabled
                  ? Theme.of(context).disabledColor
                  : selected
                      ? Theme.of(context).colorScheme.primary
                      : null,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        );

    return Semantics(
      label: label,
      button: true,
      enabled: !disabled,
      selected: selected,
      excludeSemantics: true,
      onTap: disabled ? null : () => widget.onDateSelected?.call(date),
      child: InkWell(
        canRequestFocus: !disabled,
        onTap: disabled ? null : () => widget.onDateSelected?.call(date),
        child: child,
      ),
    );
  }

  String _semanticDateLabel(DateTime date) {
    try {
      return tbd.format(
        date,
        pattern: 'd MMMM yyyy',
        era: widget.era,
        locale: widget.locale,
      );
    } on Object {
      return tbd.format(
        date,
        pattern: 'yyyy-MM-dd',
        era: widget.era,
      );
    }
  }

  bool get _canGoToPreviousMonth {
    final firstDate = widget.firstDate;
    if (firstDate == null) return true;
    final firstMonth = DateTime(firstDate.year, firstDate.month);
    return _visibleMonth.isAfter(firstMonth);
  }

  bool get _canGoToNextMonth {
    final lastDate = widget.lastDate;
    if (lastDate == null) return true;
    final lastMonth = DateTime(lastDate.year, lastDate.month);
    return _visibleMonth.isBefore(lastMonth);
  }

  void _previousMonth() => _changeMonth(-1);

  void _nextMonth() => _changeMonth(1);

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + offset);
      if (_localeReady) _computeLocaleTexts();
    });
  }
}
