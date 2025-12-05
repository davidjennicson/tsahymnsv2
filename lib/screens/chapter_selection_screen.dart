import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../databasecon/databasecon.dart';
import '../backend/bible_api.dart';
import '../languageutils/tamil_text_encoders.dart';
import '../state/app_state.dart';
import 'bible_text_screen.dart';

class ChapterSelectionScreen extends StatefulWidget {
  final String bookName;
  final int totalChapters;
  final int bookId;
  final String language;

  const ChapterSelectionScreen({
    super.key,
    required this.bookName,
    required this.totalChapters,
    required this.bookId,
    required this.language,
  });

  @override
  State<ChapterSelectionScreen> createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  bool _isLoading = false;

  Future<void> _openChapter(int chapter) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final verses = await BibleAPI.getVersesByBookAndChapter(
        bookId: widget.bookId,
        chapter: chapter,
        language: widget.language,
      );

      final List<String> verseTexts;

      if (widget.language == 'Tamil') {
        verseTexts = verses
            .map((v) =>
        (v['text'] as String? ?? ''))
            .toList();
      } else {
        verseTexts =
            verses.map((v) => v['text'] as String? ?? '').toList();
      }

      if (!mounted) return;

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => BibleTextScreen(
            bookName: widget.bookName,
            chapter: chapter,
            verses: verseTexts,
            bookId: widget.bookId,
            language: widget.language,
          ),
        )
        ,
      );
    } catch (e) {
      //print('❌ Error fetching verses: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final bool isDark = appState.isDarkMode;

        final backgroundColor =
        isDark ? const Color(0xFF0E151F) : CupertinoColors.white;

        final borderColor =
        isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE5E7EB);

        final textColor =
        isDark ? const Color(0xFFE0E0E0) : CupertinoColors.black;

        final gridButtonColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0);

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: 0.5,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(
                CupertinoIcons.chevron_left,
                color: textColor,
              ),
            ),
            middle: Text(
              widget.bookName,
              style: TextStyle(
                fontFamily: 'Inter',
                fontVariations: const [
                  FontVariation('wght', 600),
                ],
                fontSize: 18,
                color: textColor,
              ),
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // 🔹 6 buttons per row
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.2, // 🔹 compact shape
                    ),
                    itemCount: widget.totalChapters,
                    itemBuilder: (context, index) {
                      final chapterNumber = index + 1;
                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _isLoading
                            ? null
                            : () => _openChapter(chapterNumber),
                        child: Container(
                          decoration: BoxDecoration(
                            color: gridButtonColor,
                            borderRadius:
                            BorderRadius.circular(20), // 🔹 smaller radius
                            border: Border.all(
                              color: borderColor,
                              width: 0.8, // 🔹 thinner border
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$chapterNumber',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontVariations: const [
                                  FontVariation('wght', 500),
                                ],
                                fontSize: 14, // 🔹 smaller font
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CupertinoActivityIndicator(radius: 20),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}