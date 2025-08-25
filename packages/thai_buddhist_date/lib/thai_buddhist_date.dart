// ignore_for_file: unnecessary_library_name

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Parses a date string. Accepts either Gregorian year (e.g. 2025-08-22)
/// or Thai Buddhist year (e.g. 2568-08-22). The function tries to detect
/// if the input year looks like a BE year (>= 2400) and converts to CE.
DateTime parse(String input, {String format = 'yyyy-MM-dd'}) {
  // Try to parse directly first
  try {
    final dt = DateFormat(format).parseStrict(input);
    // If year looks like BE (>= 2400), convert to CE
    if (dt.year >= 2400) {
      return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute,
          dt.second, dt.millisecond, dt.microsecond);
    }
    return dt;
  } catch (_) {
    // Try to parse with relaxed patterns: extract year
    final regex = RegExp(r"(\d{4})");
    final m = regex.firstMatch(input);
    if (m == null) throw FormatException('Unrecognized date format: $input');
    final year = int.parse(m.group(0)!);
    // If year looks like BE (>=2400), convert
    final normalizedYear = year >= 2400 ? year - 543 : year;
    // Replace back
    final attempted =
        input.replaceFirst(m.group(0)!, normalizedYear.toString());
    try {
      return DateFormat(format).parseStrict(attempted);
    } catch (e) {
      throw FormatException(
          'Unrecognized date format after normalization: $attempted');
    }
  }
}

/// Choose which era to output when formatting.
enum Era { be, ce }

/// Optional language convenience for choosing locales.
enum ThaiLanguage { thai, english }

String _languageToLocale(ThaiLanguage lang) {
  switch (lang) {
    case ThaiLanguage.thai:
      return 'th_TH';
    case ThaiLanguage.english:
      return 'en_US';
  }
}

/// Parts for building custom Thai date strings.
enum ThaiDatePart { day, month, year }

/// Global settings for defaults to make usage ergonomic.
class ThaiDateSettings {
  static Era defaultEra = Era.be;
  static String defaultLocale = 'th_TH';

  static void set({Era? era, String? locale, ThaiLanguage? language}) {
    if (era != null) defaultEra = era;
    if (language != null) {
      defaultLocale = _languageToLocale(language);
    } else if (locale != null && locale.isNotEmpty) {
      defaultLocale = locale;
    }
  }

  static void useThai() => defaultLocale = 'th_TH';
  static void useEnglishUS() => defaultLocale = 'en_US';

  /// Set any locale code directly, e.g. 'fr', 'ar', 'ja', 'zh', 'de'.
  static void useLocale(String localeCode) => defaultLocale = localeCode;
}

/// Formats a [DateTime] using the given [format] and [era].
/// - Era.be: output Thai Buddhist year (พ.ศ.), e.g., 2568
/// - Era.ce: output Gregorian year (ค.ศ.), e.g., 2025
/// Example: DateTime(2025,8,22) with format 'yyyy-MM-dd'
/// - era: Era.be => '2568-08-22'
/// - era: Era.ce => '2025-08-22'
String format(DateTime dt,
    {String format = 'yyyy-MM-dd', Era era = Era.be, String? locale}) {
  if (era == Era.ce) {
    return (locale == null || locale.isEmpty)
        ? DateFormat(format).format(dt)
        : DateFormat(format, locale).format(dt);
  }
  return _tokenAwareFormat(dt, format, locale: locale);
}

/// Token-aware formatter that replaces only the year tokens (y, yy, yyyy, etc.)
/// with the Buddhist Era year while leaving other numeric tokens intact.
String _tokenAwareFormat(DateTime dt, String pattern, {String? locale}) {
  final loc = locale ?? Intl.getCurrentLocale();
  final beYear = dt.year + 543;

  // Parse pattern, replace y+ runs outside quoted literals with placeholders
  final tokens = <String>[];
  final buf = StringBuffer();
  var i = 0;
  var inQuote = false;
  var tokenIndex = 0;
  while (i < pattern.length) {
    final c = pattern[i];
    if (c == "'") {
      // handle quote toggling
      inQuote = !inQuote;
      buf.write(c);
      i++;
      continue;
    }
    if (!inQuote && c == 'y') {
      // capture run of y's
      var j = i;
      while (j < pattern.length && pattern[j] == 'y') {
        j++;
      }
      final run = pattern.substring(i, j);
      final placeholder = '__BE_YEAR${tokenIndex}__';
      tokens.add(run);
      // wrap placeholder in single quotes so DateFormat treats it as a literal
      buf.write("'$placeholder'");
      tokenIndex++;
      i = j;
      continue;
    }
    buf.write(c);
    i++;
  }

  final modifiedPattern = buf.toString();
  final base = (locale == null || locale.isEmpty)
      ? DateFormat(modifiedPattern).format(dt)
      : DateFormat(modifiedPattern, loc).format(dt);

  // Replace placeholders with BE year formatted according to token length
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
      // for length >=3, use full BE year, pad if necessary
      repl = beYear.toString().padLeft(run.length, '0');
    }
    result = result.replaceFirst(placeholder, repl);
  }
  return result;
}

