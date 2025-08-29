/// Represents the era system for date representation
enum Era {
  /// Buddhist Era (พ.ศ.) - Thai Buddhist calendar
  be('BE', 'พ.ศ.', 543),

  /// Common Era (ค.ศ.) - Gregorian calendar
  ce('CE', 'ค.ศ.', 0);

  const Era(this.code, this.thaiCode, this.offset);

  /// English code representation
  final String code;

  /// Thai code representation
  final String thaiCode;

  /// Year offset from Common Era
  final int offset;

  /// Convert CE year to this era
  int fromCE(int ceYear) => ceYear + offset;

  /// Convert year from this era to CE
  int toCE(int eraYear) => eraYear - offset;

  /// Check if a year value likely belongs to this era
  bool isLikelyYear(int year) {
    switch (this) {
      case Era.be:
        return year >= 2400; // BE years are typically >= 2400
      case Era.ce:
        return year >= 1900 && year <= 2200; // Reasonable CE range
    }
  }
}
