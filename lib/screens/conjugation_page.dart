import 'package:flashlate/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';

import '../services/cloud_function_service.dart';
import 'main_page..dart';

class ConjugationPage extends StatelessWidget {
  static const routeName = '/conjugation';

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as ConjugationArguments;

    debugPrint("gptTranslation --------${args.verbConjugations?["conjugations"]["gptTranslation"]}");
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              capitalizeFirstLetter(args.verbConjugations?["infinitive"]),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            (args.verbConjugations?["conjugations"]["gptTranslation"]?[DatabaseService.languageMap[args.sourceLang]] == null)?
            FutureBuilder<String>(
              future: CloudFunctionService.get_gpt_translations(args.verbConjugations?["infinitive"], args.sourceLang, args.lang),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ClipRRect(
                    // create border circular radius
                    borderRadius: BorderRadius.circular(4),
                    child: LoadingSkeleton(
                      width: 100,
                      height: 18,
                      colors: [Colors.amber, Colors.purpleAccent, Colors.amber],
                    ),
                ); // Show a loading indicator.
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    snapshot.data ?? 'No translation available',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w100,
                      color: Colors.grey[600],
                    ),
                  );
                }
              },
            ) :

            Text(
              args.verbConjugations?["conjugations"]["gptTranslation"][DatabaseService.languageMap[args.sourceLang]],
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w100,
                color: Colors.grey[600],
              ),
            ),
            Container(
              height: 16,
            ),
            ..._buildConjugationLists(args),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConjugationLists(args) {
    if (args.lang == "Español") {
      return [
        _buildConjugationListEs(
          "Presente",
          args.verbConjugations?["conjugations"]["presente"],
          args.lang,
        ),
        _buildConjugationListEs(
          "Imperfecto",
          args.verbConjugations?["conjugations"]["imperfecto"],
          args.lang,
        ),
        _buildConjugationListEs("Indefinido",
            args.verbConjugations?["conjugations"]["indefinido"], args.lang),
        _buildConjugationListEs("Futuro",
            args.verbConjugations?["conjugations"]["futuro"], args.lang),
        _buildConjugationListEs("Conditional",
            args.verbConjugations?["conjugations"]["condicional"], args.lang),
        _buildConjugationListEs("Perfecto",
            args.verbConjugations?["conjugations"]["perfecto"], args.lang),
        _buildConjugationListEs(
            "Pluscuamperfecto",
            args.verbConjugations?["conjugations"]["pluscuamperfecto"],
            args.lang),
        _buildConjugationListEs(
            "Subjuntivo Presente",
            args.verbConjugations?["conjugations"]["subjuntivo_presente"],
            args.lang),
        _buildConjugationListEs(
            "Imperativo Afirmativo",
            args.verbConjugations?["conjugations"]["imperativo_afirmativo"],
            args.lang),
        _buildConjugationListEs(
            "Imperativo Negativo",
            args.verbConjugations?["conjugations"]["imperativo_negativo"],
            args.lang),
      ];
    } else if (args.lang == "Deutsch") {
      return [
        _buildConjugationListDe(
          "Präsens",
          args.verbConjugations?["conjugations"]["Praesens"],
          args.lang,
        ),
        _buildConjugationListDe(
          "Präteritum",
          args.verbConjugations?["conjugations"]["Praeteritum"],
          args.lang,
        ),
        _buildConjugationListDe("Perfekt",
            args.verbConjugations?["conjugations"]["Perfekt"], args.lang),
        _buildConjugationListDe(
            "Plusquamperfekt",
            args.verbConjugations?["conjugations"]["Plusquamperfekt"],
            args.lang),
        _buildConjugationListDe("Futur I",
            args.verbConjugations?["conjugations"]["Futur_1"], args.lang),
        _buildConjugationListDe("Futur II",
            args.verbConjugations?["conjugations"]["Futur_2"], args.lang),
      ];
    } else {
      return [];
    }
  }

  Widget _buildConjugationListEs(
      String title, Map<String, dynamic> conjugations, String lang) {
    conjugations['tú'] = conjugations.remove('tu');
    conjugations['él/ella/Ud.'] = conjugations.remove('el_ella_Ud');
    conjugations['ellos/ellas/Uds.'] = conjugations.remove('ellos_ellas_Uds');

    List<String> customOrder = [
      'yo',
      'tú',
      'él/ella/Ud.',
      'nosotros',
      'vosotros',
      'ellos/ellas/Uds.',
      'ich',
      'du',
    ];

    return _buildColumn(title, conjugations, customOrder);
  }

  Widget _buildColumn(String title, Map<String, dynamic> conjugations,
      List<String> customOrder) {
    List<Widget> conjugationRows = [];

    TextStyle textStyle = TextStyle(
      fontSize: 16,
      color: Colors.grey,
      fontWeight: FontWeight.w500,
    );

    customOrder.forEach((pronoun) {
      if (conjugations.containsKey(pronoun)) {
        conjugationRows.add(
          Container(
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
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      conjugations[pronoun].toString(),
                      style: textStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    conjugations.forEach((key, value) {
      if (!customOrder.contains(key)) {
        conjugationRows.add(
          Container(
            child: Row(
              children: [
                Expanded(
                  child: Text(key, style: textStyle),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    value.toString(),
                    style: textStyle,
                  ),
                ),
              ],
            ),
          ),
        );
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
                SizedBox(height: 8.0),
                ...conjugationRows,
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
        Container(
          height: 16,
        ),
      ],
    );
  }

  Widget _buildConjugationListDe(
      String title, Map<String, dynamic> conjugations, String lang) {
    conjugations['er/sie/es'] = conjugations.remove('er_sie_es');

    List<String> customOrder = ['ich', 'du', 'er/sie/es', 'wir', 'ihr', 'sie'];

    return _buildColumn(title, conjugations, customOrder);
  }
}
