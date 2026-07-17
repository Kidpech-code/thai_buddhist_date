DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime clampDateToBounds(
  DateTime value, {
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final date = dateOnly(value);
  final first = firstDate == null ? null : dateOnly(firstDate);
  final last = lastDate == null ? null : dateOnly(lastDate);
  final boundary = first != null && date.isBefore(first)
      ? first
      : last != null && date.isAfter(last)
          ? last
          : null;
  if (boundary == null) return value;
  return DateTime(
    boundary.year,
    boundary.month,
    boundary.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

void validateDatePickerArguments({
  DateTime? firstDate,
  DateTime? lastDate,
  Iterable<DateTime?> initialDates = const <DateTime?>[],
  String initialArgumentName = 'initialDate',
}) {
  final first = firstDate == null ? null : dateOnly(firstDate);
  final last = lastDate == null ? null : dateOnly(lastDate);

  if (first != null && last != null && first.isAfter(last)) {
    throw ArgumentError.value(
      lastDate,
      'lastDate',
      'must be on or after firstDate',
    );
  }

  for (final initialDate in initialDates) {
    if (initialDate == null) continue;
    final initial = dateOnly(initialDate);
    if (first != null && initial.isBefore(first) ||
        last != null && initial.isAfter(last)) {
      throw ArgumentError.value(
        initialDate,
        initialArgumentName,
        'must be within firstDate and lastDate',
      );
    }
  }
}
