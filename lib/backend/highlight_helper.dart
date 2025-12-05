// database/highlight_helper.dart
import 'package:sqflite/sqflite.dart';

import '../databasecon/databasecon.dart';


class HighlightHelper {
  static Future<void> saveHighlight({
    required int bookId,
    required int chapter,
    required int verse,
    required int? colorValue,
    required String language,
  }) async {
    final db = await DatabaseCon.database;

    String tableName;
    switch (language.toLowerCase()) {
      case 'english':
        tableName = 'engbible';
        break;
      case 'tamil':
        tableName = 'tambible_baminicomp';
        break;
      default:
        tableName = 'engbible';
    }

    if (colorValue == null) {
      // Remove highlight
      await db.update(
        tableName,
        {
          'isHighlight': 0,
          'HighlightColor': null,
        },
        where: 'book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [bookId, chapter, verse],
      );
    } else {
      // Add/update highlight
      await db.update(
        tableName,
        {
          'isHighlight': 1,
          'HighlightColor': colorValue,
        },
        where: 'book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [bookId, chapter, verse],
      );
    }
  }

  static Future<Map<int, int>> getHighlightsForChapter({
    required int bookId,
    required int chapter,
    required String language,
  }) async {
    final db = await DatabaseCon.database;

    String tableName;
    switch (language.toLowerCase()) {
      case 'english':
        tableName = 'engbible';
        break;
      case 'tamil':
        tableName = 'tambible_baminicomp';
        break;
      default:
        tableName = 'engbible';
    }

    final results = await db.query(
      tableName,
      columns: ['verse', 'HighlightColor'],
      where: 'book_id = ? AND chapter = ? AND isHighlight = 1',
      whereArgs: [bookId, chapter],
    );

    final Map<int, int> highlights = {};
    for (var result in results) {
      final verse = result['verse'] as int;
      final colorValue = result['HighlightColor'] as int?;
      if (colorValue != null) {
        highlights[verse] = colorValue;
      }
    }

    return highlights;
  }
}