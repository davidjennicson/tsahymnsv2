import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class CustomRoundedSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const CustomRoundedSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value - min) / (max - min);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPos = box.globalToLocal(details.globalPosition);
        final newValue = (localPos.dx / box.size.width) * (max - min) + min;
        onChanged(newValue.clamp(min, max));
      },
      child: Container(
        height: 22,
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Align(
              alignment: Alignment(progress * 2 - 1, 0),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemRed.withOpacity(0.4),
                      blurRadius: 4,
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
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();
        final cardColor = appState.getCardColor();
        const accentColor = CupertinoColors.systemRed;

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
              'Settings',
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
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Appearance Section
                      _buildSectionHeader('Appearance'),
                      const SizedBox(height: 8),

                      // TEXT SIZE CARD (slider moved below)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: accentColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.textformat_size,
                                      size: 20,
                                      color: accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Text Size',
                                          style: TextStyle(
                                            fontFamily: "Inter",
                                            fontVariations: [
                                              FontVariation('wght', 600),
                                            ],
                                            fontSize: 16,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Adjust font size for reading',
                                          style: TextStyle(
                                            fontFamily: "Inter",
                                            fontVariations: [
                                              FontVariation('wght', 400),
                                            ],
                                            fontSize: 13,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    'A',
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontVariations: [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 12,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoSlider(
                                      value: appState.fontSize,
                                      min: 14.0,
                                      max: 24.0,
                                      activeColor: accentColor,
                                      onChanged: (value) =>
                                          appState.setFontSize(value),
                                    ),
                                  ),
                                  Text(
                                    'A',
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontVariations: [
                                        FontVariation('wght', 400),
                                      ],
                                      fontSize: 18,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Dark Mode
                      _buildSettingsRow(
                        icon: CupertinoIcons.moon,
                        title: 'Dark Mode',
                        subtitle: 'Switch between light and dark themes',
                        trailing: CupertinoSwitch(
                          value: appState.isDarkMode,
                          activeColor: accentColor,
                          onChanged: (value) => appState.toggleTheme(),
                        ),
                      ),




                      const SizedBox(height: 24),

                      // About Section
                      _buildSectionHeader('About'),
                      const SizedBox(height: 8),

                      _buildSettingsRow(
                        icon: CupertinoIcons.info_circle,
                        title: 'About Us',
                        subtitle: 'Learn more about TSA Hymns',
                        trailing: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: secondaryTextColor,
                        ),

                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const AboutUsScreen(),
                              ),
                            );


                        },
                      ),

                      _buildSettingsRow(
                        icon: CupertinoIcons.doc,
                        title: 'Copyright',
                        subtitle: 'View copyright information',
                        trailing: Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                          color: secondaryTextColor,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const CopyrightScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          'TSA Hymns v2.0.0',
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontVariations: [
                              FontVariation('wght', 400),
                            ],
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "Inter",
              fontVariations: [
                FontVariation('wght', 600),
              ],
              fontSize: 13,
              color: appState.getSecondaryTextColor(),
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final cardColor = appState.getCardColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();
        const accentColor = CupertinoColors.systemRed;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(16),
            onPressed: onTap,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontVariations: [
                            FontVariation('wght', 600),
                          ],
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontVariations: [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                trailing,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguagePicker(BuildContext context, AppState appState) {
    final textColor = appState.getTextColor();
    final secondaryTextColor = appState.getSecondaryTextColor();
    final cardColor = appState.getCardColor();
    const accentColor = CupertinoColors.systemRed;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: secondaryTextColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontVariations: [
                      FontVariation('wght', 600),
                    ],
                    fontSize: 18,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontVariations: [
                        FontVariation('wght', 600),
                      ],
                      fontSize: 16,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Language Options
          Expanded(
            child: ListView(
              children: ['English', 'Tamil']
                  .map((language) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: secondaryTextColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.all(16),
                    onPressed: () {
                      appState.setLanguage(language);
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            language,
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (appState.selectedLanguage == language)
                          Icon(
                            CupertinoIcons.checkmark,
                            size: 20,
                            color: accentColor,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'About Us',
          style: TextStyle(
            fontFamily: "Inter",
            fontVariations: [
              FontVariation('wght', 700),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SingleChildScrollView(
            child: Text(
              '''We are the Salvation Army Youth (SAY) Group from The Salvation Army Sion Tamil Corps, Mumbai (IWT).
            
In today's digital era, we recognized the need for a comprehensive and accessible hymnal application. What began as a humble initiative to serve Tamil-speaking Soldiers has now expanded to include English hymns, reaching international believers and Salvationists around the world.

Through this project, we aim to enrich worship, strengthen faith, and make meaningful contributions to the Kingdom of God and the continuing mission of The Salvation Army.''',
              style: TextStyle(
                fontFamily: "Inter",
                fontVariations: [
                  FontVariation('wght', 400),
                ],
                fontSize: 15.0,
              ),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: TextStyle(
                fontFamily: "Inter",
                fontVariations: [
                  FontVariation('wght', 600),
                ],
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class CopyrightScreen extends StatelessWidget {
  const CopyrightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();

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
              'Copyright',
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: appState.getCardColor(),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Copyright Information',
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontVariations: [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 20,
                                color: appState.getTextColor(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '''This is a non-commercial application. No content or data is used for financial purposes. All features are created solely for religious worship, devotion, and the spiritual growth of users.

We also do not collect or store any personal information or user data. The app functions fully offline, ensuring the privacy and safety of every user.

All English Salvation Army Hymns are sourced from the Salvation Army English Song Book, featuring only materials copyrighted by The Salvation Army and those in the public domain.

All Tamil Salvation Army Hymns are taken from the Salvation Army Tamil Song Book, with full attribution provided according to Salvation Army copyright and attribution policies, including acknowledgment of hymn authors where applicable.

The Bible content used in this application is from the American Standard Version (ASV). The ASV was originally published in 1901 and is now in the public domain (as of 2023). It remains one of the most accurate and enduring English translations, faithful to the Revised Version and widely respected for its clarity, literary beauty, and faithfulness to the original Scriptures.

Additional Tamil Christian songs have been selected only from verified public domain sources to ensure both legal compliance and spiritual authenticity.

In case of any concerns or requests for content removal or attribution clarification, please contact the authors of this application for prompt review and resolution.

© 2025 TSA Hymns v2.0.0 — All rights reserved.''',
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontVariations: [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: CupertinoColors.systemRed.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                'For any copyright concerns, please contact us for prompt resolution.',
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontVariations: [
                                    FontVariation('wght', 500),
                                  ],
                                  fontSize: 14,
                                  color: CupertinoColors.systemRed,
                                ),
                                textAlign: TextAlign.center,
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
          ),
        );
      },
    );
  }

}
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();

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
              'About Us',
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: appState.getCardColor(),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About TSA Hymns',
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontVariations: [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 20,
                                color: appState.getTextColor(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              '''We are the Salvation Army Youth (SAY) Group from The Salvation Army Sion Tamil Corps, Mumbai (IWT).

Recognizing the growing need for a modern, accessible, and unified hymnal app, we began this project to support Tamil-speaking Salvationists. Over time, the vision expanded — we now include English hymns as well, welcoming believers across linguistic and international boundaries.

Our mission is simple: to strengthen worship, deepen faith, and support the spiritual life of every user through a clean, reliable, and offline-friendly hymn application.

We aim to preserve the rich heritage of Salvation Army music while helping the next generation connect meaningfully with worship and Scripture.''',
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontVariations: [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: CupertinoColors.systemRed.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                'Thank you for supporting this mission and being part of the TSA Hymns community.',
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontVariations: [
                                    FontVariation('wght', 500),
                                  ],
                                  fontSize: 14,
                                  color: CupertinoColors.systemRed,
                                ),
                                textAlign: TextAlign.center,
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
          ),
        );
      },
    );
  }
}
