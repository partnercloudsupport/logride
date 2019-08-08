import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateAndReadDisplay extends StatelessWidget {
  const DateAndReadDisplay({Key key, this.created, this.unread})
      : super(key: key);

  final DateTime created;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (unread)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle),
              constraints: BoxConstraints.expand(width: 8.0, height: 8.0),
            ),
          ),
        Text(
          "Posted ${DateFormat.yMMMMd("en_US").format(created)}",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.left,
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}
