/// Supported languages for date formatting
enum ThaiLanguage {
  thai('th_TH', 'ไทย'),
  english('en_US', 'English');

  const ThaiLanguage(this.localeCode, this.displayName);

  /// Locale code (e.g., 'th_TH', 'en_US')
  final String localeCode;

  /// Human-readable display name
  final String displayName;
}

/// Comprehensive locale support with performance-optimized constants
class SupportedLocales {
  // Core locales
  static const String thai = 'th_TH';
  static const String english = 'en_US';

  // Extended locale support
  static const String french = 'fr_FR';
  static const String german = 'de_DE';
  static const String japanese = 'ja_JP';
  static const String korean = 'ko_KR';
  static const String chinese = 'zh_CN';
  static const String arabic = 'ar_SA';
  static const String spanish = 'es_ES';
  static const String portuguese = 'pt_BR';
  static const String russian = 'ru_RU';
  static const String vietnamese = 'vi_VN';
  static const String khmer = 'km_KH';
  static const String myanmar = 'my_MM';
  static const String laotian = 'lo_LA';

  /// All supported locales for validation
  static const Set<String> all = {
    thai,
    english,
    french,
    german,
    japanese,
    korean,
    chinese,
    arabic,
    spanish,
    portuguese,
    russian,
    vietnamese,
    khmer,
    myanmar,
    laotian,
  };

  /// Check if locale is supported
  static bool isSupported(String locale) => all.contains(locale);

  /// Get default locale
  static String get defaultLocale => thai;
}
