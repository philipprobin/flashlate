import 'package:flutter/material.dart';

class ClearButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.clear, color: Colors.black45),
      onPressed: onPressed,
    );
  }
}
