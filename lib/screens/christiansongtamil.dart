import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../backend/songs_api.dart';
import '../screens/song_lyrics_plain_screen.dart';

class ChristianSongTamilScreen extends StatefulWidget {
  const ChristianSongTamilScreen({super.key});

  @override
  State<ChristianSongTamilScreen> createState() => _ChristianSongTamilScreenState();
}

class _ChristianSongTamilScreenState extends State<ChristianSongTamilScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedSegment = 0;
  String _selectedLetter = '';
  List<Map<String, dynamic>> _allSongs = [];
  List<Map<String, dynamic>> _filteredSongs = [];
  bool _isLoading = false;
  bool _showSongList = false;
  bool _isSearchMode = false;

  // Fuzzy search instance
  late Fuzzy<Map<String, dynamic>> _fuzzySearch;

  // English letters A-Z
  final List<String> _englishLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  // Tamil letters (vowels and consonants combined)
  final List<String> _tamilLetters = [
    'அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ', 'ஓ', 'ஔ',
    'க்', 'ங்', 'ச்', 'ஞ்', 'ட்', 'ண்', 'த்', 'ந்', 'ப்', 'ம்', 'ய்', 'ர்',
    'ல்', 'வ்', 'ழ்', 'ள்', 'ற்', 'ன்'
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSongs);
    // Initialize fuzzy search with empty list, will update when songs are loaded
    _fuzzySearch = Fuzzy(
      [],
      options: FuzzyOptions(
        keys: [
          WeightedKey<Map<String, dynamic>>(
            name: 'englishheading',
            getter: (song) => song['englishheading']?.toString() ?? '',
            weight: 1.0,
          ),
          WeightedKey<Map<String, dynamic>>(
            name: 'tamilheading',
            getter: (song) => song['tamilheading']?.toString() ?? '',
            weight: 1.0,
          ),
        ],
        threshold: 0.01, // Adjust this value for more/less strict matching
        //sort: true,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSongs);
    _searchController.dispose();
    super.dispose();
  }

  // Fetch all songs for search
  Future<void> _fetchAllSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _allSongs = await SongApi.getAllSongs();
      // Update fuzzy search with all songs
      _fuzzySearch = Fuzzy(
        _allSongs,
        options: FuzzyOptions(
          keys: [
            WeightedKey<Map<String, dynamic>>(
              name: 'englishheading',
              getter: (song) => song['englishheading']?.toString() ?? '',
              weight: 1.0,
            ),
            WeightedKey<Map<String, dynamic>>(
              name: 'tamilheading',
              getter: (song) => song['tamilheading']?.toString() ?? '',
              weight: 1.0,
            ),
          ],
          threshold: 0.3,
          //sort: true,
        ),
      );
      _filteredSongs = List.from(_allSongs);
    } catch (e) {
      //print('Error fetching all songs: $e');
      _allSongs = [];
      _filteredSongs = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSongsByLetter(String letter) async {
    if (letter.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSongList = true;
      _isSearchMode = false;
    });

    try {
      _allSongs = await SongApi.getSongsByLetter(letter, _selectedSegment);
      _filteredSongs = List.from(_allSongs);
    } catch (e) {
      //print('Error fetching songs: $e');
      _allSongs = [];
      _filteredSongs = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSongs() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      if (_isSearchMode) {
        _filteredSongs = List.from(_allSongs);
      }
      return;
    }

    setState(() {
      if (_isSearchMode) {
        // Use fuzzy search for better matching
        final results = _fuzzySearch.search(query);
        _filteredSongs = results.map((result) => result.item).toList();
      } else {
        // Regular search for letter-based browsing
        final queryLower = query.toLowerCase();
        _filteredSongs = _allSongs.where((song) {
          final englishHeading = song['englishheading']?.toString().toLowerCase() ?? '';
          final tamilHeading = song['tamilheading']?.toString().toLowerCase() ?? '';
          return englishHeading.contains(queryLower) || tamilHeading.contains(queryLower);
        }).toList();
      }
    });
  }

  // Handle search mode
  void _handleSearch() {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearchMode = true;
      _showSongList = true;
      _selectedLetter = '';
    });

    if (_allSongs.isEmpty) {
      _fetchAllSongs();
    } else {
      _filterSongs();
    }
  }

  String _getDisplayTitle(Map<String, dynamic> song) {
    final englishHeading = song['englishheading']?.toString() ?? '';
    final tamilHeading = song['tamilheading']?.toString() ?? '';

    if (_selectedSegment == 0) {
      return tamilHeading.isNotEmpty
          ? '$englishHeading ($tamilHeading)'
          : englishHeading;
    } else {
      return englishHeading.isNotEmpty
          ? '$tamilHeading ($englishHeading)'
          : tamilHeading;
    }
  }

  void _handleLetterSelection(String letter) {
    setState(() {
      _selectedLetter = letter;
      _isSearchMode = false;
    });
    _fetchSongsByLetter(letter);
  }

  void _handleBackToLetters() {
    setState(() {
      _showSongList = false;
      _isSearchMode = false;
      _selectedLetter = '';
      _searchController.clear();
      _allSongs = [];
      _filteredSongs = [];
    });
  }

  Future<void> _handleSongTap(Map<String, dynamic> song, bool isDarkMode) async {
    try {
      final songId = song['id'] as int;
      final lyricsData = await SongApi.getLyrics(songId);

      if (lyricsData != null) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => SongLyricPlainScreen(
              songId: songId,
              englishTitle: lyricsData['englishheading']?.toString() ?? '',
              tamilTitle: lyricsData['tamilheading']?.toString() ?? '',
              lyrics: lyricsData['lyrics_html']?.toString() ?? '',
              isDarkMode: isDarkMode,
              selectedLanguage: 'தமிழ்',
              onThemeToggle: () {
                Provider.of<AppState>(context, listen: false).toggleTheme();
              },
            ),
          ),
        );
      }
    } catch (e) {
      //print('Error loading song lyrics: $e');
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Could not load song lyrics.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  // Helper method to create TextStyle with Montserrat
  TextStyle _textStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: "Montserrat",
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontVariations: fontWeight == FontWeight.normal
          ? null
          : [FontVariation('wght', fontWeight.index * 100.0)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final cardColor = appState.getCardColor();
        final secondaryTextColor = appState.getSecondaryTextColor();
        final accentColor = CupertinoColors.systemRed;

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            border: null,
            leading: _showSongList
                ? CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _handleBackToLetters,
              child: Icon(
                CupertinoIcons.chevron_left,
                color: textColor,
                size: 24,
              ),
            )
                : CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(
                CupertinoIcons.chevron_left,
                color: textColor,
                size: 24,
              ),
            ),
            middle: Text(
              _isSearchMode
                  ? 'Search Results'
                  : _showSongList ? '$_selectedLetter Songs' : 'Christian Songs',
              style: _textStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
          child: SafeArea(
            child: _showSongList
                ? _buildSongList(textColor, backgroundColor, cardColor, secondaryTextColor, appState.isDarkMode)
                : _buildLetterSelection(textColor, cardColor, secondaryTextColor, accentColor),
          ),
        );
      },
    );
  }

  Widget _buildLetterSelection(Color textColor, Color cardColor, Color secondaryTextColor, Color accentColor) {
    return Column(
      children: [
        // Search Bar at the top
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: secondaryTextColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _searchController,
                  placeholder: 'Search any song...',
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: null,
                  style: _textStyle(color: textColor),
                  placeholderStyle: _textStyle(color: secondaryTextColor),
                  onSubmitted: (value) => _handleSearch(),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 8),
                  minSize: 0,
                  onPressed: _handleSearch,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_right,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Header Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: secondaryTextColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.music_note_2,
                  size: 32,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Christian Songs',
                style: _textStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search any song or browse by language and starting letter',
                style: _textStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Segmented Control
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: secondaryTextColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedSegment == 0 ? accentColor : Colors.transparent,
                  onPressed: () => setState(() {
                    _selectedSegment = 0;
                    _selectedLetter = '';
                  }),
                  child: Text(
                    'English',
                    style: _textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedSegment == 0 ? CupertinoColors.white : textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedSegment == 1 ? accentColor : Colors.transparent,
                  onPressed: () => setState(() {
                    _selectedSegment = 1;
                    _selectedLetter = '';
                  }),
                  child: Text(
                    'தமிழ்',
                    style: _textStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedSegment == 1 ? CupertinoColors.white : textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selected Letter Indicator
        if (_selectedLetter.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.arrow_right,
                  size: 14,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected: $_selectedLetter',
                  style: _textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),

        // Letters Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _selectedSegment == 0
                ? _buildEnglishLettersGrid(textColor, cardColor, secondaryTextColor, accentColor)
                : _buildTamilLettersGrid(textColor, cardColor, secondaryTextColor, accentColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSongList(Color textColor, Color backgroundColor, Color cardColor, Color secondaryTextColor, bool isDarkMode) {
    return Column(
      children: [
        // Search Bar in song list
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: secondaryTextColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: _searchController,
                  placeholder: _isSearchMode ? 'Search any song...' : 'Search in $_selectedLetter songs...',
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: secondaryTextColor,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: null,
                  style: _textStyle(color: textColor),
                  placeholderStyle: _textStyle(color: secondaryTextColor),
                  onSubmitted: (value) {
                    if (_isSearchMode) {
                      _handleSearch();
                    } else {
                      _filterSongs();
                    }
                  },
                ),
              ),
              if (_searchController.text.isNotEmpty)
                CupertinoButton(
                  padding: const EdgeInsets.only(left: 8),
                  minSize: 0,
                  onPressed: _isSearchMode ? _handleSearch : _filterSongs,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                     // color: accentColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_right,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Results Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: secondaryTextColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSearchMode
                    ? 'Search Results'
                    : 'Songs starting with "$_selectedLetter"',
                style: _textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_filteredSongs.length}',
                  style: _textStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.systemBlue,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Songs List
        Expanded(
          child: _isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : _filteredSongs.isEmpty
              ? _buildEmptyState(textColor, secondaryTextColor)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _filteredSongs.length,
            itemBuilder: (context, index) {
              final song = _filteredSongs[index];
              final title = _getDisplayTitle(song);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: secondaryTextColor.withOpacity(0.1),
                  ),
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.all(16),
                  onPressed: () => _handleSongTap(song, isDarkMode),
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
                        child: Text(
                          title,
                          style: _textStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryTextColor) {
    return Center(
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
              CupertinoIcons.music_note_list,
              size: 40,
              color: secondaryTextColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _allSongs.isEmpty ? 'No songs found' : 'No matching songs',
            style: _textStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearchMode
                ? 'No songs found for "${_searchController.text}"'
                : _allSongs.isEmpty
                ? 'No songs starting with "$_selectedLetter"'
                : 'Try a different search term',
            style: _textStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnglishLettersGrid(Color textColor, Color cardColor, Color secondaryTextColor, Color accentColor) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _englishLetters.length,
      itemBuilder: (context, index) {
        final letter = _englishLetters[index];
        final isSelected = _selectedLetter == letter;

        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _handleLetterSelection(letter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accentColor : secondaryTextColor.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [],
            ),
            child: Center(
              child: Text(
                letter,
                style: _textStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? CupertinoColors.white : textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTamilLettersGrid(Color textColor, Color cardColor, Color secondaryTextColor, Color accentColor) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: _tamilLetters.length,
      itemBuilder: (context, index) {
        final letter = _tamilLetters[index];
        final isSelected = _selectedLetter == letter;

        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _handleLetterSelection(letter),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accentColor : secondaryTextColor.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [],
            ),
            child: Center(
              child: Text(
                letter,
                style: _textStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? CupertinoColors.white : textColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}