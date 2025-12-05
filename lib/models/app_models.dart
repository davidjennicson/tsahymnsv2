class Language {
  final String name;
  final String subtitle;
  final bool selected;

  Language({
    required this.name,
    required this.subtitle,
    this.selected = false,
  });
}

class BibleBook {
  final String name;
  final int chapters;

  BibleBook({
    required this.name,
    required this.chapters,
  });
}

class Song {
  final int id;
  final String number;
  final String title;
  final String author;

  Song({
    required this.id,
    required this.number,
    required this.title,
    required this.author,
  });
}

// Data
final List<Language> languages = [
  Language(name: "English", subtitle: "(Device Language)", selected: true),
  Language(name: "中文", subtitle: "(Mandarin)"),
  Language(name: "Español", subtitle: "(Spanish)"),
  Language(name: "हिंदी", subtitle: "(Hindi)"),
  Language(name: "العربية", subtitle: "(Arabic)"),
  Language(name: "বাংলা", subtitle: "(Bengali)"),
  Language(name: "Português", subtitle: "(Portuguese)"),
  Language(name: "Русский", subtitle: "(Russian)"),
];

final List<BibleBook> oldTestamentBooks = [
  BibleBook(name: "Genesis", chapters: 50),
  BibleBook(name: "Exodus", chapters: 40),
  BibleBook(name: "Leviticus", chapters: 27),
  BibleBook(name: "Numbers", chapters: 36),
  BibleBook(name: "Deuteronomy", chapters: 34),
  BibleBook(name: "Joshua", chapters: 24),
  BibleBook(name: "Judges", chapters: 21),
  BibleBook(name: "Ruth", chapters: 4),
];

final List<Song> songs = [
  Song(id: 1, number: "001", title: "Amazing Grace", author: "John Newton"),
  Song(id: 2, number: "002", title: "How Great Thou Art", author: "Carl Boberg"),
  Song(id: 3, number: "003", title: "It Is Well With My Soul", author: "Horatio Spafford"),
  Song(id: 4, number: "004", title: "Great Is Thy Faithfulness", author: "Thomas Chisholm"),
  Song(id: 5, number: "005", title: "Holy, Holy, Holy", author: "Reginald Heber"),
  Song(id: 6, number: "006", title: "Be Thou My Vision", author: "Irish Hymn"),
  Song(id: 7, number: "007", title: "Crown Him with Many Crowns", author: "Matthew Bridges"),
  Song(id: 8, number: "008", title: "All Hail the Power of Jesus' Name", author: "Edward Perronet"),
];
