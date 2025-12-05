import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tsahymnsv5/screens/song_lyrics_screen.dart';
import '../backend/bookmarkapi.dart'; // Updated import
import '../backend/songs_api.dart';
import '../state/app_state.dart';
import 'song_lyrics_screen.dart';

class SongListScreen extends StatefulWidget {
  final String selectedLanguage;

  const SongListScreen({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  List<Map<String, dynamic>> songData = [];
  List<Map<String, dynamic>> filteredSongs = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  Set<String> bookmarkedSongs = {};

  @override
  void initState() {
    super.initState();
    fetchSongs();
    _loadBookmarks();
    searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterSongs);
    searchController.dispose();
    super.dispose();
  }

  // ✅ UPDATED: Load bookmarks using new centralized system
  Future<void> _loadBookmarks() async {
    try {
      final bookmarks = await BookmarkApi.getSongBookmarks();
      setState(() {
        bookmarkedSongs = Set<String>.from(bookmarks.map((bookmark) {
          final category = bookmark.category;
          final contentId = bookmark.contentId;
          return '$category-$contentId';
        }));
      });
    } catch (e) {
      //print('Error loading bookmarks: $e');
    }
  }

  // ✅ UPDATED: Get category based on selected language
  String get _category {
    switch (widget.selectedLanguage) {
      case "English":
        return "engtsasong";
      case "தமிழ்":
        return "tsatamsong";
      default:
        return "engtsasong";
    }
  }

  // ✅ UPDATED: Check if song is bookmarked
  bool _isBookmarked(Map<String, dynamic> song) {
    final songId = _getSongId(song);
    return bookmarkedSongs.contains('$_category-$songId');
  }

  String _getSongId(Map<String, dynamic> song) {
    if (widget.selectedLanguage == "English") {
      return song['songid']?.toString() ?? '';
    } else {
      return song['id']?.toString() ?? '';
    }
  }

  String _getSongTitle(Map<String, dynamic> song) {
    if (widget.selectedLanguage == "English") {
      return '${song['heading'] ?? ''}';
    } else {
      String title = song['heading']?.toString() ?? 'No Title';
      if (title.startsWith('பாடல் :')) {
        title = title.substring('பாடல் :'.length).trim();
      }
      return title.isEmpty || title == 'No Title' ? 'பாடல்' : title;
    }
  }

  // ✅ UPDATED: Toggle bookmark using new centralized system
  Future<void> _toggleBookmark(Map<String, dynamic> song) async {
    try {
      final songId = _getSongId(song);
      final bookmarkKey = '$_category-$songId';
      final songTitle = _getSongTitle(song);

      if (_isBookmarked(song)) {
        // Remove bookmark
        final success = await BookmarkApi.removeBookmarkByContent(
          contentType: 'song',
          category: _category,
          contentId: songId,
        );

        if (success) {
          setState(() {
            bookmarkedSongs.remove(bookmarkKey);
          });
        }
      } else {
        // Add bookmark
        final bookmarkId = await BookmarkApi.bookmarkSong(
          category: _category,
          songId: songId,
          title: songTitle,
          metadata: {
            'heading': songTitle,
            ...(
                widget.selectedLanguage == "தமிழ்"
                    ? {
                  'old': song['old']?.toString() ?? '',
                  'new': song['new']?.toString() ?? '',
                }
                    : {
                  'songid': songId,
                }
            ),
          },
        );

        if (bookmarkId > 0) {
          setState(() {
            bookmarkedSongs.add(bookmarkKey);
          });
        }
      }
    } catch (e) {
      //print('Error toggling bookmark: $e');
    }
  }

  // ✅ Check if specific content is bookmarked (for real-time updates)
  Future<void> _checkBookmarkStatus(Map<String, dynamic> song) async {
    try {
      final songId = _getSongId(song);
      final isCurrentlyBookmarked = await BookmarkApi.isBookmarked(
        contentType: 'song',
        category: _category,
        contentId: songId,
      );

      final bookmarkKey = '$_category-$songId';

      setState(() {
        if (isCurrentlyBookmarked) {
          bookmarkedSongs.add(bookmarkKey);
        } else {
          bookmarkedSongs.remove(bookmarkKey);
        }
      });
    } catch (e) {
      //print('Error checking bookmark status: $e');
    }
  }

  // ✅ UPDATED: Fetch songs (no changes needed here)
  Future<void> fetchSongs() async {
    //print('Fetching songs for: ${widget.selectedLanguage}');
    try {
      List<Map<String, dynamic>> result;

      if (widget.selectedLanguage == "English") {
        result = await SongApi.getEnglishSongHeadings();
      } else if (widget.selectedLanguage == "தமிழ்") {
        result = await SongApi.getTamilSongHeadings();
      } else {
        result = [];
      }

      setState(() {
        songData = result;
        filteredSongs = result;
        isLoading = false;
      });

      //print('Loaded ${songData.length} songs.');
    } catch (e) {
      //print('Error fetching songs: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterSongs() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredSongs = songData;
      } else {
        filteredSongs = songData.where((song) {
          if (widget.selectedLanguage == "தமிழ்") {
            final title = song['heading']?.toString().toLowerCase() ?? '';
            final old = song['old']?.toString().toLowerCase() ?? '';
            final newno = song['new']?.toString().toLowerCase() ?? '';
            return title.contains(query) ||
                old.contains(query) ||
                newno.contains(query);
          } else {
            final title = song['heading']?.toString().toLowerCase() ?? '';
            return title.contains(query);
          }
        }).toList();
      }
    });
  }

  // ✅ UPDATED: Handle song tap with bookmark status check
  Future<void> _handleSongTap(
      Map<String, dynamic> song, bool isDarkMode) async {
    try {
      // Refresh bookmark status when song is tapped
      await _checkBookmarkStatus(song);

      String title;
      String lyrics = '';
      String artist = "Unknown Artist";

      if (widget.selectedLanguage == "English") {
        int songId = int.tryParse(song['songid']?.toString() ?? '') ?? 0;
        final songDetail = await SongApi.getEnglishLyrics(songId);
        if (songDetail != null) {
          title = songDetail['heading'] ?? 'Untitled';
          lyrics = songDetail['lyrics'] ?? 'Lyrics not found.';
          artist = songDetail['author'] ?? 'Author not found';
        } else {
          title = 'Not Found';
          lyrics = 'No lyrics available.';
          artist = 'Author not found';
        }
      } else {
        int songNo = int.tryParse(song['id']?.toString() ?? '') ?? 0;
        final songDetail = await SongApi.getTamilLyrics(songNo);

        if (songDetail != null) {
          title = songDetail['heading'] ?? 'Untitled';
          if (title.startsWith('பாடல் :')) {
            title = title.substring('பாடல் :'.length).trim();
          }
          lyrics = songDetail['content'] ?? 'Lyrics not found.';
        } else {
          title = 'Not Found';
          lyrics = 'No lyrics available.';
        }

        final oldNum = song['old']?.toString() ?? '';
        final newNum = song['new']?.toString() ?? '';
        artist = "Old: $oldNum    New: $newNum";
      }

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => SongLyricScreen(
            songTitle: title,
            artist: artist,
            isDarkMode: isDarkMode,
            selectedLanguage: widget.selectedLanguage,
            onThemeToggle: () {
              Provider.of<AppState>(context, listen: false).toggleTheme();
              setState(() {});
            },
            lyrics: lyrics,
          ),
        ),
      ).then((_) {
        // Refresh bookmark status when returning from lyrics screen
        _checkBookmarkStatus(song);
      });
    } catch (e) {
      //print('Error loading lyrics: $e');
    }
  }

  // ✅ Card builders updated with TTF fonts
  Widget _buildTamilSongCard(
      Map<String, dynamic> song,
      Color cardColor,
      Color textColor,
      Color secondaryTextColor,
      bool isBookmarked,
      ) {
    final oldNumber = song['old']?.toString().trim() ?? '';
    final newNumber = song['new']?.toString().trim() ?? '';
    final title = _getSongTitle(song);

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secondaryTextColor.withOpacity(0.2),
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () => _handleSongTap(
          song,
          Provider.of<AppState>(context, listen: false).isDarkMode,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.music_note_2,
                size: 20,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Source Serif 4",
                        fontVariations: [
                          FontVariation('wght', 600),
                        ],
                        fontSize: 15.5,
                        color: textColor,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),

                  if (oldNumber.isNotEmpty || newNumber.isNotEmpty)
                    Row(
                      children: [
                        if (oldNumber.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'பழைய: ',
                                style: TextStyle(
                                  fontFamily: "Noto Sans Tamil",
                                  fontVariations: [
                                    FontVariation('wght', 500),
                                  ],
                                  fontSize: 13.5,
                                  color: CupertinoColors.systemRed,
                                ),
                              ),
                              Text(
                                oldNumber,
                                style: TextStyle(
                                  fontFamily: "Noto Sans Tamil",
                                  fontVariations: [
                                    FontVariation('wght', 600),
                                  ],
                                  fontSize: 13.5,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        if (oldNumber.isNotEmpty && newNumber.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Container(
                              width: 1,
                              height: 12,
                              color: secondaryTextColor.withOpacity(0.3),
                            ),
                          ),
                        if (newNumber.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'புதிய: ',
                                style: TextStyle(
                                  fontFamily: "Noto Sans Tamil",
                                  fontVariations: [
                                    FontVariation('wght', 500),
                                  ],
                                  fontSize: 13.5,
                                  color: CupertinoColors.systemBlue,
                                ),
                              ),
                              Text(
                                newNumber,
                                style: TextStyle(
                                  fontFamily: "Noto Sans Tamil",
                                  fontVariations: [
                                    FontVariation('wght', 600),
                                  ],
                                  fontSize: 13.5,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  if (oldNumber.isEmpty && newNumber.isEmpty)
                    Text(
                      'எண்கள் இல்லை',
                      style: TextStyle(
                        fontFamily: "Noto Sans Tamil",
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 13.5,
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
              onPressed: () => _toggleBookmark(song),
              child: Icon(
                isBookmarked
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                color: isBookmarked
                    ? CupertinoColors.systemYellow
                    : secondaryTextColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnglishSongCard(
      Map<String, dynamic> song,
      Color cardColor,
      Color textColor,
      Color secondaryTextColor,
      bool isBookmarked,
      ) {
    final title = _getSongTitle(song);
    final songId = song['songid']?.toString() ?? '';

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secondaryTextColor.withOpacity(0.2),
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () => _handleSongTap(
          song,
          Provider.of<AppState>(context, listen: false).isDarkMode,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.music_note_2,
                size: 20,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontVariations: [
                          FontVariation('wght', 600),
                        ],
                        fontSize: 15.5,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (songId.isNotEmpty)
                    Text(
                      'Song $songId',
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 13.5,
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
              onPressed: () => _toggleBookmark(song),
              child: Icon(
                isBookmarked
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                color: isBookmarked
                    ? CupertinoColors.systemYellow
                    : secondaryTextColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
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
              "Songs - ${widget.selectedLanguage}",
              style: TextStyle(
                fontFamily: "Inter",
                fontVariations: [
                  FontVariation('wght', 700),
                ],
                fontSize: 18,
                color: textColor,
              ),
            ),
          ),
          child: SafeArea(
            child: isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : songData.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.music_note_list,
                    size: 64,
                    color: secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No songs found",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontVariations: [
                        FontVariation('wght', 600),
                      ],
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Failed to load songs",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            )
                : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: secondaryTextColor.withOpacity(0.2),
                      ),
                    ),
                    child: CupertinoTextField(
                      controller: searchController,
                      placeholder: widget.selectedLanguage == "தமிழ்"
                          ? 'பாடல்களை தேடுங்கள்...'
                          : 'Search songs...',
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(
                          CupertinoIcons.search,
                          size: 18,
                          color: secondaryTextColor,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: null,
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        color: textColor,
                      ),
                      placeholderStyle: TextStyle(
                        fontFamily: "Inter",
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                if (searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.selectedLanguage == "தமிழ்"
                            ? '${filteredSongs.length} ${filteredSongs.length == 1 ? 'முடிவு' : 'முடிவுகள்'}'
                            : '${filteredSongs.length} ${filteredSongs.length == 1 ? 'result' : 'results'}',
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontVariations: [
                            FontVariation('wght', 500),
                          ],
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, index) {
                      final song = filteredSongs[index];
                      final isBookmarked = _isBookmarked(song);

                      return widget.selectedLanguage == "தமிழ்"
                          ? _buildTamilSongCard(
                          song,
                          cardColor,
                          textColor,
                          secondaryTextColor,
                          isBookmarked)
                          : _buildEnglishSongCard(
                          song,
                          cardColor,
                          textColor,
                          secondaryTextColor,
                          isBookmarked);
                    },
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