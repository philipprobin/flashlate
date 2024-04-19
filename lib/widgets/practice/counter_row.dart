import 'package:flutter/material.dart';

import '../number_container_widget.dart';

class CounterRow extends StatelessWidget {
  final int currentIndex;
  final int userDeckLength;
  final int cardsUnknown;
  final int cardsKnown;

  const CounterRow({
    Key? key,
    required this.currentIndex,
    required this.userDeckLength,
    required this.cardsUnknown,
    required this.cardsKnown,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                NumberContainer(
                  color: Colors.red, // Both border and text color
                  numberValue: cardsUnknown,
                ),
                Text(
                  '${currentIndex + 1} / $userDeckLength',
                  style: TextStyle(
                    fontSize: 20, // Adjust the font size as needed
                  ),
                ),
                NumberContainer(
                  color: Theme.of(context).primaryColor, // Both border and text color
                  numberValue: cardsKnown,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
