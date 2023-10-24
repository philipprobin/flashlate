import 'package:flutter/material.dart';

class NumberContainer extends StatelessWidget {
  final Color color;
  final int numberValue;

  NumberContainer({
    required this.color, // Single argument for both border and text color
    required this.numberValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          numberValue.toString(),
          style: TextStyle(
            fontSize: 20,
            color: color, // Set both text and border color to the same value
          ),
        ),
      ),
    );
  }
}
