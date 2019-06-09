import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/ui/attractions_list_page.dart';
import 'package:log_ride/widgets/home_page/park_list_entry.dart';
import 'package:log_ride/widgets/home_page/parks_list_advanced.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';

class ParksHome extends StatefulWidget {
  ParksHome({
    Key key,
    this.auth,
    this.db,
    this.uid,
    this.webFetcher,
    this.parksManager,
    this.username,
  }) : super(key: key);

  final BaseAuth auth;
  final BaseDB db;
  final ParksManager parksManager;
  final WebFetcher webFetcher;
  final String uid;
  final String username;

  @override
  ParksHomeState createState() => ParksHomeState();
}

class ParksHomeState extends State<ParksHome> {

  void parkEntryTap(FirebasePark park) {
    if (park == null) {
      // User tapped on a park that doesn't have any data, at all, somehow
      // TODO: Handle this error with a warning / more appropriate user feedback
      print("User attempted to open a null park.");
      return;
    }

    print("Callback triggered for park id: ${park.parkID}, name: ${park.name}");
    openParkWithID(park.parkID);
  }

  void openParkWithID(int id) {
    BluehostPark serverPark = getBluehostParkByID(widget.parksManager.allParksInfo, id);
    if(serverPark.attractions == null || serverPark == null) {
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return AttractionsPage(
        pm: widget.parksManager,
        db: widget.db,
        userName: widget.username,
        serverParkData: serverPark,
        submissionCallback: (a, n) =>
            print("$a, $n"), //TODO: Get submissionCallback working
      );
    }));
  }

  void slidableActionTap(
      ParkSlideActionType slideAction, FirebasePark park) async {
    if (park == null) {
      // TODO: Handle this error in a better way
      print(
          "User somehow tapped on a park's slider, when the slider didn't have a park.");
      return;
    }

    switch (slideAction) {
      case ParkSlideActionType.faveAdd:
        widget.parksManager.addParkToFavorites(park.parkID);
        break;
      case ParkSlideActionType.faveRemove:
        widget.parksManager.removeParkFromFavorites(park.parkID);
        break;
      case ParkSlideActionType.delete:
        dynamic result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return StyledConfirmDialog(
                title: "Delete Park Data?",
                body:
                    "This will permanently delete your progress for ${park.name}",
                denyButtonText: "Cancel",
                confirmButtonText: "Delete",
              );
            });
        if (result == null) return;
        // Technically this can be done without the `==` check, but it helps
        // readability when the variable isn't well named
        if (result == true) {
          widget.parksManager.removeParkFromUserData(park.parkID);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
              title: Text(
                "My Parks",
                style: Theme.of(context)
                    .textTheme
                    .headline
                    .apply(color: Colors.white),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(FontAwesomeIcons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    );
                  },
                )
              ],
              //expandedHeight: 100.0,
              floating: true,
              pinned: false,
              snap: false),
          SliverList(
              delegate: SliverChildListDelegate([
            FirebaseParkListView(
                filter: ParksFilter(""),
                parkTapCallback: parkEntryTap,
                sliderActionCallback: slidableActionTap,
                favsQuery: widget.db.getFilteredQuery(
                    path: DatabasePath.PARKS, key: "favorite", value: true),
                allParksQuery: widget.db
                    .getQueryForUser(path: DatabasePath.PARKS, key: ""),
                shrinkWrap: true,
                physics: ClampingScrollPhysics())
          ]))
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(FontAwesomeIcons.times),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(FontAwesomeIcons.arrowLeft),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text("Results");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Text("Suggestions");
  }
}
