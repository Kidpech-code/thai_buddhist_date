import 'package:intl/intl.dart';

import '../domain/entities/thai_date.dart';
import '../domain/value_objects/thai_date_config.dart';
import '../domain/value_objects/thai_date_pattern.dart';
import '../domain/value_objects/era.dart';
import '../domain/repositories/date_repository.dart';

/// High-performance implementation of date parser repository
/// Includes intelligent era detection and multiple pattern fallbacks
class IntlDateParserRepository implements IDateParserRepository {
  // Cache of DateFormat instances for performance
  static final Map<String, DateFormat> _formatCache = {};

  @override
  ThaiDate? parse(
      String input, ThaiDatePattern pattern, ThaiDateConfig config) {
    try {
      final dateFormat = _getOrCreateFormat(pattern.pattern, config.locale);
      final parsedDateTimeRaw = dateFormat.parseStrict(input);

      // Detect era based on year value or config
      final detectedEra = _detectEra(input, config.era);

      // Normalize parsed DateTime to CE if the input looks like BE
      final parsedLooksBE = Era.be.isLikelyYear(parsedDateTimeRaw.year);
      final parsedDateTime = parsedLooksBE
          ? DateTime(
              Era.be.toCE(parsedDateTimeRaw.year),
              parsedDateTimeRaw.month,
              parsedDateTimeRaw.day,
              parsedDateTimeRaw.hour,
              parsedDateTimeRaw.minute,
              parsedDateTimeRaw.second,
              parsedDateTimeRaw.millisecond,
              parsedDateTimeRaw.microsecond,
            )
          : parsedDateTimeRaw;

      // Create ThaiDate with detected era (from CE DateTime)
      var result = ThaiDate.fromDateTime(parsedDateTime, era: detectedEra);

      // Convert to config era if needed
      if (result.era != config.era) {
        result = result.toEra(config.era);
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  ThaiDate? parseWithEra(
      String input, ThaiDatePattern pattern, ThaiDateConfig config) {
    try {
      final dateFormat = _getOrCreateFormat(pattern.pattern, config.locale);
      final parsedDateTimeRaw = dateFormat.parseStrict(input);

      // Normalize to CE if parsed year looks like BE
      final parsedLooksBE = Era.be.isLikelyYear(parsedDateTimeRaw.year);
      final parsedDateTime = parsedLooksBE
          ? DateTime(
              Era.be.toCE(parsedDateTimeRaw.year),
              parsedDateTimeRaw.month,
              parsedDateTimeRaw.day,
              parsedDateTimeRaw.hour,
              parsedDateTimeRaw.minute,
              parsedDateTimeRaw.second,
              parsedDateTimeRaw.millisecond,
              parsedDateTimeRaw.microsecond,
            )
          : parsedDateTimeRaw;

      // Create ThaiDate with explicit era from config (from CE DateTime)
      var result = ThaiDate.fromDateTime(parsedDateTime, era: config.era);

      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  bool isValid(String input, ThaiDatePattern pattern, ThaiDateConfig config) {
    return parse(input, pattern, config) != null;
  }

  Era _detectEra(String input, Era defaultEra) {
    // Extract year from input using regex
    final yearMatch = RegExp(r'(\d{4})').firstMatch(input);
    if (yearMatch != null) {
      final year = int.tryParse(yearMatch.group(1)!);
      if (year != null) {
        // Use era detection logic
        if (Era.be.isLikelyYear(year)) {
          return Era.be;
        } else if (Era.ce.isLikelyYear(year)) {
          return Era.ce;
        }
      }
    }

    // Fallback to default era
    return defaultEra;
  }

  DateFormat _getOrCreateFormat(String pattern, String locale) {
    final key = '${pattern}_$locale';
    return _formatCache[key] ??= _createFormat(pattern, locale);
  }

  DateFormat _createFormat(String pattern, String locale) {
    try {
      return locale.isEmpty ? DateFormat(pattern) : DateFormat(pattern, locale);
    } catch (_) {
      // Fallback to simple pattern if locale-specific fails
      return DateFormat(pattern);
    }
  }

  /// Parse with multiple pattern fallbacks for intelligent parsing
  ThaiDate? parseWithFallbacks(String input, ThaiDateConfig config) {
    final trimmedInput = input.trim();
    if (trimmedInput.isEmpty) return null;

    // Common patterns to try in order of likelihood
    final patterns = [
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'd MMMM yyyy',
      'd MMM yyyy',
      'yyyy-MM-dd HH:mm:ss',
      'dd/MM/yyyy HH:mm',
      'yyyy-MM-ddTHH:mm:ss',
      'EEEE, d MMMM yyyy',
    ];

    for (final patternStr in patterns) {
      final pattern = ThaiDatePattern(pattern: patternStr);
      final result = parse(trimmedInput, pattern, config);
      if (result != null) {
        return result;
      }
    }

    // Try compact numeric format (DDMMYYYY)
    if (RegExp(r'^\d{8}$').hasMatch(trimmedInput)) {
      try {
        final day = int.parse(trimmedInput.substring(0, 2));
        final month = int.parse(trimmedInput.substring(2, 4));
        final year = int.parse(trimmedInput.substring(4, 8));

        final era = Era.be.isLikelyYear(year) ? Era.be : Era.ce;
        final adjustedYear = era == Era.be ? era.toCE(year) : year;

        final dateTime = DateTime(adjustedYear, month, day);
        return ThaiDate.fromDateTime(dateTime, era: config.era);
      } catch (_) {
        // Invalid date
      }
    }

    // Try time-only format (HHMM or HH:MM:SS)
    final timeMatch =
        RegExp(r'^(\d{2}):?(\d{2})(?::?(\d{2}))?$').firstMatch(trimmedInput);
    if (timeMatch != null) {
      try {
        final hour = int.parse(timeMatch.group(1)!);
        final minute = int.parse(timeMatch.group(2)!);
        final second = int.tryParse(timeMatch.group(3) ?? '0') ?? 0;

        final now = DateTime.now();
        final dateTime =
            DateTime(now.year, now.month, now.day, hour, minute, second);

        return ThaiDate.fromDateTime(dateTime, era: config.era);
      } catch (_) {
        // Invalid time
      }
    }

    return null;
  }
}
