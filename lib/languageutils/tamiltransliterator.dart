// tamil_transliterator.dart
import 'mapper.dart';

class TamilTransliterator {
  final Mapper mapper;

  static const Map<String, Map<String, List<String>>> charmap = {
    'independent_vowels': {
      '\u0B85': ['அ', 'A'],
      '\u0B86': ['ஆ ', 'AA'],
      '\u0B87': ['இ', 'I'],
      '\u0B88': ['ஈ', 'II'],
      '\u0B89': ['உ', 'U'],
      '\u0B8A': ['ஊ', 'UU'],
      '\u0B8B': ['', '<reserved>'],
      '\u0B8C': ['', '<reserved>'],
      '\u0B8D': ['', '<reserved>'],
      '\u0B8E': ['எ', 'E'],
      '\u0B8F': ['ஏ', 'EE'],
      '\u0B90': ['ஐ', 'AI'],
      '\u0B91': ['', '<reserved>'],
      '\u0B92': ['ஒ', 'O'],
      '\u0B93': ['ஓ', 'OO'],
      '\u0B94': ['ஔ ', 'AU'],
    },
    'consonants': {
      '\u0B95': ['க', 'KA'],
      '\u0B96': ['', '<reserved>'],
      '\u0B97': ['', '<reserved>'],
      '\u0B98': ['', '<reserved>'],
      '\u0B99': ['ங', 'NGA'],
      '\u0B9A': ['ச', 'SA'],
      '\u0B9B': ['', '<reserved>'],
      '\u0B9C': ['ஜ', 'JA'],
      '\u0B9D': ['', '<reserved>'],
      '\u0B9E': ['ஞ', 'NYA'],
      '\u0B9F': ['ட', 'DA'],
      '\u0BA0': ['', '<reserved>'],
      '\u0BA1': ['', '<reserved>'],
      '\u0BA2': ['', '<reserved>'],
      '\u0BA3': ['ண', 'NNA'],
      '\u0BA4': ['த', 'THA'],
      '\u0BA5': ['', '<reserved>'],
      '\u0BA6': ['', '<reserved>'],
      '\u0BA7': ['', '<reserved>'],
      '\u0BA8': ['ந', 'NA'],
      '\u0BA9': ['ன', 'NA'],
      '\u0BAA': ['ப', 'PA'],
      '\u0BAB': ['', '<reserved>'],
      '\u0BAC': ['', '<reserved>'],
      '\u0BAD': ['', '<reserved>'],
      '\u0BAE': ['ம', 'MA'],
      '\u0BAF': ['ய', 'YA'],
      '\u0BB0': ['ர', 'RA'],
      '\u0BB1': ['ற', 'RRA'],
      '\u0BB2': ['ல', 'LA'],
      '\u0BB3': ['ள', 'LLA'],
      '\u0BB4': ['ழ', 'LLLA'],
      '\u0BB5': ['வ', 'VA'],
      '\u0BB6': ['ஶ', 'SHA'],
      '\u0BB7': ['ஷ', 'SSA'],
      '\u0BB8': ['ஸ', 'SA'],
      '\u0BB9': ['ஹ', 'HA'],
    },
    'dependent_vowels_right': {
      '\u0BBE': ['\$ா', 'AA'],
      '\u0BBF': ['\$ி', 'I'],
      '\u0BC0': ['\$ீ', 'II'],
      '\u0BC1': ['\$ு', 'U'],
      '\u0BC2': ['ஊ\$', 'UU'],
      '\u0BC3': ['', '<reserved>'],
      '\u0BC4': ['', '<reserved>'],
      '\u0BC5': ['', '<reserved>'],
    },
    'dependent_vowels_left': {
      '\u0BC6': ['\$ெ', 'E'],
      '\u0BC7': ['\$ே', 'EE'],
      '\u0BC8': ['\$ை', 'AI'],
    },
    'dependent_vowels_two_part': {
      '\u0BCA': ['\$ொ', 'O'],
      '\u0BCB': ['\$ோ', 'OO'],
      '\u0BCC': ['\$ௌ', 'AU'],
    },
    'pulli': {
      '\u0BCD': ['\$்', 'PULLI'],
    },
    'various_signs': {
      '\u0BD0': ['ௐ', 'OM'],
      '\u0BD1': ['"', '<reserved>'],
      '\u0BD2': ['"', '<reserved>'],
      '\u0BD3': ['"', '<reserved>'],
      '\u0BD4': ['"', '<reserved>'],
      '\u0BD5': ['"', '<reserved>'],
      '\u0BD6': ['"', '<reserved>'],
      '\u0BD7': ['\$ௗ', 'AU'],
      '\n': ['\n', '\n']
    },
    'punctuation': {
      '.': ['.', '.'],
      ',': [',', ','],
      '!': ['!', '!'],
      '?': ['?', '?'],
      ':': [':', ':'],
      ';': [';', ';'],
      '-': ['-', '-'],
      '—': ['—', '—'],
      '(': ['(', '('],
      ')': [')', ')'],
      '"': ['"', '"'],
      '\'': ['\'', '\''],
    },
    'english_alphabets': {
      'A': ['A', 'A'],
      'B': ['B', 'B'],
      'C': ['C', 'C'],
      'D': ['D', 'D'],
      'E': ['E', 'E'],
      'F': ['F', 'F'],
      'G': ['G', 'G'],
      'H': ['H', 'H'],
      'I': ['I', 'I'],
      'J': ['J', 'J'],
      'K': ['K', 'K'],
      'L': ['L', 'L'],
      'M': ['M', 'M'],
      'N': ['N', 'N'],
      'O': ['O', 'O'],
      'P': ['P', 'P'],
      'Q': ['Q', 'Q'],
      'R': ['R', 'R'],
      'S': ['S', 'S'],
      'T': ['T', 'T'],
      'U': ['U', 'U'],
      'V': ['V', 'V'],
      'W': ['W', 'W'],
      'X': ['X', 'X'],
      'Y': ['Y', 'Y'],
      'Z': ['Z', 'Z'],
      'a': ['a', 'a'],
      'b': ['b', 'b'],
      'c': ['c', 'c'],
      'd': ['d', 'd'],
      'e': ['e', 'e'],
      'f': ['f', 'f'],
      'g': ['g', 'g'],
      'h': ['h', 'h'],
      'i': ['i', 'i'],
      'j': ['j', 'j'],
      'k': ['k', 'k'],
      'l': ['l', 'l'],
      'm': ['m', 'm'],
      'n': ['n', 'n'],
      'o': ['o', 'o'],
      'p': ['p', 'p'],
      'q': ['q', 'q'],
      'r': ['r', 'r'],
      's': ['s', 's'],
      't': ['t', 't'],
      'u': ['u', 'u'],
      'v': ['v', 'v'],
      'w': ['w', 'w'],
      'x': ['x', 'x'],
      'y': ['y', 'y'],
      'z': ['z', 'z'],
    }
  };

