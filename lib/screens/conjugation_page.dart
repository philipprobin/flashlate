import 'package:flashlate/screens/main_page..dart';
import 'package:flutter/material.dart';

class ConjugationPage extends StatelessWidget {

  static const routeName = '/conjugation';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ConjugationArguments;

    debugPrint("verbConjugations --------${args.verbConjugations}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(args.verbConjugations?["verb"]),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildConjugationList("Presente", args.verbConjugations?["indicativo"]["Presente"]),
            _buildConjugationList("Imperfecto", args.verbConjugations?["indicativo"]["Imperfecto"]),
            _buildConjugationList("Pretérito", args.verbConjugations?["indicativo"]["Pretérito"]),
            _buildConjugationList("Futuro", args.verbConjugations?["indicativo"]["Futuro"]),
            _buildConjugationList("Conditional", args.verbConjugations?["indicativo"]["Condicional"]),
          ],
        ),
      ),
    );
  }

  // Helper method to build the conjugation list for a specific time
  Widget _buildConjugationList(String title, Map<String, dynamic> conjugations) {
    List<Widget> conjugationRows = [];
    bool isWhiteBackground = true; // Variable to alternate row backgrounds

    List<String> customOrder = ['yo', 'tú', 'él/ella/Ud.', 'nosotros', 'vosotros', 'ellos/ellas/Uds.']; // Define your custom order

    TextStyle textStyle = TextStyle(fontSize: 16,  fontWeight: FontWeight.bold); // Define the text style for values

    customOrder.forEach((key) {
      if (conjugations.containsKey(key)) {
        conjugationRows.add(
          Container(
            color: isWhiteBackground ? Colors.white : Colors.grey[300], // Alternate row background color
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 18),
                  ),
                ), // Left column
                SizedBox(width: 16.0), // Spacer
                Expanded(
                  child: Text(
                    conjugations[key].toString(),
                    style: textStyle, // Apply the text style
                  ),
                ), // Right column
              ],
            ),
          ),
        );
        isWhiteBackground = !isWhiteBackground; // Toggle row background color
      }
    });

    // Add any remaining keys not in the custom order
    conjugations.forEach((key, value) {
      if (!customOrder.contains(key)) {
        conjugationRows.add(
          Container(
            color: isWhiteBackground ? Colors.white : Colors.grey[300], // Alternate row background color
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    key,
                    style: TextStyle(fontSize: 18,),
                  ),
                ), // Left column
                SizedBox(width: 16.0), // Spacer
                Expanded(
                  child: Text(
                    value.toString(),
                    style: textStyle,// Apply the text style
                  ),
                ), // Right column
              ],
            ),
          ),
        );
        isWhiteBackground = !isWhiteBackground; // Toggle row background color
      }
    });

    return Column(
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
    );
  }

}
