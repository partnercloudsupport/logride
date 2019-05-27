import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/widgets/home_page/park_list_entry.dart';
import 'package:log_ride/widgets/home_page/parks_list_advanced.dart';
import 'package:log_ride/ui/dialogs/user_parks_search.dart';

class ParkListView extends StatelessWidget {
  ParkListView(
      {this.parksData,
        this.favsData,
      this.showSearch = false,
      this.slidableController,
      this.sliderActionCallback,
      this.onTap,
      this.filter,
      this.bottomPadding});

  final SlidableController slidableController;

  final bool showSearch;
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
      bottomPadding: bottomPadding,
    );

    Widget searchWidget;
    if (showSearch) {
      searchWidget = IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.push(
                context,
                SlideInRoute(
                    dialogStyle: true,
                    direction: SlideInDirection.UP,
                    widget: UserParksSearchPage(
                      entryCallback: onTap,
                      slidableController: slidableController,
                      parksQuery: parksData,
                      favsQuery: favsData,
                      sliderActionCallback: sliderActionCallback,
                    )));
          });
    } else {
      searchWidget = Container();
    }

    String headerText = "My Parks";

    return ClipRect(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
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
                      //arrowWidget
                    ],
                  ),
                ),
                searchWidget
              ],
            ),
          ),
          Expanded(child: content)
        ],
      ),
    );
  }
}
