import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../languageutils/tamiltransliterator.dart';
import '../state/app_state.dart';
import '../widgets/settings_modal.dart';

class SongLyricScreen extends StatefulWidget {
  final String songTitle;
  final String artist;
  final String lyrics;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final String selectedLanguage;

  const SongLyricScreen({
    super.key,
    required this.songTitle,
    required this.artist,
    required this.lyrics,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.selectedLanguage,
  });

  @override
  State<SongLyricScreen> createState() => _SongLyricScreenState();
}

class _SongLyricScreenState extends State<SongLyricScreen> {
  int _selectedSegment = 0;
  late TamilTransliterator _transliterator;

  @override
  void initState() {
    super.initState();
    _transliterator = TamilTransliterator();
    _selectedSegment = widget.selectedLanguage == "தமிழ்" ? 0 : 1;
  }

  @override
  void didUpdateWidget(covariant SongLyricScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLanguage != widget.selectedLanguage) {
      setState(() {
        _selectedSegment = widget.selectedLanguage == "தமிழ்" ? 0 : 1;
      });
    }
  }

  String _processLyrics(String lyrics, bool isTamil) {
    if (!isTamil) return lyrics;
    final lines = lyrics.split('\n');
    if (lines.length > 2) {
      return lines.sublist(2).join('\n');
    }
    return '';
  }

  String? _extractAuthorFromTamilLyrics(String lyrics) {
    final lines = lyrics.trim().split('\n');
    if (lines.isEmpty) return null;

    final lastLine = lines.last.trim();
    final regex = RegExp(r'\*\*(.+?)\*\*');
    final match = regex.firstMatch(lastLine);

    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim();
    }
    return null;
  }

  String _getDisplayTitle() {
    final bool isTamil = widget.selectedLanguage == "தமிழ்";

    if (!isTamil) return widget.songTitle;

    if (_selectedSegment == 0) return widget.songTitle;
    return _transliterator.toEnglish(widget.songTitle);
  }

  String _getDisplayArtist(String? extractedAuthor) {
    final bool isTamil = widget.selectedLanguage == "தமிழ்";

    if (extractedAuthor != null && extractedAuthor.isNotEmpty) {
      return extractedAuthor + '\n' + widget.artist;
    }

    if (!isTamil || widget.artist.isEmpty) return widget.artist;

    if (_selectedSegment == 0) return widget.artist;

    return _transliterator.toEnglish(widget.artist);
  }

  String _getDisplayLyrics() {
    final bool isTamil = widget.selectedLanguage == "தமிழ்";

    if (!isTamil) return widget.lyrics;

    final processedLyrics = _processLyrics(widget.lyrics, true);

    if (_selectedSegment == 0) return processedLyrics;

    return _transliterator.transliterate(processedLyrics);
  }

  TextStyle _getTextStyle(double fontSize, Color textColor, bool isParagraph) {
    final height = isParagraph ? 1.8 : null;

    return TextStyle(
      fontFamily: "SourceSerif4",
      fontSize: fontSize,
      color: textColor,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    final backgroundColor = appState.isDarkMode
        ? const Color(0xFF0E151F)
        : CupertinoColors.white;

    final textColor =
    appState.isDarkMode ? const Color(0xFFFFFFFF) : CupertinoColors.black;

    final fontSize = appState.fontSize;
    final bool isTamil = widget.selectedLanguage == "தமிழ்";

    final String? extractedAuthor =
    isTamil ? _extractAuthorFromTamilLyrics(widget.lyrics) : '';

    final displayTitle = _getDisplayTitle();
    final displayArtist = _getDisplayArtist(extractedAuthor);
    final displayLyrics = _getDisplayLyrics();

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        border: Border(
          bottom: BorderSide(
            color: widget.isDarkMode
                ? const Color(0xFF374151)
                : const Color(0xFFE5E7EB),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onThemeToggle,
              child: Icon(
                widget.isDarkMode
                    ? CupertinoIcons.sun_max
                    : CupertinoIcons.moon,
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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    displayTitle,
                    textAlign: TextAlign.center,
                    style: _getTextStyle(28, textColor, false).copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: "SourceSerif4",
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              if (displayArtist.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Center(
                    child: Text(
                      displayArtist,
                      textAlign: TextAlign.center,
                      style: _getTextStyle(
                          16, textColor.withOpacity(0.7), false)
                          .copyWith(
                        fontStyle: FontStyle.italic,
                        fontFamily: "SourceSerif4",
                      ),
                    ),
                  ),
                ),

              if (isTamil) ...[
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 40.0),
                    decoration: BoxDecoration(
                      color: appState.getBackgroundSecondaryColor(),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: _selectedSegment,
                      backgroundColor: Colors.transparent,
                      thumbColor: appState.getAccentColor(),
                      children: {
                        0: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text(
                            'தமிழ்',
                            style: TextStyle(
                              fontFamily: "Inter",
                              color: _selectedSegment == 0
                                  ? CupertinoColors.destructiveRed
                                  : appState
                                  .getTextColor()
                                  .withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        1: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          child: Text(
                            'English',
                            style: TextStyle(
                              fontFamily: "Inter",
                              color: _selectedSegment == 1
                                  ? CupertinoColors.destructiveRed
                                  : appState
                                  .getTextColor()
                                  .withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (value) {
                        setState(() {
                          _selectedSegment = value ?? 0;
                        });
                      },
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: isTamil
                    ? MarkdownBody(
                  data: displayLyrics.trim(),
                  styleSheet: MarkdownStyleSheet(
                    p: _getTextStyle(fontSize, textColor, true),
                    h1: _getTextStyle(
                        fontSize * 1.8, textColor, false)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: "SourceSerif4",
                    ),
                    h2: _getTextStyle(
                        fontSize * 1.6, textColor, false)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: "SourceSerif4",
                    ),
                    h3: _getTextStyle(
                        fontSize * 1.4, textColor, false)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: "SourceSerif4",
                    ),
                    listBullet:
                    _getTextStyle(fontSize, textColor, true),
                    blockquote: _getTextStyle(
                        fontSize, textColor, true)
                        .copyWith(
                      fontStyle: FontStyle.italic,
                      fontFamily: "SourceSerif4",
                    ),
                    code: _getTextStyle(
                        fontSize, textColor, true)
                        .copyWith(
                      backgroundColor:
                      textColor.withOpacity(0.1),
                      fontFamily: "SourceSerif4",
                    ),
                  ),
                )
                    : Text(
                  displayLyrics.trim(),
                  textAlign: TextAlign.start,
                  style: _getTextStyle(
                      fontSize, textColor, true),
                ),
              ),

              const SizedBox(height: 20),

              Divider(
                color: appState.isDarkMode
                    ? const Color(0xFF374151)
                    : const Color(0xFFE5E7EB),
                height: 0.5,
                thickness: 0.5,
              ),

              const SizedBox(height: 10),

              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        displayTitle,
                        textAlign: TextAlign.center,
                        style: _getTextStyle(
                            14, textColor, false)
                            .copyWith(
                          fontWeight: FontWeight.w600,
                          fontFamily: "SourceSerif4",
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (displayArtist.isNotEmpty)
                        Text(
                          isTamil
                              ? displayArtist
                              : 'Words: $displayArtist',
                          textAlign: TextAlign.center,
                          style: _getTextStyle(
                              14, textColor.withOpacity(0.8), false)
                              .copyWith(
                            fontFamily: "SourceSerif4",
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '© The General of the Salvation Army',
                        textAlign: TextAlign.center,
                        style: _getTextStyle(
                            14, textColor.withOpacity(0.7), false)
                            .copyWith(
                          fontStyle: FontStyle.italic,
                          fontFamily: "SourceSerif4",
                        ),
                      ),
                    ],
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
