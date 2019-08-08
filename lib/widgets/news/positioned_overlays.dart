import 'package:flutter/material.dart';

class PositionedArticleOverlay extends StatelessWidget {
  const PositionedArticleOverlay({Key key, this.alignment, this.child})
      : super(key: key);

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Radius bottomLeft = Radius.zero,
        bottomRight = Radius.zero,
        topLeft = Radius.zero,
        topRight = Radius.zero;
    Radius radius = Radius.circular(10.0);

    if (alignment == Alignment.topLeft) bottomRight = radius;
    if (alignment == Alignment.topRight) bottomLeft = radius;
    if (alignment == Alignment.bottomLeft) topRight = radius;
    if (alignment == Alignment.bottomRight) topLeft = radius;

    return Align(
      alignment: alignment,
      child: Material(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: bottomLeft,
                  bottomRight: bottomRight,
                  topLeft: topLeft,
                  topRight: topRight)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: child,
          )),
    );
  }
}
