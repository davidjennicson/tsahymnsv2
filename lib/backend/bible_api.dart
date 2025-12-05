import 'package:tsahymnsv5/languageutils/tamil_text_encoders.dart';

import '../databasecon/databasecon.dart';

class BibleAPI {
  /// language: 'English', 'Hindi', etc.
  static Future<List<Map<String, dynamic>>> getBooksByLanguage(String language) async {

    String abbrev = "";
    if (language == "English") {
      abbrev = "eng";
    } else if (language == "Tamil") {
      abbrev = "tam";
    }
    else {
       abbrev = "eng";
    }

    final tableName = 'book_detail_$abbrev';


    try {
      final db = await DatabaseCon.database;


      final result = await db.query(
        tableName,
        columns: ['id', 'book_name', 'chapter_count'],
        orderBy: 'id ASC',
      );




      return result;
    } catch (e) {
      // print('❌ Failed to load books for language "$language": $e');
      return [];
    }
  }


  static Future<List<Map<String, dynamic>>> getVersesByBookAndChapter({
    required int bookId,
    required int chapter,
    required String language,
  }) async {
   // print('🔍 getVersesByBookAndChapter called with bookId=$bookId, chapter=$chapter, language=$language');

    try {
      final db = await DatabaseCon.database;
     // print('✅ Database opened successfully');
     // print('LANGUAGE IS '+language);
      // Choose table name based on language
      String tableName;
      int actualBookId = bookId;
      switch (language.toLowerCase()) {
        case 'english':
          tableName = 'engbible';
          break;
        case 'tamil':
          tableName = 'tambible';
         bookId=bookId;
          actualBookId = bookId ; // Adjust for Tamil database
          break;
        default:
           throw Exception('Unsupported language: $language ');
          // tableName = 'engbible';
          // break;
      }

      final result = await db.query(
        tableName,
        where: 'book_id = ? AND chapter = ?',
        whereArgs: [bookId, chapter],
        orderBy: 'verse ASC',
      );

      // print('📊 Query successful. Number of verses fetched: ${result.length}');
      if (result.isNotEmpty) {
        // for (var verse in result) {
        //   print('Verse ${verse['verse']}: ${TamilConverter.convertToUnicode(verse['text'] as String)}');
        // }
      } else {
        //print('⚠️ No verses found for bookId=$bookId and chapter=$chapter in $tableName');
      }

      return result;
    } catch (e) {
      //print('❌ Failed to load verses for bookId=$bookId, chapter=$chapter, language=$language: $e');
      return [];
    }
  }

}
