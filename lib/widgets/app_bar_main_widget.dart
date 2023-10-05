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

    return AppBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      actions: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min, // Set to MainAxisSize.min
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Container(
                  child: SvgPicture.asset(
                    'assets/image.svg',
                    height: kToolbarHeight-8, // -2*vertical padding
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  child: ToggleWidget(
                    width: 40,
                    height: 32,
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
      ],
    );
  }
}
