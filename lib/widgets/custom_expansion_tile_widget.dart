import 'package:flutter/material.dart';
// ... other imports ...

class CustomExpansionTileWidget extends StatefulWidget {
  final String title;
  final List<Widget> children;

  CustomExpansionTileWidget({Key? key, required this.title, required this.children})
      : super(key: key);

  @override
  _CustomExpansionTileWidgetState createState() => _CustomExpansionTileWidgetState();
}

class _CustomExpansionTileWidgetState extends State<CustomExpansionTileWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: _isExpanded ? Theme.of(context).primaryColor : null,),),
      trailing: Icon(
        _isExpanded ? Icons.expand_less : Icons.expand_more,
        color: _isExpanded ? Theme.of(context).primaryColor : null,
      ),
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpanded = expanded;
          debugPrint("ExpansionTile isExpanded: $_isExpanded");
        });
      },
      children: widget.children,
    );
  }
}