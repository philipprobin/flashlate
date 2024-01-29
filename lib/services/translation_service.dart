import 'package:flutter/cupertino.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flashlate/api_key.dart';

class TranslationService {
  final String apiKey = ApiKey.googleTranslateApiKey;

  FlutterTts flutterTts = FlutterTts();

  Map<String, String> languageMap = {
    "Deutsch": "de",
    "English": "en",
    "Español": "es",
    "Français" : "fr",
    "Polski" : "pl",
    "Português" : "pt",
    "Italiano" : "it"
  };

  // text to speech
  Map<String, String> ttsMap = {
    "Deutsch": "de-DE",
    "English": "en-US",
    "Español": "es-US",
    "Français" : "fr-FR",
    "Polski" : "pl-PL",
    "Português" : "pt-BR",
    "Italiano" : "it-IT"
  };

  Future<String> translateText(String source, String target, String text) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2');

    final sourceCode = languageMap[source]!;
    final targetCode = languageMap[target]!;
    final response = await http.post(url, body: {
      'key': apiKey,
      'q': text,
      'source': sourceCode, // Source language code
      'target': targetCode, // Target language code
    });

    final data = json.decode(response.body);
    debugPrint("other translations ${data}");
    return data['data']['translations'][0]['translatedText'];
  }


  Future<void> speakText(String text, String target, bool speakSlow) async {
    debugPrint("speakText $text");
    final langCode = ttsMap[target]!;

    try {
      double speechRate = 0.5;
      if (speakSlow) {
        speechRate = 0.2;
      }
        await flutterTts.setSpeechRate(speechRate);
        await flutterTts.setLanguage(langCode);
        await flutterTts.speak(text);

    } catch (e) {
      print('Error calling flutterTts: $e');
    }
  }

}
