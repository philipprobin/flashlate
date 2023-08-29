import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ToggleButton extends StatefulWidget {
  final double width;
  final double height;

  final String leftDescription;
  final String rightDescription;

  final Color toggleColor;
  final Color toggleBackgroundColor;
  final Color toggleBorderColor;

  final Color inactiveTextColor;
  final Color activeTextColor;

  final double _leftToggleAlign = -1;
  final double _rightToggleAlign = 1;

  final VoidCallback onLeftToggleActive;
  final VoidCallback onRightToggleActive;

  const ToggleButton(
      {Key? key,
      required this.width,
      required this.height,
      required this.toggleBackgroundColor,
      required this.toggleBorderColor,
      required this.toggleColor,
      required this.activeTextColor,
      required this.inactiveTextColor,
      required this.leftDescription,
      required this.rightDescription,
      required this.onLeftToggleActive,
      required this.onRightToggleActive})
      : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  double _toggleXAlign = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.toggleBackgroundColor,
        borderRadius: BorderRadius.all(
          Radius.circular(50.0),
        ),
        border: Border.all(color: widget.toggleBorderColor),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(_toggleXAlign, 0),
            duration: Duration(milliseconds: 300),
            child: Container(
              width: widget.width * 0.5,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.toggleColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(50.0),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(
                () {
                  _toggleXAlign = widget._rightToggleAlign;
                },
              );

              widget.onRightToggleActive();
            },
            child: Align(
              alignment: Alignment(-1, 0),
              child: Container(
                width: widget.width * 0.5,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/letter_switch.svg',
                  color: Colors.green,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(
                () {
                  _toggleXAlign = widget._leftToggleAlign;
                },
              );

              widget.onLeftToggleActive();
            },
            child: Align(
              alignment: Alignment(1, 0),
              child: Container(
                width: widget.width * 0.5,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/list');
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
