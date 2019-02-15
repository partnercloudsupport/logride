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
          color: APP_ICON_BACKGROUND,
          padding: EdgeInsets.only(top: 6.0, bottom: 6.0, right: 3.0),
          child: Image.asset(
            'assets/plain.png'
          ));
    } else {
      content = Container(
        constraints: BoxConstraints.expand(),
        color: APP_ICON_BACKGROUND,
        child: Icon(
          decoration,
          size: 56.0,
          color: APP_ICON_FOREGROUND,
        ),
      );
    }

    return Column(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: GestureDetector(
              onTap: onTap != null
                  ? onTap
                  : () {}, // Pass an empty function if we don't have a tap function
              child: Container(
                  height: 85.4,
                  width: 85.4,
                  foregroundDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4.0)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60.0),
                    child: content,
                  )),
            ),
          ),
        )
      ],
    );
  }
}
