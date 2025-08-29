// thai_buddhist_date.dart
//
// Clean Architecture implementation of Thai Buddhist Date library
// Provides high-performance, maintainable date handling with Thai Buddhist Era support
//
// © 2024 Thai Buddhist Date Package - Clean Architecture Edition

library;

// Import necessary classes for the convenience functions
import 'package:intl/intl.dart';
import 'src/domain/entities/thai_date.dart';
import 'src/domain/value_objects/era.dart';
import 'src/domain/value_objects/locale_config.dart';
import 'src/presentation/thai_date_service.dart';

// Core Clean Architecture Exports
// ================================

// Domain Layer - Business Logic & Entities
export 'src/domain/entities/thai_date.dart';
export 'src/domain/value_objects/era.dart';
export 'src/domain/value_objects/locale_config.dart';
export 'src/domain/value_objects/thai_date_config.dart';
export 'src/domain/value_objects/thai_date_pattern.dart';

// Application Layer - Use Cases & Services
export 'src/application/services/cache_service.dart';
export 'src/application/use_cases/format_thai_date_use_case.dart';
export 'src/application/use_cases/parse_thai_date_use_case.dart';

// Presentation Layer - High-Level API
export 'src/presentation/thai_date_service.dart';

// Extension Methods for Ergonomic Usage
export 'src/presentation/extensions/datetime_extensions.dart';
export 'src/presentation/extensions/string_extensions.dart';
export 'src/presentation/extensions/int_extensions.dart';

// Infrastructure Layer (Optional - for advanced usage)
// export 'src/infrastructure/intl_date_formatter_repository.dart';
// export 'src/infrastructure/intl_date_parser_repository.dart';

// Convenience Re-exports for Common Usage
// ========================================

// Main service instance for quick access
ThaiDateService get thaiDateService => ThaiDateService();

// Common era values
const Era buddhistEra = Era.be;
const Era commonEra = Era.ce;

// Common locales
const String thaiLocale = 'th-TH';
const String englishLocale = 'en-US';

// Version information
const String version = '2.0.0';
const String architectureType = 'Clean Architecture';

/// Quick Format Functions - Convenience API
/// ==========================================

/// Format current date/time as Thai Buddhist date
Future<String> formatNowThai({
  String pattern = 'fullText',
  Era era = Era.be,
  String? locale,
}) async {
  return thaiDateService.formatNow(
    pattern: pattern,
    era: era,
    locale: locale,
  );
}

/// Format DateTime as Thai Buddhist date
Future<String> formatDateTime(
  DateTime dateTime, {
  String pattern = 'fullText',
  Era era = Era.be,
  String? locale,
}) async {
  final thaiDate = ThaiDate.fromDateTime(dateTime, era: era);
  return thaiDateService.format(
    thaiDate,
    pattern: pattern,
    era: era,
    locale: locale,
  );
}

/// Parse Thai Buddhist date string
ThaiDate? parseThaiDate(
  String input, {
  String? pattern,
  Era? era,
  String? locale,
}) {
  return thaiDateService.parse(
    input,
    pattern: pattern,
    era: era,
    locale: locale,
  );
}

/// Convert CE year to BE year
int convertCEToBE(int ceYear) => Era.be.fromCE(ceYear);

/// Convert BE year to CE year
int convertBEToCE(int beYear) => Era.be.toCE(beYear);

// ========================================
// Backward Compatibility Layer
// ========================================
//
// These functions provide compatibility with the old monolithic API
// while leveraging the new Clean Architecture implementation

/// Legacy parse function - backward compatible
/// Parses a date string. Accepts either Gregorian year (e.g. 2025-08-22)
/// or Thai Buddhist year (e.g. 2568-08-22). The function tries to detect
/// if the input year looks like a BE year (>= 2400) and converts to CE.
DateTime parse(String input, {String format = 'yyyy-MM-dd'}) {
  // Try to detect if this looks like a Thai Buddhist date
  final thaiDate = thaiDateService.parse(input, pattern: format);

  if (thaiDate != null) {
    return thaiDate.toDateTime();
  }

  // Fallback to simple DateTime parsing with era detection
  try {
    final regex = RegExp(r'(\d{4})');
    final match = regex.firstMatch(input);
    if (match != null) {
      final year = int.parse(match.group(0)!);
      if (year >= 2400) {
        // Looks like BE year, convert to CE
        final normalizedInput = input.replaceFirst(match.group(0)!, (year - 543).toString());
        return DateTime.parse(normalizedInput);
      }
    }
    return DateTime.parse(input);
  } catch (e) {
    throw FormatException('Unable to parse date: $input');
  }
}