  TamilTransliterator() : mapper = Mapper(charmap);

  // Main transliterate method for markdown text
  String transliterate(String markdownText) {
    return _processMarkdown(markdownText);
  }

  // NEW METHOD: Plain text transliteration without markdown processing
  String transliteratePlainText(String plainText) {
    return _transliterateTextContent(plainText);
  }

  String _processMarkdown(String markdown) {
    var lines = markdown.split('\n');
    var processedLines = <String>[];

    for (var line in lines) {
      processedLines.add(_processMarkdownLine(line));
    }

    return processedLines.join('\n');
  }

  String _processMarkdownLine(String line) {
    if (line.trim().isEmpty) {
      return line;
    }

    // Check for headers
    if (line.startsWith('#')) {
      var headerLevel = 0;
      var i = 0;
      while (i < line.length && line[i] == '#') {
        headerLevel++;
        i++;
      }
      var headerText = line.substring(i).trim();
      return '${'#' * headerLevel} ${_transliterateTextContent(headerText)}';
    }

    // Check for blockquotes
    if (line.startsWith('>')) {
      var quoteText = line.substring(1).trim();
      return '> ${_transliterateTextContent(quoteText)}';
    }

    // Check for list items
    if (line.startsWith('- ') || line.startsWith('* ') || RegExp(r'^\d+\.').hasMatch(line)) {
      var match = RegExp(r'^(\s*[-*]|\s*\d+\.)\s+').firstMatch(line);
      if (match != null) {
        var prefix = match.group(0)!;
        var listText = line.substring(match.end);
        return '$prefix${_transliterateTextContent(listText)}';
      }
    }

    // Check for code blocks
    if (line.startsWith('    ') || line.startsWith('\t')) {
      return line;
    }

    return _processInlineMarkdown(line);
  }

