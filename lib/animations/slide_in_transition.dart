import 'package:flutter/material.dart';

enum SlideInDirection { LEFT, RIGHT, UP, DOWN }

class SlideInRoute extends PageRouteBuilder {
  final Widget widget;
  final SlideInDirection direction;

  SlideInRoute({this.widget, this.direction})
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
            return SlideTransition(
              position: Tween<Offset>(begin: start, end: Offset.zero)
                  .animate(animation),
              child: child,
            );
          },
        );
}
