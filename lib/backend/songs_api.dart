import 'package:sqflite/sqflite.dart';
import 'package:tsahymnsv5/languageutils/tamil_text_encoders.dart';
import '../databasecon/databasecon.dart';

class SongApi {
  /// Get all Christian tamil other songs
  static Future<List<Map<String, dynamic>>> getAllSongs() async {
    final db = await DatabaseCon.database;
    //print('Fetching all songs from christiansongs...');
    final result = await db.query(
      'christiansongs',
      columns: ['id', 'englishheading', 'tamilheading'],
      orderBy: 'id ASC',
    );
    //print('Retrieved ${result.length} songs.');
    return result;
  }

  /// Get lyrics of a specific song by id
  static Future<Map<String, dynamic>?> getLyrics(int songId) async {
    final db = await DatabaseCon.database;
    //print('Fetching lyrics for songId: $songId');

    final result = await db.query(
      'christiansongs',
      columns: ['id', 'englishheading', 'tamilheading', 'lyrics_html'],
      where: 'id = ?',
      whereArgs: [songId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      //print('Found song for songId: $songId');

      final original = result.first;
      final lyrics = original['lyrics_html'];

      if (lyrics == null || lyrics is! String) {
        //print('lyrics_html is null or not a string');
        return null;
      }

      final convertedLyrics = TamilConverter.convertToUnicode(lyrics);

      final convertedResult = {
        ...original,
        'lyrics_html': convertedLyrics,
      };

      //print('Converted lyrics result: $convertedResult');

      return convertedResult;
    } else {
      //print('No song found for songId: $songId');
      return null;
    }
  }

  /// Get songs starting with specific letter
  static Future<List<Map<String, dynamic>>> getSongsByLetter(String letter, int languageSegment) async {
    final db = await DatabaseCon.database;
    //print('Fetching songs starting with: $letter');

    final allSongs = await db.query(
      'christiansongs',
      columns: ['id', 'englishheading', 'tamilheading'],
      orderBy: 'id ASC',
    );

    // Filter songs based on the selected language and letter
    final filteredSongs = allSongs.where((song) {
      if (languageSegment == 0) {
        // English songs
        final englishHeading = song['englishheading']?.toString() ?? '';
        return englishHeading.isNotEmpty &&
            englishHeading.toUpperCase().startsWith(letter.toUpperCase());
      } else {
        // Tamil songs
        final tamilHeading = song['tamilheading']?.toString() ?? '';
        return tamilHeading.isNotEmpty && tamilHeading.startsWith(letter);
      }
    }).toList();

    //print('Found ${filteredSongs.length} songs starting with $letter');
    return filteredSongs;
  }




  static Future<void> testDatabaseCount() async {
    final db = await DatabaseCon.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM christiansongs');
    //print('Total songs in database: ${result.first['count']}');

  }
  /// Get all English song headings from `engtsasongs`
  static Future<List<Map<String, dynamic>>> getEnglishSongHeadings() async {
    final db = await DatabaseCon.database;
    //print('Fetching all English song headings...');
    final result = await db.query(
      'engtsasongs',
      columns: ['songid', 'heading'],
      orderBy: 'songid ASC',
    );
    //print('Retrieved ${result.length} English song headings.');
    return result;
  }

  /// Get lyrics of a specific English song by songid
  static Future<Map<String, dynamic>?> getEnglishLyrics(int songId) async {
    final db = await DatabaseCon.database;
    //print('Fetching English lyrics for songId: $songId');
    final result = await db.query(
      'engtsasongs',
      columns: ['songid', 'heading', 'lyrics','author'],
      where: 'songid = ?',
      whereArgs: [songId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      //print('Found English song for songId: $songId');
    } else {
      //print('No English song found for songId: $songId');
    }
    return result.isNotEmpty ? result.first : null;
  }


  static Future<List<Map<String, dynamic>>> getTamilSongHeadings() async {
    final db = await DatabaseCon.database;
    //print('Fetching all Tamil song headings...');
    final result = await db.query(
      'tsatamsongs',
      columns: ['old','new','heading','id'],
      orderBy: 'id',
    );

    if (result.isNotEmpty) {
      //print('First song details:');
      //print('ID: ${result[0]['id']}');
      //print('Old: ${result[0]['old']}');
      //print('New: ${result[0]['new']}');
      //print('Heading: ${result[0]['heading']}');
      //print('Heading type: ${result[0]['heading']?.runtimeType}');
    }

    //print('Retrieved ${result.length} Tamil song headings.');
    return result;
  }

  static Future<Map<String, dynamic>?> getTamilLyrics(int songNo) async {
    final db = await DatabaseCon.database;
    //print('Fetching Tamil lyrics for songNo: $songNo');
    final result = await db.query(
      'tsatamsongs',
      columns: ['id','old','new','heading','content'],
      where: 'id = ?',
      whereArgs: [songNo],
      limit: 1,
    );
    //print(result);
    if (result.isNotEmpty) {
      //print('Found Tamil song for songNo: $songNo');
    } else {
      //print('No Tamil song found for songNo: $songNo');
    }
    return result.isNotEmpty ? result.first : null;
  }
}
