import 'package:flutter/material.dart';

class LangDropButtonWidget extends StatefulWidget {
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;

  LangDropButtonWidget({
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  _LangDropButtonWidgetState createState() => _LangDropButtonWidgetState();
}

class _LangDropButtonWidgetState extends State<LangDropButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          iconEnabledColor: Colors.transparent,
          isExpanded: true,
          value: widget.value,
          onChanged: widget.onChanged,
          items: widget.items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Container(
                /*decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),*/
                child: Center(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
