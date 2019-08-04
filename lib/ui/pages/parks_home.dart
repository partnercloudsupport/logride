import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/check_in_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/data/webfetcher.dart';
import 'package:log_ride/ui/attractions_list_page.dart';
import 'package:log_ride/ui/submission/submit_attraction_page.dart';
import 'package:log_ride/widgets/home_page/check_in_widget.dart';
import 'package:log_ride/widgets/home_page/park_list_entry.dart';
import 'package:log_ride/widgets/home_page/parks_list_advanced.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';

class ParksHomeFocus extends ValueNotifier<bool> {
  ParksHomeFocus(bool inFocus) : super(inFocus);
}

class ParksHome extends StatefulWidget {
  ParksHome(
      {Key key,
      this.auth,
      this.db,
      this.webFetcher,
      this.ciManager,
      this.parksManager,
      this.parksHomeFocus})
      : super(key: key);

  final BaseAuth auth;
  final BaseDB db;
  final ParksManager parksManager;
  final WebFetcher webFetcher;
  final CheckInManager ciManager;
  final ParksHomeFocus parksHomeFocus;

  @override
  ParksHomeState createState() => ParksHomeState();
}

class ParksHomeState extends State<ParksHome> {
  FirebaseAnalytics analytics = FirebaseAnalytics();

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

  void openParkWithID(int id) async {
    BluehostPark serverPark =
        getBluehostParkByID(widget.parksManager.allParksInfo, id);
    if (serverPark.attractions == null || serverPark == null) {
      return;
    }
    widget.parksHomeFocus.value = false;
    await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return AttractionsPage(
        pm: widget.parksManager,
        db: widget.db,
        serverParkData: serverPark,
        submissionCallback: (park, isNew, user) =>
            _handleAttractionSubmission(park, serverPark, isNew, user),
      );
    }));
    widget.parksHomeFocus.value = true;
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

  void _handleAttractionSubmission(BluehostAttraction attraction,
      BluehostPark parent, bool isNewAttraction, LogRideUser user) async {
    isNewAttraction ? print("New Attraction") : print("Modified Attraction");

    dynamic result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SubmitAttractionPage(
            existingData: isNewAttraction
                ? attraction
                : BluehostAttraction.copy(attraction),
            parentPark: parent,
            pm: widget.parksManager,
          );
        });

    if (result == null) return;

    BluehostAttraction newAttraction = result as BluehostAttraction;
    int response = await widget.webFetcher.submitAttractionData(
        newAttraction, parent,
        isNewAttraction: isNewAttraction,
        username: user.username,
        uid: user.uuid);

    if (response == 200) {
      analytics.logEvent(name: "new_attraction_suggested");
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StyledDialog(
              title: "Attraction Under Review",
              body:
                  "Thanks for submitting! Your attraction is now under review.",
              actionText: "Ok",
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StyledDialog(
              title: "Error during submission",
              body:
                  "Something happened during the submission process. Error $response.",
              actionText: "Ok",
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "My Parks",
            style:
                Theme.of(context).textTheme.headline.apply(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(
                      sliderActionTap: slidableActionTap,
                      parkTap: parkEntryTap,
                      favsQuery: widget.db.getFilteredQuery(
                          path: DatabasePath.PARKS,
                          key: "favorite",
                          value: true),
                      parksQuery: widget.db
                          .getQueryForUser(path: DatabasePath.PARKS, key: "")),
                );
              },
            )
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CheckInWidget(
              manager: widget.ciManager,
              onTap: openParkWithID,
            ),
            Expanded(
              child: FirebaseParkListView(
                filter: ParksFilter(""),
                parkTapCallback: parkEntryTap,
                sliderActionCallback: slidableActionTap,
                favsQuery: widget.db.getFilteredQuery(
                    path: DatabasePath.PARKS, key: "favorite", value: true),
                allParksQuery: widget.db
                    .getQueryForUser(path: DatabasePath.PARKS, key: ""),
                shrinkWrap: true,
                bottomEntryPadding: true,
                physics: ClampingScrollPhysics(),
              ),
            ),
          ],
        ));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  CustomSearchDelegate(
      {this.parksQuery, this.favsQuery, this.parkTap, this.sliderActionTap});

  final Query parksQuery, favsQuery;
  final Function parkTap, sliderActionTap;

  Widget contentWidget;

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
    return _buildContent(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    return FirebaseParkListView(
      filter: ParksFilter(query),
      parkTapCallback: (FirebasePark park) {
        close(context, null);
        parkTap(park);
      },
      sliderActionCallback: sliderActionTap,
      favsQuery: favsQuery,
      allParksQuery: parksQuery,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
}
