import 'package:flutter/material.dart';

const int _DISPLAY_LENGTH = 3;

class BigStatDisplay extends StatelessWidget {
  const BigStatDisplay({Key key, this.value, this.label}) : super(key: key);

  final num value;
  final String label;

  String roundNumber() {
    // Let's see how our number renders first:
    String testRender = value.toString();
    // If it's longer than three digits, we need to do something about it
    int length = testRender.length;
    // It's shorter than our digitsToRound, so we're good to go
    if (length < _DISPLAY_LENGTH) return testRender;
    if (length == _DISPLAY_LENGTH) {
      num newValue = value / 100;
      newValue = newValue.floor();
      return (newValue * 100).toString() + "+ ";
    }

    num newValue = value / 1000;
    String precision = newValue.toStringAsFixed(1) + "k+ ";

    return precision;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: roundNumber(),
          style: DefaultTextStyle.of(context).style.apply(fontSizeDelta: 22.0),
          children: [TextSpan(text: label, style: TextStyle(fontSize: 22.0))]),
    );
  }
}
