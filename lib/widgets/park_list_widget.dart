import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import '../animations/slide_in_transition.dart';
import '../data/park_structures.dart';
import '../widgets/park_list_entry.dart';
import '../widgets/custom_animated_firebase_list.dart';
import '../ui/user_parks_search.dart';

class ParkListView extends StatelessWidget {
  ParkListView(
      {this.parksData,
      this.favorites,
        this.showSearch = false,
      this.slidableController,
      this.sliderActionCallback,
      this.headerCallback,
      this.arrowWidget,
      this.onTap,
      this.filter});

  final SlidableController slidableController;

  final bool favorites;
  final bool showSearch;
  final Query parksData;

  final Function(ParkSlideActionType actionType, FirebasePark data)
      sliderActionCallback;
  final Function(bool isFavorites) headerCallback;
  final Function(FirebasePark park) onTap;

  final Widget arrowWidget;
  final ListFilter filter;

  @override
  Widget build(BuildContext context) {
    Widget content;

    // ParksData may not be loaded. We need to determine how we're displaying it
    String toDisplay;
    if (favorites) {
      toDisplay =
          "Swipe a park towards the right to add it to your favorites list";
    } else {
      toDisplay =
          "You haven't checked into any parks! Tap the \"+\" button to add a park";
    }
    // We're presenting legitimate data. Time to determine how.

    content = FirebaseAnimatedList(
      query: parksData,
      duration: const Duration(milliseconds: 600),
      filter: filter,
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> anim, int index, int length, String filter) {
        // Snapshot.value is some weird hash map. We need to convert it for the fromJson factory to work
        Map<String, dynamic> converted = jsonDecode(jsonEncode(snapshot.value));
        FirebasePark thisPark = FirebasePark.fromMap(converted);

        String parkName = thisPark.name.toLowerCase();
        String parkLocation = thisPark.location.toLowerCase();
        String lowerFilter = filter?.toLowerCase() ?? "";

        if (parkName.contains(lowerFilter) ||
            parkLocation.contains(lowerFilter)) {
          Widget builtWidget = ParkListEntry(
              parkData: thisPark,
              onTap: onTap,
              inFavorites: favorites,
              sliderActionCallback: sliderActionCallback,
              slidableController: slidableController);

          if (length != null) {
            if (index == length - 1 && !favorites) {
              builtWidget = Padding(
                  child: builtWidget, padding: EdgeInsets.only(bottom: 60));
            }
          }

          return FadeTransition(
            opacity: anim,
            child: builtWidget,
          );
        } else {
          return Container();
        }
      },
      defaultChild: Center(child: CircularProgressIndicator()),
      emptyChild: Padding(
          padding: EdgeInsets.only(top: 12.0, left: 8.0, right: 8.0),
          child: Text(
            toDisplay,
            style: Theme.of(context).textTheme.title,
            textAlign: TextAlign.center,
          )),
    );

    Widget searchWidget;
    if (showSearch) {
      searchWidget = IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.push(context, SlideInRoute(
              dialogStyle: true,
              direction: SlideInDirection.UP,
              widget: UserParksSearchPage(
                entryCallback: onTap,
                slidableController: slidableController,
                parksQuery: parksData,
                sliderActionCallback: sliderActionCallback,
              )
            ));
          });
    } else {
      searchWidget = Container();
    }

    String headerText = favorites ? "Favorites " : "All Parks ";

    return ClipRect(
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
    );
  }
}
