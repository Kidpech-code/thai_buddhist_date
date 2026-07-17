import 'package:intl/intl.dart';

/// Formats [dateTime] while replacing only unquoted year tokens with
/// [outputYear]. Other tokens remain delegated to `intl`.
String formatDateWithYearOverride(
  DateTime dateTime,
  String pattern, {
  required int outputYear,
  String? locale,
}) {
  final tokens = <String>[];
  final modifiedPattern = StringBuffer();
  var index = 0;
  var inQuote = false;

  while (index < pattern.length) {
    final character = pattern[index];
    if (character == "'") {
      inQuote = !inQuote;
      modifiedPattern.write(character);
      index++;
      continue;
    }

    if (!inQuote && character == 'y') {
      var end = index;
      while (end < pattern.length && pattern[end] == 'y') {
        end++;
      }
      final token = pattern.substring(index, end);
      final placeholder = '__YEAR_${tokens.length}__';
      tokens.add(token);
      modifiedPattern.write("'$placeholder'");
      index = end;
      continue;
    }

    modifiedPattern.write(character);
    index++;
  }

  final formatter = locale == null || locale.isEmpty
      ? DateFormat(modifiedPattern.toString())
      : DateFormat(modifiedPattern.toString(), locale);
  var result = formatter.format(dateTime);

  for (var tokenIndex = 0; tokenIndex < tokens.length; tokenIndex++) {
    final token = tokens[tokenIndex];
    final replacement = switch (token.length) {
      1 => outputYear.toString(),
      2 => (outputYear % 100).toString().padLeft(2, '0'),
      _ => outputYear.toString().padLeft(token.length, '0'),
    };
    result = result.replaceFirst('__YEAR_${tokenIndex}__', replacement);
  }

  return result;
}
