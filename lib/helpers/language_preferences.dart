import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {
  static const String _defaultSourceLanguage = "Deutsch";
  static const String _defaultTargetLanguage = "Español";

  Future<String> get sourceLanguage async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('source') ?? _defaultSourceLanguage;
  }

  Future<String> get targetLanguage async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('target') ?? _defaultTargetLanguage;
  }

  Future<void> setSourceLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('source', language);
  }

  Future<void> setTargetLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('target', language);
  }
}
