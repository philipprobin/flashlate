import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

Future<Map> getDict(String verb) async {
  final halfUrl = "https://de.pons.com/verbtabellen/spanisch/";
  final url = '$halfUrl$verb';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = html.parse(response.body);

      // Find the input element by its ID
      final inputElement = document.querySelector('#q');

      // Check if the element exists
      if (inputElement != null) {
        // Extract the "value" attribute from the input element
        final valueAttribute = inputElement.attributes['value'];
        inputElement.attributes['value'] = "digo";

        if (valueAttribute != null) {
          // Print the extracted value
          print('Value: $valueAttribute');
        } else {
          print('Value attribute not found.');
        }
      } else {
        print('Element with ID "q" not found.');
      }

      final elements = document.querySelectorAll('div.ft-single-table');
      print(elements.length);

      var allDicts = {};

      for (final element in elements) {
        var resultDict = {};
        var timeForm = 'empty';
        final h3Element = element.querySelector('h3');
        if (h3Element != null) {
          timeForm = h3Element.text.trim();
        }
        final table = element.querySelector('div.ft-single-table table.table');

        if (table != null) {
          final tableBody = table.querySelector('tbody');
          if (tableBody != null) {
            // Iterate through the table rows
            final rows = tableBody.querySelectorAll('tr');
            for (final row in rows) {
              final cells = row.querySelectorAll('td');
              if (cells.length >= 2) {
                final pronoun = cells[0].text.trim();
                final value =
                    cells[1].querySelector('.flected_form')?.text.trim();
                if (value != null) {
                  resultDict[timeForm] = {pronoun.toString(): value.toString()};
                  // print('$pronoun: $value');
                }
              }
            }
          }
        }

        allDicts[timeForm] = resultDict;
      }

      return allDicts;
    } else {
      return {};
    }
  } catch (e) {
    print('Error: $e');
    return {};
  }
}

Future<void> fetchAndPrintData(verb) async {
  final halfUrl = "https://us-central1-flashlate-397020.cloudfunctions.net/rae_konjugations?verb=";
  final url = Uri.parse("$halfUrl$verb");

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
      print(jsonResult);
    } else {
      // Handle HTTP error
      print('HTTP Error: ${response.statusCode}');
    }
  } catch (error) {
    // Handle network or other errors
    print('Error: $error');
  }
}


void main() async {
  fetchAndPrintData('había');
  /*final verb = 'tener'; // Replace with the verb you want to look up
  final result = await getDict(verb);*/
  // print(result);
}
