import 'package:flutter/material.dart';
import '../data/color_constants.dart';

class InterfaceButton extends StatelessWidget {
  InterfaceButton(
      {this.text, this.icon, this.onPressed, this.color, this.textColor});

  final String text;
  final Icon icon;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: color ?? UI_BUTTON_BACKGROUND,
      onPressed: onPressed ?? () => print("No function assigned for button"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: (icon != null)
          ? Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0), child: icon)
          : Text(text),
      textColor: textColor ?? Colors.black,
    );
  }
}