/// Legacy Era enum for backward compatibility
/// Choose which era to output when formatting.
// Note: The new Era enum is exported above, but we keep this comment for compatibility

/// Legacy ThaiLanguage enum for backward compatibility - uses domain enum
/// Optional language convenience for choosing locales.
// Note: ThaiLanguage enum is now imported from domain layer

String _languageToLocale(ThaiLanguage lang) {
  return lang.localeCode;
}

/// Legacy format function - backward compatible
String format(
  DateTime dateTime, {
  String? pattern,
  String? format,
  Era era = Era.be,
  ThaiLanguage? language,
  String? locale,
}) {
  final resolvedPattern = pattern ?? format ?? 'fullText';
  return ThaiCalendar.format(
    dateTime,
    pattern: resolvedPattern,
    era: era,
    locale: locale,
    language: language,
  );
}

/// Legacy formatNow function - backward compatible
String formatNow({
  String? pattern,
  String? format,
  Era era = Era.be,
  ThaiLanguage? language,
  String? locale,
}) {
  final resolvedPattern = pattern ?? format ?? 'fullText';
  return ThaiCalendar.formatNow(
    pattern: resolvedPattern,
    era: era,
    locale: locale,
    language: language,
  );
}

// ========================================
// Legacy Compatibility Classes (Shim)
// ========================================

/// Legacy global settings for defaults.
/// This is a lightweight shim that proxies to ThaiDateService.
class ThaiDateSettings {
  static Era defaultEra = Era.be;
  static String defaultLocale = SupportedLocales.defaultLocale;

  static void set({Era? era, String? locale, ThaiLanguage? language}) {
    if (era != null) {
      defaultEra = era;
      ThaiDateService().setEra(era);
    }
    if (language != null) {
      defaultLocale = _languageToLocale(language);
      ThaiDateService().setLanguage(language);
    } else if (locale != null && locale.isNotEmpty) {
      if (SupportedLocales.isSupported(locale)) {
        defaultLocale = locale;
        ThaiDateService().setLocale(locale);
      } else {
        // Still store for compatibility, even if not in SupportedLocales
        defaultLocale = locale;
      }
    }
  }

  static void useThai() => set(locale: SupportedLocales.thai);
  static void useEnglishUS() => set(locale: SupportedLocales.english);
  static void useLocale(String localeCode) => set(locale: localeCode);
}

/// Parts for building custom Thai date strings (legacy helper).
enum ThaiDatePart { day, month, year }

/// Legacy ThaiCalendar API shim that maps to ThaiDateService.
class ThaiCalendar {
  /// Ensure date symbols for a locale are loaded. Defaults to Thai.
  static Future<void> ensureInitialized([String? locale, ThaiLanguage? language]) async {
    final loc = language != null ? _languageToLocale(language) : (locale?.isNotEmpty == true ? locale! : ThaiDateSettings.defaultLocale);
    await ThaiDateService().initializeLocale(loc);
  }

