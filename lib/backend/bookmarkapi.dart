import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../databasecon/databasecon.dart';
class Bookmark {
  final int? bookmarkid;
  final String contentType; // 'bible' or 'song'
  final String category; // 'engbible', 'engtsasong', etc.
  final String contentId; // songid, bible reference
  final String title;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  Bookmark({
    this.bookmarkid,
    required this.contentType,
    required this.category,
    required this.contentId,
    required this.title,
    this.metadata = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookmarkid': bookmarkid,
      'content_type': contentType,
      'category': category,
      'content_id': contentId,
      'title': title,
      'metadata': metadata.isEmpty ? '{}' : jsonEncode(metadata),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      bookmarkid: map['bookmarkid'],
      contentType: map['content_type'],
      category: map['category'],
      contentId: map['content_id'],
      title: map['title'],
      metadata: map['metadata'] != null && map['metadata'] != '{}'
          ? jsonDecode(map['metadata'])
          : {},
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}


class BookmarkApi {
  static Future<int> createBookmark(Bookmark bookmark) async {
    final db = await DatabaseCon.database;

    try {
      final id = await db.insert(
        'bookmarks',
        bookmark.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      //print('❌ Failed to create bookmark: $e');
      rethrow;
    }
  }

  // Create specialized bookmark methods for different content types
  static Future<int> bookmarkSong({
    required String category, // 'engtsasong', 'tsatamsong', 'christiantamsong'
    required String songId,
    required String title,
    Map<String, dynamic> metadata = const {},
  }) async {
    final bookmark = Bookmark(
      contentType: 'song',
      category: category,
      contentId: songId,
      title: title,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    return await createBookmark(bookmark);
  }

  static Future<int> bookmarkBibleVerse({
    required String category, // 'engbible', 'tambible_baminicomp'
    required String reference, // e.g., "John 3:16"
    required String title,
    String? verseText,
    int? bookId,
    int? chapter,
    int? verse,
  }) async {
    final metadata = {
      if (verseText != null) 'verse_text': verseText,
      if (bookId != null) 'book_id': bookId,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
    };
    //print(metadata['verse_text']);
    final bookmark = Bookmark(
      contentType: 'bible',
      category: category,
      contentId: reference,
      title: title,
      metadata: metadata,
      createdAt: DateTime.now(),
    );

    return await createBookmark(bookmark);
  }

  // Get all bookmarks with optional filtering
  static Future<List<Bookmark>> getBookmarks({
    String? contentType,
    String? category,
  }) async {
    final db = await DatabaseCon.database;

    try {
      final whereClause = <String>[];
      final whereArgs = <dynamic>[];

      if (contentType != null) {
        whereClause.add('content_type = ?');
        whereArgs.add(contentType);
      }

      if (category != null) {
        whereClause.add('category = ?');
        whereArgs.add(category);
      }

      final where = whereClause.isNotEmpty ? whereClause.join(' AND ') : null;

      final result = await db.query(
        'bookmarks',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );

      return result.map((map) => Bookmark.fromMap(map)).toList();
    } catch (e) {
      //print('❌ Failed to get bookmarks: $e');
      return [];
    }
  }

  // Get bookmarks by type (for your segmented UI)
  static Future<List<Bookmark>> getSongBookmarks() async {
    return await getBookmarks(contentType: 'song');
  }

  static Future<List<Bookmark>> getBibleBookmarks() async {
    return await getBookmarks(contentType: 'bible');
  }

  // Check if something is bookmarked
  static Future<bool> isBookmarked({
    required String contentType,
    required String category,
    required String contentId,
  }) async {
    final db = await DatabaseCon.database;

    try {
      final result = await db.query(
        'bookmarks',
        where: 'content_type = ? AND category = ? AND content_id = ?',
        whereArgs: [contentType, category, contentId],
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      //print('❌ Failed to check bookmark: $e');
      return false;
    }
  }

  // Remove bookmark
  static Future<bool> removeBookmark(int bookmarkId) async {
    final db = await DatabaseCon.database;

    try {
      final count = await db.delete(
        'bookmarks',
        where: 'bookmarkid = ?',
        whereArgs: [bookmarkId],
      );

      return count > 0;
    } catch (e) {
      //print('❌ Failed to remove bookmark: $e');
      return false;
    }
  }

  // Remove bookmark by content reference
  static Future<bool> removeBookmarkByContent({
    required String contentType,
    required String category,
    required String contentId,
  }) async {
    final db = await DatabaseCon.database;

    try {
      final count = await db.delete(
        'bookmarks',
        where: 'content_type = ? AND category = ? AND content_id = ?',
        whereArgs: [contentType, category, contentId],
      );

      return count > 0;
    } catch (e) {
      //print('❌ Failed to remove bookmark: $e');
      return false;
    }
  }

  // Get bookmark counts for dashboard
  static Future<Map<String, int>> getBookmarkCounts() async {
    final db = await DatabaseCon.database;

    try {
      final result = await db.rawQuery('''
        SELECT 
          SUM(CASE WHEN content_type = 'song' THEN 1 ELSE 0 END) as songs,
          SUM(CASE WHEN content_type = 'bible' THEN 1 ELSE 0 END) as bible,
          COUNT(*) as total
        FROM bookmarks
      ''');

      if (result.isNotEmpty) {
        return {
          'songs': result.first['songs'] as int? ?? 0,
          'bible': result.first['bible'] as int? ?? 0,
          'total': result.first['total'] as int? ?? 0,
        };
      }

      return {'songs': 0, 'bible': 0, 'total': 0};
    } catch (e) {
      //print('❌ Failed to get bookmark counts: $e');
      return {'songs': 0, 'bible': 0, 'total': 0};
    }
  }
}