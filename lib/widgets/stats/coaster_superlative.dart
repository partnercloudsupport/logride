import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/color_constants.dart';

enum CoasterSuperlativeAlignment { left, right }

class CoasterSuperlative extends StatelessWidget {
  CoasterSuperlative(
      {this.height = 200.0,
      this.label = "Coaster Superlative",
      this.icon = FontAwesomeIcons.question,
      this.coaster,
      this.alignment = CoasterSuperlativeAlignment.left,
      this.superlative,
      this.superlativeUnit});

  /// Height of the row
  final num height;
  final String label;
  final IconData icon;
  final AttractionBundle coaster;
  final CoasterSuperlativeAlignment alignment;

  /// Return a string that will be used to display the superlative
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
          (alignment == CoasterSuperlativeAlignment.left)
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
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      label,
                      textAlign: (alignment == CoasterSuperlativeAlignment.left)
                          ? TextAlign.left
                          : TextAlign.right,
                    ),
                  ),
                  AutoSizeText(
                    coaster?.bluehost?.attractionName ?? "No Coaster",
                    textAlign: (alignment == CoasterSuperlativeAlignment.left)
                        ? TextAlign.left
                        : TextAlign.right,
                    maxLines: 1,
                    maxFontSize: 25.0,
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 25.0),
                  ),
                  Text(coaster?.parkName ?? "")
                ],
              ),
            ),
          ),
          // Superlative Data
          (alignment == CoasterSuperlativeAlignment.right)
              ? iconStack
              : superlativeWidget,
        ],
      ),
    );
  }
}
