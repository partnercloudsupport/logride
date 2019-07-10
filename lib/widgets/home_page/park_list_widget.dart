import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/widgets/home_page/park_list_entry.dart';
import 'package:log_ride/widgets/home_page/parks_list_advanced.dart';

class ParkListView extends StatelessWidget {
  ParkListView(
      {this.parksData,
      this.favsData,
      this.slidableController,
      this.sliderActionCallback,
      this.onTap,
      this.filter,
      this.bottomPadding});

  final SlidableController slidableController;

  final bool bottomPadding;
  final Query parksData;
  final Query favsData;

  final Function(ParkSlideActionType actionType, FirebasePark data)
      sliderActionCallback;
  final Function(FirebasePark park) onTap;

  final ParksFilter filter;

  @override
  Widget build(BuildContext context) {
    Widget content;

    content = FirebaseParkListView(
      allParksQuery: parksData,
      favsQuery: favsData,
      parkTapCallback: onTap,
      sliderActionCallback: sliderActionCallback,
      filter: filter,
      bottomEntryPadding: bottomPadding,
    );

    String headerText = "My Parks";

    return ClipRect(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 10.0, right: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 4 / 6,
                  child: Row(
                    children: <Widget>[
                      AutoSizeText(
                        headerText,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headline,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(child: content)
        ],
      ),
    );
  }
}
