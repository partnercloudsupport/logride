import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import '../data/park_structures.dart';
import '../widgets/park_list_entry.dart';

class ParkListView extends StatelessWidget {
  ParkListView(
      {this.parksData,
      this.favorites,
      this.hasContent = true,
      this.slidableController,
      this.sliderActionCallback,
      this.headerCallback,
      this.arrowWidget,
      this.onTap});

  final SlidableController slidableController;

  final bool favorites;
  final bool hasContent;
  final Query parksData;

  final Function(ParkSlideActionType actionType, BasicPark data)
      sliderActionCallback;
  final Function(bool isFavorites) headerCallback;
  final Function(BasicPark park) onTap;

  final Widget arrowWidget;

  @override
  Widget build(BuildContext context) {
    Widget content;

    // ParksData may not be loaded. We need to determine how we're displaying it
    if (!hasContent) {
      String toDisplay;
      if (favorites) {
        toDisplay =
            "Swipe a park towards the right to add it to your favorites list";
      } else {
        toDisplay =
            "You haven't checked into any parks! Tap the \"+\" button to add a park";
      }
      content = Padding(
          padding: EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
          child: Text(
            toDisplay,
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          ));
    } else {
      // We're presenting legitimate data. Time to determine how.

      content = FirebaseAnimatedList(
        query: parksData,
        duration: const Duration(milliseconds: 600),
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> anim, int index) {
          // Snapshot.value is some weird hash map. We need to convert it for the fromJson factory to work
          Map<String, dynamic> converted =
              jsonDecode(jsonEncode(snapshot.value));
          BasicPark thisPark = BasicPark.fromJson(converted);
          return FadeTransition(
            opacity: anim,
            child: ParkListEntry(
                parkData: thisPark,
                onTap: onTap,
                inFavorites: favorites,
                sliderActionCallback: sliderActionCallback,
                slidableController: slidableController),
          );
        },
        defaultChild: Center(child: CircularProgressIndicator()),
      );
    }

    Widget searchWidget;
    if (!favorites) {
      searchWidget = IconButton(
          icon: Icon(Icons.search), onPressed: () => print("Search"));
    } else {
      searchWidget = Container();
    }

    String headerText = favorites ? "Favorites " : "All Parks ";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ClipRect(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // Update the data model with the new focus state (note - not final implementation)
                headerCallback(favorites);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Text(
                            headerText,
                            style: Theme.of(context).textTheme.headline,
                            textAlign: TextAlign.left,
                          ),
                          arrowWidget
                        ],
                      ),
                    ),
                    searchWidget
                  ],
                ),
              ),
            ),
            Expanded(child: content)
          ],
        ),
      ),
    );
  }
}
