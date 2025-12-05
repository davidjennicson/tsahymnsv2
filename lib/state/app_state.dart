import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../databasecon/databasecon.dart';

class AppState extends ChangeNotifier {
  // Theme settings
  bool _isDarkMode = false;
  double _textScaleFactor = 1.0;
  bool _ignoreDeviceTextScale = true;

  // Font settings
  double _fontSize = 16.0;

  // Language settings
  String _selectedLanguage = 'English';

  // Available languages
  final List<String> _availableLanguages = [
    'English',
    'Tamil',
  ];

  String? selectedSongLanguage;

  static const String _tableName = 'app_settings';

  // Getters
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  String get selectedLanguage => _selectedLanguage;
  List<String> get availableLanguages => _availableLanguages;
  double get textScaleFactor => _textScaleFactor;
  bool get ignoreDeviceTextScale => _ignoreDeviceTextScale;

  // Initialize and load settings
  Future<void> initialize() async {
    await _createSettingsTable();
    await _loadSettings();
  }

  // Create settings table if it doesn't exist
  Future<void> _createSettingsTable() async {
    final database = await DatabaseCon.database;

    await database.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');
  }

  // Load settings from database
  Future<void> _loadSettings() async {
    try {
      final database = await DatabaseCon.database;
      final List<Map<String, dynamic>> settings =
      await database.query(_tableName);

      if (settings.isEmpty) {
        // Save default settings if no settings exist
        await _saveDefaultSettings();
        return;
      }

      for (final setting in settings) {
        final key = setting['key'] as String;
        final value = setting['value'] as String;

        _applySetting(key, value);
      }

      notifyListeners();
    } catch (e) {
      //print('Error loading settings: $e');
    }
  }

  // Apply setting from database value
  void _applySetting(String key, String value) {
    switch (key) {
      case 'isDarkMode':
        _isDarkMode = value.toLowerCase() == 'true';
        break;
      case 'fontSize':
        _fontSize = double.tryParse(value) ?? 16.0;
        break;
      case 'textScaleFactor':
        _textScaleFactor = double.tryParse(value) ?? 1.0;
        break;
      case 'ignoreDeviceTextScale':
        _ignoreDeviceTextScale = value.toLowerCase() == 'true';
        break;
      case 'selectedLanguage':
        if (_availableLanguages.contains(value)) {
          _selectedLanguage = value;
        }
        break;
      case 'selectedSongLanguage':
        selectedSongLanguage = value.isNotEmpty ? value : null;
        break;
    }
  }

  // Save default settings to database
  Future<void> _saveDefaultSettings() async {
    final defaultSettings = {
      'isDarkMode': 'false',
      'fontSize': '16.0',
      'textScaleFactor': '1.0',
      'ignoreDeviceTextScale': 'true',
      'selectedLanguage': 'English',
      'selectedSongLanguage': '',
    };

    for (final entry in defaultSettings.entries) {
      await _saveSetting(entry.key, entry.value);
    }
  }

  // Save individual setting to database
  Future<void> _saveSetting(String key, String value) async {
    try {
      final database = await DatabaseCon.database;
      await database.insert(
        _tableName,
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      //print('Error saving setting $key: $e');
    }
  }

  // Song language methods
  void setSongLanguage(String language) {
    selectedSongLanguage = language;
    _saveSetting('selectedSongLanguage', language);
    notifyListeners();
  }

  // Theme methods
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveSetting('isDarkMode', _isDarkMode.toString());
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _saveSetting('isDarkMode', value.toString());
    notifyListeners();
  }

  // Font size methods
  void setFontSize(double size) {
    _fontSize = size.clamp(12.0, 24.0);
    _saveSetting('fontSize', _fontSize.toString());
    notifyListeners();
  }

  void increaseFontSize() {
    if (_fontSize < 24.0) {
      _fontSize += 1.0;
      _saveSetting('fontSize', _fontSize.toString());
      notifyListeners();
    }
  }

  void decreaseFontSize() {
    if (_fontSize > 12.0) {
      _fontSize -= 1.0;
      _saveSetting('fontSize', _fontSize.toString());
      notifyListeners();
    }
  }

