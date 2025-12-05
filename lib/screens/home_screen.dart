import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:tsahymnsv5/screens/doctrine_screen.dart';
import 'package:tsahymnsv5/screens/songbooklanguagescreen.dart';
import '../widgets/verse_card.dart';
import '../state/app_state.dart';

import 'bookmarks.dart';
import 'language_selection_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToScreen(String screen) {
    switch (screen) {
      case 'Bible':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const LanguageSelectionScreen(),
          ),
        );
        break;
      case 'Doctrine':
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const DoctrineScreen()),
        );
        break;
      case 'Songbook':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const SongLanguageSelectionScreen(),
          ),
        );
        break;
      case 'Bookmarks':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const BookmarkScreen(),
          ),
        );
        break;
      case 'Settings':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
    }
  }

  // Helper method to get font style with variations
  TextStyle _getTextStyle({
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    String? fontFamily = 'Inter',
  }) {
    // Convert FontWeight to a numeric value for variable fonts
    double weightValue;
    switch (fontWeight) {
      case FontWeight.w100:
        weightValue = 100;
        break;
      case FontWeight.w200:
        weightValue = 200;
        break;
      case FontWeight.w300:
        weightValue = 300;
        break;
      case FontWeight.w400:
        weightValue = 400;
        break;
      case FontWeight.w500:
        weightValue = 500;
        break;
      case FontWeight.w600:
        weightValue = 600;
        break;
      case FontWeight.w700:
        weightValue = 700;
        break;
      case FontWeight.w800:
        weightValue = 800;
        break;
      case FontWeight.w900:
        weightValue = 900;
        break;
      default:
        weightValue = 400;
    }

    return TextStyle(
      fontFamily: fontFamily,
      color: color,
      fontSize: fontSize,
      fontVariations: [
        FontVariation('wght', weightValue),
      ],
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600 || size.width > size.height;
    final isSmallPhone = size.width < 375;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();
        final cardColor = appState.getCardColor();

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: backgroundColor,
            border: null,
            middle: Text(
              'TSA Hymns',
              style: _getTextStyle(
                color: textColor,
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _navigateToScreen('Settings'),
              child: Icon(
                CupertinoIcons.gear,
                color: textColor,
                size: isTablet ? 24 : 22,
              ),
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildWelcomeSection(context, appState, isTablet),
                    ),
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 24 : 16,
                            vertical: 8,
                          ),
                          child: VerseCard(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * 0.5),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildQuickAccess(
                          context,
                          appState,
                          isTablet,
                          isSmallPhone,
                          constraints,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: isTablet ? 32 : 24),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context, AppState appState, bool isTablet) {
    final textColor = appState.getTextColor();
    final secondaryTextColor = appState.getSecondaryTextColor();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16,
        isTablet ? 20 : 16,
        isTablet ? 24 : 16,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome',
            style: _getTextStyle(
              color: textColor,
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'May your day be filled with grace and peace',
            style: _getTextStyle(
              color: secondaryTextColor,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context, AppState appState, bool isTablet, bool isSmallPhone, BoxConstraints constraints) {
    final textColor = appState.getTextColor();

    return Padding(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: _getTextStyle(
              color: textColor,
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          if (isTablet)
            _buildTabletLayout(context, appState)
          else if (isSmallPhone)
            _buildSmallPhoneLayout(context, appState)
          else
            _buildPhoneLayout(context, appState, constraints),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppState appState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTabletQuickAccessItem('Bible', CupertinoIcons.book_circle_fill, context, appState),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTabletQuickAccessItem('Songbook', CupertinoIcons.music_note_2, context, appState),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTabletQuickAccessItem('Doctrine', CupertinoIcons.doc_text, context, appState),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTabletQuickAccessItem('Bookmarks', CupertinoIcons.bookmark_fill, context, appState),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneLayout(BuildContext context, AppState appState, BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth - 32;
    final cardWidth = (screenWidth - 16) / 2;
    final cardHeight = cardWidth * 0.85;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildMobileQuickAccessItem('Bible', CupertinoIcons.book_circle_fill, context, appState),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildMobileQuickAccessItem('Songbook', CupertinoIcons.music_note_2, context, appState),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildMobileQuickAccessItem('Doctrine', CupertinoIcons.doc_text, context, appState),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: _buildMobileQuickAccessItem('Bookmarks', CupertinoIcons.bookmark_fill, context, appState),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallPhoneLayout(BuildContext context, AppState appState) {
    return Column(
      children: [
        _buildSmallPhoneQuickAccessItem('Bible', CupertinoIcons.book_circle_fill, context, appState),
        const SizedBox(height: 12),
        _buildSmallPhoneQuickAccessItem('Songbook', CupertinoIcons.music_note_2, context, appState),
        const SizedBox(height: 12),
        _buildSmallPhoneQuickAccessItem('Doctrine', CupertinoIcons.doc_text, context, appState),
        const SizedBox(height: 12),
        _buildSmallPhoneQuickAccessItem('Bookmarks', CupertinoIcons.bookmark_fill, context, appState),
      ],
    );
  }

  Widget _buildTabletQuickAccessItem(String title, IconData icon, BuildContext context, AppState appState) {
    final cardColor = appState.getCardColor();
    final textColor = appState.getTextColor();
    final secondaryTextColor = appState.getSecondaryTextColor();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToScreen(title),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: secondaryTextColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: CupertinoColors.systemRed,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: _getTextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getItemDescription(title),
                        style: _getTextStyle(
                          color: secondaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: secondaryTextColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    color: secondaryTextColor.withOpacity(0.6),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileQuickAccessItem(String title, IconData icon, BuildContext context, AppState appState) {
    final cardColor = appState.getCardColor();
    final textColor = appState.getTextColor();
    final secondaryTextColor = appState.getSecondaryTextColor();

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _navigateToScreen(title),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: CupertinoColors.systemRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: _getTextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  _getItemDescription(title),
                  style: _getTextStyle(
                    color: secondaryTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPhoneQuickAccessItem(String title, IconData icon, BuildContext context, AppState appState) {
    final cardColor = appState.getCardColor();
    final textColor = appState.getTextColor();
    final secondaryTextColor = appState.getSecondaryTextColor();

    return SizedBox(
      height: 80,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _navigateToScreen(title),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: CupertinoColors.systemRed,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: _getTextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getItemDescription(title),
                        style: _getTextStyle(
                          color: secondaryTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: secondaryTextColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getItemDescription(String title) {
    switch (title) {
      case 'Bible':
        return 'Read scriptures in multiple languages';
      case 'Songbook':
        return 'Browse and search hymns';
      case 'Doctrine':
        return 'Study TSA doctrines';
      case 'Bookmarks':
        return 'Your saved verses and hymns';
      default:
        return '';
    }
  }
}