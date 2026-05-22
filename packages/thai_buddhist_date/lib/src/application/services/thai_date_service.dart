import 'cache_service.dart';
import '../use_cases/format_thai_date_use_case.dart';
import '../use_cases/parse_thai_date_use_case.dart';
import '../../infrastructure/intl_date_formatter_repository.dart';
import '../../infrastructure/intl_date_parser_repository.dart';
import '../../domain/entities/thai_date.dart';
import '../../domain/value_objects/thai_date_config.dart';
import '../../domain/value_objects/era.dart';
import '../../domain/value_objects/locale_config.dart';
import '../../domain/repositories/i_date_formatter_repository.dart';
import '../../domain/repositories/i_date_parser_repository.dart';

/// Application service that orchestrates Thai Buddhist date operations.
///
/// Provides a high-level, ergonomic API over the domain use cases and
/// handles dependency wiring.
///
/// **Usage:**
/// ```dart
/// // Global singleton
/// final svc = ThaiDateService();
///
/// // Isolated instance for testing / custom DI
/// final svc = ThaiDateService.create(
///   formatterRepository: MyCustomFormatter(),
/// );
/// ```
class ThaiDateService {
  /// Returns the global singleton instance.
  factory ThaiDateService() => _instance ??= ThaiDateService._(
        formatterRepository: IntlDateFormatterRepository(),
        parserRepository: IntlDateParserRepository(),
        cacheService: CacheService(),
      );

  /// Creates an isolated instance with injectable dependencies.
  ///
  /// Any omitted dependency falls back to the default [intl]-based
  /// implementation. Use this factory in tests to inject mocks.
  factory ThaiDateService.create({
    IDateFormatterRepository? formatterRepository,
    IDateParserRepository? parserRepository,
    CacheService? cacheService,
  }) =>
      ThaiDateService._(
        formatterRepository:
            formatterRepository ?? IntlDateFormatterRepository(),
        parserRepository: parserRepository ?? IntlDateParserRepository(),
        cacheService: cacheService ?? CacheService(),
      );

  ThaiDateService._({
    required IDateFormatterRepository formatterRepository,
    required IDateParserRepository parserRepository,
    required CacheService cacheService,
  })  : _formatterRepository = formatterRepository,
        _parserRepository = parserRepository,
        _cacheService = cacheService {
    _formatUseCase = FormatThaiDateUseCase(
      formatterRepository: _formatterRepository,
      cacheService: _cacheService,
    );
    _parseUseCase = ParseThaiDateUseCase(
      parserRepository: _parserRepository,
      cacheService: _cacheService,
    );
  }

  static ThaiDateService? _instance;

  final IDateFormatterRepository _formatterRepository;
  final IDateParserRepository _parserRepository;
  final CacheService _cacheService;

  late final FormatThaiDateUseCase _formatUseCase;
  late final ParseThaiDateUseCase _parseUseCase;

  ThaiDateConfig _config = ThaiDateConfig.defaultConfig;

  /// The active configuration used as the default for all operations.
  ThaiDateConfig get config => _config;

  /// Resets the singleton instance.
  ///
  /// **For testing only.** The next call to [ThaiDateService()] will create a
  /// fresh instance with the default configuration.
  static void resetInstance() => _instance = null;

  /// Replaces the active configuration.
  void updateConfig(ThaiDateConfig newConfig) {
    if (newConfig.isValid) {
      _config = newConfig;
    }
  }

  /// Sets the default era.
  void setEra(Era era) {
    _config = _config.copyWith(era: era);
  }

  /// Sets the default locale.
  ///
  /// No-op when [locale] is not in [SupportedLocales.all].
  void setLocale(String locale) {
    if (SupportedLocales.isSupported(locale)) {
      _config = _config.copyWith(locale: locale);
    }
  }

  /// Sets the default language (also updates the locale accordingly).
  void setLanguage(ThaiLanguage language) {
    _config = _config.copyWith(
      language: language,
      locale: language.localeCode,
    );
  }

  /// Formats [date] with an optional [pattern], [era] and [locale] override.
  Future<String> format(
    ThaiDate date, {
    String pattern = 'fullText',
    Era? era,
    String? locale,
  }) async {
    final effectiveConfig = _buildEffectiveConfig(era: era, locale: locale);
    return _formatUseCase.execute(
      date: date,
      patternKey: pattern,
      config: effectiveConfig,
    );
  }

  /// Formats the current date/time.
  Future<String> formatNow({
    String pattern = 'fullText',
    Era? era,
    String? locale,
  }) async {
    final effectiveConfig = _buildEffectiveConfig(era: era, locale: locale);
    return _formatUseCase.executeNow(
      patternKey: pattern,
      config: effectiveConfig,
    );
  }

  /// Formats [date] synchronously (suitable for numeric-only patterns).
  String formatSync(
    ThaiDate date, {
    String pattern = 'iso',
    Era? era,
    String? locale,
  }) {
    final effectiveConfig = _buildEffectiveConfig(era: era, locale: locale);
    return _formatUseCase.executeSync(
      date: date,
      patternKey: pattern,
      config: effectiveConfig,
    );
  }

  /// Parses [input] into a [ThaiDate], or returns `null` on failure.
  ThaiDate? parse(
    String input, {
    String? pattern,
    Era? era,
    String? locale,
  }) {
    final effectiveConfig = _buildEffectiveConfig(era: era, locale: locale);
    return _parseUseCase.execute(
      input: input,
      patternKey: pattern,
      config: effectiveConfig,
    );
  }

  /// Parses [input] with an explicit era hint.
  ThaiDate? parseWithEra(
    String input, {
    required String pattern,
    required Era era,
    String? locale,
  }) {
    final effectiveConfig = _buildEffectiveConfig(era: era, locale: locale);
    return _parseUseCase.executeWithEra(
      input: input,
      patternKey: pattern,
      era: era,
      config: effectiveConfig,
    );
  }

  /// Returns `true` if [input] can be parsed as a valid date.
  bool isValid(String input, {String? pattern}) {
    return _parseUseCase.isValid(
      input: input,
      patternKey: pattern,
      config: _config,
    );
  }

  /// Ensures locale data is ready for formatted output.
  Future<void> initializeLocale([String? locale]) async {
    final targetLocale = locale ?? _config.locale;
    await _formatterRepository.initializeLocale(targetLocale);
  }

  /// Returns a human-readable summary of cache statistics.
  String getCacheStats() => _cacheService.stats.toString();

  /// Clears the format/parse result cache.
  void clearCache() => _cacheService.clear();

  /// Resets configuration to defaults and clears the cache.
  void reset() {
    _config = ThaiDateConfig.defaultConfig;
    clearCache();
  }

  ThaiDateConfig _buildEffectiveConfig({Era? era, String? locale}) {
    var effectiveConfig = _config;
    if (era != null) effectiveConfig = effectiveConfig.copyWith(era: era);
    if (locale != null && SupportedLocales.isSupported(locale)) {
      effectiveConfig = effectiveConfig.copyWith(locale: locale);
    }
    return effectiveConfig;
  }
}
