import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/color_constants.dart';

enum UserSuperlativeAlignment { left, right }

class UserSuperlative extends StatelessWidget {
  UserSuperlative(
      {this.height = 200.0,
      this.label = "Coaster Superlative",
      this.icon = FontAwesomeIcons.question,
      this.alignment = UserSuperlativeAlignment.left,
      this.superlative,
      this.superlativeUnit});

  /// Height of the row
  final num height;
  final String label;
  final IconData icon;
  final UserSuperlativeAlignment alignment;

  final String superlative;
  final String superlativeUnit;

  @override
  Widget build(BuildContext context) {
    Widget iconStack, superlativeWidget;

    iconStack = Container(
      height: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: APP_ICON_BACKGROUND,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icon,
          size: 25.0,
          color: APP_ICON_FOREGROUND,
        ),
      ),
    );

    superlativeWidget = Align(
      alignment: Alignment.centerRight,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AutoSizeText(
              superlative,
              style: TextStyle(fontSize: 30.0),
              maxLines: 1,
            ),
            if (superlativeUnit != null) Text(superlativeUnit)
          ],
        ),
      ),
    );

    return Container(
      height: 75.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Icon Stack
          (alignment == UserSuperlativeAlignment.left)
              ? iconStack
              : superlativeWidget,
          // Coaster Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AutoSizeText(
                    label,
                    textAlign: (alignment == UserSuperlativeAlignment.left)
                        ? TextAlign.left
                        : TextAlign.right,
                    maxLines: 1,
                    maxFontSize: 25.0,
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 25.0),
                  ),
                ],
              ),
            ),
          ),
          // Superlative Data
          (alignment == UserSuperlativeAlignment.right)
              ? iconStack
              : superlativeWidget,
        ],
      ),
    );
  }
}
