import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/color_constants.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/user_structure.dart';
import 'package:log_ride/ui/details_page.dart';
import 'package:log_ride/widgets/attractions_page/attraction_list_widget.dart';
import 'package:log_ride/widgets/dialogs/park_settings_dialog.dart';
import 'package:log_ride/widgets/shared/progress_bars.dart';
import 'package:provider/provider.dart';

class AttractionsPage extends StatefulWidget {
  AttractionsPage(
      {this.pm, this.db, this.serverParkData, this.submissionCallback});

  final ParksManager pm;
  final BaseDB db;
  final BluehostPark serverParkData;
  final Function(dynamic, bool, LogRideUser) submissionCallback;

  @override
  _AttractionsPageState createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage>
    with SingleTickerProviderStateMixin {
  final SlidableController _slidableController = SlidableController();
  final ScrollController _scrollController =
      ScrollController(initialScrollOffset: 54.0);

  Stream<Event> _parkStream;

  double lastRatio;

  @override
  void initState() {
    print(
        "Initializing State for the Attraction List Page of park ${widget.serverParkData.parkName}");
    print("Bluehost ID: ${widget.serverParkData.id.toString()}");

    _parkStream = widget.db.getLiveEntryAtPath(
        path: DatabasePath.PARKS, key: widget.serverParkData.id.toString());

    FirebaseAnalytics().logEvent(
        name: "view_park",
        parameters: {"parkName": widget.serverParkData.parkName});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: StreamBuilder<Event>(
            stream: _parkStream,
            builder: (BuildContext context, AsyncSnapshot<Event> stream) {
              if (!stream.hasData ||
                  stream.data == null ||
                  stream.data.snapshot.value == null) {
                return Center(child: CircularProgressIndicator());
              } else {
                FirebasePark parkData =
                    FirebasePark.fromMap(Map.from(stream.data.snapshot.value));

                // Sometimes we do get data but it's not quite proper. This means something is happening elsewhere
                // Just show the circle thing.
                if (parkData == null || parkData.totalRides == null) {
                  return Container(
                      constraints: BoxConstraints.expand(),
                      child: Center(child: CircularProgressIndicator()));
                }

                print(
                    "Successfully recived parkData for attractions list page for park ${parkData.name}");

                return CustomScrollView(
                    controller: _scrollController,
                    physics: NeverScrollableScrollPhysics(),
                    slivers: <Widget>[
                      _buildTitleBar(context, parkData),
                      SliverFillRemaining(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 54.0),
                          child: AttractionsListView(
                            sourceAttractions:
                                widget.serverParkData.attractions,
                            parentPark: parkData,
                            slidableController: _slidableController,
                            pm: widget.pm,
                            db: widget.db,
                            submissionCallback: widget.submissionCallback,
                          ),
                        ),
                      ),
                    ]);
              }
            }));
  }

  /// Returns the titlebar used in [AttractionListPage]. Contains three buttons,
  /// settings, info, and back, separated by a text that contains the name of
  /// the park.
  Widget _buildTitleBar(BuildContext context, FirebasePark parkData) {
    double tempOldRatio = lastRatio;
    lastRatio = 0.0;
    if (parkData.totalRides != 0)
      lastRatio = parkData.ridesRidden / parkData.totalRides;

    return SliverAppBar(
      title: AutoSizeText(
        "${widget.serverParkData.parkName}",
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.headline.apply(color: Colors.white),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          FontAwesomeIcons.arrowLeft,
          color: Colors.white,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.info, color: Colors.white),
          onPressed: _openDetailsPane,
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.cog, color: Colors.white),
          onPressed: () => _openSettingsPage(context, parkData),
        ),
      ],
      bottom: PreferredSize(
          child: FullParkProgressBar(
            oldRatio: tempOldRatio,
            showSeasonal: parkData.showSeasonal,
            showDefunct: parkData.showDefunct ||
                !getBluehostParkByID(widget.pm.allParksInfo, parkData.parkID)
                    .active,
            totalCount: parkData.totalRides,
            riddenCount: parkData.ridesRidden,
            seasonalCount: parkData.numSeasonalRidden,
            defunctCount: parkData.numDefunctRidden,
            barColor: widget.serverParkData.active
                ? Colors.green
                : PROGRESS_BAR_DEFUNCT,
          ),
          preferredSize: Size.fromHeight(25.0)),
      pinned: true,
    );
  }

  void _openDetailsPane() {
    Navigator.push(
        context,
        SlideInRoute(
            direction: SlideInDirection.UP,
            dialogStyle: true,
            widget: DetailsPage(
              data: widget.serverParkData,
              db: widget.db,
            )));
  }

  void _settingsChangeCallback(
      ParkSettingsCategory cat, dynamic data, FirebasePark userData) {
    switch (cat) {
      case ParkSettingsCategory.TALLY:
        userData.incrementorEnabled = data as bool;
        break;
      case ParkSettingsCategory.SHOW_DEFUNCT:
        userData.showDefunct = data as bool;
        break;
      case ParkSettingsCategory.SHOW_SEASONAL:
        userData.showSeasonal = data as bool;
        break;
    }

    widget.db.setEntryAtPath(
        payload: userData.toMap(),
        key: userData.parkID.toString(),
        path: DatabasePath.PARKS);
  }

  void _openSettingsPage(BuildContext context, FirebasePark userData) {
    LogRideUser user = Provider.of<LogRideUser>(context);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ParkSettingsDialog(
            userData: userData,
            parkData: widget.serverParkData,
            submissionCallback: (d, n) => widget.submissionCallback(d, n, user),
            callback: (cat, dat) => _settingsChangeCallback(cat, dat, userData),
          );
        });
  }
}
