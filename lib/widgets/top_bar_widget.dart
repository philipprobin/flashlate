import 'package:flashlate/widgets/toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TopBarWidget extends StatefulWidget {
  final ValueChanged<bool>? isEditingMode;

  TopBarWidget({this.isEditingMode});

  @override
  _TopBarWidgetState createState() => _TopBarWidgetState();
}

class _TopBarWidgetState extends State<TopBarWidget> {
  bool isEditingMode = false;

  @override
  Widget build(BuildContext context) {
    final OnSelected selected = ((index, instance) {
      debugPrint('Select $index, toggle ${instance.labels[index]}');
      //editingMode = ;
      widget.isEditingMode?.call((index == 1));
    });

    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Container(
                child: SvgPicture.asset(
                  'assets/image.svg',
                  height: 60,
                ),
              ),
            ),
            SizedBox(width: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      // Color of the shadow
                      spreadRadius: 1,
                      // Spread radius
                      blurRadius: 5,
                      // Blur radius
                      offset: Offset(0, 2), // Offset of the shadow
                    ),
                  ],
                ),
                child: ToggleWidget(
                  width: 40,
                  height: 35,
                  icons: [
                    SvgPicture.asset(
                      'assets/translate.svg',
                    ),
                    SvgPicture.asset(
                      'assets/edit.svg',
                    ),
                  ],
                  labels: const ['', ''],
                  onSelected: selected,
                  selectedColor: Theme.of(context).highlightColor,
                  enabledElementColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
