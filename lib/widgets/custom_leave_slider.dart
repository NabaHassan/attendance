import 'package:flutter/material.dart';

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

  final VoidCallback onLeftToggleActive;
  final VoidCallback onRightToggleActive;

  const ToggleButton({
    Key? key,
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
    required this.onRightToggleActive,
  }) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  // -1 = left active, 1 = right active
  double _toggleXAlign = -1;
  late bool _isLeftActive;

  @override
  void initState() {
    super.initState();
    _isLeftActive = true; // default left selected
  }

  void _activateLeft() {
    setState(() {
      _toggleXAlign = -1;
      _isLeftActive = true;
    });
    widget.onLeftToggleActive();
  }

  void _activateRight() {
    setState(() {
      _toggleXAlign = 1;
      _isLeftActive = false;
    });
    widget.onRightToggleActive();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.toggleBackgroundColor,
        borderRadius: BorderRadius.circular(50.0),
        border: Border.all(color: widget.toggleBorderColor),
      ),
      child: Stack(
        children: [
          // Sliding background
          AnimatedAlign(
            alignment: Alignment(_toggleXAlign, 0),
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: widget.width * 0.5,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.toggleColor,
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),

          // Left button
          GestureDetector(
            onTap: _activateLeft,
            child: Align(
              alignment: const Alignment(-1, 0),
              child: Container(
                width: widget.width * 0.5,
                alignment: Alignment.center,
                child: Text(
                  widget.leftDescription,
                  style: TextStyle(
                    color: _isLeftActive
                        ? widget.activeTextColor
                        : widget.inactiveTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Right button
          GestureDetector(
            onTap: _activateRight,
            child: Align(
              alignment: const Alignment(1, 0),
              child: Container(
                width: widget.width * 0.5,
                alignment: Alignment.center,
                child: Text(
                  widget.rightDescription,
                  style: TextStyle(
                    color: !_isLeftActive
                        ? widget.activeTextColor
                        : widget.inactiveTextColor,
                    fontWeight: FontWeight.bold,
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
