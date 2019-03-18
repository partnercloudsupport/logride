import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/animations/fade_widget.dart';

enum BackButtonDirection {
  LEFT,
  RIGHT
}

class RoundBackButton extends StatelessWidget {
  RoundBackButton({this.direction = BackButtonDirection.LEFT});

  final BackButtonDirection direction;

  @override
  Widget build(BuildContext context) {
    bool left = (direction == BackButtonDirection.LEFT);
    return Align(
      alignment: left ? Alignment.topLeft : Alignment.topRight,
      child: FadeWidget(
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
                  icon: Icon(
                    left ? FontAwesomeIcons.arrowLeft : FontAwesomeIcons.arrowRight,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
