import 'package:flutter/material.dart';

class SideStrikeText extends StatelessWidget {
  SideStrikeText(
      {this.bodyText,
      this.strikeColor = Colors.black,
      this.strikeThickness = 2.0,
      this.strikePadding = 8.0});

  final Text bodyText;
  final Color strikeColor;
  final double strikeThickness;
  final double strikePadding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildSideStrike(context),
        bodyText,
        _buildSideStrike(context)
      ],
    );
  }

  Widget _buildSideStrike(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(strikePadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            height: strikeThickness,
            color: strikeColor,
          ),
        ),
      ),
    );
  }
}
