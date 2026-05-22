import '../entities/thai_date.dart';
import '../value_objects/thai_date_config.dart';
import '../value_objects/thai_date_pattern.dart';

/// Repository interface for date formatting operations.
///
/// Follows the repository pattern: the domain defines what it needs;
/// the infrastructure layer provides the concrete implementation.
abstract class IDateFormatterRepository {
  /// Formats a [ThaiDate] using the specified [pattern] and [config].
  Future<String> format(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  );

  /// Formats synchronously (suitable for simple numeric patterns only).
  String formatSync(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  );

  /// Initialises locale data required for localised month/day names.
  Future<void> initializeLocale(String locale);

  /// Returns `true` if [locale] has already been initialised.
  bool isLocaleInitialized(String locale);
}
