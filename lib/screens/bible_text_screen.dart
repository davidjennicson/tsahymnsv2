import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tsahymnsv5/widgets/settings_modal.dart';
import '../backend/bookmarkapi.dart';
import '../backend/highlight_helper.dart';
import '../state/app_state.dart';
import '../widgets/highlight_modal.dart';
import 'package:tsahymnsv5/screens/verse_poster_screen.dart'; // Add this import
import 'package:flutter/material.dart' as material;

class BibleTextScreen extends StatefulWidget {
  final String bookName;
  final int chapter;
  final List<String> verses;
  final int bookId;
  final String language;
  final int? highlightVerse; // Add this for deep links

  const BibleTextScreen({
    super.key,
    required this.bookName,
    required this.chapter,
    required this.verses,
    required this.bookId,
    required this.language,
    this.highlightVerse, // Add this
  });

  @override
  State<BibleTextScreen> createState() => _BibleTextScreenState();
}

class _BibleTextScreenState extends State<BibleTextScreen> {
  int? _selectedVerseIndex;
  Map<int, Color?> _highlightedVerses = {};
  Map<int, bool> _savedVerses = {};
  Map<int, bool> _bookmarkedVerses = {};
  final ScrollController _scrollController = ScrollController();
  bool _showHighlightModal = false;
  int _currentVerseIndex = 0;
  String _currentVerseText = '';

  // Deep link highlighting variables
  int? _verseToHighlight;
  bool _isHighlighting = false;
  Timer? _highlightTimer;

  OverlayEntry? _toastOverlayEntry;

  @override
  void initState() {
    super.initState();
    _loadVerseStatus();
    _loadBookmarks();
    _handleDeepLinkHighlight();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _removeToast();
    _highlightTimer?.cancel();
    super.dispose();
  }