class ThaiCalendar {
  static const String _defaultLocale = 'th_TH';
  static final Map<String, Future<void>> _initFutures = {};

  /// Ensure date symbols for a locale are loaded. Defaults to Thai.
  static Future<void> ensureInitialized(
      [String? locale, ThaiLanguage? language]) {
    final loc = language != null
        ? _languageToLocale(language)
        : (locale?.isNotEmpty == true ? locale! : _defaultLocale);
    return _initFutures[loc] ??= initializeDateFormatting(loc);
  }

  static final Map<String, String Function(DateTime)> _formats = {
    // Explicit D MY (e.g., 25 สิงหาคม 2568) using current default locale
    'dmy': (d) {
      final loc = ThaiDateSettings.defaultLocale;
      final s = DateFormat('d MMMM yyyy', loc).format(d);
      return _replaceYearWithBE(s, d.year);
    },
    'fullText': (d) {
      final s = DateFormat.yMMMMEEEEd(ThaiDateSettings.defaultLocale).format(d);
      return _replaceYearWithBE(s, d.year);
    },
    'long': (d) {
      final s = DateFormat.yMMMMd(ThaiDateSettings.defaultLocale).format(d);
      return _replaceYearWithBE(s, d.year);
    },
    'slash': (d) => '${_pad2(d.day)}/${_pad2(d.month)}/${d.year + 543}',
    'dash': (d) => '${_pad2(d.day)}-${_pad2(d.month)}-${d.year + 543}',
    'iso': (d) =>
        '${(d.year + 543).toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}',
    'compact': (d) => _pad2(d.day) + _pad2(d.month) + (d.year + 543).toString(),
    'slashTime': (d) =>
        '${_pad2(d.day)}/${_pad2(d.month)}/${d.year + 543} ${_pad2(d.hour)}:${_pad2(d.minute)}',
    'isoTime': (d) =>
        '${(d.year + 543).toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}T${_pad2(d.hour)}:${_pad2(d.minute)}:${_pad2(d.second)}',
    'timeMs': (d) =>
        '${_pad2(d.hour)}:${_pad2(d.minute)}:${_pad2(d.second)}.${d.millisecond.toString().padLeft(3, '0')}',
  };

  static String _pad2(int n) => n.toString().padLeft(2, '0');
  static String _replaceYearWithBE(String s, int ceYear) {
    final be = (ceYear + 543).toString();
    final ce = ceYear.toString();
    return s.replaceAllMapped(
        RegExp(r'\d{4}'), (m) => m.group(0) == ce ? be : m.group(0)!);
  }

