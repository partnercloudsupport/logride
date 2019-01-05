import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import '../ui/standard_page_structure.dart';
import '../data/parks_manager.dart';
import '../data/park_structures.dart';
import '../data/fbdb_manager.dart';
import '../widgets/content_frame.dart';
import '../widgets/park_progress.dart';
import '../widgets/attraction_list_widget.dart';
import 'dart:convert';

class AttractionsPage extends StatefulWidget {
  AttractionsPage({this.pm, this.db, this.serverParkData});

  final ParksManager pm;
  final BaseDB db;
  final BluehostPark serverParkData;

  @override
  _AttractionsPageState createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage> {
  final SlidableController _slidableController = SlidableController();

  Stream<Event> _parkStream;

  void _handleExperienceTap(num parkID) {}

  void _handleExperienceLongTap(num parkID) {}

  @override
  void initState() {
    _parkStream = widget.db.getLiveEntryAtPath(
        path: DatabasePath.PARKS, key: widget.serverParkData.id.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                return Column(
                  children: <Widget>[
                    // Padding used to make sure the iconButton doesn't overlap
                    // our header.
                    Padding(
                      padding: EdgeInsets.only(top: 34),
                      child: Container(),
                    ),

                    // Titlebar w/ info and settings buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildTitleBar(context),
                    ),

                    // Percentage Complete bar
                    ParkProgressFullBar(
                        numRidden: parkData.ridesRidden,
                        numRides: parkData.totalRides,
                        defunctRidden: parkData.numDefunctRidden,
                        showDefunct: parkData.showDefunct,
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
                      )
                    )
                  ],
                );
              }
            }),
      ),
    );
  }

  /// Returns the titlebar used in [AttractionListPage]. Contains two buttons,
  /// settings and info, separated by an expanded text that contains the name of
  /// the park.
  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Left icon
          _buildTitleBarIcon(context,
              icon: FontAwesomeIcons.info, onTap: () => print("Info")),
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
          _buildTitleBarIcon(context,
              icon: FontAwesomeIcons.cog, onTap: () => print("Setings")),
        ],
      )),
    );
  }

  /// Returns the properly stylized buttons used in the titlebar of an attractions
  /// list page.
  Widget _buildTitleBarIcon(BuildContext context,
      {IconData icon, Function onTap}) {
    num iconSize = 26.0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            icon,
            color: Theme.of(context).buttonColor,
            size: iconSize,
          )),
    );
  }
}
