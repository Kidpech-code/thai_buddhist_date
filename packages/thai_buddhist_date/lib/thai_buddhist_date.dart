library thai_buddhist_date;

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
      return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond, dt.microsecond);
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
    final attempted = input.replaceFirst(m.group(0)!, normalizedYear.toString());
    try {
      return DateFormat(format).parseStrict(attempted);
    } catch (e) {
      throw FormatException('Unrecognized date format after normalization: $attempted');
    }
  }
}

/// Formats a [DateTime] to Thai Buddhist year (พ.ศ.) string using [format].
/// Example: DateTime(2025,8,22) with format 'yyyy-MM-dd' => '2568-08-22'
String format(DateTime dt, {String format = 'yyyy-MM-dd'}) {
  return _tokenAwareFormat(dt, format);
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
      while (j < pattern.length && pattern[j] == 'y') j++;
      final run = pattern.substring(i, j);
      final placeholder = '__BE_YEAR${tokenIndex}__';
      tokens.add(run);
      // wrap placeholder in single quotes so DateFormat treats it as a literal
      buf.write("'${placeholder}'");
      tokenIndex++;
      i = j;
      continue;
    }
    buf.write(c);
    i++;
  }

  final modifiedPattern = buf.toString();
  final base = (locale == null || locale.isEmpty) ? DateFormat(modifiedPattern).format(dt) : DateFormat(modifiedPattern, loc).format(dt);

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
  static const String _locale = 'th_TH';
  static Future<void>? _initFuture;
  static Future<void> ensureInitialized() {
    return _initFuture ??= initializeDateFormatting(_locale);
  }

  static final Map<String, String Function(DateTime)> _formats = {
    'fullText': (d) {
      final s = DateFormat.yMMMMEEEEd(_locale).format(d);
      return _replaceYearWithBE(s, d.year);
    },
    'long': (d) {
      final s = DateFormat.yMMMMd(_locale).format(d);
      return _replaceYearWithBE(s, d.year);
    },
    'slash': (d) => '${_pad2(d.day)}/${_pad2(d.month)}/${d.year + 543}',
    'dash': (d) => '${_pad2(d.day)}-${_pad2(d.month)}-${d.year + 543}',
    'iso': (d) => '${(d.year + 543).toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}',
    'compact': (d) => _pad2(d.day) + _pad2(d.month) + (d.year + 543).toString(),
    'slashTime': (d) => '${_pad2(d.day)}/${_pad2(d.month)}/${d.year + 543} ${_pad2(d.hour)}:${_pad2(d.minute)}',
    'isoTime': (d) =>
        '${(d.year + 543).toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}T${_pad2(d.hour)}:${_pad2(d.minute)}:${_pad2(d.second)}',
    'timeMs': (d) => '${_pad2(d.hour)}:${_pad2(d.minute)}:${_pad2(d.second)}.${d.millisecond.toString().padLeft(3, '0')}',
  };

  static String _pad2(int n) => n.toString().padLeft(2, '0');
  static String _replaceYearWithBE(String s, int ceYear) {
    final be = (ceYear + 543).toString();
    final ce = ceYear.toString();
    return s.replaceAllMapped(RegExp(r'\d{4}'), (m) => m.group(0) == ce ? be : m.group(0)!);
  }

  static String format(DateTime date, {String pattern = 'fullText'}) {
    if (_formats.containsKey(pattern)) {
      return _formats[pattern]!(date);
    }
    final s = DateFormat(pattern, _locale).format(date);
    return _replaceYearWithBE(s, date.year);
  }

  /// Format using an explicit [DateFormat] instance. This lets callers
  /// create DateFormat via constructors/skeletons (e.g. DateFormat.yMMMMd('th'))
  /// and pass it directly. The year tokens in the DateFormat's pattern will
  /// be replaced with BE years in a token-aware way.
  static String formatWith(DateFormat df, DateTime date) {
    final pattern = df.pattern ?? '';
    // Use the df to format non-year parts by creating a modified pattern where
    // year tokens are wrapped as literals placeholders, then replace placeholders
    // with BE year according to token length.
    final loc = (df.locale.isEmpty) ? '' : df.locale;
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
          return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond, dt.microsecond);
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
  static Future<String> formatInitialized(DateTime date, {String pattern = 'fullText'}) async {
    await ensureInitialized();
    return format(date, pattern: pattern);
  }

  /// Synchronous format without relying on locale data. Only safe for
  /// numeric patterns (e.g., 'yyyy-MM-dd', 'dd/MM/yyyy'). Does not
  /// support localized month names.
  static String formatSync(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    // Use token-aware formatter without locale to avoid locale init.
    return _tokenAwareFormat(date, pattern, locale: '');
  }

  static DateTime? parse(String input, {String? customPattern}) {
    input = input.trim();
    bool hasBEYear(String s) {
      final m = RegExp(r'(\d{4})').firstMatch(s);
      if (m == null) return false;
      final y = int.tryParse(m.group(1)!);
      return y != null && y >= 2400;
    }

    DateTime adjustIfBE(DateTime dt) {
      if (hasBEYear(input)) {
        return DateTime(dt.year - 543, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond, dt.microsecond);
      }
      return dt;
    }

    if (customPattern != null) {
      try {
        final dt = DateFormat(customPattern, _locale).parseStrict(input);
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
        final dt = DateFormat(p, _locale).parseStrict(input);
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

  static String? convert(String input, {String toPattern = 'fullText', String? fromPattern}) {
    final dt = parse(input, customPattern: fromPattern);
    if (dt == null) return null;
    return format(dt, pattern: toPattern);
  }

  static bool isValid(String input, {String? pattern}) => parse(input, customPattern: pattern) != null;
}
