import 'package:flutter/material.dart';
import 'package:log_ride/widgets/home_icon.dart';

/// Centers content and applies a homeIcon in the appropriate position on the stack.
class StandardPageStructure extends StatelessWidget {
  StandardPageStructure({this.content, this.iconDecoration, this.iconFunction});

  final List<Widget> content;
  final Widget iconDecoration;
  final Function iconFunction;

  @override
  Widget build(BuildContext context) {
    content.add(HomeIconButton(onTap: iconFunction, decoration: iconDecoration));
    return Container(
        child: Center(
      child: SafeArea(
        child: Stack(
          children: content,
        ),
      ),
    ));
  }
}
