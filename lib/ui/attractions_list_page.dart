import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../ui/standard_page_structure.dart';
import '../data/parks_manager.dart';
import '../data/park_structures.dart';
import '../data/attraction_structures.dart';
import '../data/fbdb_manager.dart';
import '../widgets/content_frame.dart';
import '../widgets/park_progress.dart';

class AttractionsPage extends StatefulWidget {
  AttractionsPage({this.pm, this.db, this.userParkData, this.serverParkData});

  final ParksManager pm;
  final BaseDB db;
  final FirebasePark userParkData;
  final BluehostPark serverParkData;

  @override
  _AttractionsPageState createState() => _AttractionsPageState();
}

class _AttractionsPageState extends State<AttractionsPage> {
  final SlidableController _slidableController = SlidableController();

  void _handleExperienceTap(num parkID) {}

  void _handleExperienceLongTap(num parkID) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: StandardPageStructure(
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
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 34), child: Container(),),
            // Titlebar w/ info and settings buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildTitleBar(context),
            ),
            // Percentage Complete bar
            ParkProgressFullBar(
              numRidden: widget.userParkData.ridesRidden,
              numRides: widget.userParkData.totalRides,
              defunctRidden: widget.userParkData.numDefunctRidden,
              showDefunct: widget.userParkData.showDefunct,
            )
            // Listview (Expanded)
          ],
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Left icon
          _buildTitleBarIcon(context, icon: FontAwesomeIcons.info, onTap: () => print("Info")),
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
          _buildTitleBarIcon(context, icon: FontAwesomeIcons.cog, onTap: () => print("Setings")),
        ],
      )),
    );
  }

  Widget _buildTitleBarIcon(BuildContext context, {IconData icon, Function onTap}){
    num iconSize = 26.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(icon, color: Theme.of(context).buttonColor, size: iconSize,)
    );
  }
}
