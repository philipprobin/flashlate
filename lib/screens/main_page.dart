import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../helpers/language_preferences.dart';
import '../helpers/translation_helper.dart';
import '../helpers/debouncer.dart';
import '../services/translation_service.dart';
import '../widgets/app_bar_main_widget.dart';
import '../widgets/current_deck_widget.dart';
import '../widgets/main/add_to_deck_button.dart';
import '../widgets/main/language_button_row.dart';
import '../widgets/main/source_text_input_widget.dart';
import '../widgets/main/target_text_input_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TranslationHelper translationHelper = TranslationHelper();
  final Debouncer debounce = Debouncer(milliseconds: 500);

  String textToTranslate = '';
  String translatedText = '';
  bool uploadSuccess = false;
  String currentDropdownValue = '';

  static const double cornerRadius = 20.0;
  static const secondBoxColor = Color(0xFFf8f8f8);

  TextEditingController targetTextEditingController = TextEditingController();
  TextEditingController sourceTextEditingController = TextEditingController();
  bool editingMode = false;

  List<String> dropdownItems = [];

  late LanguagePreferences languagePreferences;
  bool _isEditingMode = false;
  String sourceLanguage = '';
  String targetLanguage = '';

  @override
  void initState() {
    super.initState();
    languagePreferences = LanguagePreferences();
    _initializeDeckNames();
    _retrieveLanguages();
  }

  Future<void> _initializeDeckNames() async {
    translationHelper.getDeckNames((deck, items) {
      setState(() {
        currentDropdownValue = deck;
        dropdownItems = items;
      });
    });
  }

  Future<void> _retrieveLanguages() async {
    final sourceLang = await languagePreferences.sourceLanguage;
    final targetLang = await languagePreferences.targetLanguage;
    setState(() {
      sourceLanguage = sourceLang;
      targetLanguage = targetLang;
    });
  }

  Future<void> refreshOnTogglePress(bool mode) async {
    setState(() {
      if (!mode) {
        if (textToTranslate.isEmpty && translatedText.isNotEmpty) {
          _translateAndSetText(targetLanguage, sourceLanguage, translatedText,
              sourceTextEditingController);
        }
        if (textToTranslate.isNotEmpty && translatedText.isEmpty) {
          _translateAndSetText(sourceLanguage, targetLanguage, textToTranslate,
              targetTextEditingController);
        }
      }
      editingMode = mode;
    });
  }

  void targetTextDeleted() {
    targetTextEditingController.text = '';
    translatedText = "";
  }

  void sourceTextDeleted() {
    sourceTextEditingController.text = '';
    textToTranslate = "";
  }

  Future<void> _translateAndSetText(
    String sourceLang,
    String targetLang,
    String textToTranslate,
    TextEditingController controller,
  ) async {
    final translated = await TranslationService()
        .translateText(sourceLang, targetLang, textToTranslate);
    setState(() {
      debugPrint(
          "sourceLang: $sourceLang targetLang: $targetLang textToTranslate: $textToTranslate translated: $translated");
      translatedText = translated;
      controller.text = translated;
    });
  }

  Future<void> speakTextSourceWrapper(String text) async {
    translationHelper.speakTextWrapper(text, sourceLanguage);
  }

  Future<void> speakTextTargetWrapper(String text) async {
    translationHelper.speakTextWrapper(text, targetLanguage);
  }

  @override
  Widget build(BuildContext context) {
    double factor = 0.40;
    double addBoxPadding = (1 - factor - 0.46) * 100;
    Color addBoxColor = Theme.of(context).primaryColor;
    double translateBoxHeight = MediaQuery.of(context).size.width * factor;

    return KeyboardVisibilityBuilder(builder: (context, visible) {
      return Scaffold(
        body: sourceLanguage.isEmpty || targetLanguage.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    TopBarWidget(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          LanguageButtonRow(
                            onLangChanged:
                                (String sourceLang, String targetLang) {
                              this.sourceLanguage = sourceLang;
                              this.targetLanguage = targetLang;
                              setState(() {});
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CurrentDeckWidget(
                                dropdownItems: dropdownItems,
                                currentDropdownValue: currentDropdownValue,
                                onDeckChanged: (newValue) {
                                  setState(() {
                                    currentDropdownValue = newValue;
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      _isEditingMode = !_isEditingMode;
                                    });
                                    await refreshOnTogglePress(_isEditingMode);
                                  },
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  label: Text('edit', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isEditingMode
                                        ? Color(0xFFFDCB6E)
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SourceTextInputWidget(
                            controller: sourceTextEditingController,
                            editingMode: editingMode,
                            onTextChanged: (value) {
                              setState(() {
                                textToTranslate = value;
                                if (value.isEmpty) {
                                  translatedText = "";
                                }
                                debounce.run(() {
                                  _translateAndSetText(
                                    sourceLanguage,
                                    targetLanguage,
                                    textToTranslate,
                                    targetTextEditingController,
                                  );
                                });
                              });
                            },
                            speakText: speakTextSourceWrapper,
                            onClearText: () {
                              setState(() {
                                if (editingMode) {
                                  sourceTextDeleted();
                                } else {
                                  sourceTextDeleted();
                                  targetTextDeleted();
                                }
                              });
                            },
                          ),
                          TargetTextInputWidget(
                            controller: targetTextEditingController,
                            editingMode: editingMode,
                            onTextChanged: (value) {
                              setState(() {
                                textToTranslate = value;
                                if (value.isEmpty) {
                                  translatedText = "";
                                }
                                debounce.run(() {
                                  _translateAndSetText(
                                    targetLanguage,
                                    sourceLanguage,
                                    textToTranslate,
                                    sourceTextEditingController,
                                  );
                                });
                              });
                            },
                            speakText: speakTextTargetWrapper,
                            onClearText: () {
                              setState(() {
                                if (editingMode) {
                                  targetTextDeleted();
                                } else {
                                  sourceTextDeleted();
                                  targetTextDeleted();
                                }
                              });
                            },
                            cornerRadius: cornerRadius,
                            translateBoxHeight: translateBoxHeight,
                            secondBoxColor: secondBoxColor,
                          ),
                          AddToCardDeckButton(
                            sourceTextEditingController:
                                sourceTextEditingController,
                            targetTextEditingController:
                                targetTextEditingController,
                            cornerRadius: cornerRadius,
                            addBoxPadding: addBoxPadding,
                            addBoxColor: addBoxColor,
                            onSuccess: () {
                              setState(() {
                                targetTextEditingController.text = "";
                                sourceTextEditingController.text = "";
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      );
    });
  }
}
