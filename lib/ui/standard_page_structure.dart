import 'package:flutter/material.dart';
import '../widgets/home_icon.dart';

class StandardPageStructure extends StatelessWidget {
  StandardPageStructure({this.content, this.iconFunction});

  final List<Widget> content;
  final Function iconFunction;

  @override
  Widget build(BuildContext context) {
    content.add(HomeIconButton(onTap: iconFunction));
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
