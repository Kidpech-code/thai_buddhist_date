import '../entities/thai_date.dart';
import '../value_objects/thai_date_config.dart';
import '../value_objects/thai_date_pattern.dart';

/// Repository interface for date formatting operations
/// Follows repository pattern for testability and loose coupling
abstract class IDateFormatterRepository {
  /// Format a ThaiDate using the specified pattern and config
  Future<String> format(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  );

  /// Format synchronously (for simple numeric patterns)
  String formatSync(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  );

  /// Initialize locale data for formatting
  Future<void> initializeLocale(String locale);

  /// Check if locale is initialized
  bool isLocaleInitialized(String locale);
}

/// Repository interface for date parsing operations
abstract class IDateParserRepository {
  /// Parse a date string to ThaiDate
  ThaiDate? parse(String input, ThaiDatePattern pattern, ThaiDateConfig config);

  /// Parse with explicit era hint
  ThaiDate? parseWithEra(
      String input, ThaiDatePattern pattern, ThaiDateConfig config);

  /// Check if date string is valid
  bool isValid(String input, ThaiDatePattern pattern, ThaiDateConfig config);
}
