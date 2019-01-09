import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shimmer/shimmer.dart';

/// [ParkProgessListItem] is a small progressbar overlaid with text, documenting how many
/// [numRides] a park has and comparing that to the user's [numRidden]
/// [numRides] - a number representing how many rides are in a park
/// [numRidden] - a number representing how many rides the user has ridden at
///   least once in the park
class ParkProgressListItem extends StatelessWidget {
  ParkProgressListItem({this.numRides, this.numRidden});

  final num numRides;
  final num numRidden;

  @override
  Widget build(BuildContext context) {

    return Container(
        // Hard-coding the size of the box in dp. This may change later.
        constraints: BoxConstraints.loose(Size(62.0, 32.0)),
        // Stack contains two elements, the clipped bar and the text on top
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      color: new Color.fromARGB(255, 221, 222, 224),
                      constraints: BoxConstraints.expand(),
                    ),
                    RewardProgressBar(
                      numerator: numRidden,
                      denominator: numRides,
                    )
                  ],
                )),
            Center(
                child: AutoSizeText(
              "$numRidden/$numRides",
              textScaleFactor: 1.4,
              style: Theme.of(context).textTheme.body2,
            )),
          ],
        ));
  }
}

class ParkProgressFullBar extends StatelessWidget {
  ParkProgressFullBar(
      {this.numRides = 0,
      this.numRidden = 0,
      this.defunctRidden = 0,
      this.showDefunct = false});

  final num numRides;
  final num numRidden;
  final num defunctRidden;
  final bool showDefunct;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Stack(
        children: <Widget>[
          _buildProgressBar(context),
          // Background bar, full width
          // Text overlay - Progress
          _buildProgressLabel(context),
          showDefunct
              ? _buildDefunctLabel(context)
              : Container() // Text overlay - defunct
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    num ratio;
    if (this.numRides == 0) {
      ratio = 0.0;
    } else {
      ratio = this.numRidden / this.numRides;
    }

    bool completed = (ratio == 1.0);

    return Stack(
      children: <Widget>[
        // Background - full bar with blank decor
        Container(
          color: Color.fromARGB(255, 221, 222, 224),
          constraints: BoxConstraints.expand(),
        ),
        // Foreground - percentage bar with progress color
        RewardProgressBar(
          numerator: this.numRidden,
          denominator: this.numRides,
        )
      ],
    );
  }

  Widget _buildProgressLabel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Progress: ${this.numRidden}/${this.numRides}",
          textAlign: TextAlign.center,
          textScaleFactor: 1.2,
        )
      ],
    );
  }

  Widget _buildDefunctLabel(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            "Defunct: ${this.defunctRidden}",
            textAlign: TextAlign.right,
            textScaleFactor: 1.2,
          ),
        )
      ],
    );
  }
}

// TODO: MAKE ANIMATED
class RewardProgressBar extends StatelessWidget{
  RewardProgressBar({this.numerator, this.denominator});

  final num numerator;
  final num denominator;

  @override
  Widget build(BuildContext context) {
    num ratio;
    if (denominator == 0) {
      ratio = 0.01;
    } else {
      ratio = numerator / denominator;
    }

    Color barColor;
    if (ratio == 1.0) {
      barColor = Color.fromARGB(255, 250, 204, 73);
    } else {
      barColor = Colors.green;
    }

    Widget content = FractionallySizedBox(
      widthFactor: ratio,
      heightFactor: 1.0,
      child: Container(
        color: barColor,
        constraints: BoxConstraints.expand(),
      ),
    );

    if (ratio == 1.0) {
      return Shimmer.fromColors(
        child: content,
        baseColor: barColor,
        highlightColor: Color.fromARGB(255, 252, 227, 154),
        period: const Duration(milliseconds: 2500),
      );
    } else {
      return content;
    }
  }
}
