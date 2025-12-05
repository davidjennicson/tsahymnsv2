import 'dart:math';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gradient_generator/gradient_generator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:auto_size_text/auto_size_text.dart';

class VersePosterScreen extends StatelessWidget {
  final LinearGradient gradient;
  final String verse;
  final String reference;
  final String title;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  VersePosterScreen({
    super.key,
    required this.gradient,
    required this.verse,
    required this.reference,
    required this.title,
  });

  Future<void> _shareVerse(BuildContext context) async {
    try {
      final boundary = _repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not capture image')),
        );
        return;
      }

      const double highPixelRatio = 5.0;
      final image = await boundary.toImage(pixelRatio: highPixelRatio);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No image data')),
        );
        return;
      }

      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/verse_poster.png').create();
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)],
          text: 'Check out this Bible verse!');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: $e')),
      );
    }
  }

  Color _getTextColor(List<Color> colors) {
    final avgLuminance =
        colors.map((c) => c.computeLuminance()).reduce((a, b) => a + b) /
            colors.length;
    return avgLuminance > 0.5 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 720;
    final isLandscape = size.width > size.height;

    final textColor = _getTextColor(gradient.colors);
    Color darker(Color c, [double amount = 0.2]) {
      final hsl = HSLColor.fromColor(c);
      final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
      return hslDark.toColor();
    }

    final bg = darker(gradient.colors.first, 0.35);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back & share buttons
            Padding(
              padding: EdgeInsets.all(isLandscape ? 12.0 : 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Verse Poster',
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontVariations: [
                        FontVariation('wght', 600),
                      ],
                      color: textColor,
                      fontSize: isLandscape ? 16 : 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: textColor),
                    onPressed: () => _shareVerse(context),
                  ),
                ],
              ),
            ),

            // Poster container - increased width for portrait
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Container(
                      height: size.height * 0.75,
                      width: isLandscape
                          ? size.width * 0.8  // Landscape: 80% of screen width
                          : size.width, // Portrait: 95% of screen width (increased from 0.9)
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 20,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isLandscape ? 24.0 : 32.0),
                        child: _buildPosterContent(context, isLandscape, isTablet, textColor),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Instructions
            Padding(
              padding: EdgeInsets.all(isLandscape ? 8.0 : 16.0),
              child: Text(
                'Tap the share icon to save or share this verse',
                style: TextStyle(
                  fontFamily: "Inter",
                  fontVariations: [
                    FontVariation('wght', 400),
                  ],
                  color: textColor.withOpacity(0.6),
                  fontSize: isLandscape ? 12 : 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterContent(BuildContext context, bool isLandscape, bool isTablet, Color textColor) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isLandscape ? 400 : 500,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo and "VERSE OF THE DAY" centered in one line
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/tsa.svg',
                height: isLandscape ? 32 : 40,
                width: isLandscape ? 32 : 40,
              ),
              SizedBox(width: isLandscape ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Inter",
                  fontVariations: [
                    FontVariation('wght', 600),
                  ],
                  fontSize: isLandscape ? 14 : (isTablet ? 18 : 16),
                  color: textColor.withOpacity(0.7),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          SizedBox(height: isLandscape ? 24 : 48),

          // Reference centered
          Text(
            reference,
            style: TextStyle(
              fontFamily: "Inter",
              fontVariations: [
                FontVariation('wght', 600),
              ],
              fontSize: isLandscape ? 16 : (isTablet ? 20 : 18),
              color: textColor.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isLandscape ? 20 : 36),

          // Verse text - responsive with proper constraints
          LayoutBuilder(
            builder: (context, constraints) {
              final double baseFontSize = _calculateOptimalFontSize(
                verse,
                constraints.maxWidth,
                constraints.maxHeight,
                isLandscape,
              );

              return AutoSizeText(
                verse,
                style: TextStyle(
                  fontFamily: "SourceSerif4",
                  fontVariations: [
                    FontVariation('wght', 500),
                  ],
                  fontSize: baseFontSize,
                  color: textColor,
                  height: isLandscape ? 1.25 : 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 10,
                minFontSize: 14,
                stepGranularity: 1,
                overflowReplacement: AutoSizeText(
                  verse,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontVariations: [
                      FontVariation('wght', 700),
                    ],
                    fontSize: baseFontSize * 0.9,
                    color: textColor,
                    height: isLandscape ? 1.2 : 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 12,
                  minFontSize: 12,
                ),
              );
            },
          ),

      SizedBox(
        height: isLandscape ? 40 : min(86, 56),
      ),

          // Church name at bottom - centered
          Text(
            "THE SALVATION ARMY TAMIL CHURCH SION",
            style: TextStyle(
              fontFamily: "Inter",
              fontVariations: [
                FontVariation('wght', 700),
              ],
              fontSize: isLandscape ? 10 : 12,
              color: textColor.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  double _calculateOptimalFontSize(String text, double maxWidth, double maxHeight, bool isLandscape) {
    final int textLength = text.length;

    // Base font sizes adjusted for landscape
    double baseSize;
    if (textLength < 50) {
      baseSize = isLandscape ? 24 : 32;
    } else if (textLength < 100) {
      baseSize = isLandscape ? 20 : 28;
    } else if (textLength < 150) {
      baseSize = isLandscape ? 18 : 24;
    } else {
      baseSize = isLandscape ? 16 : 20;
    }

    // Adjust based on available width
    final double avgCharWidth = 0.6;
    final double charsPerLine = maxWidth / (baseSize * avgCharWidth);
    final int estimatedLines = (textLength / charsPerLine).ceil();

    // Check if text fits in available height
    final double lineHeight = 1.3;
    final double requiredHeight = estimatedLines * baseSize * lineHeight;

    if (requiredHeight > maxHeight * 0.6) {
      // Reduce font size if it doesn't fit
      double adjustedSize = (maxHeight * 0.6) / (estimatedLines * lineHeight);
      return adjustedSize.clamp(isLandscape ? 14 : 16, baseSize);
    }

    return baseSize;
  }
}