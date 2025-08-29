import 'package:flutter/material.dart';
import 'package:thai_buddhist_date/thai_buddhist_date.dart' as tbd;

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
    this.headerBuilder,
    this.dayBuilder,
  });

  final DateTime? initialMonth; // month to show (1st of month is used)
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final tbd.Era era; // BE or CE output
  final String? locale; // e.g., 'th_TH' for Thai
  final int firstWeekday; // DateTime.monday or DateTime.sunday
  final bool showWeekdayHeaders;
  final DateTime? firstDate; // min selectable date
  final DateTime? lastDate; // max selectable date
  /// Optional custom header builder. If provided, overrides default month header and nav.
  final Widget Function(
    BuildContext context,
    DateTime visibleMonth,
    tbd.Era era,
    String? locale,
    VoidCallback onPrev,
    VoidCallback onNext,
  )?
  headerBuilder;

  /// Optional custom day cell builder. Receives date, selected, disabled flags.
  final Widget Function(
    BuildContext context,
    DateTime date,
    bool selected,
    bool disabled,
  )?
  dayBuilder;

  @override
  State<BuddhistGregorianCalendar> createState() =>
      _BuddhistGregorianCalendarState();
}

class _BuddhistGregorianCalendarState extends State<BuddhistGregorianCalendar> {
  late DateTime _visibleMonth; // normalized to first of month
  bool _localeReady = false;
  String _monthTitle = '';
  List<String> _weekdayLabels = const [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final init = widget.initialMonth ?? DateTime(now.year, now.month, 1);
    _visibleMonth = DateTime(init.year, init.month, 1);
    _ensureLocale();
  }

  Future<void> _ensureLocale() async {
    try {
      await tbd.thaiDateService.initializeLocale('th_TH');
    } catch (_) {
      // ignore, we'll still try to render numeric-only parts
    }
    if (mounted) {
      _localeReady = true;
      await _computeLocaleTexts();
      if (mounted) setState(() {});
    }
  }

  Future<void> _computeLocaleTexts() async {
    final locale = widget.locale;
    try {
      // Month title
      _monthTitle = tbd.format(
        _visibleMonth,
        format: 'MMMM yyyy',
        era: widget.era,
        locale: locale,
      );
      // Weekday labels starting from configured start
      final start = widget.firstWeekday == DateTime.sunday
          ? DateTime.sunday
          : DateTime.monday;
      final order = List<int>.generate(7, (i) => ((start + i - 1) % 7) + 1);
      final base = DateTime(2025, 8, 25); // arbitrary week reference (Mon)
      _weekdayLabels = [
        for (final wd in order)
          tbd.format(
            base.add(Duration(days: wd - base.weekday)),
            format: 'EEE',
            era: tbd.Era.ce,
            locale: locale,
          ),
      ];
    } catch (_) {
      // Fallbacks will be used in build
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final monthTitle = _localeReady && _monthTitle.isNotEmpty
        ? _monthTitle
        : tbd.thaiDateService.formatSync(
            tbd.ThaiDate.fromDateTime(_visibleMonth),
            pattern: 'yyyy-MM',
            era: widget.era,
            locale: locale,
          );

    final grid = _buildMonthGrid();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.headerBuilder != null)
          widget.headerBuilder!(
            context,
            _visibleMonth,
            widget.era,
            locale,
            _prevMonth,
            _nextMonth,
          )
        else
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _prevMonth,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    monthTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
        if (widget.showWeekdayHeaders)
          _localeReady
              ? _buildWeekdayHeader(locale)
              : const SizedBox(height: 0),
        grid,
      ],
    );
  }

  Widget _buildWeekdayHeader(String? locale) {
    final start = widget.firstWeekday == DateTime.sunday
        ? DateTime.sunday
        : DateTime.monday;
    final order = List<int>.generate(
      7,
      (i) => ((start + i - 1) % 7) + 1,
    ); // 1..7 starting from start
    final todayWeek = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var idx = 0; idx < order.length; idx++)
          Expanded(
            child: Center(
              child: Text(
                _weekdayLabels.isNotEmpty
                    ? _weekdayLabels[idx]
                    : todayWeek
                          .add(Duration(days: (order[idx] - todayWeek.weekday)))
                          .weekday
                          .toString(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMonthGrid() {
    final first = _visibleMonth;
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final firstWeekday = first.weekday; // Mon=1..Sun=7
    final weekStart = widget.firstWeekday == DateTime.sunday
        ? DateTime.sunday
        : DateTime.monday;
    final leading = _leadingEmptySlots(firstWeekday, weekStart);
    // final totalCells = leading + daysInMonth;

    final cells = <Widget>[];
    // leading blanks
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    // days
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(first.year, first.month, d);
      final isSelected =
          widget.selectedDate != null &&
          _isSameDate(widget.selectedDate!, date);
      cells.add(_buildDayCell(date, isSelected));
    }
    // pad trailing to complete rows
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  int _leadingEmptySlots(int firstWeekday, int weekStart) {
    // Convert to 0-based where weekStart is 0
    int normalize(int wd) {
      // Map 1..7 to 0..6 starting at weekStart
      final zeroBased = (wd - weekStart) % 7;
      return zeroBased < 0 ? zeroBased + 7 : zeroBased;
    }

    return normalize(firstWeekday);
  }

  Widget _buildDayCell(DateTime date, bool selected) {
    bool disabled = false;
    if (widget.firstDate != null) {
      final fd = DateTime(
        widget.firstDate!.year,
        widget.firstDate!.month,
        widget.firstDate!.day,
      );
      disabled = disabled || date.isBefore(fd);
    }
    if (widget.lastDate != null) {
      final ld = DateTime(
        widget.lastDate!.year,
        widget.lastDate!.month,
        widget.lastDate!.day,
      );
      disabled = disabled || date.isAfter(ld);
    }
    if (widget.dayBuilder != null) {
      return InkWell(
        onTap: disabled ? null : () => widget.onDateSelected?.call(date),
        child: widget.dayBuilder!(context, date, selected, disabled),
      );
    }
    return InkWell(
      onTap: disabled ? null : () => widget.onDateSelected?.call(date),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: disabled
                ? Theme.of(context).disabledColor
                : (selected ? Theme.of(context).colorScheme.primary : null),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _prevMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1, 1);
    });
    if (_localeReady) {
      _computeLocaleTexts().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
    if (_localeReady) {
      _computeLocaleTexts().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
