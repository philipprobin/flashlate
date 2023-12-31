import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudFunctionService {


  static Future<Map<String, dynamic>?> fetchSpanishConjugations(String verb, String currentSourceValueLang) async {
    const parameterlessUrl = "https://us-central1-flashlate-397020.cloudfunctions.net/check_is_spanish_verb?verb=";
    final url = Uri.parse("$parameterlessUrl$verb&sourceLang=$currentSourceValueLang");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Convert the response to UTF-8
        final utf8Response = utf8.decode(response.bodyBytes);

        // Parse the JSON
        final jsonResult = json.decode(utf8Response);

        // Save the JSON to a file (optional)
        // You can use the `path_provider` package to manage file I/O.

        // Print the JSON result
        print("jsonresult $jsonResult");
        return jsonResult;
      } else {
        // Handle HTTP error
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
      return null;
    }
  }
}