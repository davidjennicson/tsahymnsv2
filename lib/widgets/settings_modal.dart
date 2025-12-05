import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDarkMode = appState.isDarkMode;
    final fontSize = appState.fontSize;

    final bgColor = isDarkMode ? const Color(0xFF111827) : CupertinoColors.white;
    final containerColor =
    isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFF8FAFC);
    final textColor =
    isDarkMode ? CupertinoColors.white : const Color(0xFF1F2937);
    final labelColor =
    isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
    final accentColor = const Color(0xFFEF4444);
    final borderColor =
    isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.settings,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontVariations: [FontVariation('wght', 600)],
                    fontSize: 18,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FONT SIZE SECTION
                  _buildSectionHeader('FONT SIZE', labelColor),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                CupertinoIcons.textformat_size,
                                size: 16,
                                color: labelColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CupertinoSlider(
                                value: fontSize,
                                min: 12.0,
                                max: 24.0,
                                divisions: 12,
                                activeColor: accentColor,
                                thumbColor: accentColor,
                                onChanged: (value) {
                                  appState.setFontSize(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                CupertinoIcons.textformat_alt,
                                size: 16,
                                color: labelColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // THEME SECTION
                  _buildSectionHeader('INTERFACE THEME', labelColor),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isDarkMode
                                ? CupertinoIcons.moon_fill
                                : CupertinoIcons.sun_max_fill,
                            size: 20,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontVariations: [FontVariation('wght', 600)],
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isDarkMode ? 'Enabled' : 'Disabled',
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontVariations: [FontVariation('wght', 400)],
                                fontSize: 14,
                                color: labelColor,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Transform.scale(
                          scale: 0.9,
                          child: CupertinoSwitch(
                            value: isDarkMode,
                            activeColor: accentColor,
                            trackColor: isDarkMode
                                ? const Color(0xFF4B5563)
                                : const Color(0xFFE5E7EB),
                            onChanged: (_) => appState.toggleTheme(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "Inter",
          fontVariations: [FontVariation('wght', 600)],
          fontSize: 12,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
