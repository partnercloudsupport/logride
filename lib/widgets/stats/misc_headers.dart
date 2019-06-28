import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  PageHeader({this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 12.0, left: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class HeaderStat extends StatelessWidget {
  HeaderStat({this.stat = 0, this.text});

  final num stat;
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
            stat.toString(),
            style: TextStyle(
                fontSize: 32.0, textBaseline: TextBaseline.alphabetic),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 22.0, textBaseline: TextBaseline.alphabetic),
            ),
          )
        ],
      ),
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