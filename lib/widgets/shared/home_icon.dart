import 'package:flutter/material.dart';
import 'package:log_ride/data/color_constants.dart';

class HomeIconButton extends StatelessWidget {
  HomeIconButton({this.onTap, this.decoration});

  final Function onTap;
  final IconData decoration;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (decoration == null) {
      content = Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: APP_ICON_BACKGROUND,
          ),
          padding: EdgeInsets.only(top: 6.0, bottom: 6.0, right: 3.0),
          child: Image.asset('assets/plain.png'));
    } else {
      content = Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: APP_ICON_BACKGROUND,
        ),
        child: Icon(
          decoration,
          size: 56.0,
          color: APP_ICON_FOREGROUND,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: GestureDetector(
        onTap: onTap != null
            ? onTap
            : () {}, // Pass an empty function if we don't have a tap function
        child: SizedBox(
            height: 85.4,
            width: 85.4,
            child: Container(
                foregroundDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4.0)),
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: content,
                ))),
      ),
    );
  }
}
