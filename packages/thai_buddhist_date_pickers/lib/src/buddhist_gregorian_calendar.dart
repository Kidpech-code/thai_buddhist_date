// Copied from app demo; kept lightweight for re-use in pickers package.
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

  final DateTime? initialMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final tbd.Era era;
  final String? locale;
  final int firstWeekday;
  final bool showWeekdayHeaders;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget Function(BuildContext context, DateTime visibleMonth, tbd.Era era, String? locale, VoidCallback onPrev, VoidCallback onNext)?
  headerBuilder;
  final Widget Function(BuildContext context, DateTime date, bool selected, bool disabled)? dayBuilder;

  @override
  State<BuddhistGregorianCalendar> createState() => _BuddhistGregorianCalendarState();
}

class _BuddhistGregorianCalendarState extends State<BuddhistGregorianCalendar> {
  late DateTime _visibleMonth;
  bool _localeReady = false;

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
      await tbd.ThaiCalendar.ensureInitialized();
    } catch (_) {}
    if (mounted) setState(() => _localeReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final monthTitle = _localeReady
        ? tbd.format(_visibleMonth, format: 'MMMM yyyy', era: widget.era, locale: locale)
        : tbd.ThaiCalendar.formatSync(_visibleMonth, pattern: 'yyyy-MM', era: widget.era);

    final grid = _buildMonthGrid();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.headerBuilder != null)
          widget.headerBuilder!(context, _visibleMonth, widget.era, locale, _prevMonth, _nextMonth)
        else
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
              Expanded(
                child: Center(child: Text(monthTitle, style: Theme.of(context).textTheme.titleMedium)),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
            ],
          ),
        if (widget.showWeekdayHeaders) _localeReady ? _buildWeekdayHeader(locale) : const SizedBox(height: 0),
        grid,
      ],
    );
  }

  Widget _buildWeekdayHeader(String? locale) {
    final start = widget.firstWeekday == DateTime.sunday ? DateTime.sunday : DateTime.monday;
    final order = List<int>.generate(7, (i) => ((start + i - 1) % 7) + 1);
    final todayWeek = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final wd in order)
          Expanded(
            child: Center(
              child: Text(
                tbd.format(
                  todayWeek.add(Duration(days: (wd - todayWeek.weekday))),
                  format: 'EEE',
                  era: tbd.Era.ce,
                  locale: locale,
                ),
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
    final firstWeekday = first.weekday;
    final weekStart = widget.firstWeekday == DateTime.sunday ? DateTime.sunday : DateTime.monday;
    final leading = _leadingEmptySlots(firstWeekday, weekStart);

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final date = DateTime(first.year, first.month, d);
      final isSelected = widget.selectedDate != null && _isSameDate(widget.selectedDate!, date);
      cells.add(_buildDayCell(date, isSelected));
    }
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }

    return GridView.count(crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: cells);
  }

  int _leadingEmptySlots(int firstWeekday, int weekStart) {
    int normalize(int wd) {
      final zeroBased = (wd - weekStart) % 7;
      return zeroBased < 0 ? zeroBased + 7 : zeroBased;
    }

    return normalize(firstWeekday);
  }

  Widget _buildDayCell(DateTime date, bool selected) {
    bool disabled = false;
    if (widget.firstDate != null) {
      final fd = DateTime(widget.firstDate!.year, widget.firstDate!.month, widget.firstDate!.day);
      disabled = disabled || date.isBefore(fd);
    }
    if (widget.lastDate != null) {
      final ld = DateTime(widget.lastDate!.year, widget.lastDate!.month, widget.lastDate!.day);
      disabled = disabled || date.isAfter(ld);
    }
    if (widget.dayBuilder != null) {
      return InkWell(onTap: disabled ? null : () => widget.onDateSelected?.call(date), child: widget.dayBuilder!(context, date, selected, disabled));
    }
    return InkWell(
      onTap: disabled ? null : () => widget.onDateSelected?.call(date),
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          date.day.toString(),
          style: TextStyle(
            color: disabled ? Theme.of(context).disabledColor : (selected ? Theme.of(context).colorScheme.primary : null),
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
  }

  void _nextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    });
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
