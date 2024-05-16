import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_skeleton_niu/loading_skeleton.dart';

import '../models/core/conjugation/conjugation.dart';
import '../models/core/conjugation/conjugation_result.dart';
import '../models/core/conjugation/mood.dart';
import '../models/core/conjugation/tense.dart';
import '../services/cloud_function_service.dart';
import '../services/translation_service.dart';
import 'main_page..dart';

class ConjugationPage extends StatefulWidget {
  static const routeName = '/conjugation';

  @override
  _ConjugationPageState createState() => _ConjugationPageState();
}

class _ConjugationPageState extends State<ConjugationPage> {

  @override
  Widget build(BuildContext context) {
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
              future: CloudFunctionService.get_gpt_translations(args.conjugationResult.infinitive, args.currentSourceValueLang, args.currentTargetValueLang),
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
            ),
            Container(
              height: 16,
            ),
            ..._buildConjugationLists(args.conjugationResult),
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

  List<Widget> _buildConjugationLists(ConjugationResult conjugationResult) {
    List<Widget> widgets = [];
    for (Mood mood in conjugationResult.moods) {
      widgets.add(Text(
        mood.moodName,
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
      ));
      for (Tense tense in mood.tenses) {
        widgets.add(_buildColumn(tense.tenseName, tense.conjugations));
      }
    }
    return widgets;
  }

  Widget _buildColumn(String title, List<Conjugation> conjugations) {
    List<Widget> conjugationRows = conjugations.map((conjugation) {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(conjugation.pronoun,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(conjugation.mainVerb,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.black45),
                onPressed: () {
                  setState(() {
                    TranslationService().speakText(
                        conjugation.mainVerb,
                        "Français",
                    );
                  });
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
