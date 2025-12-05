import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

import 'bookselectionscreen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'English';
  String selectedValue ='English';
  final List<Map<String, String>> languages = [
    {'name': 'English', 'subtitle': '(Device Language)','value':'English'},
    {'name': 'தமிழ்', 'subtitle': '(Tamil)','value':'Tamil'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final backgroundColor = appState.isDarkMode ? const Color(0xFF0E151F) : CupertinoColors.white;

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
                color: appState.isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            middle: Text(
              'Select Language',
              style: TextStyle(
                fontFamily: "Inter",
                fontVariations: [
                  FontVariation('wght', 600),
                ],
                fontSize: 18,
                color: appState.isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            trailing: Icon(
              CupertinoIcons.search,
              color: appState.isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: languages.length,
                    separatorBuilder: (context, index) => Container(
                      height: 0.5,
                      color: appState.isDarkMode
                          ? const Color(0xFF374151).withOpacity(0.6)
                          : const Color(0xFFE5E7EB).withOpacity(0.6),
                    ),
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final isSelected = language['name'] == selectedLanguage;

                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            selectedLanguage = language['name']!;
                            selectedValue = language['value']!;
                           // print(selectedLanguage);
                          });
                          appState.setLanguage(language['name']!);
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => BookSelectionScreen(language: selectedValue),
                            ),
                          );
                        },
                        child: Container(
                          color: CupertinoColors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      language['name']!,
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontVariations: [
                                          FontVariation('wght', 500),
                                        ],
                                        fontSize: 16,
                                        color: appState.isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      language['subtitle']!,
                                      style: TextStyle(
                                        fontFamily: "Inter",
                                        fontVariations: [
                                          FontVariation('wght', 400),
                                        ],
                                        fontSize: 14,
                                        color: appState.isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
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