import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tsahymnsv5/screens/christiansongtamil.dart';
import '../state/app_state.dart';
import 'songlistscreen.dart';

class SongLanguageSelectionScreen extends StatefulWidget {
  const SongLanguageSelectionScreen({super.key});

  @override
  State<SongLanguageSelectionScreen> createState() =>
      _SongLanguageSelectionScreenState();
}

class _SongLanguageSelectionScreenState
    extends State<SongLanguageSelectionScreen> {
  String? selectedOption;

  final List<Map<String, String>> songOptions = [
    {'name': 'English TSA Songbook', 'subtitle': ''},
    {'name': 'Tamil TSA Songbook', 'subtitle': 'இரட்சணிய சேனை தமிழ் பாடல்கள்'},
    {'name': 'Christian Songbook Tamil', 'subtitle': 'கிறிஸ்தவ தமிழ் பாடல்கள்'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final selectedSongLanguage = appState.selectedSongLanguage ?? 'English TSA Songbook';
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: appState.isDarkMode
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
            middle: Text(
              'Select Songbook',
              style: TextStyle(
                fontFamily: "Inter",
                fontVariations: [
                  FontVariation('wght', 600),
                ],
                fontSize: 18,
                color: textColor,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: songOptions.length,
                    separatorBuilder: (context, index) => Container(
                      height: 0.5,
                      color: appState.isDarkMode
                          ? const Color(0xFF374151).withOpacity(0.6)
                          : const Color(0xFFE5E7EB).withOpacity(0.6),
                    ),
                    itemBuilder: (context, index) {
                      final option = songOptions[index];
                      final isSelected = option['name'] == selectedSongLanguage;

                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            selectedOption = option['name'];
                          });
                          appState.setSongLanguage(option['name']!);

                          if (option['name'] == 'English TSA Songbook') {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SongListScreen(
                                  selectedLanguage: "English",
                                ),
                              ),
                            );
                          } else if (option['name'] == 'Tamil TSA Songbook') {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => SongListScreen(
                                  selectedLanguage: "தமிழ்",
                                ),
                              ),
                            );
                          } else {
                            // Handle Christian Songbook Tamil selection
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ChristianSongTamilScreen(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          color: CupertinoColors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['name']!,
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontVariations: [
                                          FontVariation('wght', 500),
                                        ],
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      option['subtitle']!,
                                      style: TextStyle(
                                        fontFamily: option['subtitle']!.isNotEmpty
                                            ? "Noto Sans Tamil"
                                            : "Inter",
                                        fontVariations: [
                                          FontVariation('wght', 400),
                                        ],
                                        fontSize: 14,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircleAvatar(
                                      radius: 4,
                                      backgroundColor: CupertinoColors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
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