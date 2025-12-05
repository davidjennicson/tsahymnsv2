// mapper.dart
import 'dart:convert';

class Mapper {
  final Map<String, String> codepointToEnglish = {};
  final Map<String, String> codepointToCategory = {};
  final Map<String, String> codepointToChar = {};
  final Map<String, String> categories = {
    'consonants': 'consonants',
    'pulli': 'pulli',
    'dependent_vowels_two_part': 'vowels',
    'dependent_vowels_left': 'vowels',
    'various_signs': 'vowels',
    'independent_vowels': 'vowels',
    'dependent_vowels_right': 'vowels',
    'punctuation': 'punctuation'
  };

  Mapper(Map<String, Map<String, List<String>>> charmap) {
    _populateMap(charmap);
  }

  void _populateMap(Map<String, Map<String, List<String>>> charmap) {
    for (var category in charmap.entries) {
      for (var codepoint in category.value.entries) {
        codepointToChar[codepoint.key] = codepoint.value[0];
        codepointToEnglish[codepoint.key] = codepoint.value[1];
        codepointToCategory[codepoint.key] = category.key;
      }
    }
  }

  String inEnglish(String c) {
    return codepointToEnglish[c] ?? c; // Preserve the character if no mapping exists
  }

  List<String> charType(String c) {
    var subType = codepointToCategory[c] ?? '';
    var parentType = categories[subType] ?? '';
    return [parentType, subType];
  }
}