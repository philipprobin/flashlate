import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../helpers/debouncer.dart';
import '../../helpers/language_preferences.dart';
import '../../models/core/conjugation/conjugation_args.dart';
import '../../models/core/conjugation/conjugation_result.dart';
import '../../screens/conjugation_page.dart';
import 'icon_buttons/clear_button.dart';
import 'icon_buttons/copy_paste_button.dart';
import 'icon_buttons/speak_button.dart';
import '../../helpers/translation_helper.dart';

class TargetTextInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool editingMode;
  final Function(String) onTextChanged;
  final Function(String) speakText;
  final VoidCallback onClearText;
  final double cornerRadius;
  final double translateBoxHeight;
  final Color secondBoxColor;

  TargetTextInputWidget({
    Key? key,
    required this.controller,
    required this.editingMode,
    required this.onTextChanged,
    required this.speakText,
    required this.onClearText,
    required this.cornerRadius,
    required this.translateBoxHeight,
    required this.secondBoxColor,
  }) : super(key: key);

  @override
  _TargetTextInputWidgetState createState() => _TargetTextInputWidgetState();
}

class _TargetTextInputWidgetState extends State<TargetTextInputWidget> {
  ConjugationResult? conjugationResult;
  final TranslationHelper translationHelper = TranslationHelper();

  final Debouncer debounce = Debouncer(milliseconds: 500);

  Future<void> _pasteFromClipboard(TextEditingController controller) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null) {
      setState(() {
        controller.text = clipboardData.text ?? '';
        widget.onTextChanged(controller.text);
        _checkConjugations(controller.text);
      });
    }
  }

  String currentTargetValueLang = "Español";
  String currentSourceValueLang = "Deutsch";

  @override
  void initState() {
    super.initState();
    _initializeSourceLang();

    widget.controller.addListener(_onTextChanged);
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
  void dispose() {
    // Dispose of the controller when the widget is disposed
    widget.controller.dispose();
    super.dispose();
  }

  // The function that gets called whenever the text changes
  void _onTextChanged() {
    debounce.run(() {
      print("Text has changed: ${widget.controller.text}");
      _checkConjugations(widget.controller.text);
      // Your debounced logic here
    });
  }

  void _checkConjugations(String text) {
    if (currentTargetValueLang == "Français" ||
        currentTargetValueLang == "Español" ||
        currentTargetValueLang == "Deutsch") {
      translationHelper.checkConjugations(text, currentTargetValueLang,
          (result) {
        setState(() {
          conjugationResult = result;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.translateBoxHeight,
      decoration: BoxDecoration(
        color: widget.secondBoxColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(widget.cornerRadius),
          bottomRight: Radius.circular(widget.cornerRadius),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                "Target",
                style: TextStyle(
                  color: Color(0xFFbcbcbd),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: TextFormField(
                  maxLines: 2,
                  onChanged: (value) {
                    if (!widget.editingMode) {
                      widget.onTextChanged(value);
                    }
                    setState(() {});
                  },
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  controller: widget.controller,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Enter text',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 24,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.controller.text.isNotEmpty)
                    ClearButton(onPressed: widget.onClearText),
                  CopyPasteButton(
                    controller: widget.controller,
                    onCopy: () {},
                    onPaste: () {
                      _pasteFromClipboard(widget.controller);
                    },
                  ),
                  if (widget.controller.text.isNotEmpty)
                    SpeakButton(
                      onPressed: () {
                        widget.speakText(widget.controller.text);
                      },
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 10,
              child: (conjugationResult != null)
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).indicatorColor,
                      ),
                      onPressed: () {
                        if (conjugationResult != null) {
                          Navigator.pushNamed(
                            context,
                            ConjugationPage.routeName,
                            arguments: ConjugationArguments(
                              conjugationResult!,
                              currentTargetValueLang,
                              currentSourceValueLang,
                            ),
                          );
                        } else {
                          debugPrint("conjugationResult == null");
                        }
                      },
                      // todo check why conjugationResult is not triggered
                      child: Text(
                        "Conjugate ${conjugationResult!.infinitive}",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
