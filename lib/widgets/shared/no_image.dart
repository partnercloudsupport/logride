import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoImage extends StatelessWidget {
  const NoImage({Key key, this.label, this.child}) : super(key: key);

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final _backgroundColor = Colors.grey[600];
    final _foregroundColor = Colors.grey[400];

    return Container(
      color: _backgroundColor,
      height: 200.0,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Icon(
              FontAwesomeIcons.image,
              color: _foregroundColor,
              size: 40.0,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: _foregroundColor),
          ),
          if (child != null) child
        ],
      ),
    );
    ;
  }
}
