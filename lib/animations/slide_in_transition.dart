import 'package:flutter/material.dart';

enum SlideInDirection { LEFT, RIGHT, UP, DOWN }

class SlideInRoute extends PageRouteBuilder {
  final Widget widget;
  final SlideInDirection direction;
  final bool dialogStyle;

  SlideInRoute({this.widget, this.direction, this.dialogStyle = false})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            Offset start;
            switch (direction) {
              case SlideInDirection.LEFT:
                start = const Offset(-1.0, 0.0);
                break;
              case SlideInDirection.RIGHT:
                start = const Offset(1.0, 0.0);
                break;
              case SlideInDirection.UP:
                start = const Offset(0.0, 1.0);
                break;
              case SlideInDirection.DOWN:
                start = const Offset(0.0, -1.0);
                break;
            }


            SlideTransition contentTransition = SlideTransition(
              position: Tween<Offset>(begin: start, end: Offset.zero)
                  .animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutExpo)),
              child: child,
            );

            if(!dialogStyle) return contentTransition;

            return Stack(
              children: <Widget>[
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 0.45).animate(animation),
                  child: Container(
                    color: Colors.black,
                    constraints: BoxConstraints.expand(),
                  ),
                ),
                contentTransition
              ],
            );
          },
          opaque: !dialogStyle,
        );
}
