import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../domain/entities/thai_date.dart';
import '../domain/value_objects/thai_date_config.dart';
import '../domain/value_objects/thai_date_pattern.dart';
import '../domain/repositories/i_date_formatter_repository.dart';
import '../domain/value_objects/locale_config.dart';
import 'token_aware_date_formatter.dart';

/// [intl]-based implementation of [IDateFormatterRepository].
///
/// Locale initialisation state is instance-level so that isolated instances
/// (e.g. in tests) do not share state.
class IntlDateFormatterRepository implements IDateFormatterRepository {
  IntlDateFormatterRepository({
    String fallbackLocale = SupportedLocales.thai,
  }) : _fallbackLocale = fallbackLocale;

  final Map<String, Future<void>> _localeInitFutures = {};
  final Set<String> _initializedLocales = {};
  final Map<String, String> _resolvedLocales = {};
  String _fallbackLocale;

  /// Changes the locale used when `intl` rejects a requested locale.
  void setFallbackLocale(String locale) {
    final normalized = _normalizeLocale(locale);
    if (_fallbackLocale == normalized) return;
    _fallbackLocale = normalized;
    _localeInitFutures.clear();
    _initializedLocales.clear();
    _resolvedLocales.clear();
  }

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
      final workingDate =
          config.era == date.era ? date : date.toEra(config.era);
      return _formatTokenAware(workingDate, pattern, config.locale);
    } catch (e) {
      // If locale isn't initialized, fall back to basic string formatting
      final workingDate =
          config.era == date.era ? date : date.toEra(config.era);
      return _formatBasic(workingDate, pattern.pattern);
    }
  }

  @override
  Future<void> initializeLocale(String locale) async {
    final normalizedLocale = _normalizeLocale(locale);
    if (_initializedLocales.contains(normalizedLocale)) {
      return;
    }

    _localeInitFutures[normalizedLocale] ??=
        _doInitializeLocale(normalizedLocale);
    await _localeInitFutures[normalizedLocale]!;
  }

  @override
  bool isLocaleInitialized(String locale) {
    return _initializedLocales.contains(_normalizeLocale(locale));
  }

  Future<void> _doInitializeLocale(String locale) async {
    try {
      await initializeDateFormatting(locale);
      DateFormat('MMMM', locale).format(DateTime(2025, 8, 1));
      _resolvedLocales[locale] = locale;
      _initializedLocales.add(locale);
    } catch (_) {
      final fallbackLocale = _normalizeLocale(_fallbackLocale);
      await initializeDateFormatting(fallbackLocale);
      try {
        DateFormat('MMMM', fallbackLocale).format(DateTime(2025, 8, 1));
        _resolvedLocales[locale] = fallbackLocale;
      } on Object {
        const safeFallback = SupportedLocales.thai;
        await initializeDateFormatting(safeFallback);
        _resolvedLocales[locale] = safeFallback;
      }
      _initializedLocales.add(locale);
    }
  }

  String _formatDirect(
      ThaiDate date, ThaiDatePattern pattern, ThaiDateConfig config) {
    return _formatTokenAware(date, pattern, config.locale);
  }

  String _formatTokenAware(
      ThaiDate date, ThaiDatePattern pattern, String locale) {
    final resolvedLocale = _resolvedLocales[_normalizeLocale(locale)] ?? locale;
    return formatDateWithYearOverride(
      date.toDateTime(),
      pattern.pattern,
      outputYear: date.year,
      locale: resolvedLocale,
    );
  }

  String _normalizeLocale(String locale) {
    final trimmed = locale.trim();
    return trimmed.isEmpty
        ? SupportedLocales.defaultLocale
        : Intl.canonicalizedLocale(trimmed);
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
