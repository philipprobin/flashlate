/*
import 'dart:convert';
import 'dart:io';
import 'package:puppeteer/puppeteer.dart' as pup;

final lang = "spanisch/";
final filePath = 'lib/spanischVerbs.txt'; // Provide the correct file path
final fileName = 'verbsESzwei.json';

void main() async {
  // Launch the Puppeteer browser.
  final browser = await pup.puppeteer.launch();

  // Open a new page.
  final page = await browser.newPage();

  // Navigate to the URL.
  final lines = await readLinesFromFile(filePath);

  final half_url = 'https://de.pons.com/verbtabellen/';

  //var lines = ["haber", "ir"];
  // final verb = 'volver';
  List<String> timeForms = supportedTimeForms();
  int counter = 0;
  for (String verb in lines) {
    print(half_url + lang + verb);
    counter += 1;
    print("counter $counter");

    await page.goto(half_url + lang + verb);

    final elements = await page.$$('div.word-translated-wrap');

    print(elements);

    // Call another method from main.
    /* await searchForVerb(page, "decir");
    final button = await page.$('#search_button');
    // Click on the button element.
    await button.click();
    // Wait for the page to reload. You can adjust the waiting time as needed.
    await page.waitForNavigation();*/

    Map verbMap = await lookForKonjugations(page, timeForms);
    addVerbToFile(verb, verbMap);
  }
  // Close the browser.
  await browser.close();
}

void addVerbToFile(String verb, Map verbMap) {
  File file = File(fileName);
  Map<String, dynamic> existingData = {};

  // Check if the file exists and read its content.
  if (file.existsSync()) {
    final jsonString = file.readAsStringSync();
    existingData = json.decode(jsonString);
  }

  // Add or update the data in the map.
  existingData[verb] = verbMap;

  // Write the updated data to the file with indentation.
  final encoder = JsonEncoder.withIndent('  '); // Two spaces for indentation.
  final prettyJson = encoder.convert(existingData);
  file.writeAsStringSync(prettyJson);
}

Future<List<String>> readLinesFromFile(String filePath) async {
  final lines = <String>[];
  try {
    final file = File(filePath);
    final contents = await file.readAsLines();
    lines.addAll(contents);
  } catch (e) {
    print('An error occurred: $e');
  }
  return lines;
}

String? pronounReplacements(String pronoun) {
  if (lang == "spanisch/") {
    Map<String, String> replacements = {
      'él/ella/usted': 'el_ella_Ud',
      'nosotros/nosotras': 'nosotros',
      'vosotros/vosotras': 'vosotros',
      'ellos/ellas/ustedes': 'ellos_ellas_Uds',
      'tú' : 'tu',
      '(tú)': 'tu',
      '(usted)': 'el_ella_Ud.',
      '(nosotros/nosotras)': 'nosotros',
      '(vosotros/vosotras)': 'vosotros',
      '(ustedes)': 'ellos_ellas_Uds',
    };
    return replacements[pronoun];
  }
  if (lang == "deutsch/") {
    Map<String, String> replacements = {
      "er/sie/es" : "er_sie_es"
    };
    return replacements[pronoun];
  }
  return null;
}

List<String> supportedTimeForms() {
  if (lang == "spanisch/") {
    return [
      "presente",
      "imperfecto",
      "indefinido",
      "futuro",
      "condicional",
      "perfecto",
      "pluscuamperfecto",
      "subjuntivo presente",
      "imperativo afirmativo",
      "imperativo negativo"
    ];
  }
  if (lang == "deutsch/") {
    return [
      "Präsens",
      "Präteritum",
      "Perfekt",
      "Plusquamperfekt",
      "Futur I",
      "Futur II",
    ];
  }
  return [];
}

Future<Map> lookForKonjugations(pup.Page page, List<String> timeForms) async {
  var verbDict = {};
  print("lookForKonjugations");
  final elements = await page.$$('div.ft-single-table');
  print(elements.length);

  for (final element in elements) {
    try {
      var timeForm = 'empty';
      final h3Element = await element.$('h3');
      timeForm =
          await h3Element.evaluate('(element) => element.textContent.trim()');

      print("timeform $timeForm");
      if (!timeForms.contains(timeForm)) {
        continue;
      }
      //timeForm = timeForm.replaceAll(" ", "_").replaceAll("ä", "ae");
      var timeFormDict = {};
      timeFormDict[timeForm] = {};
      final table = await element.$('div.ft-single-table table.table');


      final tableBody = await table.$('tbody');
      // Iterate through the table rows
      final rows = await tableBody.$$('tr');
      for (final row in rows) {
        final cells = await row.$$('td');
        if (cells.length >= 2) {
          var auxVerb = "";
          var mainVerb = "";
          final pronoun = await cells[0]
              .evaluate('(element) => element.textContent.trim()');
          /*final value = await cells[1].$eval(
              '.flected_form', '(element) => element.textContent.trim()');
*/
          var value = await cells[1].$eval(
            'span',
            '(element) => element.textContent.trim()',
          );
          try {
            // if there is an auxillary verb like: yo he hecho
            mainVerb = await cells[2].$eval(
              'span',
              '(element) => element.textContent.trim()',
            );
            auxVerb = value;
          } catch (e) {
            mainVerb = value;
          }
          if (pronoun != null) {
            String newPronoun = pronounReplacements(pronoun) ?? pronoun;
            // print("words : ${newPronoun} $value");
            if (timeForms.contains(timeForm)) {
              timeFormDict[timeForm][newPronoun] = {"mainVerb": mainVerb, "auxVerb": auxVerb};
            }
            //resultDict[pronoun] = value;
          }
        }
      }
      if (timeFormDict.isNotEmpty) {
        verbDict[timeForm] = timeFormDict[timeForm];
      }
    } catch (e) {
      print("crashed");
    }
  }
  print("verbDict  $verbDict");
  return verbDict;
  //allDicts[timeForm] = resultDict;
}

Future<void> searchForVerb(pup.Page page, String verb) async {
  final input = await page.$('.pons-search-input');

  // Get the value of the input element.
  var value = await input.property('value');
  print('Input Element Value: ${await value.jsonValue}');

  final inputSelector = '#q';
  await page.waitForSelector(inputSelector);
  await page.type(inputSelector, verb,
      delay: const Duration(milliseconds: 100));

  // Verify the new value of the input element.
  final newValue =
      await page.evaluate('() => document.querySelector("#q").value');
  print('Input Element Value: $newValue');

  value = await input.property('value');
  print('Input Element Value: ${await value.jsonValue}');
}
*/