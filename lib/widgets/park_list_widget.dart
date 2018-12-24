import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../data/park_structures.dart';
import '../widgets/park_list_entry.dart';

class ParkListView extends StatelessWidget {
  ParkListView(
      {this.parksData,
      this.favorites,
      this.slidableController,
      this.sliderActionCallback,
      this.headerCallback,
      this.arrowWidget,
      this.onTap});

  final SlidableController slidableController;

  final bool favorites;
  final List<ParkData> parksData;

  final Function(ParkSlideActionType actionType, ParkData data)
      sliderActionCallback;
  final Function(bool isFavorites) headerCallback;
  final Function(ParkData park) onTap;

  final Widget arrowWidget;

  @override
  Widget build(BuildContext context) {
    Widget content;

    // ParksData may not be loaded. We need to determine how we're displaying it
    if (parksData == null) {
      // Show the loading icon - data has not been loaded
      content = Center(child:CircularProgressIndicator());
    } else if (parksData.length == 0 || (countFavoriteParks(parksData) == 0 && favorites)) {
      // In the case that there's either no parks or no favorite parks (if we're the favorites box),
      // we're printing info on how to fix this to the user.
      String toDisplay;
      if(favorites){
        toDisplay = "Swipe a park towards the right to add it to your favorites list";
      } else {
        toDisplay = "You haven't checked into any parks! Tap the \"+\" button to add a park";
      }
      content = Padding(
        padding: EdgeInsets.only(top: 12.0, left: 8.0,right: 8.0),
        child: Text(toDisplay,
        style: Theme.of(context).textTheme.title,
        textAlign: TextAlign.center,
      ));
    } else {
      // We're presenting legitimate data. Time to determine how.

      content = ListView.builder(
              itemCount: parksData.length,
              itemBuilder: (context, index)
      {
        Widget builtWidget;

        // ParksData includes both the parks which are the user's favorites
        // and those that are not. We need to make sure we display the
        // favorites if we're the favorites widget, or all if we're not
        if (parksData[index].favorite == favorites || !favorites) {
          builtWidget = ParkListEntry(
            parkData: parksData[index],
            inFavorites: favorites,
            slidableController: slidableController,
            sliderActionCallback: sliderActionCallback,
            onTap: onTap,
          );
        } else {
          builtWidget = Container();
        }

        // AllParks has a floating action button obscuring the bottom-most
        // entry. Adding padding to the last element in the list lets the
        // user view it without issue.
        if (index == parksData.length - 1 && !favorites) {
          builtWidget = Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: builtWidget);
        }
        return builtWidget;
      });

    }


    Widget searchWidget;
    if(!favorites){
      searchWidget = IconButton(icon: Icon(Icons.search), onPressed: () => print("Search"));
    } else {
      searchWidget = Container();
    }

    // Determines the arrow's state from where we were and where we're going
    // This is an ugly mess and I'm so sorry to whoever maintains this in the future

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
            Expanded(
                child: content)
          ],
      ),
        ),
    );
  }
}
