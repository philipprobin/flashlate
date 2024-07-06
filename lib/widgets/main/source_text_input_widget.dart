import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'icon_buttons/clear_button.dart';
import 'icon_buttons/copy_paste_button.dart';
import 'icon_buttons/speak_button.dart';

class SourceTextInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool editingMode;
  final Function(String) onTextChanged;
  final Function(String) speakText;
  final VoidCallback onClearText;

  SourceTextInputWidget({
    Key? key,
    required this.controller,
    required this.editingMode,
    required this.onTextChanged,
    required this.speakText,
    required this.onClearText,
  }) : super(key: key);

  @override
  _SourceTextInputWidgetState createState() => _SourceTextInputWidgetState();
}

class _SourceTextInputWidgetState extends State<SourceTextInputWidget> {


  Future<void> _pasteFromClipboard(TextEditingController controller) async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null) {
      setState(() {
        controller.text = clipboardData.text ?? '';
        widget.onTextChanged(controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        color: Color(0xFFf8f8f8),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  "Source",
                  style: TextStyle(
                    color: Color(0xFFbcbcbd),
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
