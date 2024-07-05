import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyPasteButton extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onCopy;
  final VoidCallback onPaste;

  const CopyPasteButton({
    Key? key,
    required this.controller,
    required this.onCopy,
    required this.onPaste,
  }) : super(key: key);

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null) {
      controller.text = clipboardData.text ?? '';
      onPaste();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        controller.text.isNotEmpty ? Icons.copy : Icons.content_paste,
        color: Colors.black45,
      ),
      onPressed: () {
        if (controller.text.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: controller.text)).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Copied to clipboard'),
                duration: Duration(seconds: 2),
              ),
            );
            onCopy();
          });
        } else {
          _pasteFromClipboard();
        }
      },
    );
  }
}