  // Language methods
  void setLanguage(String language) {
    if (_availableLanguages.contains(language)) {
      _selectedLanguage = language;
      _saveSetting('selectedLanguage', language);
      notifyListeners();
    }
  }

  // Text scale methods
  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor.clamp(0.8, 1.5);
    _saveSetting('textScaleFactor', _textScaleFactor.toString());
    notifyListeners();
  }

  void toggleIgnoreDeviceTextScale() {
    _ignoreDeviceTextScale = !_ignoreDeviceTextScale;
    _saveSetting('ignoreDeviceTextScale', _ignoreDeviceTextScale.toString());
    notifyListeners();
  }

  void setIgnoreDeviceTextScale(bool value) {
    _ignoreDeviceTextScale = value;
    _saveSetting('ignoreDeviceTextScale', value.toString());
    notifyListeners();
  }

  // Get font family based on selected language
  String getFontFamily() {
    switch (_selectedLanguage) {
      case 'Tamil':
        return 'NotoSansTamil';
      case 'Marathi':
      case 'Hindi':
        return 'NotoSans';
      default:
        return 'Inter';
    }
  }

  // COLOR METHODS (Using method syntax as you prefer)
  Color getBackgroundColor() {
    return _isDarkMode
        ? const Color(0xFF0E151F)
        : const Color(0xFFF2F2F7);
  }

  Color getCardColor() {
    return _isDarkMode
        ? const Color(0xFF1A2332)
        : CupertinoColors.white;
  }

  Color getTextColor() {
    return _isDarkMode
        ? CupertinoColors.white
        : CupertinoColors.black;
  }

  Color getSecondaryTextColor() {
    return _isDarkMode
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey2;
  }

  Color getBackgroundSecondaryColor() {
    return _isDarkMode ? const Color(0xFF1E293B) : CupertinoColors.systemGrey6;
  }

  Color getAccentColor() {
    return _isDarkMode ? const Color(0xFF374151) : CupertinoColors.white;
  }

  // Update getContentTextStyle to respect text scaling
  TextStyle getContentTextStyle() {
    return TextStyle(
      fontFamily: getFontFamily(),
      fontSize: _fontSize,
      height: 1.6,
      color: getTextColor(),
    );
  }

  // Add a method to get the effective text scale factor
  double getEffectiveTextScaleFactor(BuildContext context) {
    if (_ignoreDeviceTextScale) {
      return _textScaleFactor;
    } else {
      return MediaQuery.of(context).textScaleFactor * _textScaleFactor;
    }
  }

  // Export settings as Map (for backup/restore)
  Map<String, dynamic> exportSettings() {
    return {
      'isDarkMode': _isDarkMode,
      'fontSize': _fontSize,
      'textScaleFactor': _textScaleFactor,
      'ignoreDeviceTextScale': _ignoreDeviceTextScale,
      'selectedLanguage': _selectedLanguage,
      'selectedSongLanguage': selectedSongLanguage,
    };
  }

  // Import settings from Map (for restore)
  Future<void> importSettings(Map<String, dynamic> settings) async {
    _isDarkMode = settings['isDarkMode'] ?? _isDarkMode;
    _fontSize = settings['fontSize'] ?? _fontSize;
    _textScaleFactor = settings['textScaleFactor'] ?? _textScaleFactor;
    _ignoreDeviceTextScale = settings['ignoreDeviceTextScale'] ?? _ignoreDeviceTextScale;
    _selectedLanguage = settings['selectedLanguage'] ?? _selectedLanguage;
    selectedSongLanguage = settings['selectedSongLanguage'];

    // Save all imported settings to database
    for (final entry in settings.entries) {
      await _saveSetting(entry.key, entry.value.toString());
    }

    notifyListeners();
  }

  // Clear all settings (reset to defaults)
  Future<void> resetToDefaults() async {
    _isDarkMode = false;
    _fontSize = 16.0;
    _textScaleFactor = 1.0;
    _ignoreDeviceTextScale = true;
    _selectedLanguage = 'English';
    selectedSongLanguage = null;

    await _saveDefaultSettings();
    notifyListeners();
  }
}