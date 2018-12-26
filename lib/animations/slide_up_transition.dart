import 'package:flutter/material.dart';

class SlideUpRoute extends PageRouteBuilder {
  final Widget widget;

  SlideUpRoute({this.widget})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return Stack(
              children: <Widget>[
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 0.45)
                      .animate(animation),
                  child: Container(
                    color: Colors.black,
                    constraints: BoxConstraints.expand(),
                  ),
                ),
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(animation),
                  child: child,
                )
              ],
            );
          },
          opaque: false,
        );
}
