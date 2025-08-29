import 'era.dart';
import 'locale_config.dart';

/// Configuration for Thai Buddhist date operations
/// Immutable value object with validation
class ThaiDateConfig {
  const ThaiDateConfig({
    this.era = Era.be,
    this.locale = SupportedLocales.thai,
    this.language = ThaiLanguage.thai,
  }) : assert(locale != '');

  /// Default era for date operations
  final Era era;

  /// Locale for formatting operations
  final String locale;

  /// Language preference
  final ThaiLanguage language;

  /// Create copy with modified properties
  ThaiDateConfig copyWith({
    Era? era,
    String? locale,
    ThaiLanguage? language,
  }) {
    return ThaiDateConfig(
      era: era ?? this.era,
      locale: locale ?? this.locale,
      language: language ?? this.language,
    );
  }

  /// Validate configuration
  bool get isValid {
    return SupportedLocales.isSupported(locale);
  }

  /// Default configuration
  static const ThaiDateConfig defaultConfig = ThaiDateConfig();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThaiDateConfig &&
          runtimeType == other.runtimeType &&
          era == other.era &&
          locale == other.locale &&
          language == other.language;

  @override
  int get hashCode => Object.hash(era, locale, language);

  @override
  String toString() =>
      'ThaiDateConfig(era: $era, locale: $locale, language: $language)';
}
