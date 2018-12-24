import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// ParkProgress is a small progressbar overlaid with text, documenting how many
/// [numRides] a park has and comparing that to the user's [numRidden]
/// [numRides] - a number representing how many rides are in a park
/// [numRidden] - a number representing how many rides the user has ridden at
///   least once in the park
class ParkProgress extends StatelessWidget {
  ParkProgress({this.numRides, this.numRidden});

  final num numRides;
  final num numRidden;

  @override
  Widget build(BuildContext context) {
    double progress;
    if(numRides == 0){
      progress = 0.0;
    } else {
      progress = numRidden / numRides;
    }

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
                    FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          color: Colors.green,
                          constraints: BoxConstraints.expand(),
                        )),
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
