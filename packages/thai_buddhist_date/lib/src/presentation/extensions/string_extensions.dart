import '../../domain/entities/thai_date.dart';
import '../../domain/value_objects/era.dart';
import '../thai_date_service.dart';

/// Extension methods on String for Thai Buddhist date operations
extension StringThaiExtensions on String {
  /// Parse string as Thai Buddhist date
  Future<ThaiDate?> parseThaiDate({
    String? pattern,
    Era? era,
    String? locale,
  }) async {
    try {
      return ThaiDateService().parse(
        this,
        pattern: pattern,
        era: era,
        locale: locale,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse string as Thai Buddhist date synchronously
  ThaiDate? parseThaiDateSync({
    String? pattern,
    Era? era,
    String? locale,
  }) {
    try {
      return ThaiDateService().parse(
        this,
        pattern: pattern,
        era: era,
        locale: locale,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if string is a valid Thai Buddhist date
  Future<bool> isValidThaiDate({
    String? pattern,
    Era? era,
    String? locale,
  }) async {
    final result = await parseThaiDate(
      pattern: pattern,
      era: era,
      locale: locale,
    );
    return result != null;
  }

  /// Check if string is a valid Thai Buddhist date synchronously
  bool isValidThaiDateSync({
    String? pattern,
    Era? era,
    String? locale,
  }) {
    final result = parseThaiDateSync(
      pattern: pattern,
      era: era,
      locale: locale,
    );
    return result != null;
  }

  /// Convert Thai date string to DateTime
  Future<DateTime?> toDateTime({
    String? pattern,
    Era? era,
    String? locale,
  }) async {
    final thaiDate = await parseThaiDate(
      pattern: pattern,
      era: era,
      locale: locale,
    );
    return thaiDate?.toDateTime();
  }

  /// Convert Thai date string to DateTime synchronously
  DateTime? toDateTimeSync({
    String? pattern,
    Era? era,
    String? locale,
  }) {
    final thaiDate = parseThaiDateSync(
      pattern: pattern,
      era: era,
      locale: locale,
    );
    return thaiDate?.toDateTime();
  }
}
