/// Date component parts for Thai date formatting
enum ThaiDatePart {
  day('day'),
  month('month'),
  year('year');

  const ThaiDatePart(this.name);

  final String name;

  @override
  String toString() => name;
}

/// Immutable date pattern configuration
class ThaiDatePattern {
  const ThaiDatePattern({
    required this.pattern,
    this.parts = const [
      ThaiDatePart.day,
      ThaiDatePart.month,
      ThaiDatePart.year
    ],
    this.separator = ' ',
    this.monthShort = false,
  });

  /// Pattern string for formatting
  final String pattern;

  /// Order of date parts
  final List<ThaiDatePart> parts;

  /// Separator between parts
  final String separator;

  /// Whether to use short month names
  final bool monthShort;

  /// Predefined common patterns with performance optimization
  static const Map<String, ThaiDatePattern> predefined = {
    'dmy': ThaiDatePattern(
      pattern: 'd MMMM yyyy',
      parts: [ThaiDatePart.day, ThaiDatePart.month, ThaiDatePart.year],
    ),
    'fullText': ThaiDatePattern(
      pattern: 'EEEE, d MMMM yyyy',
    ),
    'long': ThaiDatePattern(
      pattern: 'd MMMM yyyy',
    ),
    'iso': ThaiDatePattern(
      pattern: 'yyyy-MM-dd',
    ),
    'slash': ThaiDatePattern(
      pattern: 'dd/MM/yyyy',
      separator: '/',
    ),
    'dash': ThaiDatePattern(
      pattern: 'dd-MM-yyyy',
      separator: '-',
    ),
  };

  /// Get predefined pattern or create custom
  static ThaiDatePattern get(String key) {
    return predefined[key] ?? ThaiDatePattern(pattern: key);
  }

  /// Create copy with modified properties
  ThaiDatePattern copyWith({
    String? pattern,
    List<ThaiDatePart>? parts,
    String? separator,
    bool? monthShort,
  }) {
    return ThaiDatePattern(
      pattern: pattern ?? this.pattern,
      parts: parts ?? this.parts,
      separator: separator ?? this.separator,
      monthShort: monthShort ?? this.monthShort,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThaiDatePattern &&
          runtimeType == other.runtimeType &&
          pattern == other.pattern &&
          const ListEquality().equals(parts, other.parts) &&
          separator == other.separator &&
          monthShort == other.monthShort;

  @override
  int get hashCode => Object.hash(
        pattern,
        const ListEquality().hash(parts),
        separator,
        monthShort,
      );
}

/// Helper class for list equality checking
class ListEquality<T> {
  const ListEquality();

  bool equals(List<T>? list1, List<T>? list2) {
    if (identical(list1, list2)) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }

  int hash(List<T>? list) {
    if (list == null) return 0;
    return Object.hashAll(list);
  }
}
