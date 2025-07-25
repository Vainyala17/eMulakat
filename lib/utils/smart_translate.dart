import 'package:easy_localization/easy_localization.dart';

String smartTranslate(String input) {
  final RegExp pattern = RegExp(r'\b\w+\b|[^\s\w]');
  final matches = pattern.allMatches(input);

  return matches.map((match) {
    final word = match.group(0)!;
    return tr(word, args: [], namedArgs: {}, gender: null) != word ? tr(word) : word;
  }).join(' ');
}
