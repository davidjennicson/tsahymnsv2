// book_helper.dart
import '../databasecon/databasecon.dart';

class BookHelper {
  static Future<String> getBookName(int bookId, String language) async {
    try {
      final db = await DatabaseCon.database;
      String abbrev = language.toLowerCase() == 'tamil' ? 'tam' : 'eng';
      final tableName = 'book_detail_$abbrev';

      final result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [bookId],
      );

      if (result.isNotEmpty) {

        return result.first['book_name'] as String;

      }

      return 'Book $bookId';
    } catch (e) {
      //print('Error getting book name: $e');
      return 'Book $bookId';
    }
  }
}