import '../services/cache_service.dart';
import '../../domain/entities/thai_date.dart';
import '../../domain/value_objects/thai_date_config.dart';
import '../../domain/value_objects/thai_date_pattern.dart';
import '../../domain/repositories/date_repository.dart';

/// Use case for formatting Thai dates with caching for performance
class FormatThaiDateUseCase {
  const FormatThaiDateUseCase({
    required IDateFormatterRepository formatterRepository,
    required CacheService cacheService,
  })  : _formatterRepository = formatterRepository,
        _cacheService = cacheService;

  final IDateFormatterRepository _formatterRepository;
  final CacheService _cacheService;

  /// Execute format operation with caching
  Future<String> execute({
    required ThaiDate date,
    required String patternKey,
    required ThaiDateConfig config,
  }) async {
    final pattern = ThaiDatePattern.get(patternKey);
    final cacheKey = _buildCacheKey(date, pattern, config);

    // Check cache first for performance
    final cached = _cacheService.get<String>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Ensure locale is initialized
    if (!_formatterRepository.isLocaleInitialized(config.locale)) {
      await _formatterRepository.initializeLocale(config.locale);
    }

    // Format and cache result
    final result = await _formatterRepository.format(date, pattern, config);
    _cacheService.set(cacheKey, result);

    return result;
  }

  /// Execute synchronous format (for simple patterns)
  String executeSync({
    required ThaiDate date,
    required String patternKey,
    required ThaiDateConfig config,
  }) {
    final pattern = ThaiDatePattern.get(patternKey);
    final cacheKey = _buildCacheKey(date, pattern, config);

    // Check cache first
    final cached = _cacheService.get<String>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Format and cache
    final result = _formatterRepository.formatSync(date, pattern, config);
    _cacheService.set(cacheKey, result);

    return result;
  }

  /// Format current date/time
  Future<String> executeNow({
    required String patternKey,
    required ThaiDateConfig config,
  }) async {
    final now = ThaiDate.now(era: config.era);
    return execute(date: now, patternKey: patternKey, config: config);
  }

  String _buildCacheKey(
      ThaiDate date, ThaiDatePattern pattern, ThaiDateConfig config) {
    return '${date.hashCode}_${pattern.pattern}_${config.hashCode}';
  }
}
