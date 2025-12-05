import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../backend/bible_api.dart';
import '../state/app_state.dart';
import 'chapter_selection_screen.dart';

class BookSelectionScreen extends StatefulWidget {
  final String language;

  const BookSelectionScreen({super.key, required this.language});

  @override
  State<BookSelectionScreen> createState() => _BookSelectionScreenState();
}

class _BookSelectionScreenState extends State<BookSelectionScreen> {
  late Future<List<Map<String, dynamic>>> _booksFuture;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _booksFuture = BibleAPI.getBooksByLanguage(widget.language);
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks() {
    _booksFuture.then((books) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _filteredBooks = books;
        } else {
          _filteredBooks = books.where((book) {
            final bookName = book['book_name']?.toString().toLowerCase() ?? '';
            return bookName.contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
              'Select Book',
              style: TextStyle(
                fontFamily: 'Inter',
                fontVariations: const [
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
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: secondaryTextColor.withOpacity(0.2),
                      ),
                    ),
                    child: CupertinoTextField(
                      controller: _searchController,
                      placeholder: 'Search books...',
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(CupertinoIcons.search, size: 18, color: secondaryTextColor),
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: null,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        color: textColor,
                      ),
                      placeholderStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontVariations: const [
                          FontVariation('wght', 400),
                        ],
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ),

                // Books List
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _booksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CupertinoActivityIndicator(
                            color: textColor,
                          ),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.book,
                                size: 64,
                                color: secondaryTextColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No books found",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontVariations: const [
                                    FontVariation('wght', 600),
                                  ],
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Failed to load books",
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontVariations: const [
                                    FontVariation('wght', 400),
                                  ],
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final books = _searchController.text.isEmpty ? snapshot.data! : _filteredBooks;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];

                          // Show section header for Old/New Testament
                          if (index == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('OLD TESTAMENT', textColor, secondaryTextColor),
                                _buildBookCard(book, cardColor, textColor, secondaryTextColor),
                              ],
                            );
                          } else if (index == 39) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('NEW TESTAMENT', textColor, secondaryTextColor),
                                _buildBookCard(book, cardColor, textColor, secondaryTextColor),
                              ],
                            );
                          } else {
                            return _buildBookCard(book, cardColor, textColor, secondaryTextColor);
                          }
                        },
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

  Widget _buildSectionHeader(String title, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontVariations: const [
            FontVariation('wght', 700),
          ],
          fontSize: 12,
          color: CupertinoColors.systemRed,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book, Color cardColor, Color textColor, Color secondaryTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: secondaryTextColor.withOpacity(0.2),
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ChapterSelectionScreen(
                bookName: book['book_name'],
                bookId: book['id'],
                language: widget.language,
                totalChapters: book['chapter_count'],
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.book,
                size: 20,
                color: CupertinoColors.systemRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['book_name'],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontVariations: const [
                        FontVariation('wght', 600),
                      ],
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book['chapter_count']} chapters',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontVariations: const [
                        FontVariation('wght', 400),
                      ],
                      fontSize: 14,
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: secondaryTextColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}