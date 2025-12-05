import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'databasecon/databasecon.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';
// Add these imports for deep linking
import 'package:go_router/go_router.dart';
import 'screens/bible_text_screen.dart'; // Import your BibleTextScreen

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await DatabaseCon.initDatabase();

  runApp(const BibleApp());
}

// Create a GoRouter configuration
final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/bible/:bookId/:chapter',
      builder: (context, state) {
        final bookId = int.tryParse(state.pathParameters['bookId'] ?? '');
        final chapter = int.tryParse(state.pathParameters['chapter'] ?? '');
        final verse = int.tryParse(state.uri.queryParameters['verse'] ?? '');

        // You'll need to pass the actual data here
        // This is a simplified example - you'll need to fetch the actual book data
        return BibleTextScreen(
          bookName: _getBookName(bookId ?? 1),
          chapter: chapter ?? 1,
          verses: [], // You'll need to load these from your database
          bookId: bookId ?? 1,
          language: 'english', // You might want to get this from state
          highlightVerse: verse,
        );
      },
    ),
  ],
  errorBuilder: (context, state) => const ErrorScreen(),
);

String _getBookName(int bookId) {
  // Map bookId to book name - you should implement this properly
  final books = {
    1: 'Genesis', 2: 'Exodus', 3: 'Leviticus', 4: 'Numbers', 5: 'Deuteronomy',
    6: 'Joshua', 7: 'Judges', 8: 'Ruth', 9: '1 Samuel', 10: '2 Samuel',
    11: '1 Kings', 12: '2 Kings', 13: '1 Chronicles', 14: '2 Chronicles',
    15: 'Ezra', 16: 'Nehemiah', 17: 'Esther', 18: 'Job', 19: 'Psalms',
    20: 'Proverbs', 21: 'Ecclesiastes', 22: 'Song of Solomon',
    23: 'Isaiah', 24: 'Jeremiah', 25: 'Lamentations', 26: 'Ezekiel',
    27: 'Daniel', 28: 'Hosea', 29: 'Joel', 30: 'Amos', 31: 'Obadiah',
    32: 'Jonah', 33: 'Micah', 34: 'Nahum', 35: 'Habakkuk', 36: 'Zephaniah',
    37: 'Haggai', 38: 'Zechariah', 39: 'Malachi', 40: 'Matthew',
    41: 'Mark', 42: 'Luke', 43: 'John', 44: 'Acts', 45: 'Romans',
    46: '1 Corinthians', 47: '2 Corinthians', 48: 'Galatians',
    49: 'Ephesians', 50: 'Philippians', 51: 'Colossians',
    52: '1 Thessalonians', 53: '2 Thessalonians', 54: '1 Timothy',
    55: '2 Timothy', 56: 'Titus', 57: 'Philemon', 58: 'Hebrews',
    59: 'James', 60: '1 Peter', 61: '2 Peter', 62: '1 John',
    63: '2 John', 64: '3 John', 65: 'Jude', 66: 'Revelation',
  };
  return books[bookId] ?? 'Unknown Book';
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Error'),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'The requested page could not be found.',
              style: CupertinoTheme.of(context).textTheme.textStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return CupertinoApp.router(
            title: 'Salvation Army Hymns',
            routerConfig: _router,
            theme: CupertinoThemeData(
              brightness: appState.isDarkMode ? Brightness.dark : Brightness.light,
              primaryColor: const Color(0xFFEF4444),
              scaffoldBackgroundColor: appState.getBackgroundColor(),
              barBackgroundColor: appState.getBackgroundColor(),
              textTheme: CupertinoTextThemeData(
                primaryColor: appState.getTextColor(),
              ),
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: appState.getEffectiveTextScaleFactor(context),
                ),
                child: child!,
              );
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _appInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAppState();
  }

  Future<void> _initializeAppState() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.initialize();

    setState(() {
      _appInitialized = true;
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Use GoRouter to navigate
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (!_appInitialized) {
          return CupertinoPageScaffold(
            backgroundColor: CupertinoColors.systemBackground,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CupertinoActivityIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final backgroundColor = appState.getBackgroundColor();
        final textColor = appState.getTextColor();
        final secondaryTextColor = appState.getSecondaryTextColor();

        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.translate(
                                offset: _slideAnimation.value,
                                child: SvgPicture.asset(
                                  'assets/icons/tsa.svg',
                                  width: 180,
                                  height: 180,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.translate(
                                offset: _slideAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            'Salvation Army Hymns',
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontVariations: [
                                FontVariation('wght', 800),
                              ],
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.05,
                              letterSpacing: -0.9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.translate(
                                offset: _slideAnimation.value,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            'Sing to the lord with all your heart',
                            style: TextStyle(
                              fontFamily: "Inter",
                              fontVariations: [
                                FontVariation('wght', 400),
                              ],
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: secondaryTextColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        'Developed by SAY group',
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontVariations: [
                            FontVariation('wght', 500),
                          ],
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The Salvation Army Sion Tamil Corps Mumbai IWT',
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontVariations: [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                        textAlign: TextAlign.center,
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
}