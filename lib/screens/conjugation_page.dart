
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';

import '../models/core/conjugation/conjugation.dart';
import '../models/core/conjugation/conjugation_args.dart';
import '../models/core/conjugation/mood.dart';
import '../models/core/conjugation/tense.dart';
import '../services/cloud_function_service.dart';
import '../services/translation_service.dart';

class ConjugationPage extends StatefulWidget {
  static const routeName = '/conjugation';

  @override
  _ConjugationPageState createState() => _ConjugationPageState();
}

class _ConjugationPageState extends State<ConjugationPage> {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xFF00b894), // Change this color to your desired color
      statusBarIconBrightness: Brightness.light, // Change the status bar icon color to
    ));
    final ConjugationArguments args =
        ModalRoute.of(context)!.settings.arguments as ConjugationArguments;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              capitalizeFirstLetter(args.conjugationResult.infinitive),
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
            ),
            FutureBuilder<String>(
              future: CloudFunctionService.get_gpt_translations(
                  args.conjugationResult.infinitive),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ClipRRect(
                    // create border circular radius
                    borderRadius: BorderRadius.circular(4),
                    child: LoadingSkeleton(
                      width: 100,
                      height: 18,
                      colors: [Colors.grey, Colors.white, Colors.grey],
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
            ),
            Container(
              height: 20,
            ),
            ..._buildConjugationLists(args),
          ],
        ),
      ),
    );
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  List<Widget> _buildConjugationLists(ConjugationArguments args) {
    List<Widget> widgets = [];
    for (Mood mood in args.conjugationResult.moods) {
      widgets.add(Text(
        mood.moodName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ));
      for (Tense tense in mood.tenses) {
        widgets.add(_buildColumn(tense.tenseName, tense.conjugations, args));
      }
    }
    return widgets;
  }

  Widget _buildColumn(
      String title, List<Conjugation> conjugations, ConjugationArguments args) {
    List<Widget> conjugationRows = conjugations.map((conjugation) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(conjugation.pronoun,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(conjugation.mainVerb,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.black45),
                onPressed: () {
                  TranslationService().speakText(
                    conjugation.mainVerb,
                    args.currentTargetValueLang,
                  );
                },
              ),
            ),
          ),
        ],
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...conjugationRows,
        SizedBox(height: 16),
      ],
    );
  }
}
