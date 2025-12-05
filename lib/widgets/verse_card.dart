import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:gradient_generator/gradient_generator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../backend/promiseapi.dart';
import '../screens/verse_poster_screen.dart';
import '../state/app_state.dart';

class VerseCard extends StatefulWidget {
  const VerseCard({super.key});

  @override
  State<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> {
  Map<String, dynamic>? _currentPromise;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyVerse();
  }

  Future<void> _loadDailyVerse() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final lastDate = prefs.getString('last_promise_fetch_date');
      final savedData = prefs.getString('daily_promise_verse');

      if (lastDate != null && savedData != null) {
        final last = DateTime.parse(lastDate);
        if (_isSameDay(last, today)) {
          setState(() {
            _currentPromise = json.decode(savedData);
            _isLoading = false;
          });
          return;
        }
      }

      final verse = await PromiseAPI.fetchPromiseVerse();
      if (verse != null) {
        await prefs.setString('last_promise_fetch_date', today.toIso8601String());
        await prefs.setString('daily_promise_verse', json.encode(verse));
        setState(() {
          _currentPromise = verse;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  LinearGradient _generateGradient(bool dark) {
    final seed = DateTime.now().day;
    final random = Random(seed);
    final base = random.nextDouble() * 360;
    double offset = base + random.nextDouble() * 50 - 30;
    if (offset < 0) offset += 360;
    if (offset > 360) offset -= 360;

    // Reduced luminance for light mode (from 0.6/0.55 to 0.5/0.45)
    final c1 = HSLColor.fromAHSL(1, base, 0.6, dark ? 0.25 : 0.5).toColor();
    final c2 = HSLColor.fromAHSL(1, offset, 0.3, dark ? 0.2 : 0.45).toColor();

    return GradientX.linear(
      colors: [c1, c2],
      angle: random.nextInt(360).toDouble(),
    );
  }

  String _formatRef(Map<String, dynamic> p) {
    final names = {
      '1': 'Genesis',
      '2': 'Exodus',
      '3': 'Leviticus',
      '4': 'Numbers',
      '5': 'Deuteronomy',
      '6': 'Joshua',
      '7': 'Judges',
      '8': 'Ruth',
      '9': '1 Samuel',
      '10': '2 Samuel',
      '11': '1 Kings',
      '12': '2 Kings',
      '13': '1 Chronicles',
      '14': '2 Chronicles',
      '15': 'Ezra',
      '16': 'Nehemiah',
      '17': 'Esther',
      '18': 'Job',
      '19': 'Psalms',
      '20': 'Proverbs',
      '21': 'Ecclesiastes',
      '22': 'Song of Solomon',
      '23': 'Isaiah',
      '24': 'Jeremiah',
      '25': 'Lamentations',
      '26': 'Ezekiel',
      '27': 'Daniel',
      '28': 'Hosea',
      '29': 'Joel',
      '30': 'Amos',
      '31': 'Obadiah',
      '32': 'Jonah',
      '33': 'Micah',
      '34': 'Nahum',
      '35': 'Habakkuk',
      '36': 'Zephaniah',
      '37': 'Haggai',
      '38': 'Zechariah',
      '39': 'Malachi',
      '40': 'Matthew',
      '41': 'Mark',
      '42': 'Luke',
      '43': 'John',
      '44': 'Acts',
      '45': 'Romans',
      '46': '1 Corinthians',
      '47': '2 Corinthians',
      '48': 'Galatians',
      '49': 'Ephesians',
      '50': 'Philippians',
      '51': 'Colossians',
      '52': '1 Thessalonians',
      '53': '2 Thessalonians',
      '54': '1 Timothy',
      '55': '2 Timothy',
      '56': 'Titus',
      '57': 'Philemon',
      '58': 'Hebrews',
      '59': 'James',
      '60': '1 Peter',
      '61': '2 Peter',
      '62': '1 John',
      '63': '2 John',
      '64': '3 John',
      '65': 'Jude',
      '66': 'Revelation',
    };
    //print(p['book_id']);
    return '${names[p['book_id'].toString()]} ${p['chapter']}:${p['verse']}';
  }

  double _calculateAdaptiveFontSize(String text, double width, double height, bool isTablet) {
    final baseFontSize = isTablet ? 28.0 : 22.0;
    final lengthFactor = (text.length / (isTablet ? 180 : 120)).clamp(0.7, 2.5);
    final areaFactor = (height / (isTablet ? 300 : 200)).clamp(0.8, 1.4);
    double fontSize = (baseFontSize / lengthFactor) * areaFactor;

    // Set min and max bounds for each device type
    if (isTablet) {
      fontSize = fontSize.clamp(18.0, 32.0);
    } else {
      fontSize = fontSize.clamp(14.0, 26.0);
    }

    return fontSize * 0.98;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 720;
    final baseHeight = isTablet ? 300.0 : 220.0;
    final padding = isTablet ? 24.0 : 20.0;

    return Consumer<AppState>(
      builder: (context, app, _) {
        final grad = _generateGradient(app.isDarkMode);
        // Slightly reduced opacity for light mode to make text more comfortable
        final textColor = Colors.white.withOpacity(app.isDarkMode ? 0.95 : 0.92);

        if (_isLoading) return _buildLoading(grad, baseHeight, isTablet);
        if (_currentPromise == null) return _buildError(grad, baseHeight, textColor, isTablet);

        final verse = _currentPromise!['text'] ?? '';
        final ref = _formatRef(_currentPromise!);

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VersePosterScreen(
                gradient: grad,
                verse: verse,
                reference: ref,
                title: "VERSE OF THE DAY",
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fontSize = _calculateAdaptiveFontSize(
                verse,
                constraints.maxWidth,
                constraints.maxHeight,
                isTablet,
              );

              return Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: baseHeight,
                  maxHeight: double.infinity,
                ),
                decoration: BoxDecoration(
                  gradient: grad,
                  borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
                ),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DAILY PROMISE',

                          style: TextStyle(
                              fontFamily: "Inter",
                              color: textColor.withOpacity(app.isDarkMode ? 0.8 : 0.75),
                              fontSize: isTablet ? 16 : 12,
                              letterSpacing: isTablet ? 1.5 : 1.3,
                              fontVariations:[ FontVariation(
                                  'wght', 600
                              )
                              ]
                          ),
                        ),
                        SizedBox(height: isTablet ? 10 : 6),
                        Text(
                          verse,
                          textAlign: TextAlign.start,
                          softWrap: true,
                          style: TextStyle(
                            color: textColor,
                            fontFamily: "SourceSerif4",
                            fontSize: fontSize,
                            height: isTablet ? 1.4 : 1.3,
                              fontVariations:[ FontVariation(
                              'wght', 600
                          )]
                          ),
                        ),
                        SizedBox(height: isTablet ? 20 : 16),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            ref,
                            style: TextStyle(
                              fontFamily: "Inter",
                              color: textColor.withOpacity(app.isDarkMode ? 0.9 : 0.85),
                              fontSize: isTablet ? 20 : 16,
                                fontVariations:[ FontVariation(
                                    'wght', 500
                                )
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLoading(Gradient g, double h, bool isTablet) => Container(
    height: h,
    decoration: BoxDecoration(
      gradient: g,
      borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
    ),
    child: Center(
      child: SizedBox(
        width: isTablet ? 28 : 22,
        height: isTablet ? 28 : 22,
        child: CircularProgressIndicator(
          strokeWidth: isTablet ? 2.5 : 2,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _buildError(Gradient g, double h, Color t, bool isTablet) => Container(
    height: h,
    decoration: BoxDecoration(
      gradient: g,
      borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
    ),
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16.0 : 8.0),
        child: Text(
          'Tap to reload verse',
          textAlign: TextAlign.center,

          style: TextStyle(
              fontFamily: "Inter",
              color: t,
              fontSize: isTablet ? 18 : 14,
              fontVariations:[ FontVariation(
                  'wght', 500
              )
              ]
          ),
        ),
      ),
    ),
  );
}