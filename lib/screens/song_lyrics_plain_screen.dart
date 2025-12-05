// song_lyrics_plain_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tsahymnsv5/languageutils/tamil_text_encoders.dart';
import '../languageutils/tamiltransliterator.dart';
import '../state/app_state.dart';
import '../widgets/settings_modal.dart';

class SongLyricPlainScreen extends StatefulWidget {
  final int songId;
  final String englishTitle;
  final String tamilTitle;
  final String lyrics;
  final bool isDarkMode;
  final String selectedLanguage;
  final VoidCallback onThemeToggle;

  const SongLyricPlainScreen({
    super.key,
    required this.songId,
    required this.englishTitle,
    required this.tamilTitle,
    required this.lyrics,
    required this.isDarkMode,
    required this.selectedLanguage,
    required this.onThemeToggle,
  });

  @override
  State<SongLyricPlainScreen> createState() => _SongLyricPlainScreenState();
}

class _SongLyricPlainScreenState extends State<SongLyricPlainScreen> {
  // Local state for Tamil display mode
  int _tamilDisplayMode = 0; // 0 = Tamil, 1 = Tamil Transliterated

  // Helper function to remove HTML tags and clean the text
  String _cleanLyrics(String lyrics) {
    // Remove basic HTML tags
    String cleaned = lyrics.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    cleaned = cleaned
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');

    return cleaned.trim();
  }

  // Helper function to remove the first line for Tamil content
  String _processLyrics(String lyrics, bool isTamil) {
    if (!isTamil) return _cleanLyrics(lyrics);

    // Split the lyrics into lines
    final lines = _cleanLyrics(lyrics).split('\n');

    // Remove the first line if there's more than one line
    if (lines.length > 1) {
      return lines.sublist(0).join('\n');
    }

    // Return empty string if there's only one line
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final backgroundColor = appState.isDarkMode ? const Color(0xFF0E151F) : CupertinoColors.white;
    final textColor = appState.isDarkMode ? const Color(0xFFFFFFFF) : CupertinoColors.black;
    final secondaryTextColor = appState.isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final fontSize = appState.fontSize;

    // Check if the selected language is Tamil (main language)
    final bool isMainLanguageTamil = widget.selectedLanguage == "தமிழ்";

    // Only show segmented control if main language is Tamil
    final bool showTamilOptions = isMainLanguageTamil;

    // Convert lyrics to Unicode and process them
    String convertedLyrics = TamilConverter.convertToUnicode(widget.lyrics);
    String processedLyrics = _processLyrics(convertedLyrics, isMainLanguageTamil);

    // Apply transliteration if Tamil Transliterated mode is selected
    if (showTamilOptions && _tamilDisplayMode == 1) {
      processedLyrics = TamilTransliterator().transliterate(processedLyrics);
    }

    // Determine if we're showing Tamil script or transliterated text
    final bool showingTamilScript = showTamilOptions && _tamilDisplayMode == 0;
    final bool showingTransliterated = showTamilOptions && _tamilDisplayMode == 1;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: widget.isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
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
          showingTamilScript ? 'பாடல்' : 'Song',
          style: TextStyle(
            fontFamily: showingTamilScript ? "Noto Sans Tamil" : "Inter",
            fontVariations: [
              FontVariation('wght', 600),
            ],
            color: textColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onThemeToggle,
              child: Icon(
                widget.isDarkMode ? CupertinoIcons.sun_max : CupertinoIcons.moon,
                color: textColor,
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (_) => const SettingsModal(),
                );
              },
              child: Icon(
                CupertinoIcons.ellipsis,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Moved Segmented Control Here
              if (showTamilOptions)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _tamilDisplayMode,
                      children: const {
                        0: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Text('தமிழ்'),
                        ),
                        1: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Text('English'),
                        ),
                      },
                      onValueChanged: (value) {
                        setState(() {
                          _tamilDisplayMode = value ?? 0;
                        });
                      },
                      backgroundColor: appState.isDarkMode
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      thumbColor: appState.isDarkMode
                          ? appState.getAccentColor()
                          : appState.getAccentColor(),
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Title display (swapped logic for Tamil/Transliterated)
              Center(
                child: Text(
                  showingTamilScript ? widget.tamilTitle : widget.englishTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: showingTamilScript ? "NotoSansTamil" : "SourceSerif4",
                    fontVariations: [
                      FontVariation('wght', 600),
                    ],
                    fontSize: 28,
                    color: textColor,
                  ),
                ),
              ),

              if (widget.englishTitle.isNotEmpty && widget.tamilTitle.isNotEmpty)
                const SizedBox(height: 6),
              if (widget.englishTitle.isNotEmpty && widget.tamilTitle.isNotEmpty)
                Center(
                  child: Text(
                    showingTamilScript ? widget.englishTitle : widget.tamilTitle,
                    style: TextStyle(
                      fontFamily: showingTamilScript ? "SourceSerif4" : "NotoSansTamil",
                      fontVariations: [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: secondaryTextColor,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              processedLyrics.isNotEmpty
                  ? Text(
                processedLyrics,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: showingTamilScript ? "NotoSansTamil" : "SourceSerif4",
                  fontVariations: [
                    FontVariation('wght', 400),
                  ],
                  fontSize: fontSize,
                  height: 1.8,
                  color: textColor,
                ),
              )
                  : Center(
                child: Text(
                  'No lyrics available',
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontVariations: [
                      FontVariation('wght', 400),
                    ],
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}