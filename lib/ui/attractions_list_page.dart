import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/ui/details_page.dart';
import 'package:log_ride/ui/standard_page_structure.dart';
import 'package:log_ride/ui/park_settings_page.dart';
import 'package:log_ride/data/parks_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/widgets/content_frame.dart';
import 'package:log_ride/widgets/progress_bars.dart';
import 'package:log_ride/widgets/attraction_list_widget.dart';
import 'package:log_ride/widgets/title_bar_icon.dart';

class AttractionsPage extends StatefulWidget {
  AttractionsPage({this.pm, this.db, this.serverParkData});

  final ParksManager pm;
  final BaseDB db;
  final BluehostPark serverParkData;

  @override
  _AttractionsPageState createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage>
    with SingleTickerProviderStateMixin {
  final SlidableController _slidableController = SlidableController();

  Stream<Event> _parkStream;

  double lastRatio = 0.0;

  @override
  void initState() {
    _parkStream = widget.db.getLiveEntryAtPath(
        path: DatabasePath.PARKS, key: widget.serverParkData.id.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        body: StandardPageStructure(
          // IconFunction and IconDecoration relate to the homeIcon
          iconFunction: () => Navigator.of(context).pop(),
          iconDecoration: Container(
            child: Icon(Icons.home, size: 60, color: Colors.white),
            constraints: BoxConstraints.expand(),
          ),
          content: <Widget>[_buildAttractionsCard(context)],
        ));
  }

  Widget _buildAttractionsCard(BuildContext context) {
    return ContentFrame(
        child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Material(
        color: Colors.transparent,
        child: StreamBuilder<Event>(
            stream: _parkStream,
            builder: (BuildContext context, AsyncSnapshot<Event> stream) {
              if (!stream.hasData) {
                return Container(
                    constraints: BoxConstraints.expand(),
                    child: CircularProgressIndicator());
              } else {
                Map parkDataMap =
                    jsonDecode(jsonEncode(stream.data.snapshot.value));
                FirebasePark parkData = FirebasePark.fromMap(parkDataMap);
                print(
                    "Successfully recived parkData for attractions list page");

                double tempOldRatio = lastRatio;
                lastRatio = 0.0;
                if (parkData.totalRides != 0)
                  lastRatio = parkData.ridesRidden / parkData.totalRides;

                return Column(children: <Widget>[
                  // Padding used to make sure the iconButton doesn't overlap
                  // our header.
                  Padding(
                    padding: EdgeInsets.only(top: 34),
                    child: Container(),
                  ),

                  // Titlebar w/ info and settings buttons
                  _buildTitleBar(context, parkData),

                  // Percentage Complete bar
                  FullParkProgressBar(
                    oldRatio: tempOldRatio,
                    showSeasonal: parkData.showSeasonal,
                    showDefunct: parkData.showDefunct,
                    totalCount: parkData.totalRides,
                    riddenCount: parkData.ridesRidden,
                    seasonalCount: parkData.numSeasonalRidden,
                    defunctCount: parkData.numDefunctRidden,
                  ),

                  // Listview (Expanded)

                  Expanded(
                      child: AttractionsListView(
                    sourceAttractions: widget.serverParkData.attractions,
                    parentPark: parkData,
                    slidableController: _slidableController,
                    pm: widget.pm,
                    db: widget.db,
                    // Data here
                  ))
                ]);
              }
            }),
      ),
    ));
  }

  /// Returns the titlebar used in [AttractionListPage]. Contains two buttons,
  /// settings and info, separated by an expanded text that contains the name of
  /// the park.
  Widget _buildTitleBar(BuildContext context, FirebasePark parkData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Left icon
          TitleBarIcon(icon: FontAwesomeIcons.info, onTap: _openDetailsPane),
          // Label
          Expanded(
            child: AutoSizeText(
              widget.serverParkData.parkName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline,
              maxLines: 2,
            ),
          ),
          // Right icon
          TitleBarIcon(
              icon: FontAwesomeIcons.cog,
              onTap: () {
                _openSettingsPage(parkData);
              })
        ],
      )),
    );
  }

  void _openDetailsPane() {
    int condensedStatus = widget.serverParkData.active ? 1 : 0;
    condensedStatus += widget.serverParkData.seasonal ? 10 : 0;

    print(condensedStatus.toString());

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

  void _openSettingsPage(FirebasePark userData) {
    Future<dynamic> result = Navigator.push(
        context,
        SlideInRoute(
          direction: SlideInDirection.UP,
          dialogStyle: true,
          widget: ParkSettingsPage(
            userData: userData,
            parkData: widget.serverParkData,
          )
        ));

    result.then((value) {
      if(value != Null){
        ParkSettingsData settingsData = value as ParkSettingsData;
        print("User has submitted settings");
        userData.incrementorEnabled = settingsData.tally;
        userData.showSeasonal = settingsData.showSeasonal;
        userData.showDefunct = settingsData.showDefunct;
        widget.db.setEntryAtPath(payload: userData.toMap(), key: userData.parkID.toString(), path: DatabasePath.PARKS);
      }
    });
  }
}
