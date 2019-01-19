import 'package:flutter/material.dart';

class TitleBarIcon extends StatelessWidget {
  TitleBarIcon({this.icon, this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    num iconSize = 26.0;
    return InkWell(
      onTap: onTap,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(
            icon,
            color: Theme.of(context).buttonColor,
            size: iconSize,
          )),
    );
  }
}
