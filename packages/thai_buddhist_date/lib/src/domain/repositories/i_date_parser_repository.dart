import '../entities/thai_date.dart';
import '../value_objects/thai_date_config.dart';
import '../value_objects/thai_date_pattern.dart';

/// Repository interface for date parsing operations.
///
/// Follows the repository pattern: the domain defines what it needs;
/// the infrastructure layer provides the concrete implementation.
abstract class IDateParserRepository {
  /// Parses [input] into a [ThaiDate] using [pattern] and [config].
  ///
  /// Returns `null` if parsing fails.
  ThaiDate? parse(String input, ThaiDatePattern pattern, ThaiDateConfig config);

  /// Parses [input] with an explicit era hint taken from [config].
  ///
  /// Returns `null` if parsing fails.
  ThaiDate? parseWithEra(
      String input, ThaiDatePattern pattern, ThaiDateConfig config);

  /// Returns `true` if [input] is a valid date for the given [pattern].
  bool isValid(String input, ThaiDatePattern pattern, ThaiDateConfig config);
}
