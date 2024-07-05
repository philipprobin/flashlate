import 'package:flutter/material.dart';

class SpeakButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SpeakButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.volume_up, color: Colors.black45),
      onPressed: onPressed,
    );
  }
}