  /// Format a DateTime with optional preset pattern and era.
  static String format(
    DateTime date, {
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) {
    final loc = language != null ? _languageToLocale(language) : (locale?.isNotEmpty == true ? locale! : ThaiDateSettings.defaultLocale);

    // Preset patterns (legacy)
    String preset(String key) {
      switch (key) {
        case 'fullText':
          final s = DateFormat.yMMMMEEEEd(loc).format(date);
          return era == Era.be ? _replaceYearWithBE(s, date.year) : s;
        case 'long':
          final s = DateFormat.yMMMMd(loc).format(date);
          return era == Era.be ? _replaceYearWithBE(s, date.year) : s;
        case 'dmy':
          final s = DateFormat('d MMMM yyyy', loc).format(date);
          return era == Era.be ? _replaceYearWithBE(s, date.year) : s;
        case 'slash':
          return '${_pad2(date.day)}/${_pad2(date.month)}/${era == Era.be ? date.year + 543 : date.year}';
        case 'dash':
          return '${_pad2(date.day)}-${_pad2(date.month)}-${era == Era.be ? date.year + 543 : date.year}';
        case 'iso':
          final y = era == Era.be ? (date.year + 543) : date.year;
          return '${y.toString().padLeft(4, '0')}-${_pad2(date.month)}-${_pad2(date.day)}';
        case 'compact':
          return _pad2(date.day) + _pad2(date.month) + (era == Era.be ? (date.year + 543) : date.year).toString();
        case 'slashTime':
          final y = era == Era.be ? (date.year + 543) : date.year;
          return '${_pad2(date.day)}/${_pad2(date.month)}/$y ${_pad2(date.hour)}:${_pad2(date.minute)}';
        case 'isoTime':
          final y = era == Era.be ? (date.year + 543) : date.year;
          return '${y.toString().padLeft(4, '0')}-${_pad2(date.month)}-${_pad2(date.day)}T${_pad2(date.hour)}:${_pad2(date.minute)}:${_pad2(date.second)}';
        case 'timeMs':
          return '${_pad2(date.hour)}:${_pad2(date.minute)}:${_pad2(date.second)}.${date.millisecond.toString().padLeft(3, '0')}';
        default:
          // Custom pattern via intl
          if (era == Era.ce) {
            return DateFormat(pattern, loc).format(date);
          } else {
            return _tokenAwareFormat(date, pattern, locale: loc);
          }
      }
    }

    return preset(pattern);
  }

  /// Convenience: format the current time (DateTime.now()).
  static String formatNow({
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) {
    return format(DateTime.now(), pattern: pattern, era: era, locale: locale, language: language);
  }

  /// Format using an explicit DateFormat.
  static String formatWith(DateFormat df, DateTime date, {Era era = Era.be}) {
    final pattern = df.pattern ?? 'yyyy-MM-dd';
    final loc = (df.locale.isEmpty) ? ThaiDateSettings.defaultLocale : df.locale;
    if (era == Era.ce) {
      return DateFormat(pattern, loc).format(date);
    }
    return _tokenAwareFormat(date, pattern, locale: loc);
  }

  /// Async wrapper that ensures locale data is initialized and then formats.
  static Future<String> formatInitialized(
    DateTime date, {
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) async {
    await ensureInitialized(locale, language);
    return format(date, pattern: pattern, era: era, locale: locale, language: language);
  }

  /// Convenience: ensure locale data then format the current time.
  static Future<String> formatInitializedNow({
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) async {
    await ensureInitialized(locale, language);
    return formatNow(pattern: pattern, era: era, locale: locale, language: language);
  }

  /// Synchronous format for numeric-only patterns (no localized names).
  static String formatSync(
    DateTime date, {
    String pattern = 'yyyy-MM-dd',
    Era era = Era.be,
  }) {
    final thaiDate = ThaiDate.fromDateTime(date, era: era);
    return ThaiDateService().formatSync(thaiDate, pattern: pattern, era: era);
  }

  /// Parse a date string with optional custom pattern.
  static DateTime? parse(
    String input, {
    String? customPattern,
    String? locale,
    ThaiLanguage? language,
  }) {
    final loc = language != null ? _languageToLocale(language) : (locale?.isNotEmpty == true ? locale! : ThaiDateSettings.defaultLocale);
    final thai = ThaiDateService().parse(input, pattern: customPattern, locale: loc);
    return thai?.toDateTime();
  }

  /// Parse using an explicit era hint.
  static DateTime? parseWithEra(
    String input, {
    required String pattern,
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) {
    final loc = language != null ? _languageToLocale(language) : (locale?.isNotEmpty == true ? locale! : ThaiDateSettings.defaultLocale);
    final thai = ThaiDateService().parseWithEra(input, pattern: pattern, era: era, locale: loc);
    return thai?.toDateTime();
  }

  /// Parse using an explicit DateFormat instance (legacy helper).
  static DateTime? parseWith(DateFormat df, String input) {
    try {
      final dt = df.parseStrict(input);
      final m = RegExp(r'(\d{4})').firstMatch(input);
      if (m != null) {
        final y = int.tryParse(m.group(1)!);
        if (y != null && y >= 2400) {
          return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond, dt.microsecond);
        }
      }
      return dt;
    } catch (_) {
      return null;
    }
  }

  /// Convert from one pattern/era to another.
  static String? convert(
    String input, {
    String toPattern = 'fullText',
    String? fromPattern,
    Era toEra = Era.be,
    String? locale,
  }) {
    final dt = parse(input, customPattern: fromPattern, locale: locale);
    if (dt == null) return null;
    return format(dt, pattern: toPattern, era: toEra, locale: locale);
  }

  /// Validate input against optional pattern heuristics.
  static bool isValid(String input, {String? pattern}) {
    return ThaiDateService().isValid(input, pattern: pattern);
  }

  /// Build a Thai date string by reordering/omitting parts.
  static String formatThaiDateParts(
    DateTime date, {
    List<ThaiDatePart>? order,
    Era era = Era.be,
    String? locale,
    String separator = ' ',
    bool monthShort = false,
  }) {
    final loc = (locale?.isNotEmpty == true) ? locale! : ThaiDateSettings.defaultLocale;
    final effectiveOrder = order ?? const [ThaiDatePart.day, ThaiDatePart.month, ThaiDatePart.year];
    String day() => date.day.toString();
    String month() => DateFormat(monthShort ? 'MMM' : 'MMMM', loc).format(date);
    String year() => (era == Era.be ? date.year + 543 : date.year).toString();

    final parts = <String>[];
    for (final p in effectiveOrder) {
      switch (p) {
        case ThaiDatePart.day:
          parts.add(day());
          break;
        case ThaiDatePart.month:
          parts.add(month());
          break;
        case ThaiDatePart.year:
          parts.add(year());
          break;
      }
    }
    return parts.join(separator).trim();
  }

  // --- Legacy helpers (token-aware BE formatting) ---
  static String _pad2(int n) => n.toString().padLeft(2, '0');

  static String _replaceYearWithBE(String s, int ceYear) {
    final be = (ceYear + 543).toString();
    final ce = ceYear.toString();
    return s.replaceAllMapped(RegExp(r'\d{4}'), (m) => m.group(0) == ce ? be : m.group(0)!);
  }

  static String _tokenAwareFormat(DateTime dt, String pattern, {String? locale}) {
    final loc = locale ?? Intl.getCurrentLocale();
    final beYear = dt.year + 543;

    final tokens = <String>[];
    final buf = StringBuffer();
    var i = 0;
    var inQuote = false;
    var tokenIndex = 0;
    while (i < pattern.length) {
      final c = pattern[i];
      if (c == "'") {
        inQuote = !inQuote;
        buf.write(c);
        i++;
        continue;
      }
      if (!inQuote && c == 'y') {
        var j = i;
        while (j < pattern.length && pattern[j] == 'y') {
          j++;
        }
        final run = pattern.substring(i, j);
        final placeholder = '__BE_YEAR${tokenIndex}__';
        tokens.add(run);
        buf.write("'$placeholder'");
        tokenIndex++;
        i = j;
        continue;
      }
      buf.write(c);
      i++;
    }

    final modifiedPattern = buf.toString();
    final base = DateFormat(modifiedPattern, loc).format(dt);

    var result = base;
    for (var idx = 0; idx < tokens.length; idx++) {
      final run = tokens[idx];
      final placeholder = '__BE_YEAR${idx}__';
      String repl;
      if (run.length == 2) {
        repl = (beYear % 100).toString().padLeft(2, '0');
      } else if (run.length == 1) {
        repl = beYear.toString();
      } else {
        repl = beYear.toString().padLeft(run.length, '0');
      }
      result = result.replaceFirst(placeholder, repl);
    }
    return result;
  }
}

/// A simple, reusable formatter class (legacy helper).
class ThaiFormatter {
  final String pattern;
  final Era era;
  final String? locale;
  final ThaiLanguage? language;

  const ThaiFormatter({
    this.pattern = 'yyyy-MM-dd',
    this.era = Era.be,
    this.locale,
    this.language,
  });

  ThaiFormatter copyWith({String? pattern, Era? era, String? locale, ThaiLanguage? language}) => ThaiFormatter(
        pattern: pattern ?? this.pattern,
        era: era ?? this.era,
        locale: locale ?? this.locale,
        language: language ?? this.language,
      );

  String format(DateTime date) => ThaiCalendar.format(
        date,
        pattern: pattern,
        era: era,
        locale: locale,
        language: language,
      );

  String formatDate(DateTime date) => format(date);
}

/// Common locale codes for convenience (legacy helper).
class TbdLocales {
  static const th = 'th_TH';
  static const en = 'en_US';
  static const sq = 'sq';
  static const ar = 'ar';
  static const hy = 'hy';
  static const az = 'az';
  static const eu = 'eu';
  static const bn = 'bn';
  static const bg = 'bg';
  static const ca = 'ca';
  static const zh = 'zh';
  static const da = 'da';
  static const nl = 'nl';
  static const fr = 'fr';
  static const de = 'de';
  static const he = 'he';
  static const id = 'id';
  static const it = 'it';
  static const ja = 'ja';
  static const kk = 'kk';
  static const ko = 'ko';
  static const fa = 'fa';
  static const pl = 'pl';
  static const pt = 'pt';
  static const ru = 'ru';
  static const es = 'es';
  static const sv = 'sv';
  static const tr = 'tr';
  static const vi = 'vi';
  static const km = 'km';
  static const hi = 'hi';
}
