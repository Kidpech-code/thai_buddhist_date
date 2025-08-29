import '../../domain/value_objects/era.dart';

/// Extension methods on int for era conversions
extension IntThaiExtensions on int {
  /// Convert CE year to BE year
  int get toBE => Era.be.fromCE(this);

  /// Convert BE year to CE year
  int get toCE => Era.ce.fromCE(this);

  /// Create year in BE era
  int get beYear => Era.be.fromCE(this);

  /// Create year in CE era (same value)
  int get ceYear => this;

  /// Check if year is in valid Buddhist Era range
  bool get isValidBE => this >= 2400 && this <= 3000; // Reasonable BE range

  /// Check if year is in valid Common Era range
  bool get isValidCE => this >= 1900 && this <= 2200; // Reasonable CE range
}

/// Extension methods on double for era conversions (if needed for calculations)
extension DoubleThaiExtensions on double {
  /// Convert CE year to BE year (rounded)
  int get toBE => Era.be.fromCE(round());

  /// Convert BE year to CE year (rounded)
  int get toCE => Era.ce.fromCE(round());
}
