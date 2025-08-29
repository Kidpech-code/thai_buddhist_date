// ignore_for_file: avoid_print
// example/main.dart
//
// Comprehensive examples of the Clean Architecture Thai Buddhist Date library
// Demonstrates both the new Clean Architecture API and backward compatibility

import 'package:thai_buddhist_date/thai_buddhist_date.dart';

void main() async {
  // Initialize the service
  print('=== Thai Buddhist Date Library - Clean Architecture Edition ===');
  print('Version: $version');
  print('Architecture: $architectureType');
  print('');

  await demonstrateBasicUsage();
  await demonstrateExtensions();
  await demonstrateAdvancedFeatures();
  await demonstrateBackwardCompatibility();
  await demonstratePerformance();
}

/// Basic usage examples with the new Clean Architecture API
Future<void> demonstrateBasicUsage() async {
  print('=== Basic Usage Examples ===');

  // Create Thai dates
  final now = ThaiDate.now();
  final specificDate = ThaiDate(year: 2567, month: 8, day: 22, era: Era.be);
  final fromDateTime = ThaiDate.fromDateTime(DateTime(2024, 8, 22));

  print('Current Thai date (BE): $now');
  print('Specific date: $specificDate');
  print('From DateTime: $fromDateTime');

  // Format dates
  final service = ThaiDateService();

  final fullText = await service.format(now, pattern: 'fullText');
  final shortDate = await service.format(now, pattern: 'shortDate');
  final isoFormat = service.formatSync(now, pattern: 'iso');

  print('Full text format: $fullText');
  print('Short date format: $shortDate');
  print('ISO format (sync): $isoFormat');

  // Parse dates
  final parsed = service.parse('2567-08-22', pattern: 'yyyy-MM-dd');
  print('Parsed date: $parsed');

  // Convert between eras
  print('BE to CE: ${Era.be.toCE(2567)} (should be 2024)');
  print('CE to BE: ${Era.be.fromCE(2024)} (should be 2567)');

  print('');
}

/// Demonstrate extension methods for ergonomic usage
Future<void> demonstrateExtensions() async {
  print('=== Extension Methods Examples ===');

  // DateTime extensions
  final dateTime = DateTime(2024, 8, 22);
  final thaiString = await dateTime.toThaiString();
  final thaiStringSync = dateTime.toThaiStringSync();
  final beYear = dateTime.beYear;

  print('DateTime to Thai string: $thaiString');
  print('DateTime to Thai string (sync): $thaiStringSync');
  print('BE year from DateTime: $beYear');

  // String extensions
  const dateString = '2567-08-22';
  final parsedFromString = await dateString.parseThaiDate();
  final isValid = await dateString.isValidThaiDate();
  final backToDateTime = await dateString.toDateTime();

  print('Parse from string: $parsedFromString');
  print('Is valid Thai date: $isValid');
  print('String to DateTime: $backToDateTime');

  // Int extensions
  const ceYear = 2024;
  final converted = ceYear.toBE;
  final isValidBE = 2567.isValidBE;
  final isValidCE = 2024.isValidCE;

  print('CE $ceYear to BE: $converted');
  print('2567 is valid BE: $isValidBE');
  print('2024 is valid CE: $isValidCE');

  print('');
}

/// Advanced features demonstration
Future<void> demonstrateAdvancedFeatures() async {
  print('=== Advanced Features ===');

  final service = ThaiDateService();

  // Configuration management
  print('Current config: ${service.config}');

  service.setEra(Era.be);
  service.setLanguage(ThaiLanguage.thai);
  print('Updated config: ${service.config}');

  // Multiple locale support
  final thaiDate = ThaiDate.now();
  final thaiFormat = await service.format(thaiDate, locale: 'th-TH');
  final englishFormat = await service.format(thaiDate, locale: 'en-US');

  print('Thai locale format: $thaiFormat');
  print('English locale format: $englishFormat');

  // Different patterns
  final patterns = ['fullText', 'shortDate', 'longDate', 'iso', 'custom'];
  for (final pattern in patterns) {
    try {
      final formatted = await service.format(thaiDate, pattern: pattern);
      print('Pattern "$pattern": $formatted');
    } catch (e) {
      final fallback = service.formatSync(thaiDate, pattern: 'iso');
      print('Pattern "$pattern": $fallback (fallback)');
    }
  }

  print('');
}

/// Backward compatibility demonstration
Future<void> demonstrateBackwardCompatibility() async {
  print('=== Backward Compatibility ===');

  // Legacy parse function
  final legacyParsed1 = parse('2567-08-22'); // BE year
  final legacyParsed2 = parse('2024-08-22'); // CE year

  print('Legacy parse (BE): $legacyParsed1');
  print('Legacy parse (CE): $legacyParsed2');

  // Legacy format functions
  final dateTime = DateTime(2024, 8, 22);
  final legacyFormatted = format(dateTime, era: Era.be, pattern: 'fullText');
  final legacyNow = formatNow(era: Era.be, language: ThaiLanguage.thai);

  print('Legacy format: $legacyFormatted');
  print('Legacy formatNow: $legacyNow');

  // Convenience functions
  final quickFormat = await formatDateTime(dateTime);
  final quickParse = parseThaiDate('2567-08-22');

  print('Quick format: $quickFormat');
  print('Quick parse: $quickParse');

  print('');
}

/// Performance demonstration
Future<void> demonstratePerformance() async {
  print('=== Performance Demonstration ===');

  final service = ThaiDateService();
  final testDate = ThaiDate.now();

  // Measure formatting performance
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < 1000; i++) {
    service.formatSync(testDate, pattern: 'iso');
  }

  stopwatch.stop();
  print('1000 synchronous formats took: ${stopwatch.elapsedMilliseconds}ms');

  for (int i = 0; i < 100; i++) {
    await service.format(testDate, pattern: 'fullText');
  }

  stopwatch.stop();
  print('100 async formats took: ${stopwatch.elapsedMilliseconds}ms');

  // Measure parsing performance
  const testInput = '2567-08-22';

  for (int i = 0; i < 1000; i++) {
    service.parse(testInput, pattern: 'yyyy-MM-dd');
  }

  stopwatch.stop();
  print('1000 parses took: ${stopwatch.elapsedMilliseconds}ms');

  // Demonstrate caching benefits
// Access internal cache through configuration

  print('Cache is working transparently to improve performance');
  print('Repeated operations with same parameters will be faster');

  print('');
  print('=== Demo Complete ===');
  print(
      'The Clean Architecture provides better maintainability, testability, and performance!');
}
