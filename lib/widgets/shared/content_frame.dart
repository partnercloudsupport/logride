import 'package:flutter/material.dart';

/// Used when a HomeIcon is in play. Pushes the content down into the padded card form
class ContentFrame extends StatelessWidget {
  ContentFrame({this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 54.0, left: 8.0, right: 8.0, bottom: 8.0),
      child: child,
    );
  }
}
