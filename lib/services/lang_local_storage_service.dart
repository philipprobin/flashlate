
import 'package:shared_preferences/shared_preferences.dart';

class LangLocalStorageService{

  static Future<void> setLanguage(String targetOrSourceKey, String language) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(targetOrSourceKey, language);
  }

  // Method to get the target language from SharedPreferences
  static Future<String?> getLanguage(String targetOrSourceKey,) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(targetOrSourceKey);
  }
}