import '../services/cache_service.dart';
import '../../domain/entities/thai_date.dart';
import '../../domain/value_objects/thai_date_config.dart';
import '../../domain/value_objects/thai_date_pattern.dart';
import '../../domain/value_objects/era.dart';
import '../../domain/repositories/date_repository.dart';

/// Use case for parsing Thai date strings with intelligent era detection
class ParseThaiDateUseCase {
  const ParseThaiDateUseCase({
    required IDateParserRepository parserRepository,
    required CacheService cacheService,
  })  : _parserRepository = parserRepository,
        _cacheService = cacheService;

  final IDateParserRepository _parserRepository;
  final CacheService _cacheService;

  /// Parse date string with intelligent era detection
  ThaiDate? execute({
    required String input,
    String? patternKey,
    ThaiDateConfig? config,
  }) {
    final normalizedInput = input.trim();
    if (normalizedInput.isEmpty) return null;

    final effectiveConfig = config ?? ThaiDateConfig.defaultConfig;
    final cacheKey =
        _buildCacheKey(normalizedInput, patternKey, effectiveConfig);

    // Check cache first
    final cached = _cacheService.get<ThaiDate>(cacheKey);
    if (cached != null) {
      return cached;
    }

    ThaiDate? result;

    if (patternKey != null) {
      // Use specific pattern
      final pattern = ThaiDatePattern.get(patternKey);
      result =
          _parserRepository.parse(normalizedInput, pattern, effectiveConfig);
    } else {
      // Try intelligent parsing with era detection
      result = _parseWithEraDetection(normalizedInput, effectiveConfig);
    }

    // Cache successful results
    if (result != null) {
      _cacheService.set(cacheKey, result);
    }

    return result;
  }

  /// Parse with explicit era hint
  ThaiDate? executeWithEra({
    required String input,
    required String patternKey,
    required Era era,
    ThaiDateConfig? config,
  }) {
    final normalizedInput = input.trim();
    if (normalizedInput.isEmpty) return null;

    final effectiveConfig =
        (config ?? ThaiDateConfig.defaultConfig).copyWith(era: era);
    final pattern = ThaiDatePattern.get(patternKey);

    final cacheKey =
        _buildCacheKey(normalizedInput, patternKey, effectiveConfig);

    // Check cache
    final cached = _cacheService.get<ThaiDate>(cacheKey);
    if (cached != null) {
      return cached;
    }

    final result = _parserRepository.parseWithEra(
        normalizedInput, pattern, effectiveConfig);

    if (result != null) {
      _cacheService.set(cacheKey, result);
    }

    return result;
  }

  /// Validate date string
  bool isValid({
    required String input,
    String? patternKey,
    ThaiDateConfig? config,
  }) {
    final result =
        execute(input: input, patternKey: patternKey, config: config);
    return result != null;
  }

  /// Convert between patterns
  String? convert({
    required String input,
    required String fromPatternKey,
    required String toPatternKey,
    Era? toEra,
    ThaiDateConfig? config,
  }) {
    final parsedDate = execute(
      input: input,
      patternKey: fromPatternKey,
      config: config,
    );

    if (parsedDate == null) return null;

    // This would need the format use case - simplified for now
    // In real implementation, inject FormatThaiDateUseCase
    return null; // Placeholder
  }

  ThaiDate? _parseWithEraDetection(String input, ThaiDateConfig config) {
    // Extract potential year from input
    final yearMatch = RegExp(r'(\d{4})').firstMatch(input);
    if (yearMatch != null) {
      final year = int.tryParse(yearMatch.group(1)!);
      if (year != null) {
        // Determine likely era based on year value
        final detectedEra = Era.be.isLikelyYear(year) ? Era.be : Era.ce;
        final adjustedConfig = config.copyWith(era: detectedEra);

        // Try common patterns
        for (final patternKey in ['iso', 'slash', 'dash', 'dmy']) {
          final pattern = ThaiDatePattern.get(patternKey);
          final result =
              _parserRepository.parse(input, pattern, adjustedConfig);
          if (result != null) {
            return result;
          }
        }
      }
    }

    return null;
  }

  String _buildCacheKey(String input, String? pattern, ThaiDateConfig config) {
    return '${input}_${pattern ?? 'auto'}_${config.hashCode}';
  }
}
