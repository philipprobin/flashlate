import 'package:flashlate/screens/main_page..dart';
import 'package:flutter/material.dart';

class ConjugationPage extends StatelessWidget {
  static const routeName = '/conjugation';

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input; // Return the input string as-is if it's null or empty
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  String extractLetters(String input) {
    // Define a regular expression to match letters
    final RegExp regex = RegExp(r'[^0-9]+');

    // Use the RegExp pattern to find all matches in the input string
    Iterable<Match> matches = regex.allMatches(input);

    // Join the matched letters to form a new string
    String result = matches.map((match) => match.group(0)!).join('');

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ConjugationArguments;

    debugPrint("verbConjugations --------${args.verbConjugations}");
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0, // Remove the elevation (shadow)
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded, // Change this to your preferred icon
            color: Colors.black, // Change the icon color if needed
          ),
          onPressed: () {
            // Handle the back button press here
            Navigator.of(context).pop(); // Example: Navigate back
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              extractLetters(
                  capitalizeFirstLetter(args.verbConjugations?["infinitive"])),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              args.verbConjugations?["translations"] ?? "",
              style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w100,
                  color: Colors.grey[600]),
            ),
            Container(
              height: 16,
            ),
            _buildConjugationList(
                "Presente", args.verbConjugations?["conjugations"]["presente"]),
            _buildConjugationList("Imperfecto",
                args.verbConjugations?["conjugations"]["imperfecto"]),
            _buildConjugationList(
                "Indefinido", args.verbConjugations?["conjugations"]["indefinido"]),
            _buildConjugationList(
                "Futuro", args.verbConjugations?["conjugations"]["futuro"]),
            _buildConjugationList("Conditional",
                args.verbConjugations?["conjugations"]["condicional"]),
            _buildConjugationList("Perfecto",
                args.verbConjugations?["conjugations"]["perfecto"]),
            _buildConjugationList("Pluscuamperfecto",
                args.verbConjugations?["conjugations"]["pluscuamperfecto"]),
            _buildConjugationList("Subjuntivo Presente",
                args.verbConjugations?["conjugations"]["subjuntivo_presente"]),
            _buildConjugationList("Imperativo Afirmativo",
                args.verbConjugations?["conjugations"]["imperativo_afirmativo"]),
            _buildConjugationList("Imperativo Negativo",
                args.verbConjugations?["conjugations"]["imperativo_negativo"]),
          ],
        ),
      ),
    );
  }

  // Helper method to build the conjugation list for a specific time
  Widget _buildConjugationList(
      String title, Map<String, dynamic> conjugations) {
    List<Widget> conjugationRows = [];

    List<String> customOrder = [
      'yo',
      'tú',
      'él/ella/Ud.',
      'nosotros',
      'vosotros',
      'ellos/ellas/Uds.'
    ]; // Define your custom order

    // convert keys
    conjugations['tú'] = conjugations.remove('tu');
    conjugations['él/ella/Ud.'] = conjugations.remove('el_ella_Ud');
    conjugations['ellos/ellas/Uds.'] = conjugations.remove('ellos_ellas_Uds');



    TextStyle textStyle = TextStyle(
        fontSize: 16,
        color: Colors.grey,
        fontWeight: FontWeight.w500); // Define the text style for values

    customOrder.forEach((pronoun) {
      // presente = {yo: amo, tu : amas}
      if (conjugations.containsKey(pronoun)) {
        conjugationRows.add(
          Container(
            // Alternate row background color
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      pronoun,
                      style: textStyle,
                    ),
                  ),
                ), // Left column
                SizedBox(width: 16.0), // Spacer
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      // value (conjugation)
                      conjugations[pronoun].toString(),
                      style: textStyle, // Apply the text style
                    ),
                  ),
                ), // Right column
              ],
            ),
          ),
        ); // Toggle row background color
      }
    });

    // Add any remaining keys not in the custom order
    conjugations.forEach((key, value) {
      if (!customOrder.contains(key)) {
        conjugationRows.add(
          Container(
            // Alternate row background color
            child: Row(
              children: [
                Expanded(
                  child: Text(key, style: textStyle),
                ), // Left column
                SizedBox(width: 16.0), // Spacer
                Expanded(
                  child: Text(
                    value.toString(),
                    style: textStyle, // Apply the text style
                  ),
                ), // Right column
              ],
            ),
          ),
        ); // Toggle row background color
      }
    });

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0), // Add some spacing
                ...conjugationRows, // Use the spread operator to add all rows
                SizedBox(height: 16.0), // Add spacing between time sections
              ],
            ),
          ),
        ),
        Container(
          height: 16,
        )
      ],
    );
  }
}
