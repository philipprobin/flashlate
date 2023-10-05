import 'package:puppeteer/puppeteer.dart' as pup;

void main() async {
  // Launch the Puppeteer browser.
  final browser = await pup.puppeteer.launch();

  // Open a new page.
  final page = await browser.newPage();

  // Navigate to the URL.
  final half_url = 'https://konjugator.reverso.net/konjugation-spanisch-verb-';
  final verb = 'volver';
  final end = '.html';

  print(half_url + verb + end);

  await page.goto(half_url + verb + end);

  final elements = await page.$$('div.word-translated-wrap');

  print(elements);

  // Call another method from main.

  await searchForVerb(page, "decir");

  final button = await page.$('#search_button');

  // Click on the button element.
  await button.click();

  // Wait for the page to reload. You can adjust the waiting time as needed.
  await page.waitForNavigation();

  await lookForKonjugations(page);

  // Close the browser.
  await browser.close();
}

Future<void> lookForKonjugations(pup.Page page) async {
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
      final table = await element.$('div.ft-single-table table.table');
      print("table found");

      final tableBody = await table.$('tbody');
      // Iterate through the table rows
      final rows = await tableBody.$$('tr');
      for (final row in rows) {
        final cells = await row.$$('td');
        if (cells.length >= 2) {
          final pronoun = await cells[0]
              .evaluate('(element) => element.textContent.trim()');
          final value = await cells[1].$eval(
              '.flected_form', '(element) => element.textContent.trim()');
          if (pronoun != null && value != null) {
            print("words : $pronoun $value");
            //resultDict[pronoun] = value;
          }
        }
      }
    } catch (e) {
      print("crashed");
    }
  }

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

