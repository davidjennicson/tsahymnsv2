import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tsahymnsv5/screens/song_lyrics_plain_screen.dart' hide AppState;
import 'package:tsahymnsv5/screens/song_lyrics_screen.dart';
import '../backend/bookmarkapi.dart';
import '../backend/bible_api.dart';
import '../backend/songs_api.dart';
import '../languageutils/tamil_text_encoders.dart';
import '../state/app_state.dart';
import 'bible_text_screen.dart';
import 'chapter_selection_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  int _selectedSegment = 0;
  List<Bookmark> _songBookmarks = [];
  List<Bookmark> _bibleBookmarks = [];
  bool _isLoading = false;
  Bookmark? _selectedBibleBookmark;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allBookmarks = await BookmarkApi.getBookmarks();

      final songBookmarks = allBookmarks.where((bookmark) => bookmark.contentType == 'song').toList();
      final bibleBookmarks = allBookmarks.where((bookmark) => bookmark.contentType == 'bible').toList();

      setState(() {
        _songBookmarks = songBookmarks;
        _bibleBookmarks = bibleBookmarks;
        _isLoading = false;
      });
    } catch (e) {
      //print('❌ Error loading bookmarks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(Bookmark bookmark) async {
    try {
      final success = await BookmarkApi.removeBookmark(bookmark.bookmarkid!);

      if (success) {
        setState(() {
          if (bookmark.contentType == 'song') {
            _songBookmarks.remove(bookmark);
          } else if (bookmark.contentType == 'bible') {
            _bibleBookmarks.remove(bookmark);
          }
        });

        _showToast('Bookmark removed');
      }
    } catch (e) {
      //print('❌ Error removing bookmark: $e');
      _showToast('Failed to remove bookmark', isError: true);
    }
  }

  void _showBibleVerseModal(Bookmark bookmark) {
    setState(() {
      _selectedBibleBookmark = bookmark;
    });
  }

  void _hideBibleVerseModal() {
    setState(() {
      _selectedBibleBookmark = null;
    });
  }

  Future<void> _navigateToChapter(Bookmark bookmark) async {
    final metadata = bookmark.metadata;
    final bookId = metadata['book_id'] as int?;
    final chapter = metadata['chapter'] as int?;
    final bookName = _extractBookName(bookmark.contentId);

    if (bookId != null && chapter != null) {
      _hideBibleVerseModal();

      try {
        setState(() {
          _isLoading = true;
        });

        final verses = await BibleAPI.getVersesByBookAndChapter(
          bookId: bookId,
          chapter: chapter,
          language: _getLanguageFromCategory(bookmark.category),
        );

        final List<String> verseTexts;
        if (_getLanguageFromCategory(bookmark.category) == 'Tamil') {
          verseTexts = verses
              .map((v) => TamilConverter.convertToUnicode(v['text'] as String? ?? ''))
              .toList();
        } else {
          verseTexts = verses.map((v) => v['text'] as String? ?? '').toList();
        }

        if (!mounted) return;

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => BibleTextScreen(
              bookName: bookName,
              chapter: chapter,
              verses: verseTexts,
              bookId: bookId,
              language: _getLanguageFromCategory(bookmark.category),
            ),
          ),
        );
      } catch (e) {
        //print('❌ Error fetching chapter: $e');
        _showToast('Failed to load chapter', isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _showToast('Invalid bookmark data', isError: true);
    }
  }

  String _extractBookName(String reference) {
    final parts = reference.split(' ');
    if (parts.length >= 2) {
      return parts.take(parts.length - 1).join(' ');
    }
    return reference;
  }

  String _getLanguageFromCategory(String category) {
    switch (category) {
      case 'engbible':
        return 'English';
      case 'tambible_baminicomp':
        return 'Tamil';
      default:
        return 'English';
    }
  }

  OverlayEntry? _toastOverlayEntry;

  void _showToast(String message, {bool isError = false}) {
    _removeToast();

    _toastOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? CupertinoColors.systemRed : CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isError ? CupertinoIcons.exclamationmark_triangle : CupertinoIcons.checkmark_alt,
                  size: 18,
                  color: isError ? CupertinoColors.white : CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: 14,
                      fontVariations: const [
                        FontVariation('wght', 500),
                      ],
                      color: isError ? CupertinoColors.white : CupertinoColors.label,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_toastOverlayEntry!);
    Future.delayed(const Duration(seconds: 2), _removeToast);
  }

  void _removeToast() {
    if (_toastOverlayEntry != null) {
      _toastOverlayEntry!.remove();
      _toastOverlayEntry = null;
    }
  }

  @override
  void dispose() {
    _removeToast();
    super.dispose();
  }

  Widget _buildDashboard(Color textColor, Color secondaryTextColor, Color cardColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secondaryTextColor.withOpacity(0.2),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Use responsive layout for landscape
          final isLandscape = constraints.maxWidth > 600;

          return Row(
            mainAxisAlignment: isLandscape ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceAround,
            children: [
              _buildDashboardItem(
                'Songs',
                _songBookmarks.length,
                CupertinoIcons.music_note_2,
                CupertinoColors.systemRed,
                textColor,
                secondaryTextColor,
                isLandscape: isLandscape,
              ),
              _buildDashboardItem(
                'Bible',
                _bibleBookmarks.length,
                CupertinoIcons.book,
                CupertinoColors.systemBlue,
                textColor,
                secondaryTextColor,
                isLandscape: isLandscape,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardItem(
      String title,
      int count,
      IconData icon,
      Color iconColor,
      Color textColor,
      Color secondaryTextColor, {
        bool isLandscape = false,
      }) {
    return Container(
      width: isLandscape ? 120 : null, // Fixed width in landscape
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isLandscape ? 16 : 12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: isLandscape ? 24 : 20,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: isLandscape ? 20 : 18,
              fontVariations: const [
                FontVariation('wght', 700),
              ],
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: "Inter",
              fontSize: isLandscape ? 14 : 12,
              fontVariations: const [
                FontVariation('wght', 500),
              ],
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color textColor, Color secondaryTextColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: secondaryTextColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: secondaryTextColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 18,
                fontVariations: const [
                  FontVariation('wght', 600),
                ],
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: "Inter",
                  fontSize: 14,
                  fontVariations: const [
                    FontVariation('wght', 400),
                  ],
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongBookmarks(Color backgroundColor, Color textColor, Color secondaryTextColor, Color cardColor) {
    if (_songBookmarks.isEmpty) {
      return _buildEmptyState(
        "No Song Bookmarks",
        "Songs you bookmark will appear here",
        CupertinoIcons.music_note_list,
        textColor,
        secondaryTextColor,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 600;

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 24 : 16,
            vertical: 8,
          ),
          itemCount: _songBookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = _songBookmarks[index];
            final songTitle = bookmark.title;
            final additionalInfo = _getSongAdditionalInfo(bookmark);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: secondaryTextColor.withOpacity(0.2),
                ),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.all(isLandscape ? 20 : 16),
                onPressed: () => _navigateToSong(bookmark),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.music_note_2,
                        size: 20,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            songTitle,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: isLandscape ? 18 : 16,
                              fontVariations: const [
                                FontVariation('wght', 600),
                              ],
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            additionalInfo,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: isLandscape ? 15 : 14,
                              fontVariations: const [
                                FontVariation('wght', 400),
                              ],
                              color: secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => _removeBookmark(bookmark),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.trash,
                          size: 18,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBibleBookmarks(Color backgroundColor, Color textColor, Color secondaryTextColor, Color cardColor) {
    if (_bibleBookmarks.isEmpty) {
      return _buildEmptyState(
        "No Bible Bookmarks",
        "Bible verses and chapters you bookmark will appear here",
        CupertinoIcons.book,
        textColor,
        secondaryTextColor,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 600;

        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 24 : 16,
            vertical: 8,
          ),
          itemCount: _bibleBookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = _bibleBookmarks[index];
            final reference = bookmark.contentId;
            final verseText = bookmark.metadata['verse_text']?.toString() ?? '';
            final textPreview = verseText.length > 50 ? '${verseText.substring(0, 50)}...' : verseText;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: secondaryTextColor.withOpacity(0.2),
                ),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.all(isLandscape ? 20 : 16),
                onPressed: () => _showBibleVerseModal(bookmark),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.book,
                        size: 20,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reference,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: isLandscape ? 18 : 16,
                              fontVariations: const [
                                FontVariation('wght', 600),
                              ],
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (textPreview.isNotEmpty)
                            Text(
                              textPreview,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: isLandscape ? 15 : 14,
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                color: secondaryTextColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () => _removeBookmark(bookmark),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.trash,
                          size: 18,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBibleVerseModal(
      Color backgroundColor,
      Color textColor,
      Color secondaryTextColor,
      Color cardColor,
      ) {
    if (_selectedBibleBookmark == null) return const SizedBox.shrink();

    final bookmark = _selectedBibleBookmark!;
    final reference = bookmark.contentId;
    final verseText = bookmark.metadata['verse_text']?.toString() ?? '';
    final isTamil = bookmark.category == 'tambible_baminicomp';
    final displayText = isTamil ? TamilConverter.convertToUnicode(verseText) : verseText;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > 600;

          return Container(
            width: isLandscape
                ? MediaQuery.of(context).size.width * 0.7
                : MediaQuery.of(context).size.width * 0.85,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * (isLandscape ? 0.8 : 0.62),
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLandscape ? 24 : 18,
                    vertical: isLandscape ? 18 : 14,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.book_fill,
                          size: 19,
                          color: CupertinoColors.systemBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bible Verse',
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 12,
                                fontVariations: const [
                                  FontVariation('wght', 500),
                                ],
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reference,
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: isLandscape ? 18 : 16,
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 0,
                        onPressed: _hideBibleVerseModal,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Verse Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 24 : 18,
                      vertical: isLandscape ? 20 : 16,
                    ),
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: isLandscape ? 16.5 : 15.5,
                        height: 1.5,
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        color: textColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: EdgeInsets.fromLTRB(
                    isLandscape ? 24 : 18,
                    12,
                    isLandscape ? 24 : 18,
                    isLandscape ? 18 : 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          borderRadius: BorderRadius.circular(9),
                          color: CupertinoColors.systemGrey6,
                          onPressed: _hideBibleVerseModal,
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14.5,
                              fontVariations: const [
                                FontVariation('wght', 600),
                              ],
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: isLandscape ? 16 : 10),
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          borderRadius: BorderRadius.circular(9),
                          color: CupertinoColors.systemBlue,
                          onPressed: () => _navigateToChapter(bookmark),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Open Chapter',
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontSize: 14.5,
                                  fontVariations: const [
                                    FontVariation('wght', 600),
                                  ],
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.arrow_right,
                                size: 14,
                                color: CupertinoColors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getSongAdditionalInfo(Bookmark bookmark) {
    final metadata = bookmark.metadata;

    switch (bookmark.category) {
      case 'engtsasong':
        return 'Song ${bookmark.contentId}';
      case 'tsatamsong':
        final oldNum = metadata['old']?.toString() ?? '';
        final newNum = metadata['new']?.toString() ?? '';
        if (oldNum.isNotEmpty && newNum.isNotEmpty) {
          return 'Old: $oldNum • New: $newNum';
        } else if (oldNum.isNotEmpty) {
          return 'Old: $oldNum';
        } else if (newNum.isNotEmpty) {
          return 'New: $newNum';
        }
        return 'Song ${bookmark.contentId}';
      case 'christiantamsong':
        return 'Christian Song ${bookmark.contentId}';
      default:
        return 'Song ${bookmark.contentId}';
    }
  }

  void _navigateToSong(Bookmark bookmark) {
    final songId = bookmark.contentId;
    final category = bookmark.category;
    final selectedLanguage = _getLanguageFromSongCategory(category);
    _loadAndNavigateToSong(bookmark, selectedLanguage);
  }

  String _getLanguageFromSongCategory(String category) {
    switch (category) {
      case 'engtsasong':
        return 'English';
      case 'tsatamsong':
      case 'christiantamsong':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  Future<void> _loadAndNavigateToSong(Bookmark bookmark, String selectedLanguage) async {
    final songId = bookmark.contentId;
    final category = bookmark.category;
    final metadata = bookmark.metadata;

    try {
      setState(() {
        _isLoading = true;
      });

      String title = bookmark.title;
      String lyrics = '';
      String artist = "Unknown Artist";

      if (category == 'engtsasong') {
        int songIdInt = int.tryParse(songId) ?? 0;
        final songDetail = await SongApi.getEnglishLyrics(songIdInt);

        if (songDetail != null) {
          title = songDetail['heading'] ?? bookmark.title;
          lyrics = songDetail['lyrics'] ?? 'Lyrics not found.';
          artist = songDetail['author'] ?? 'Author not found';
        } else {
          title = bookmark.title;
          lyrics = 'No lyrics available.';
          artist = 'Author not found';
        }

        if (!mounted) return;

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => SongLyricScreen(
              songTitle: title,
              artist: artist,
              isDarkMode: Provider.of<AppState>(context, listen: false).isDarkMode,
              selectedLanguage: selectedLanguage,
              onThemeToggle: () {
                Provider.of<AppState>(context, listen: false).toggleTheme();
              },
              lyrics: lyrics,
            ),
          ),
        );
      } else if (category == 'tsatamsong') {
        int songNo = int.tryParse(songId) ?? 0;
        final songDetail = await SongApi.getTamilLyrics(songNo);

        if (songDetail != null) {
          title = songDetail['heading'] ?? bookmark.title;
          if (title.startsWith('பாடல் :')) {
            title = title.substring('பாடல் :'.length).trim();
          }
          lyrics = songDetail['content'] ?? 'Lyrics not found.';
        } else {
          title = bookmark.title;
          lyrics = 'No lyrics available.';
        }

        final oldNum = metadata['old']?.toString() ?? '';
        final newNum = metadata['new']?.toString() ?? '';
        artist = "Old: $oldNum    New: $newNum";

        if (!mounted) return;

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => SongLyricScreen(
              songTitle: title,
              artist: artist,
              isDarkMode: Provider.of<AppState>(context, listen: false).isDarkMode,
              selectedLanguage: selectedLanguage,
              onThemeToggle: () {
                Provider.of<AppState>(context, listen: false).toggleTheme();
              },
              lyrics: lyrics,
            ),
          ),
        );
      } else if (category == 'christiantamsong') {
        int songNo = int.tryParse(songId) ?? 0;
        final songDetail = await SongApi.getLyrics(songNo);

        if (songDetail != null) {
          final englishTitle = songDetail['englishheading']?.toString() ?? '';
          final tamilTitle = songDetail['tamilheading']?.toString() ?? '';
          lyrics = songDetail['lyrics_html']?.toString() ?? 'Lyrics not found.';

          title = selectedLanguage == 'தமிழ்'
              ? (tamilTitle.isNotEmpty ? tamilTitle : bookmark.title)
              : (englishTitle.isNotEmpty ? englishTitle : bookmark.title);

          if (!mounted) return;

          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => SongLyricPlainScreen(
                songId: songNo,
                englishTitle: englishTitle,
                tamilTitle: tamilTitle,
                lyrics: lyrics,
                isDarkMode: Provider.of<AppState>(context, listen: false).isDarkMode,
                selectedLanguage: selectedLanguage,
                onThemeToggle: () {
                  Provider.of<AppState>(context, listen: false).toggleTheme();
                },
              ),
            ),
          );
        } else {
          title = bookmark.title;
          lyrics = 'No lyrics available.';
          _showToast('Failed to load song lyrics', isError: true);
        }
      }

    } catch (e) {
      //print('❌ Error loading song lyrics: $e');
      _showToast('Failed to load song', isError: true);
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
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();
        final cardColor = appState.getCardColor();

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            border: null,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(
                CupertinoIcons.chevron_left,
                color: textColor,
                size: 24,
              ),
            ),
            middle: Text(
              'Bookmarks',
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 18,
                fontVariations: const [
                  FontVariation('wght', 700),
                ],
                color: textColor,
              ),
            ),
          ),
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Dashboard
                    _buildDashboard(textColor, secondaryTextColor, cardColor),

                    // Segmented Control
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: secondaryTextColor.withOpacity(0.2),
                          ),
                        ),
                        child: CupertinoSlidingSegmentedControl<int>(
                          groupValue: _selectedSegment,
                          onValueChanged: (value) {
                            setState(() {
                              _selectedSegment = value ?? 0;
                            });
                          },
                          children: {
                            0: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.music_note_2,
                                    size: 16,
                                    color: _selectedSegment == 0 ? CupertinoColors.white : textColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Songs',
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontVariations: const [
                                        FontVariation('wght', 600),
                                      ],
                                      color: _selectedSegment == 0 ? CupertinoColors.white : textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            1: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.book,
                                    size: 16,
                                    color: _selectedSegment == 1 ? CupertinoColors.white : textColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Bible',
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontVariations: const [
                                        FontVariation('wght', 600),
                                      ],
                                      color: _selectedSegment == 1 ? CupertinoColors.white : textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          },
                        ),
                      ),
                    ),

                    // Content
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CupertinoActivityIndicator())
                          : _selectedSegment == 0
                          ? _buildSongBookmarks(backgroundColor, textColor, secondaryTextColor, cardColor)
                          : _buildBibleBookmarks(backgroundColor, textColor, secondaryTextColor, cardColor),
                    ),
                  ],
                ),
              ),

              // Bible Verse Modal
              if (_selectedBibleBookmark != null)
                _buildBibleVerseModal(backgroundColor, textColor, secondaryTextColor, cardColor),
            ],
          ),
        );
      },
    );
  }
}