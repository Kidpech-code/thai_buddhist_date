import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../domain/entities/thai_date.dart';
import '../domain/value_objects/thai_date_config.dart';
import '../domain/value_objects/thai_date_pattern.dart';
import '../domain/repositories/date_repository.dart';

/// High-performance implementation of date formatter repository using intl package
/// Includes token-aware formatting and locale initialization caching
class IntlDateFormatterRepository implements IDateFormatterRepository {
  static final Map<String, Future<void>> _localeInitFutures = {};
  static final Set<String> _initializedLocales = {};

  @override
  Future<String> format(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  ) async {
    // Ensure locale is initialized
    await initializeLocale(config.locale);

    if (config.era == date.era) {
      // No era conversion needed
      return _formatDirect(date, pattern, config);
    } else {
      // Convert era first
      final convertedDate = date.toEra(config.era);
      return _formatDirect(convertedDate, pattern, config);
    }
  }

  @override
  String formatSync(
    ThaiDate date,
    ThaiDatePattern pattern,
    ThaiDateConfig config,
  ) {
    try {
      // For sync operations, only handle simple numeric patterns
      if (_isNumericPattern(pattern.pattern)) {
        final workingDate =
            config.era == date.era ? date : date.toEra(config.era);
        return _formatTokenAware(workingDate, pattern, config.locale);
      } else {
        // Fallback to regular DateTime formatting
        final dateTime = date.toDateTime();
        return DateFormat(pattern.pattern).format(dateTime);
      }
    } catch (e) {
      // If locale isn't initialized, fall back to basic string formatting
      final workingDate =
          config.era == date.era ? date : date.toEra(config.era);
      return _formatBasic(workingDate, pattern.pattern);
    }
  }

  @override
  Future<void> initializeLocale(String locale) async {
    if (_initializedLocales.contains(locale)) {
      return;
    }

    _localeInitFutures[locale] ??= _doInitializeLocale(locale);
    await _localeInitFutures[locale]!;
  }

  @override
  bool isLocaleInitialized(String locale) {
    return _initializedLocales.contains(locale);
  }

  Future<void> _doInitializeLocale(String locale) async {
    try {
      await initializeDateFormatting(locale);
      _initializedLocales.add(locale);
    } catch (e) {
      // Fallback to default locale if specific locale fails
      if (locale != 'en_US') {
        await initializeDateFormatting('en_US');
        _initializedLocales.add(locale); // Mark as initialized to avoid retry
      }
    }
  }

  String _formatDirect(
      ThaiDate date, ThaiDatePattern pattern, ThaiDateConfig config) {
    // Convert to DateTime for formatting
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );

    // Use predefined optimized patterns when possible
    if (ThaiDatePattern.predefined.containsKey(pattern.pattern)) {
      return _formatOptimized(dateTime, pattern, config.locale);
    }

    // Use token-aware formatting for custom patterns
    return _formatTokenAware(date, pattern, config.locale);
  }

  String _formatOptimized(
      DateTime dateTime, ThaiDatePattern pattern, String locale) {
    // Fast path for common patterns
    switch (pattern.pattern) {
      case 'iso':
        return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      case 'slash':
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      case 'dash':
        return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
      default:
        return DateFormat(pattern.pattern, locale).format(dateTime);
    }
  }

  String _formatTokenAware(
      ThaiDate date, ThaiDatePattern pattern, String locale) {
    final patternStr = pattern.pattern;

    // Fast path for patterns without year tokens
    if (!patternStr.contains('y')) {
      final dateTime = date.toDateTime();
      return locale.isEmpty
          ? DateFormat(patternStr).format(dateTime)
          : DateFormat(patternStr, locale).format(dateTime);
    }

    // Token-aware formatting for year conversion
    return _performTokenAwareFormatting(date, patternStr, locale);
  }

  String _performTokenAwareFormatting(
      ThaiDate date, String pattern, String locale) {
    // Create DateTime with CE year for intl formatting
    final ceDateTime = DateTime(
      date.era.toCE(date.year),
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );

    // Parse and replace year tokens
    final tokens = <String>[];
    final modifiedPattern = StringBuffer();
    var i = 0;
    var inQuote = false;
    var tokenIndex = 0;

    while (i < pattern.length) {
      final c = pattern[i];

      if (c == "'") {
        inQuote = !inQuote;
        modifiedPattern.write(c);
        i++;
        continue;
      }

      if (!inQuote && c == 'y') {
        // Extract year token run
        var j = i;
        while (j < pattern.length && pattern[j] == 'y') {
          j++;
        }

        final yearToken = pattern.substring(i, j);
        final placeholder = '__YEAR_${tokenIndex}__';
        tokens.add(yearToken);
        modifiedPattern.write("'$placeholder'");
        tokenIndex++;
        i = j;
        continue;
      }

      modifiedPattern.write(c);
      i++;
    }

    // Format with modified pattern
    final baseResult = locale.isEmpty
        ? DateFormat(modifiedPattern.toString()).format(ceDateTime)
        : DateFormat(modifiedPattern.toString(), locale).format(ceDateTime);

    // Replace year placeholders with era-appropriate years
    var result = baseResult;
    for (var idx = 0; idx < tokens.length; idx++) {
      final token = tokens[idx];
      final placeholder = '__YEAR_${idx}__';
      final yearValue = _formatYearToken(date.year, token);
      result = result.replaceFirst(placeholder, yearValue);
    }

    return result;
  }

  String _formatYearToken(int year, String token) {
    switch (token.length) {
      case 1:
        return year.toString();
      case 2:
        return (year % 100).toString().padLeft(2, '0');
      default:
        return year.toString().padLeft(token.length, '0');
    }
  }

  bool _isNumericPattern(String pattern) {
    // Simple heuristic: pattern contains only date/time tokens without words
    const numericTokens = {'y', 'M', 'd', 'H', 'h', 'm', 's', 'S', 'E', 'a'};
    const separators = {'-', '/', ' ', ':', '.', 'T', 'Z'};

    for (int i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      if (!numericTokens.contains(char) && !separators.contains(char)) {
        return false;
      }
    }
    return true;
  }

  /// Basic formatting without intl dependency (fallback)
  String _formatBasic(ThaiDate date, String pattern) {
    var result = pattern;

    // Replace common patterns
    result = result.replaceAll(
        RegExp(r'y{4,}'), date.year.toString().padLeft(4, '0'));
    result = result.replaceAll(
        RegExp(r'y{2,3}'), (date.year % 100).toString().padLeft(2, '0'));
    result = result.replaceAll('y', date.year.toString());

    result = result.replaceAll(
        RegExp(r'M{2,}'), date.month.toString().padLeft(2, '0'));
    result = result.replaceAll('M', date.month.toString());

    result = result.replaceAll(
        RegExp(r'd{2,}'), date.day.toString().padLeft(2, '0'));
    result = result.replaceAll('d', date.day.toString());

    result = result.replaceAll(
        RegExp(r'H{2,}'), date.hour.toString().padLeft(2, '0'));
    result = result.replaceAll('H', date.hour.toString());

    result = result.replaceAll(
        RegExp(r'm{2,}'), date.minute.toString().padLeft(2, '0'));
    result = result.replaceAll('m', date.minute.toString());

    result = result.replaceAll(
        RegExp(r's{2,}'), date.second.toString().padLeft(2, '0'));
    result = result.replaceAll('s', date.second.toString());

    return result;
  }
}
