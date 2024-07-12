import 'package:flutter/material.dart';
import 'package:flashlate/services/local_storage_service.dart';

class CurrentDeckWidget extends StatefulWidget {
  final List<String> dropdownItems;
  final String currentDropdownValue;
  final Function(String) onDeckChanged;

  const CurrentDeckWidget({
    Key? key,
    required this.dropdownItems,
    required this.currentDropdownValue,
    required this.onDeckChanged,
  }) : super(key: key);

  @override
  _CurrentDeckWidgetState createState() => _CurrentDeckWidgetState();
}

class _CurrentDeckWidgetState extends State<CurrentDeckWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Theme.of(context).indicatorColor,
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            dropdownColor: Theme.of(context).indicatorColor,
            value: widget.currentDropdownValue.isEmpty
                ? (widget.dropdownItems.isNotEmpty
                    ? widget.dropdownItems[0]
                    : null)
                : widget.currentDropdownValue,
            onChanged: (String? newValue) {
              widget.onDeckChanged(newValue!);
              setState(() {
                LocalStorageService.setCurrentDeck(newValue);
              });
            },
            items: widget.dropdownItems.map<DropdownMenuItem<String>>(
              (String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'AvertaStd',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
