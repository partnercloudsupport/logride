import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsTile extends StatelessWidget {
  SettingsTile(
      {this.title, this.subtitle, this.onTap, this.showNavArrow = false});

  final String title;
  final String subtitle;
  final bool showNavArrow;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title ?? "Navigation Tile"),
      subtitle: (subtitle != null) ? Text(subtitle) : null,
      trailing: (showNavArrow) ? Icon(FontAwesomeIcons.angleRight) : null,
      onTap: onTap,
    );
  }
}
