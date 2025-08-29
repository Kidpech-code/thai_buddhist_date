import '../../domain/entities/thai_date.dart';
import '../../domain/value_objects/era.dart';
import '../thai_date_service.dart';

/// Extension methods on DateTime for Thai Buddhist date operations
extension DateTimeThaiExtensions on DateTime {
  /// Convert DateTime to ThaiDate
  ThaiDate toThaiDate({Era era = Era.be}) {
    return ThaiDate.fromDateTime(this, era: era);
  }

  /// Format DateTime as Thai Buddhist date
  Future<String> toThaiString({
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
  }) async {
    final thaiDate = toThaiDate(era: era);
    return ThaiDateService().format(
      thaiDate,
      pattern: pattern,
      era: era,
      locale: locale,
    );
  }

  /// Format DateTime synchronously
  String toThaiStringSync({
    String pattern = 'iso',
    Era era = Era.be,
    String? locale,
  }) {
    final thaiDate = toThaiDate(era: era);
    return ThaiDateService().formatSync(
      thaiDate,
      pattern: pattern,
      era: era,
      locale: locale,
    );
  }

  /// Get Buddhist Era year from DateTime
  int get beYear => year + Era.be.offset;

  /// Get Common Era year from DateTime (same as year)
  int get ceYear => year;
}
