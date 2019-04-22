import 'package:flutter/material.dart';
import 'package:log_ride/data/color_constants.dart';

class InterfaceButton extends StatelessWidget {
  InterfaceButton(
      {this.text, this.subtext, this.icon, this.onPressed, this.color, this.textColor});

  final String text;
  final String subtext;
  final Icon icon;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {

    Widget content = Container();
    if(icon != null){
      content = Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0), child: icon);
    } else {
      content = Text(text);
      if(subtext != null){
        content = Column(children: <Widget>[
          content,
          Text(subtext, textScaleFactor: 0.8,)
        ],);
      }
    }

    return RaisedButton(
      color: color ?? UI_BUTTON_BACKGROUND,
      onPressed: onPressed ?? () => print("No function assigned for interace button"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: content,
      textColor: textColor ?? Colors.black,
    );
  }
}
