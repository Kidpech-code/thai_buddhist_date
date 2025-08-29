import '../application/services/cache_service.dart';
import '../application/use_cases/format_thai_date_use_case.dart';
import '../application/use_cases/parse_thai_date_use_case.dart';
import '../infrastructure/intl_date_formatter_repository.dart';
import '../infrastructure/intl_date_parser_repository.dart';
import '../domain/entities/thai_date.dart';
import '../domain/value_objects/thai_date_config.dart';
import '../domain/value_objects/era.dart';
import '../domain/value_objects/locale_config.dart';

/// High-performance facade for Thai Buddhist date operations
/// Implements dependency injection and provides clean API
class ThaiDateService {
  factory ThaiDateService() => _instance ??= ThaiDateService._internal();

  ThaiDateService._internal()
      : _cacheService = CacheService(),
        _formatterRepository = IntlDateFormatterRepository(),
        _parserRepository = IntlDateParserRepository() {
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

  final CacheService _cacheService;
  final IntlDateFormatterRepository _formatterRepository;
  final IntlDateParserRepository _parserRepository;

  late final FormatThaiDateUseCase _formatUseCase;
  late final ParseThaiDateUseCase _parseUseCase;

  // Current configuration
  ThaiDateConfig _config = ThaiDateConfig.defaultConfig;

  /// Get current configuration
  ThaiDateConfig get config => _config;

  /// Update global configuration
  void updateConfig(ThaiDateConfig newConfig) {
    if (newConfig.isValid) {
      _config = newConfig;
    }
  }

  /// Set era globally
  void setEra(Era era) {
    _config = _config.copyWith(era: era);
  }

  /// Set locale globally
  void setLocale(String locale) {
    if (SupportedLocales.isSupported(locale)) {
      _config = _config.copyWith(locale: locale);
    }
  }

  /// Set language globally
  void setLanguage(ThaiLanguage language) {
    _config = _config.copyWith(
      language: language,
      locale: language.localeCode,
    );
  }

  /// Format date with current configuration
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

  /// Format current date/time
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

  /// Format synchronously (for simple patterns)
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

  /// Parse date string
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

  /// Parse with explicit era
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

  /// Validate date string
  bool isValid(String input, {String? pattern}) {
    return _parseUseCase.isValid(
      input: input,
      patternKey: pattern,
      config: _config,
    );
  }

  /// Initialize locale for formatting
  Future<void> initializeLocale([String? locale]) async {
    final targetLocale = locale ?? _config.locale;
    await _formatterRepository.initializeLocale(targetLocale);
  }

  /// Get cache statistics
  String getCacheStats() {
    return _cacheService.stats.toString();
  }

  /// Clear cache
  void clearCache() {
    _cacheService.clear();
  }

  /// Reset to default configuration
  void reset() {
    _config = ThaiDateConfig.defaultConfig;
    clearCache();
  }

  ThaiDateConfig _buildEffectiveConfig({Era? era, String? locale}) {
    ThaiDateConfig effectiveConfig = _config;

    if (era != null) {
      effectiveConfig = effectiveConfig.copyWith(era: era);
    }

    if (locale != null && SupportedLocales.isSupported(locale)) {
      effectiveConfig = effectiveConfig.copyWith(locale: locale);
    }

    return effectiveConfig;
  }
}
