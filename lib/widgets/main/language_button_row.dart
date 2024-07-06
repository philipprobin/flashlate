import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helpers/language_preferences.dart';
import '../../utils/supported_languages.dart';

class LanguageButtonRow extends StatefulWidget {
  final void Function(String sourceLang, String targetLang)? onLangChanged;
  const LanguageButtonRow({super.key, required this.onLangChanged});

  @override
  State<LanguageButtonRow> createState() => _LanguageButtonRowState();
}

class _LanguageButtonRowState extends State<LanguageButtonRow> {
  String currentTargetValueLang = "Español";
  String currentSourceValueLang = "Deutsch";
  final List<String> translationLanguages =
      SupportedLanguages.translationLanguages;

  @override
  void initState() {
    super.initState();
    _initializeSourceLang();
  }

  Future<void> _initializeSourceLang() async {
    final sourceLang = await LanguagePreferences().sourceLanguage;
    final targetLang = await LanguagePreferences().targetLanguage;
    setState(() {
      currentSourceValueLang = sourceLang;
      currentTargetValueLang = targetLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // source language dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                items: translationLanguages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(child: Text(value)),
                  );
                }).toList(),
                value: currentSourceValueLang,

                onChanged: (String? newValue) {
                  setState(() {
                    currentSourceValueLang = newValue!;
                  });
                  LanguagePreferences().setSourceLanguage(newValue!);
                  widget.onLangChanged!(currentSourceValueLang, currentTargetValueLang);
                },
                icon: Container(), // Remove the dropdown indicator arrow
                dropdownColor: Colors.grey[300],
                underline: SizedBox(), // Remove the underline
              ),
            ),
          ),
          Spacer(),
          // target language dropdown
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                items: translationLanguages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(child: Text(value)),
                  );
                }).toList(),
                value: currentTargetValueLang,
                onChanged: (String? newValue) {
                  setState(() {
                    currentTargetValueLang = newValue!;
                  });
                  LanguagePreferences().setTargetLanguage(newValue!);
                  widget.onLangChanged!(currentSourceValueLang, currentTargetValueLang);
                },
                icon: Container(), // Remove the dropdown indicator arrow
                dropdownColor: Colors.grey[300],
                underline: SizedBox(), // Remove the underline
              ),
            ),
          ),
        ],
      ),
    );
  }
}
