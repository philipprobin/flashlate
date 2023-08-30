import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordTileWidget extends StatelessWidget {
  final String word;
  final String translation;

  WordTileWidget(this.word, this.translation);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(word),
      subtitle: Text(translation),
    );
  }
}