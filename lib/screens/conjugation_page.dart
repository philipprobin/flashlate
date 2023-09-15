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
              capitalizeFirstLetter(args.verbConjugations?["verb"]),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "translation1, translation2",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              height: 16,
            ),
            _buildConjugationList("Presente",
                args.verbConjugations?["indicativo"]["Presente"]),
            _buildConjugationList("Imperfecto",
                args.verbConjugations?["indicativo"]["Imperfecto"]),
            _buildConjugationList("Pretérito",
                args.verbConjugations?["indicativo"]["Pretérito"]),
            _buildConjugationList(
                "Futuro", args.verbConjugations?["indicativo"]["Futuro"]),
            _buildConjugationList("Conditional",
                args.verbConjugations?["indicativo"]["Condicional"]),
          ],
        ),
      ),
    );
  }

  // Helper method to build the conjugation list for a specific time
  Widget _buildConjugationList(
      String title, Map<String, dynamic> conjugations) {
    List<Widget> conjugationRows = [];
    bool isWhiteBackground = true; // Variable to alternate row backgrounds

    List<String> customOrder = [
      'yo',
      'tú',
      'él/ella/Ud.',
      'nosotros',
      'vosotros',
      'ellos/ellas/Uds.'
    ]; // Define your custom order

    TextStyle textStyle = TextStyle(
        fontSize: 16,
        color: Colors.grey,
        fontWeight: FontWeight.w500); // Define the text style for values

    customOrder.forEach((key) {
      if (conjugations.containsKey(key)) {
        conjugationRows.add(
          Container(
            // Alternate row background color
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      key,
                      style: textStyle,
                    ),
                  ),
                ), // Left column
                SizedBox(width: 16.0), // Spacer
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      conjugations[key].toString(),
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
                  child: Text(
                    key,
                    style: textStyle
                  ),
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
        Container(height: 16,)
      ],
    );
  }
}