  static String format(
    DateTime date, {
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) {
    final loc = language != null
        ? _languageToLocale(language)
        : (locale?.isNotEmpty == true
            ? locale!
            : ThaiDateSettings.defaultLocale);
    if (_formats.containsKey(pattern)) {
      // For preset patterns, regenerate using locale
      String base;
      if (pattern == 'fullText') {
        base = DateFormat.yMMMMEEEEd(loc).format(date);
        base = _replaceYearWithBE(base, date.year);
      } else if (pattern == 'long') {
        base = DateFormat.yMMMMd(loc).format(date);
        base = _replaceYearWithBE(base, date.year);
      } else {
        base = _formats[pattern]!(date);
      }
      if (era == Era.ce) {
        // When CE requested for predefined Thai formats: regenerate without BE replacement
        if (pattern == 'fullText') {
          return DateFormat.yMMMMEEEEd(loc).format(date);
        } else if (pattern == 'long') {
          return DateFormat.yMMMMd(loc).format(date);
        } else if (pattern == 'dmy') {
          return DateFormat('d MMMM yyyy', loc).format(date);
        } else if (pattern == 'slash') {
          return '${_pad2(date.day)}/${_pad2(date.month)}/${date.year}';
        } else if (pattern == 'dash') {
          return '${_pad2(date.day)}-${_pad2(date.month)}-${date.year}';
        } else if (pattern == 'iso') {
          return '${date.year.toString().padLeft(4, '0')}-${_pad2(date.month)}-${_pad2(date.day)}';
        } else if (pattern == 'compact') {
          return _pad2(date.day) + _pad2(date.month) + date.year.toString();
        } else if (pattern == 'slashTime') {
          return '${_pad2(date.day)}/${_pad2(date.month)}/${date.year} ${_pad2(date.hour)}:${_pad2(date.minute)}';
        } else if (pattern == 'isoTime') {
          return '${date.year.toString().padLeft(4, '0')}-${_pad2(date.month)}-${_pad2(date.day)}T${_pad2(date.hour)}:${_pad2(date.minute)}:${_pad2(date.second)}';
        } else if (pattern == 'timeMs') {
          return '${_pad2(date.hour)}:${_pad2(date.minute)}:${_pad2(date.second)}.${date.millisecond.toString().padLeft(3, '0')}';
        }
      }
      return base;
    }
    final s = DateFormat(pattern, loc).format(date);
    return era == Era.be ? _replaceYearWithBE(s, date.year) : s;
  }

  /// Build a custom Thai date string from parts, with reordering or omission.
  ///
  /// Example:
  /// - Default (day, month, year): 25 สิงหาคม 2568
  /// - Swap to month, day: สิงหาคม 25
  /// - Omit year: 25 สิงหาคม
  static String formatThaiDateParts(
    DateTime date, {
    List<ThaiDatePart>? order,
    Era era = Era.be,
    String? locale,
    String separator = ' ',
    bool monthShort = false,
  }) {
    final loc =
        (locale?.isNotEmpty == true) ? locale! : ThaiDateSettings.defaultLocale;
    final effectiveOrder = order ??
        const [ThaiDatePart.day, ThaiDatePart.month, ThaiDatePart.year];
    final parts = <String>[];
    String day() => date.day.toString();
    String month() => DateFormat(monthShort ? 'MMM' : 'MMMM', loc).format(date);
    String year() => (era == Era.be ? date.year + 543 : date.year).toString();
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

  /// Convenience: format the current time (DateTime.now()) with the same options.
  static String formatNow({
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) {
    return format(DateTime.now(),
        pattern: pattern, era: era, locale: locale, language: language);
  }

  /// Format using an explicit [DateFormat] instance. This lets callers
  /// create DateFormat via constructors/skeletons (e.g. DateFormat.yMMMMd('th'))
  /// and pass it directly. The year tokens in the DateFormat's pattern will
  /// be replaced with BE years in a token-aware way.
  static String formatWith(DateFormat df, DateTime date, {Era era = Era.be}) {
    final pattern = df.pattern ?? '';
    // Use the df to format non-year parts by creating a modified pattern where
    // year tokens are wrapped as literals placeholders, then replace placeholders
    // with BE year according to token length.
    final loc = (df.locale.isEmpty) ? '' : df.locale;
    if (era == Era.ce) {
      return (loc.isEmpty)
          ? DateFormat(pattern).format(date)
          : DateFormat(pattern, loc).format(date);
    }
    return _tokenAwareFormat(date, pattern, locale: loc);
  }

  /// Parse using an explicit [DateFormat] instance. If the input contains a
  /// BE year (>=2400) it will be converted to CE in the returned DateTime.
  static DateTime? parseWith(DateFormat df, String input) {
    try {
      final dt = df.parseStrict(input);
      // if input contains BE year, adjust
      final hasBE = RegExp(r'(\d{4})').firstMatch(input)?.group(1);
      if (hasBE != null) {
        final y = int.tryParse(hasBE);
        if (y != null && y >= 2400) {
          return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute,
              dt.second, dt.millisecond, dt.microsecond);
        }
      }
      return dt;
    } catch (_) {
      return null;
    }
  }

  /// Convenience async wrapper that ensures locale data is initialized
  /// and then formats the date. Useful when you don't want to call
  /// `ensureInitialized()` manually.
  static Future<String> formatInitialized(
    DateTime date, {
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) async {
    await ensureInitialized(locale, language);
    return format(date,
        pattern: pattern, era: era, locale: locale, language: language);
  }

  /// Convenience: ensure locale data then format the current time.
  static Future<String> formatInitializedNow({
    String pattern = 'fullText',
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) async {
    await ensureInitialized(locale, language);
    return formatNow(
        pattern: pattern, era: era, locale: locale, language: language);
  }

  /// Synchronous format without relying on locale data. Only safe for
  /// numeric patterns (e.g., 'yyyy-MM-dd', 'dd/MM/yyyy'). Does not
  /// support localized month names.
  static String formatSync(
    DateTime date, {
    String pattern = 'yyyy-MM-dd',
    Era era = Era.be,
  }) {
    // For CE just format normally; for BE use token-aware without locale.
    if (era == Era.ce) {
      return DateFormat(pattern).format(date);
    }
    return _tokenAwareFormat(date, pattern, locale: '');
  }

  static DateTime? parse(String input,
      {String? customPattern, String? locale, ThaiLanguage? language}) {
    input = input.trim();
    final loc = language != null
        ? _languageToLocale(language)
        : (locale?.isNotEmpty == true
            ? locale!
            : ThaiDateSettings.defaultLocale);
    bool hasBEYear(String s) {
      final m = RegExp(r'(\d{4})').firstMatch(s);
      if (m == null) return false;
      final y = int.tryParse(m.group(1)!);
      return y != null && y >= 2400;
    }

    DateTime adjustIfBE(DateTime dt) {
      if (hasBEYear(input)) {
        return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute,
            dt.second, dt.millisecond, dt.microsecond);
      }
      return dt;
    }

    if (customPattern != null) {
      try {
        final dt = DateFormat(customPattern, loc).parseStrict(input);
        return adjustIfBE(dt);
      } catch (_) {
        return null;
      }
    }
    const patternsToTry = <String>[
      // full Thai month name with time
      'd MMMM yyyy HH:mm:ss.SSS',
      // short Thai month name
      'd MMM yyyy HH:mm:ss',
      // common separators
      'dd/MM/yyyy HH:mm',
      "yyyy-MM-dd'T'HH:mm:ss",
      // ISO with timezone offset
      "yyyy-MM-dd'T'HH:mm:ssZ",
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'yyyy-MM-dd',
      'd MMMM yyyy',
      'd MMM yyyy',
    ];
    for (final p in patternsToTry) {
      try {
        final dt = DateFormat(p, loc).parseStrict(input);
        return adjustIfBE(dt);
      } catch (_) {}
    }
    if (RegExp(r'^\d{8}$').hasMatch(input)) {
      try {
        final day = int.parse(input.substring(0, 2));
        final month = int.parse(input.substring(2, 4));
        final yearBE = int.parse(input.substring(4, 8));
        return DateTime(yearBE - 543, month, day);
      } catch (_) {
        return null;
      }
    }
    final hhmm = RegExp(r'^(\d{2})(\d{2})$');
    final m1 = hhmm.firstMatch(input);
    if (m1 != null) {
      try {
        final now = DateTime.now();
        final h = int.parse(m1.group(1)!);
        final m = int.parse(m1.group(2)!);
        return DateTime(now.year, now.month, now.day, h, m);
      } catch (_) {}
    }
    final hms = RegExp(r'^(\d{2}):(\d{2}):(\d{2})$');
    final m2 = hms.firstMatch(input);
    if (m2 != null) {
      try {
        final now = DateTime.now();
        final h = int.parse(m2.group(1)!);
        final m = int.parse(m2.group(2)!);
        final s = int.parse(m2.group(3)!);
        return DateTime(now.year, now.month, now.day, h, m, s);
      } catch (_) {}
    }
    return null;
  }

  /// Parse using an explicit era hint.
  ///
  /// If [era] is [Era.be], the parsed year is treated as Buddhist Era and
  /// converted to CE by subtracting 543 (regardless of its numeric value).
  /// Provide [pattern] for the input format (e.g., 'd MMMM yyyy').
  static DateTime? parseWithEra(
    String input, {
    required String pattern,
    Era era = Era.be,
    String? locale,
    ThaiLanguage? language,
  }) {
    input = input.trim();
    final loc = language != null
        ? _languageToLocale(language)
        : (locale?.isNotEmpty == true
            ? locale!
            : ThaiDateSettings.defaultLocale);
    try {
      final dt = DateFormat(pattern, loc).parseStrict(input);
      if (era == Era.be) {
        return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute,
            dt.second, dt.millisecond, dt.microsecond);
      }
      return dt;
    } catch (_) {
      return null;
    }
  }

  static String? convert(
    String input, {
    String toPattern = 'fullText',
    String? fromPattern,
    Era toEra = Era.be,
  }) {
    final dt = parse(input, customPattern: fromPattern);
    if (dt == null) return null;
    return format(dt, pattern: toPattern, era: toEra);
  }

  static bool isValid(String input, {String? pattern}) =>
      parse(input, customPattern: pattern) != null;
}

/// A simple formatter you can configure once and reuse.
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

  ThaiFormatter copyWith(
          {String? pattern,
          Era? era,
          String? locale,
          ThaiLanguage? language}) =>
      ThaiFormatter(
        pattern: pattern ?? this.pattern,
        era: era ?? this.era,
        locale: locale ?? this.locale,
        language: language ?? this.language,
      );

  String format(DateTime date) => formatDate(date);

  String formatDate(DateTime date) =>
      tbdFormat(date, pattern: pattern, era: era, locale: _resolveLocale());

  String _resolveLocale() {
    if (language != null) return _languageToLocale(language!);
    return (locale?.isNotEmpty == true)
        ? locale!
        : ThaiDateSettings.defaultLocale;
  }
}

// Internal alias to avoid shadowing the top-level function name inside class methods.
String tbdFormat(DateTime dt,
        {required String pattern, required Era era, String? locale}) =>
    format(dt, format: pattern, era: era, locale: locale);

/// DateTime extensions for ergonomic usage.
extension ThaiDateTimeFormatting on DateTime {
  String toThaiString(
      {String pattern = 'yyyy-MM-dd',
      Era? era,
      String? locale,
      ThaiLanguage? language}) {
    final resolvedLocale = language != null
        ? _languageToLocale(language)
        : (locale?.isNotEmpty == true
            ? locale!
            : ThaiDateSettings.defaultLocale);
    return format(this,
        format: pattern,
        era: era ?? ThaiDateSettings.defaultEra,
        locale: resolvedLocale);
  }
}

/// String parsing extensions.
extension ThaiStringParsing on String {
  DateTime? toThaiDate(
      {String? pattern, String? locale, ThaiLanguage? language}) {
    return ThaiCalendar.parse(this,
        customPattern: pattern, locale: locale, language: language);
  }
}

/// Common locale codes for convenience.
/// Use with ThaiDateSettings.useLocale(...) or pass as `locale:` to APIs.
class TbdLocales {
  static const th = 'th_TH';
  static const en = 'en_US';
  static const sq = 'sq'; // Albanian
  static const ar = 'ar'; // Arabic
  static const hy = 'hy'; // Armenian
  static const az = 'az'; // Azerbaijani
  static const eu = 'eu'; // Basque
  static const bn = 'bn'; // Bengali
  static const bg = 'bg'; // Bulgarian
  static const ca = 'ca'; // Catalan
  static const zh = 'zh'; // Chinese (generic)
  static const da = 'da'; // Danish
  static const nl = 'nl'; // Dutch
  static const fr = 'fr'; // French
  static const de = 'de'; // German
  static const he = 'he'; // Hebrew
  static const id = 'id'; // Indonesian
  static const it = 'it'; // Italian
  static const ja = 'ja'; // Japanese
  static const kk = 'kk'; // Kazakh
  static const ko = 'ko'; // Korean
  static const fa = 'fa'; // Persian
  static const pl = 'pl'; // Polish
  static const pt = 'pt'; // Portuguese
  static const ru = 'ru'; // Russian
  static const es = 'es'; // Spanish
  static const sv = 'sv'; // Swedish
  static const tr = 'tr'; // Turkish
  static const vi = 'vi'; // Vietnamese
  static const km = 'km'; // Khmer
  static const hi = 'hi'; // Hindi (India)
}
