import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../animations/fade_widget.dart';

class RoundBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FadeWidget(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey[900],
                  offset: Offset(0, 1),
                  blurRadius: 3.0
                )
              ]
            ),
            child: Material(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(24.0),
              child: IconButton(
                alignment: Alignment.topLeft,
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: Colors.white,
                  size: 32.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
