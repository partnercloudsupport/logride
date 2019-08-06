import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  PageHeader({this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 8.0, left: 16.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class PadlessPageHeader extends StatelessWidget {
  PadlessPageHeader({this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w800),
    );
  }
}

class HeaderStat extends StatelessWidget {
  HeaderStat(
      {this.stat = 0,
      this.text,
      this.leftAlign = true,
      this.emphasis = 1.0,
      this.bold = false,
      this.padding = const EdgeInsets.only(top: 12.0)});

  final num stat;
  final String text;
  final bool leftAlign;
  final num emphasis;
  final bool bold;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          if (leftAlign)
            Text(
              stat.toString(),
              style: TextStyle(
                  fontSize: 32.0 * emphasis,
                  textBaseline: TextBaseline.alphabetic,
                  fontWeight: (bold) ? FontWeight.bold : FontWeight.normal),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 22.0 * emphasis,
                    textBaseline: TextBaseline.alphabetic,
                    fontWeight: (bold) ? FontWeight.bold : FontWeight.normal),
                textAlign: (leftAlign) ? TextAlign.left : TextAlign.right,
              ),
            ),
          ),
          if (!leftAlign)
            Text(
              stat.toString(),
              style: TextStyle(
                  fontSize: 32.0 * emphasis,
                  textBaseline: TextBaseline.alphabetic,
                  fontWeight: (bold) ? FontWeight.bold : FontWeight.normal),
            ),
        ],
      ),
    );
  }
}

class StackedHeaderStat extends StatelessWidget {
  StackedHeaderStat(
      {this.topStat, this.topLabel, this.bottomStat, this.bottomLabel});

  final num topStat;
  final num bottomStat;
  final String topLabel;
  final String bottomLabel;

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle =
        TextStyle(fontSize: 22.0, textBaseline: TextBaseline.alphabetic);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          topStat.toString(),
          style:
              TextStyle(fontSize: 44.0, textBaseline: TextBaseline.alphabetic),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 8.0),
                child: Text(
                  topLabel,
                  textAlign: TextAlign.left,
                  style: labelStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                child: Text(
                  bottomLabel,
                  textAlign: TextAlign.right,
                  style: labelStyle,
                ),
              )
            ],
          ),
        ),
        Text(
          bottomStat.toString(),
          style:
              TextStyle(fontSize: 44.0, textBaseline: TextBaseline.alphabetic),
        ),
      ],
    );
  }
}

class StatlessHeader extends StatelessWidget {
  StatlessHeader({this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
                fontSize: 22.0, textBaseline: TextBaseline.alphabetic),
          ),
        ],
      ),
    );
  }
}
