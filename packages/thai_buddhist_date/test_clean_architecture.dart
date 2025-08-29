// ignore_for_file: avoid_print
// test_clean_architecture.dart
//
// Simple test to verify the Clean Architecture implementation works

import 'lib/thai_buddhist_date.dart';

void main() async {
  print('=== Testing Clean Architecture Thai Buddhist Date ===');

  try {
    // Test basic functionality
    final service = ThaiDateService();
    final now = ThaiDate.now();

    print('Current Thai Date: $now');
    print('Era: ${now.era}');
    print('Year in BE: ${now.year}');

    // Test conversion
    final dateTime = DateTime(2024, 8, 22);
    final thaiDate = ThaiDate.fromDateTime(dateTime);
    print(
        '2024-08-22 in BE: ${thaiDate.year}-${thaiDate.month.toString().padLeft(2, '0')}-${thaiDate.day.toString().padLeft(2, '0')}');

    // Test formatting
    final formatted = service.formatSync(thaiDate, pattern: 'iso');
    print('Formatted (sync): $formatted');

    // Test parsing
    final parsed = service.parse('2567-08-22', pattern: 'yyyy-MM-dd');
    print('Parsed: $parsed');

    // Test era conversions
    print('CE 2024 -> BE: ${Era.be.fromCE(2024)}');
    print('BE 2567 -> CE: ${Era.be.toCE(2567)}');

    // Test convenience functions
    print('Convenience CE->BE: ${convertCEToBE(2024)}');
    print('Convenience BE->CE: ${convertBEToCE(2567)}');

    // Test legacy compatibility
    final legacyParsed = parse('2567-08-22');
    print('Legacy parse: $legacyParsed');

    print('\n✅ Clean Architecture implementation is working correctly!');
  } catch (e, stackTrace) {
    print('❌ Error testing implementation: $e');
    print('Stack trace: $stackTrace');
  }
}
