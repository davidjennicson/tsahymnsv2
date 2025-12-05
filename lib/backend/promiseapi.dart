import 'package:sqflite/sqflite.dart';

import '../databasecon/databasecon.dart';

class PromiseAPI {
  static Future<void> _createPromisesTableIfNotExists() async {
    try {
      final db = await DatabaseCon.database;

      // Check if promises table exists
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='promises'"
      );

      if (tables.isEmpty) {
        //print('📋 Creating promises table...');

        // Create the promises table
        await db.execute('''
          CREATE TABLE promises (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            book_id INTEGER NOT NULL,
            chapter INTEGER NOT NULL,
            verse INTEGER NOT NULL,
            isused INTEGER DEFAULT 0,
            UNIQUE(book_id, chapter, verse)
          )
        ''');

        // Populate with some example promise verses
        // You can modify this list with actual promise verses
        final examplePromises = [
          {'book_id': 19, 'chapter': 23, 'verse': 4}, // Psalm 23:4
          {'book_id': 19, 'chapter': 27, 'verse': 1}, // Psalm 27:1
          {'book_id': 19, 'chapter': 46, 'verse': 1}, // Psalm 46:1
          {'book_id': 19, 'chapter': 91, 'verse': 1}, // Psalm 91:1
          {'book_id': 19, 'chapter': 121, 'verse': 1}, // Psalm 121:1
          {'book_id': 23, 'chapter': 40, 'verse': 31}, // Isaiah 40:31
          {'book_id': 23, 'chapter': 41, 'verse': 10}, // Isaiah 41:10
          {'book_id': 23, 'chapter': 43, 'verse': 2}, // Isaiah 43:2
          {'book_id': 66, 'chapter': 21, 'verse': 4}, // Revelation 21:4
          {'book_id': 45, 'chapter': 8, 'verse': 28}, // Romans 8:28
          {'book_id': 43, 'chapter': 14, 'verse': 27}, // John 14:27
          {'book_id': 42, 'chapter': 11, 'verse': 28}, // Matthew 11:28
          {'book_id': 58, 'chapter': 4, 'verse': 16}, // Hebrews 4:16
          {'book_id': 59, 'chapter': 1, 'verse': 5}, // James 1:5
          {'book_id': 60, 'chapter': 5, 'verse': 7}, // 1 Peter 5:7
        ];

        for (final promise in examplePromises) {
          await db.insert('promises', promise);
        }

        //print('✅ Promises table created and populated with ${examplePromises.length} verses');
      } else {
        //print('✅ Promises table already exists');
      }
    } catch (e) {
      //print('❌ Failed to create promises table: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchPromiseVerse() async {
    try {
      final db = await DatabaseCon.database;

      // Ensure promises table exists
      await _createPromisesTableIfNotExists();

      // Step 1: Check if all promises are used
      final unusedCount = await getUnusedPromisesCount();
      if (unusedCount == 0) {
        //print('🔄 All promises have been used, resetting...');
        await resetAllPromises();
      }

      // Step 2: Randomly select an UNUSED row from promises table
      final randomPromise = await db.rawQuery('''
        SELECT * FROM promises 
        WHERE isused = 0
        ORDER BY RANDOM() 
        LIMIT 1
      ''');

      if (randomPromise.isEmpty) {
        //print('⚠️ No unused promises found');
        return null;
      }

      final promise = randomPromise.first;
      final bookId = promise['book_id'] as int;
      final chapter = promise['chapter'] as int;
      final verse = promise['verse'] as int;

      //print('🎲 Randomly selected promise: book_id=$bookId, chapter=$chapter, verse=$verse');

      // Step 3: Get the text from engbible table
      final engVerse = await db.query(
        'engbible',
        where: 'book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [bookId, chapter, verse],
      );

      if (engVerse.isEmpty) {
        //print('⚠️ No corresponding verse found in engbible table for book_id=$bookId, chapter=$chapter, verse=$verse');
        return null;
      }

      // Step 4: Mark this promise as used AUTOMATICALLY
      await db.update(
        'promises',
        {'isused': 1},
        where: 'book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [bookId, chapter, verse],
      );

      //print('✅ Automatically marked promise as used: book_id=$bookId, chapter=$chapter, verse=$verse');

      // Step 5: Combine the data
      final result = {
        'book_id': bookId,
        'chapter': chapter,
        'verse': verse,
        'isused': 1,
        'text': engVerse.first['text'],
      };

      //print('✅ Successfully fetched promise verse with text');
      return result;

    } catch (e) {
      //print('❌ Failed to fetch promise verse: $e');
      return null;
    }
  }

  // Reset all promises to unused (isused = 0)
  static Future<void> resetAllPromises() async {
    try {
      final db = await DatabaseCon.database;

      await db.update(
        'promises',
        {'isused': 0},
      );

      //print('🔄 Reset all promises to unused state');
    } catch (e) {
      //print('❌ Failed to reset promises: $e');
    }
  }

  // Get count of unused promises
  static Future<int> getUnusedPromisesCount() async {
    try {
      final db = await DatabaseCon.database;

      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM promises WHERE isused = 0'
      );

      return result.first['count'] as int;
    } catch (e) {
      //print('❌ Failed to get unused promises count: $e');
      return 0;
    }
  }

  // Get total promises count
  static Future<int> getTotalPromisesCount() async {
    try {
      final db = await DatabaseCon.database;

      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM promises'
      );

      return result.first['count'] as int;
    } catch (e) {
      //print('❌ Failed to get total promises count: $e');
      return 0;
    }
  }

  // Get progress information
  static Future<Map<String, dynamic>> getProgress() async {
    final unused = await getUnusedPromisesCount();
    final total = await getTotalPromisesCount();
    final used = total - unused;

    return {
      'used': used,
      'unused': unused,
      'total': total,
      'percentage': total > 0 ? (used / total * 100) : 0,
    };
  }

  // Method to manually add a promise verse
  static Future<void> addPromiseVerse(int bookId, int chapter, int verse) async {
    try {
      final db = await DatabaseCon.database;
      await _createPromisesTableIfNotExists();

      await db.insert('promises', {
        'book_id': bookId,
        'chapter': chapter,
        'verse': verse,
        'isused': 0,
      });

      //print('✅ Added promise verse: book_id=$bookId, chapter=$chapter, verse=$verse');
    } catch (e) {
      //print('❌ Failed to add promise verse: $e');
    }
  }
}