import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

typedef OnSelected = void Function(int idx, ToggleWidget instance);

class ToggleWidget extends StatefulWidget {
  const ToggleWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.labels,
    this.cornerRadius = 10,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.green,
    this.disabledElementColor = Colors.green,
    this.enabledElementColor = Colors.white,
    this.fontSize = 16.0,
    this.icons,
    this.onSelected
  }):   assert(labels.length >= 2),
        assert(width > 0),
        assert(height > 0),
        assert(cornerRadius > 0),
        super(key: key);

  ///
  /// Width of a toggle button length, warning: this is not full length!!<br>
  /// example, width is 50.0 and labels are [1,2] that results of below.<br>
  ///   [  1 (50.0) ][  2 (50.0) ]<br>
  /// So makes a full length 100.0 size toggle buttons include 2 label texts.<br>
  ///
  final double width;

  ///
  /// Height of toggle buttons.
  ///
  final double height;

  ///
  /// Required toggle button texts. Allow empty text.<br>
  /// FkToggle(<br>
  ///   <t>width: 50,<br>
  ///   height: 30,<br>
  ///   labels: const ['1', '2', '', '', '3', '4']<br>
  /// )<br>
  ///<br>
  ///   Result [1][2][][][3][4], So Some toggles has empty text.<br>
  ///   For example case of wants to set icons in empty label buttons.<br>
  ///
  final List<String> labels;

  ///
  /// Typical 10 to 20, Recommended 5 to 30.
  ///
  final double cornerRadius;

  ///
  /// unselected toggle color
  ///
  final Color backgroundColor;

  ///
  /// selected toggle color
  ///
  final Color selectedColor;

  ///
  /// unselected label color
  ///
  final Color disabledElementColor;

  ///
  /// selected label color
  ///
  final Color enabledElementColor;

  ///
  /// font size of labels
  ///
  final double fontSize;

  ///
  /// Allow null value in lists,You can set an icon for any Toggl
  ///
  final List<SvgPicture?>? icons;

  ///
  /// provide toggle change event, Provide index and instance
  ///
  final OnSelected? onSelected;

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<ToggleWidget> {
  late final Widget _selectedSwitch;
  late final BorderRadius _roundedRadius;

  int _selectedIndex = 0;
  double _topMargin = 0.0;

  @override
  void initState() {
    super.initState();
    _roundedRadius = BorderRadius.all(Radius.circular(widget.cornerRadius));
    _selectedSwitch = Material(
      color: widget.selectedColor,
      borderRadius: _roundedRadius,
      child: InkWell(
        onTap: () {},
        borderRadius: _roundedRadius,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: _roundedRadius,
      color: widget.backgroundColor,
      child: InkWell(
        highlightColor: Colors.white54,
        borderRadius: _roundedRadius,
        radius: 50,
        onTap: () {
          debugPrint('tap');
        },
        onTapDown: (TapDownDetails details) {
          final int index = details.localPosition.dy ~/ widget.height;
          debugPrint("current index $index");
          setState(() {
            _selectedIndex = index;
            _topMargin = (index * (widget.height));
          });
          if (widget.onSelected != null) {
            widget.onSelected!(index, widget);
          }
          debugPrint('tapDown');
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height * widget.labels.length, // Adjust the height
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top: _topMargin), // Adjust the top padding
                child: _selectedSwitch,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Column( // Use Column to stack buttons vertically
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildLabels(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLabels() {
    final List<Widget> list = [];
    widget.labels.asMap().forEach((idx, label) {
      final child = Expanded(
        flex: 1,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: widget.fontSize,
              color: _selectedIndex == idx
                  ? widget.enabledElementColor
                  : widget.disabledElementColor,
            ),
            children: [
              WidgetSpan(
                child: Center(
                  child: SizedBox(
                    height: widget.height, // Set the height to match the button height
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                        child: _tryGet(widget.icons, idx) ?? const SizedBox(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

      );
      list.add(child);
    });
    return list;
  }

  SvgPicture? _tryGet(List<SvgPicture?>? icons, int idx) {
    if (icons != null && idx < icons.length) {
      return icons[idx];
    }
    return null;
  }
}