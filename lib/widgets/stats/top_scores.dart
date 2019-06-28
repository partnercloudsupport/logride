import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/park_structures.dart';

class TopScores extends StatelessWidget {
  TopScores({this.title, this.unit, this.scores});

  final String title;
  final String unit;
  final LinkedHashMap<String, int> scores;

  final TextStyle entryStyle = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    Widget scoresDisplay = Container();
    List<Widget> scoresDisplayList = List<Widget>();

    if (scores.length <= 0) {
      scoresDisplay = Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text("No $unit"),
          ),
        ],
      );
    } else {
      scoresDisplayList = List<Widget>.generate(scores.length, (index) {
        // Build a row widget for each entry, append that to the column
        String key = scores.keys.elementAt(index);
        int score = scores[key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
              textBaseline: TextBaseline.alphabetic,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "${index + 1}.",
                    style: entryStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    key,
                    style: entryStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "$score $unit",
                    textAlign: TextAlign.right,
                    style: entryStyle,
                    maxLines: 1,
                  ),
                )
              ]),
        );
      });
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          if (scoresDisplayList.length > 0)
            ...scoresDisplayList
          else
            scoresDisplay
        ]));
  }
}

class TopParkScores extends StatelessWidget {
  TopParkScores({this.scores});

  final LinkedHashMap<BluehostPark, int> scores;

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, int> displayScores = LinkedHashMap<String, int>();
    scores.keys.forEach((BluehostPark park) {
      displayScores[park.parkName] = scores[park];
    });

    return TopScores(
      title: "TOP PARKS",
      unit: "check-ins",
      scores: displayScores,
    );
  }
}

class TopAttractionScores extends StatelessWidget {
  TopAttractionScores({this.scores});

  final LinkedHashMap<BluehostAttraction, int> scores;

  @override
  Widget build(BuildContext context) {
    LinkedHashMap<String, int> displayScores = LinkedHashMap<String, int>();
    scores.keys.forEach((BluehostAttraction attraction) {
      displayScores[attraction.attractionName] = scores[attraction];
    });

    return TopScores(
      title: "TOP ATTRACTIONS",
      unit: "Exps.",
      scores: displayScores,
    );
  }
}
