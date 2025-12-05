import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/verse_poster_screen.dart';
import '../theme/app_theme.dart';

class HighlightColorPicker extends StatefulWidget {
  final Function(Color?) onColorSelected;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onAddNote;
  final VoidCallback onRemoveHighlight;
  final VoidCallback onSave;
  final VoidCallback onBookmark;
  final bool isSaved;
  final bool isBookmarked;
  final String selectedText; // Add this to receive the selected text for sharing

  const HighlightColorPicker({
    super.key,
    required this.onColorSelected,
    required this.onCopy,
    required this.onShare,
    required this.onAddNote,
    required this.onRemoveHighlight,
    required this.onSave,
    required this.onBookmark,
    required this.isSaved,
    required this.isBookmarked,
    required this.selectedText, // Add this parameter
  });

  @override
  State<HighlightColorPicker> createState() => _HighlightColorPickerState();
}

class _HighlightColorPickerState extends State<HighlightColorPicker> {
  bool showColors = false;

  // Share functionality
  Future<void> _shareText() async {
    try {
      if (widget.selectedText.isEmpty) {
        _showSnackBar('No text selected to share');
        return;
      }

      await Share.share(
        widget.selectedText+"\n\nShared from Salvation Army Hymns App v2.0",
        subject: 'Bible Verse',
      );
    } catch (e) {
      _showSnackBar('Error sharing: $e');
    }
  }
  Future<void> _shareImage() async {
    try {
      if (widget.selectedText.isEmpty) {
        _showSnackBar('No text selected to share');
        return;
      }
      Navigator.push(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (_, animation, secondaryAnimation) => VersePosterScreen(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF001F3F),
                Color(0xFF003366),
              ],
            ),
            verse: widget.selectedText,
            reference: "",
            title: "BIBLE VERSE",
          ),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return CupertinoPageTransition(
              primaryRouteAnimation: animation,
              secondaryRouteAnimation: secondaryAnimation,
              linearTransition: true,
              child: child,
            );
          },
        ),
      );

      // await Share.share(
      //   widget.selectedText,
      //   subject: 'Bible Verse',
      // );
    } catch (e) {
      _showSnackBar('Error sharing: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Color(0xFF0A0F1C) : CupertinoColors.white;
    final cardColor = isDark ? Color(0xFF1A2235) : CupertinoColors.white;
    final textColor = isDark ? CupertinoColors.white : CupertinoColors.black;
    final secondaryTextColor = isDark ? Color(0xFF94A3B8) : Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: secondaryTextColor.withOpacity(0.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: secondaryTextColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Main action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: CupertinoIcons.pen,
                    label: "Color",
                    onTap: () => setState(() => showColors = !showColors),
                    isActive: showColors,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    cardColor: cardColor,
                  ),

                  _buildActionButton(
                    icon: CupertinoIcons.doc_on_doc,
                    label: "Copy",
                    onTap: widget.onCopy,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    cardColor: cardColor,
                  ),

                  _buildActionButton(
                    icon: CupertinoIcons.paperplane,
                    label: "Share",
                    onTap: _shareText, // Use the new share function
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    cardColor: cardColor,
                  ),
                  _buildActionButton(
                    icon: CupertinoIcons.photo,
                    label: "Share Image",
                    onTap: _shareImage, // Use the new share function
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    cardColor: cardColor,
                  ),

                  // Bookmark button
                  _buildActionButton(
                    icon: widget.isBookmarked ? CupertinoIcons.star_fill : CupertinoIcons.star,
                    label: "Bookmark",
                    onTap: widget.onBookmark,
                    isActive: widget.isBookmarked,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    cardColor: cardColor,
                    activeColor: CupertinoColors.systemYellow,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Color picker section
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: showColors
                    ? Column(
                  children: [
                    // Color options
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: secondaryTextColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Highlight Color',
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontVariations: [
                                FontVariation('wght', 600),
                              ],
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildColorOption(
                                color: Color(0xFFFFD60A),
                                label: "Yellow",
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                              ),
                              _buildColorOption(
                                color: Color(0xFFB4D9FF),
                                label: "Blue",
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                              ),
                              _buildColorOption(
                                color: Color(0xFFFFD1D9),
                                label: "Pink",
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                              ),
                              _buildColorOption(
                                color: Color(0xFFBEFFCD),
                                label: "Green",
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Remove highlight button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CupertinoColors.systemRed.withOpacity(0.3),
                        ),
                      ),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(16),
                        onPressed: () {
                          widget.onRemoveHighlight();
                          setState(() => showColors = false);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.delete,
                              size: 18,
                              color: CupertinoColors.systemRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Remove Highlight",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontVariations: [
                                  FontVariation('wght', 600),
                                ],
                                fontSize: 14,
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardColor,
    bool isActive = false,
    Color? activeColor,
  }) {
    final activeColorValue = activeColor ?? CupertinoColors.systemRed;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive ? activeColorValue.withOpacity(0.1) : cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? activeColorValue : secondaryTextColor.withOpacity(0.2),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? activeColorValue : textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Inter",
              fontVariations: [
                FontVariation('wght', 500),
              ],
              fontSize: 11,
              color: isActive ? activeColorValue : secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption({
    required Color color,
    required String label,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onColorSelected(color);
        setState(() => showColors = false);
      },
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: secondaryTextColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: "Inter",
              fontVariations: [
                FontVariation('wght', 500),
              ],
              fontSize: 11,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}