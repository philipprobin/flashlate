import 'package:flutter/material.dart';

class ProficiencyButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const ProficiencyButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            side: MaterialStateProperty.all(BorderSide(
              color: color,
              width: 2.0,
            )),
            foregroundColor: MaterialStateProperty.all(color),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
