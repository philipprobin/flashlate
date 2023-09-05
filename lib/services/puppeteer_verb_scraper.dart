import 'package:flutter/cupertino.dart';
import 'package:puppeteer/puppeteer.dart';

Future<Map> getDict(String verb) async {
  var browser = await puppeteer.launch();

  // Open a new tab
  var myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://dart.dev', wait: Until.networkIdle);

  // Do something... See other examples
  await myPage.screenshot();
  await myPage.pdf();
  await myPage.evaluate<String>('() => document.title');

  // Gracefully close the browser's process
  await browser.close();


  final page = await browser.newPage();

  final halfUrl = "https://de.pons.com/verbtabellen/spanisch/";
  final url = '$halfUrl$verb';

  try {
    await page.goto(url);

    // Find the input element by its ID
    final inputElement = await page.$('#q');

    // Check if the element exists
    if (inputElement != null) {
      // Set the input element's value to "digo"
      await inputElement.type('digo');

      // Extract the "value" attribute from the input element
      final valueAttribute = await inputElement.evaluate('(element) => element.value');

      if (valueAttribute != null) {
        // Print the extracted value
        print('Value: $valueAttribute');
      } else {
        print('Value attribute not found.');
      }
    } else {
      print('Element with ID "q" not found.');
    }

    final elements = await page.$$('div.ft-single-table');
    print(elements.length);

    final allDicts = {};

    for (final element in elements) {
      final resultDict = {};
      var timeForm = 'empty';
      final h3Element = await element.$('h3');
      if (h3Element != null) {
        timeForm = await h3Element.evaluate('(element) => element.textContent.trim()');
      }
      final table = await element.$('div.ft-single-table table.table');

      if (table != null) {
        final tableBody = await table.$('tbody');
        if (tableBody != null) {
          // Iterate through the table rows
          final rows = await tableBody.$$('tr');
          for (final row in rows) {
            final cells = await row.$$('td');
            if (cells.length >= 2) {
              final pronoun = await cells[0].evaluate('(element) => element.textContent.trim()');
              debugPrint("pronun : $pronoun");
              final value = await cells[1].$eval('.flected_form', '(element) => element.textContent.trim()');
              if (pronoun != null && value != null) {
                resultDict[pronoun] = value;
              }
            }
          }
        }
      }

      allDicts[timeForm] = resultDict;
    }

    await browser.close();
    return allDicts;
  } catch (e) {
    print('Error: $e');
    await browser.close();
    return {};
  }
}

void main() async {
  final verb = 'tener'; // Replace with the verb you want to look up
  final result = await getDict(verb);
  print(result);
}
