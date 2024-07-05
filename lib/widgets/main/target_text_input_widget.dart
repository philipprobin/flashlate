import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../helpers/language_preferences.dart';
import '../../utils/supported_languages.dart';
import 'icon_buttons/clear_button.dart';
import 'icon_buttons/copy_paste_button.dart';
import 'icon_buttons/speak_button.dart';

class TargetTextInputWidget extends StatefulWidget {
  final TextEditingController controller;
  // final String initialTargetValueLang;
  // final String currentSourceValueLang;
  final bool editingMode;
  final Function(String) onTextChanged;
  // final Function(String, String, String, Function(String)) translateTargetText;
  final Function(String) speakText;
  final VoidCallback onClearText;
  final double cornerRadius;
  final double translateBoxHeight;
  final Color secondBoxColor;

  TargetTextInputWidget({
    Key? key,
    required this.controller,
    // required this.initialTargetValueLang,
    // required this.currentSourceValueLang,
    required this.editingMode,
    required this.onTextChanged,
    // required this.translateTargetText,
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
  String currentTargetValueLang = "Español";
  final List<String> translationLanguages = SupportedLanguages.translationLanguages;

  @override
  void initState() {
    super.initState();
    _initializeTargetLang();
  }

  Future<void> _initializeTargetLang() async {
    final targetLang = await LanguagePreferences().targetLanguage;
    setState(() {
      currentTargetValueLang = targetLang;
    });
  }

  Future<void> _pasteFromClipboard(TextEditingController controller) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null) {
      setState(() {
        controller.text = clipboardData.text ?? '';
        widget.onTextChanged(controller.text);
        // widget.translateTargetText(
        //   currentTargetValueLang,
        //   widget.currentSourceValueLang,
        //   controller.text,
        //       (translation) {
        //     setState(() {
        //       widget.controller.text = translation;
        //     });
        //   },
        // );
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
            Positioned(
              top: 5,
              left: 15,
              child: DropdownButton<String>(
                items: translationLanguages.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: currentTargetValueLang,
                onChanged: (String? newValue) {
                  setState(() {
                    currentTargetValueLang = newValue!;
                    debugPrint("new dropdownvalue: $currentTargetValueLang");
                    LanguagePreferences().setTargetLanguage(newValue);
                  });
                },
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
                      // widget.translateTargetText(
                      //   currentTargetValueLang,
                      //   widget.currentSourceValueLang,
                      //   value,
                      //       (translation) {
                      //     setState(() {
                      //       // widget.controller.text = translation;
                      //     });
                      //   },
                      // );
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
          ],
        ),
      ),
    );
  }
}