  void _handleDeepLinkHighlight() {
    if (widget.highlightVerse != null) {
      final verseIndex = widget.highlightVerse! - 1;

      if (verseIndex >= 0 && verseIndex < widget.verses.length) {
        // Scroll to verse after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToVerse(verseIndex);
        });

        // Start highlight animation
        _startHighlightAnimation(verseIndex);
      }
    }
  }

  void _startHighlightAnimation(int verseIndex) {
    setState(() {
      _verseToHighlight = verseIndex;
      _isHighlighting = true;
    });

    // Remove highlight after 1 second
    _highlightTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        _isHighlighting = false;
      });

      // Clear verse reference after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _verseToHighlight = null;
        });
      });
    });
  }

  void _scrollToVerse(int verseIndex) {
    final double verseHeight = 80.0;
    final double targetOffset = verseIndex * verseHeight;

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Generate share link with deep link
  String _generateShareLink(int verseNumber) {
    // Using custom scheme - choose one that matches your manifest
    return "tsahymns://bible/${widget.bookId}/${widget.chapter}/$verseNumber";

    // Alternative schemes:
    // return "bibleapp://open/${widget.bookId}/${widget.chapter}/$verseNumber";
    // return "https://tsahymns.com/bible/${widget.bookId}/${widget.chapter}/$verseNumber";
  }

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
              color:
              isError ? CupertinoColors.systemRed : CupertinoColors.systemGrey6,
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
                  isError
                      ? CupertinoIcons.exclamationmark_triangle
                      : CupertinoIcons.checkmark_alt,
                  size: 18,
                  color: isError
                      ? CupertinoColors.white
                      : CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontVariations: const [
                        FontVariation('wght', 500),
                      ],
                      fontSize: 14,
                      color: isError
                          ? CupertinoColors.white
                          : CupertinoColors.label,
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

    Future.delayed(const Duration(seconds: 2), () {
      _removeToast();
    });
  }

  void _removeToast() {
    if (_toastOverlayEntry != null) {
      _toastOverlayEntry!.remove();
      _toastOverlayEntry = null;
    }
  }

  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await BookmarkApi.getBibleBookmarks();

      final chapterBookmarks = bookmarks.where((bookmark) {
        final metadata = bookmark.metadata;
        final bookmarkBookId = metadata['book_id'] as int?;
        final bookmarkChapter = metadata['chapter'] as int?;

        return bookmarkBookId == widget.bookId &&
            bookmarkChapter == widget.chapter;
      }).toList();

      final Map<int, bool> verseBookmarks = {};
      for (final bookmark in chapterBookmarks) {
        final verse = bookmark.metadata['verse'] as int?;
        if (verse != null) {
          verseBookmarks[verse - 1] = true;
        }
      }

      setState(() {
        _bookmarkedVerses = verseBookmarks;
      });
    } catch (e) {
      //print('❌ Error loading bookmarks: $e');
    }
  }

  Future<void> _loadVerseStatus() async {
    try {
      final highlights = await HighlightHelper.getHighlightsForChapter(
        bookId: widget.bookId,
        chapter: widget.chapter,
        language: widget.language,
      );

      setState(() {
        _highlightedVerses = highlights.map(
              (verse, colorValue) => MapEntry(
            verse - 1,
            colorValue != null ? Color(colorValue) : null,
          ),
        );
      });
    } catch (e) {
      //print('❌ Error loading verse status: $e');
    }
  }

  Widget _buildHighlightModal() {
    final isSaved = _savedVerses[_currentVerseIndex] ?? false;
    final isBookmarked = _bookmarkedVerses[_currentVerseIndex] ?? false;

    return HighlightColorPicker(
      onColorSelected: _handleColorSelected,
      onCopy: _handleCopy,
      onShare: _handleShare, // Updated to use new share method
      onAddNote: () => _hideColorPickerModal(),
      onRemoveHighlight: _handleRemoveHighlight,
      onSave: _handleSaveVerse,
      onBookmark: _handleBookmarkVerse,
      isSaved: isSaved,
      isBookmarked: isBookmarked,
      selectedText: _currentVerseText+"\n\n"+'${widget.bookName} ${widget.chapter}:'+ (_currentVerseIndex + 1).toString(),
    );
  }

  // Updated share method with deep link
  void _handleShare() {
    final verseNumber = _currentVerseIndex + 1;
    final verseText = _currentVerseText;
    final reference = '${widget.bookName} ${widget.chapter}:$verseNumber';
    print("hey");
    // Navigate to VersePosterScreen instead of using Share.share()
    Navigator.push(
      context,
      material.MaterialPageRoute(
        builder: (context) => VersePosterScreen(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB), // Purple
              Color(0xFF2575FC), // Blue
            ],
          ),
          verse: verseText,
          reference: reference,
          title: "BIBLE VERSE",
        ),
      ),
    );

    _hideColorPickerModal();
  }

  Future<void> _handleBookmarkVerse() async {
    try {
      final verseNumber = _currentVerseIndex + 1;
      final reference = '${widget.bookName} ${widget.chapter}:$verseNumber';
      final verseText = _currentVerseText;

      final isCurrentlyBookmarked = _bookmarkedVerses[_currentVerseIndex] ?? false;

      if (isCurrentlyBookmarked) {
        final success = await BookmarkApi.removeBookmarkByContent(
          contentType: 'bible',
          category: _getBibleCategory(),
          contentId: reference,
        );

        if (success) {
          setState(() {
            _bookmarkedVerses.remove(_currentVerseIndex);
          });
          _showToast('Bookmark removed');
        }
      } else {
        final bookmarkId = await BookmarkApi.bookmarkBibleVerse(
          category: _getBibleCategory(),
          reference: reference,
          title: reference,
          verseText: verseText,
          bookId: widget.bookId,
          chapter: widget.chapter,
          verse: verseNumber,
        );

        if (bookmarkId > 0) {
          setState(() {
            _bookmarkedVerses[_currentVerseIndex] = true;
          });
          _showToast('Verse bookmarked');
        }
      }

      _hideColorPickerModal();
    } catch (e) {
      //print('Error toggling bookmark: $e');
      _showToast('Failed to update bookmark', isError: true);
    }
  }

  String _getBibleCategory() {
    switch (widget.language.toLowerCase()) {
      case 'english':
        return 'engbible';
      case 'tamil':
        return 'tambible_baminicomp';
      default:
        return 'engbible';
    }
  }

  Future<void> _handleSaveVerse() async {
    try {
      final verseNumber = _currentVerseIndex + 1;

      _hideColorPickerModal();
    } catch (e) {
      //print('Error toggling save: $e');
      _showToast('Failed to update save status', isError: true);
    }
  }

  Future<void> _loadHighlights() async {
    try {
      final highlights = await HighlightHelper.getHighlightsForChapter(
        bookId: widget.bookId,
        chapter: widget.chapter,
        language: widget.language,
      );

      setState(() {
        _highlightedVerses = highlights.map(
              (verse, colorValue) => MapEntry(
            verse - 1,
            colorValue != null ? Color(colorValue) : null,
          ),
        );
      });
    } catch (e) {
      //print('Error loading highlights: $e');
    }
  }

  void _handleColorSelected(Color? color) async {
    try {
      final verseNumber = _currentVerseIndex + 1;

      await HighlightHelper.saveHighlight(
        bookId: widget.bookId,
        chapter: widget.chapter,
        verse: verseNumber,
        colorValue: color?.value,
        language: widget.language,
      );

      setState(() {
        if (color == null) {
          _highlightedVerses.remove(_currentVerseIndex);
        } else {
          _highlightedVerses[_currentVerseIndex] = color;
        }
        _selectedVerseIndex = null;
        _showHighlightModal = false;
      });

      if (color != null) _showToast('Highlight applied');
    } catch (e) {
      //print('Error saving highlight: $e');
      _showToast('Failed to save highlight', isError: true);
    }
  }

  void _handleRemoveHighlight() async {
    try {
      final verseNumber = _currentVerseIndex + 1;

      await HighlightHelper.saveHighlight(
        bookId: widget.bookId,
        chapter: widget.chapter,
        verse: verseNumber,
        colorValue: null,
        language: widget.language,
      );

      setState(() {
        _highlightedVerses.remove(_currentVerseIndex);
        _selectedVerseIndex = null;
        _showHighlightModal = false;
      });

      _showToast('Highlight removed');
    } catch (e) {
      //print('Error removing highlight: $e');
      _showToast('Failed to remove highlight', isError: true);
    }
  }

  void _showSettingsModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => const SettingsModal(),
    );
  }

  void _showColorPickerModal(int verseIndex, String verseText) {
    setState(() {
      _selectedVerseIndex = verseIndex;
      _showHighlightModal = true;
      _currentVerseIndex = verseIndex;
      _currentVerseText = verseText;
    });
  }

  void _hideColorPickerModal() => setState(() => _showHighlightModal = false);

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: _currentVerseText));
    _showToast('Copied to clipboard');
    _hideColorPickerModal();
  }

  bool get _isTablet => MediaQuery.of(context).size.width >= 600;

  /// ✅ FONT HELPER — uses Noto Sans Tamil for Tamil, otherwise SourceSerif4
  TextStyle _getFontStyle({
    required double fontSize,
    required Color color,
    double fontWeightValue = 400,
    double? height,
    Color? backgroundColor,
  }) {
    if (widget.language.toLowerCase() == 'tamil') {
      return TextStyle(
        fontFamily: 'NotoSansTamil',
        fontVariations: [
          FontVariation('wght', fontWeightValue),
        ],
        fontSize: fontSize,
        color: color,
        height: height,
        backgroundColor: backgroundColor,
      );
    }
    return TextStyle(
      fontFamily: 'SourceSerif4',
      fontVariations: [
        FontVariation('wght', fontWeightValue),
      ],
      fontSize: fontSize,
      color: color,
      height: height,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDarkMode = appState.isDarkMode;
    final fontSize = appState.fontSize;

    final backgroundColor =
    isDarkMode ? const Color(0xFF0E151F) : CupertinoColors.white;
    final textColor =
    isDarkMode ? const Color(0xFFFFFFFF) : CupertinoColors.black;
    final verseNumberColor =
    isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color:
                isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.chevron_left, color: textColor),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: appState.toggleTheme,
                  child: Icon(
                    isDarkMode
                        ? CupertinoIcons.sun_max
                        : CupertinoIcons.moon,
                    color: textColor,
                    size: 22,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _showSettingsModal(context),
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: textColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (_selectedVerseIndex != null) {
                  setState(() => _selectedVerseIndex = null);
                }
                if (_showHighlightModal) _hideColorPickerModal();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                '${widget.bookName} ${widget.chapter}',
                                style: _getFontStyle(
                                  fontSize: fontSize * 1.8,
                                  color: textColor,
                                  fontWeightValue: 700,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            _isTablet
                                ? _buildTwoColumnVerses(
                              widget.verses,
                              fontSize,
                              verseNumberColor,
                              textColor,
                              isDarkMode,
                            )
                                : _buildVerseListWidget(
                              widget.verses,
                              fontSize,
                              verseNumberColor,
                              textColor,
                              isDarkMode,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            if (widget.language.toLowerCase() == 'english')
                              Center(
                                child: Text(
                                  'Bible Version: American Standard Version (Public Domain)',
                                  style: TextStyle(
                                    fontFamily: 'SourceSerif4',
                                    fontVariations: const [
                                      FontVariation('wght', 400),
                                    ],
                                    fontSize: fontSize * 0.8,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_showHighlightModal)
          Positioned(bottom: 0, left: 0, right: 0, child: _buildHighlightModal()),
      ],
    );
  }

  Widget _buildVerseListWidget(List<String> verses, double fontSize,
      Color verseNumberColor, Color textColor, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < verses.length; i++)
          _buildSelectableVerseWidget(
            verses[i],
            i,
            fontSize,
            verseNumberColor,
            textColor,
            isDarkMode,
          ),
      ],
    );
  }

  Widget _buildSelectableVerseWidget(String verse, int index, double fontSize,
      Color verseNumberColor, Color textColor, bool isDarkMode) {
    final verseText = verse.trim();
    final Color? highlightColor = _highlightedVerses[index];
    final bool isSelected = _selectedVerseIndex == index;
    final bool isSaved = _savedVerses[index] ?? false;
    final bool isBookmarked = _bookmarkedVerses[index] ?? false;

    // Deep link highlight check
    final bool isDeepLinkHighlight = _verseToHighlight == index && _isHighlighting;

    final Color selectedTextColor = isDarkMode ? Colors.yellow : Colors.red[700]!;
    final double selectedFontWeightValue = 600;
    final double normalFontWeightValue = isDarkMode ? 500 : 400;
    final Color verseTextColor = (highlightColor != null && isDarkMode) ? Colors.black87 : textColor;

    return GestureDetector(
      onTap: () => _showColorPickerModal(index, verse),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDeepLinkHighlight
              ? (isDarkMode ? Colors.yellow.withOpacity(0.3) : Colors.yellow.withOpacity(0.2))
              : isSelected
              ? (isDarkMode ? Colors.white12 : Colors.grey[100])
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isDeepLinkHighlight
              ? Border.all(
            color: isDarkMode ? Colors.yellow : Colors.orange,
            width: 2,
          )
              : null,
          boxShadow: isDeepLinkHighlight
              ? [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Container(
              width: 22,
              alignment: Alignment.topLeft,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: _getFontStyle(
                  fontSize: fontSize * 0.8,
                  fontWeightValue: isSelected || isDeepLinkHighlight
                      ? selectedFontWeightValue
                      : 500,
                  color: isSelected || isDeepLinkHighlight
                      ? selectedTextColor
                      : verseNumberColor,
                ),
                child: Text('${index + 1}'),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: _getFontStyle(
                    fontSize: fontSize,
                    height: 1.45,
                    fontWeightValue: isSelected || isDeepLinkHighlight
                        ? selectedFontWeightValue
                        : normalFontWeightValue,
                    color: isSelected || isDeepLinkHighlight
                        ? selectedTextColor
                        : verseTextColor,
                    backgroundColor: highlightColor,
                  ),
                  children: [
                    TextSpan(text: verseText),
                    if (isSaved)
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Icon(
                            Icons.bookmark,
                            size: fontSize * 0.65,
                            color: isSelected || isDeepLinkHighlight
                                ? selectedTextColor
                                : Colors.orange,
                          ),
                        ),
                      ),
                    if (isBookmarked)
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3),
                          child: Icon(
                            Icons.star,
                            size: fontSize * 0.65,
                            color: isSelected || isDeepLinkHighlight
                                ? selectedTextColor
                                : CupertinoColors.systemYellow,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoColumnVerses(List<String> verses, double fontSize,
      Color verseNumberColor, Color textColor, bool isDarkMode) {
    final int half = (verses.length / 2).ceil();
    final List<String> firstHalf = verses.sublist(0, half);
    final List<String> secondHalf = verses.sublist(half);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < firstHalf.length; i++)
                _buildSelectableVerseWidget(
                  firstHalf[i],
                  i,
                  fontSize,
                  verseNumberColor,
                  textColor,
                  isDarkMode,
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < secondHalf.length; i++)
                _buildSelectableVerseWidget(
                  secondHalf[i],
                  half + i,
                  fontSize,
                  verseNumberColor,
                  textColor,
                  isDarkMode,
                ),
            ],
          ),
        ),
      ],
    );
  }
}