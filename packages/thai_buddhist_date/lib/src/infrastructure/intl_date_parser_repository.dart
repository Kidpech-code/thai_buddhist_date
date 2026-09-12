import 'package:intl/intl.dart';

import '../domain/entities/thai_date.dart';
import '../domain/value_objects/thai_date_config.dart';
import '../domain/value_objects/thai_date_pattern.dart';
import '../domain/value_objects/era.dart';
import '../domain/value_objects/locale_config.dart';
import '../domain/repositories/i_date_parser_repository.dart';

/// [intl]-based implementation of [IDateParserRepository].
///
/// The DateFormat instance cache is instance-level so isolated instances
/// (e.g. in tests) do not share state.
class IntlDateParserRepository implements IDateParserRepository {
  IntlDateParserRepository({
    String fallbackLocale = SupportedLocales.thai,
  }) : _fallbackLocale = fallbackLocale;

  final Map<String, DateFormat> _formatCache = {};
  String _fallbackLocale;

  /// Changes the locale used when `intl` rejects a requested locale.
  void setFallbackLocale(String locale) {
    final normalized = _normalizeLocale(locale);
    if (_fallbackLocale == normalized) return;
    _fallbackLocale = normalized;
    _formatCache.clear();
  }

  @override
  ThaiDate? parse(
      String input, ThaiDatePattern pattern, ThaiDateConfig config) {
    try {
      final dateFormat = _getOrCreateFormat(pattern.pattern, config.locale);
      final rawYear = dateFormat.parse(input).year;
      final inputEra = Era.be.isLikelyYear(rawYear) ? Era.be : Era.ce;
      final date = _parseInEra(input, dateFormat, inputEra);
      return ThaiDate.fromDateTime(date, era: config.era);
    } catch (_) {
      return null;
    }
  }

  @override
  ThaiDate? parseWithEra(
      String input, ThaiDatePattern pattern, ThaiDateConfig config) {
    try {
      final dateFormat = _getOrCreateFormat(pattern.pattern, config.locale);
      final date = _parseInEra(input, dateFormat, config.era);
      return ThaiDate.fromDateTime(date, era: config.era);
    } catch (_) {
      return null;
    }
  }

  @override
  bool isValid(String input, ThaiDatePattern pattern, ThaiDateConfig config) {
    return parse(input, pattern, config) != null;
  }

  DateTime _parseInEra(String input, DateFormat format, Era era) {
    if (era == Era.ce) return format.parseStrict(input);

    // Read the year without validating February against the Buddhist year.
    // Validation still uses intl's strict parser, with the actual Gregorian
    // year. For CE years <= 0, use a positive year in the same 400-year leap
    // cycle because intl only reads unsigned year fields.
    final rawYear = format.parse(input).year;
    final ceYear = era.toCE(rawYear);
    final validationYear = ceYear > 0 ? ceYear : 2000 + ceYear % 400;
    final zero = format.dateSymbols.ZERODIGIT?.codeUnitAt(0) ?? 48;
    final digits = RegExp(
        '[0-9${String.fromCharCode(zero)}-${String.fromCharCode(zero + 9)}]+');
    for (final match in digits.allMatches(input)) {
      final token = match.group(0)!;
      final ascii = String.fromCharCodes(token.codeUnits.map(
        (c) => c >= zero && c <= zero + 9 ? c - zero + 48 : c,
      ));
      final value = int.parse(ascii);
      if (value != rawYear && !(token.length == 2 && value == rawYear % 100)) {
        continue;
      }
      try {
        final adjusted =
            input.replaceRange(match.start, match.end, '$validationYear');
        final date = format.parseStrict(adjusted);
        // Only accept replacing a year field, never a numeric quoted literal,
        // day, or time field that happens to contain the same digits.
        if (date.year != validationYear) continue;
        return DateTime(ceYear, date.month, date.day, date.hour, date.minute,
            date.second, date.millisecond, date.microsecond);
      } on FormatException {
        continue;
      }
    }

    // Patterns without a year retain intl's default year behavior.
    final raw = format.parseStrict(input);
    return ThaiDate.safe(
      year: raw.year,
      month: raw.month,
      day: raw.day,
      hour: raw.hour,
      minute: raw.minute,
      second: raw.second,
      millisecond: raw.millisecond,
      microsecond: raw.microsecond,
      era: era,
    ).toDateTime();
  }

  DateFormat _getOrCreateFormat(String pattern, String locale) {
    final key = '${pattern}_$locale';
    return _formatCache[key] ??= _createFormat(pattern, locale);
  }

  DateFormat _createFormat(String pattern, String locale) {
    try {
      return locale.isEmpty ? DateFormat(pattern) : DateFormat(pattern, locale);
    } catch (_) {
      try {
        return DateFormat(pattern, _normalizeLocale(_fallbackLocale));
      } on Object {
        return DateFormat(pattern, SupportedLocales.thai);
      }
    }
  }

  String _normalizeLocale(String locale) {
    final trimmed = locale.trim();
    return trimmed.isEmpty
        ? SupportedLocales.defaultLocale
        : Intl.canonicalizedLocale(trimmed);
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