  String _processInlineMarkdown(String text) {
    var result = StringBuffer();
    var currentPos = 0;

    final patterns = [
      RegExp(r'\*\*(.*?)\*\*'),
      RegExp(r'\*(.*?)\*'),
      RegExp(r'`(.*?)`'),
      RegExp(r'\[(.*?)\]\((.*?)\)'),
    ];

    while (currentPos < text.length) {
      var earliestMatch = patterns
          .map((pattern) => pattern.firstMatch(text.substring(currentPos)))
          .where((match) => match != null)
          .fold<RegExpMatch?>(null, (earliest, match) {
        if (match == null) return earliest;
        if (earliest == null) return match;
        return match.start < earliest.start ? match : earliest;
      });

      if (earliestMatch == null) {
        result.write(_transliterateTextContent(text.substring(currentPos)));
        break;
      }

      var beforeText = text.substring(currentPos, currentPos + earliestMatch.start);
      result.write(_transliterateTextContent(beforeText));

      var fullMatch = earliestMatch.group(0)!;
      if (fullMatch.startsWith('**')) {
        var boldText = earliestMatch.group(1)!;
        result.write('**${_transliterateTextContent(boldText)}**');
      } else if (fullMatch.startsWith('*') && !fullMatch.startsWith('**')) {
        var italicText = earliestMatch.group(1)!;
        result.write('*${_transliterateTextContent(italicText)}*');
      } else if (fullMatch.startsWith('`')) {
        result.write(fullMatch);
      } else if (fullMatch.startsWith('[')) {
        var linkText = earliestMatch.group(1)!;
        var url = earliestMatch.group(2)!;
        result.write('[${_transliterateTextContent(linkText)}]($url)');
      }

      currentPos += earliestMatch.start + fullMatch.length;
    }

    return result.toString();
  }

  String _transliterateTextContent(String text) {
    var output = <String>[];
    var currentText = <String>[];

    for (var c in text.split('')) {
      if (_isTamilCharacter(c)) {
        currentText.add(c);
      } else {
        if (currentText.isNotEmpty) {
          output.add(_capitalizeFirstLetterOfWords(toEnglish(currentText.join(''))));
          currentText.clear();
        }
        output.add(c);
      }
    }

    if (currentText.isNotEmpty) {
      output.add(_capitalizeFirstLetterOfWords(toEnglish(currentText.join(''))));
    }

    return _normalizeWhitespace(output.join(''));
  }

  String _normalizeWhitespace(String text) {
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    return text.trim();
  }

  String _capitalizeFirstLetterOfWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String toEnglish(String text) {
    text = _preprocess(text);
    var output = <String>[];

    for (var c in text.split('')) {
      var inEnglish = mapper.inEnglish(c);
      var tuple = mapper.charType(c);
      var parentType = tuple[0];
      var subType = tuple[1];

      if (parentType == 'pulli') {
        if (output.isNotEmpty) {
          output.removeLast();
        }
      } else if (parentType == 'vowels' && subType != 'independent_vowels') {
        if (output.isNotEmpty) {
          output.removeLast();
        }
        output.addAll(inEnglish.split(''));
      } else {
        output.addAll(inEnglish.split(''));
      }
    }

    return output.join('');
  }

  bool _isTamilCharacter(String c) {
    return (c.codeUnitAt(0) >= 0x0B80 && c.codeUnitAt(0) <= 0x0BFF);
  }

  String _preprocess(String text) {
    return text;
  }
}

void main() {
  var transliterator = TamilTransliterator();

  // Test markdown transliteration
  var markdown = """
# தமிழ் தலைப்பு

இது ஒரு **தமிழ்** பத்தி.

- முதல் பட்டியல் உருப்படி
- இரண்டாம் பட்டியல் உருப்படி

> இது ஒரு மேற்கோள்
""";

  var result = transliterator.transliterate(markdown);
  //print("Markdown transliteration:");
  //print(result);

  // Test plain text transliteration
  var plainText = "இது ஒரு சாதாரண தமிழ் வாக்கியம்";
  var plainResult = transliterator.transliteratePlainText(plainText);
  //print("\nPlain text transliteration:");
  //print(plainResult);
}