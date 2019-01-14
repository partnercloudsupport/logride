import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as oldLatLng;
import '../data/fbdb_manager.dart';
import '../widgets/content_frame.dart';
import '../widgets/side-strike-text.dart';
import '../widgets/embedded_map_entry.dart';
import '../ui/standard_page_structure.dart';
import '../widgets/stored_image_widget.dart';

enum HeaderText { TITLE, TYPE }

enum DetailsType {
  MEDIA_CONTENT, // done
  MAP_CONTENT, // done
  OPENING_DATE,
  STATUS,
  CLOSING_DATE,
  FURTHER_DETAILS
}

class DetailsPage extends StatefulWidget {
  DetailsPage({this.db, this.detailsMap, this.headerText});

  final BaseDB db;
  final Map<DetailsType, dynamic> detailsMap;
  final Map<HeaderText, String> headerText;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: StandardPageStructure(
          iconFunction: () => Navigator.of(context).pop(),
          iconDecoration: Container(
            child: Icon(
              FontAwesomeIcons.info,
              size: 60,
              color: Colors.white,
            ),
            constraints: BoxConstraints.expand(),
          ),
          content: <Widget>[_buildDetailsCard(context)],
        ));
  }

  Widget _buildDetailsCard(BuildContext context) {
    return ContentFrame(
        child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 34),
            child: Container(),
          ),
          // Title Bar
          _buildTitleBar(context),

          Expanded(
            child: ListView(
              children: <Widget>[
                // Map Section is built only if map details are passed.
                (widget.detailsMap.containsKey(DetailsType.MAP_CONTENT))
                    ? _buildMapSection(context)
                    : Container(),
                (widget.detailsMap.containsKey(DetailsType.MEDIA_CONTENT))
                    ? _buildMediaSection(context)
                    : Container(),
                // Status Section
                // Further Details Section
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildTitleBar(BuildContext context) {
    return Column(
      children: <Widget>[
        AutoSizeText(
          widget.headerText[HeaderText.TITLE] ?? "Placeholder Title",
          maxLines: 2,
          style: Theme.of(context).textTheme.headline,
        ),
        SideStrikeText(
          bodyText: Text(
            widget.headerText[HeaderText.TYPE] ?? "Placeholder Type",
            textScaleFactor: 1.25,
          ),
          strikeColor: Theme.of(context).primaryColor,
          strikeThickness: 4.0,
        )
      ],
    );
  }

  Widget _buildMapSection(BuildContext context) {
    // The detailsMap for map content should be a map of
    Map<List<String>, oldLatLng.LatLng> data =
        widget.detailsMap[DetailsType.MAP_CONTENT];

    Map<List<String>, LatLng> markers = data.map((key, value) =>
        MapEntry<List<String>, LatLng>(key, _convertLatLng(value)));

    return Container(
      height: 250,
      child: _wrapAsWindow(
        EmbeddedMapEntry(
          center: markers.entries.first.value,
          markers: markers,
        ),
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    Map mediaData = widget.detailsMap[DetailsType.MEDIA_CONTENT];
    assert(mediaData.containsKey("attractionID"));
    assert(mediaData.containsKey("parkID"));
    return Container(
        height: 250,
        child: _wrapAsWindow(FirebaseAttractionImage(
          attractionID: mediaData["attractionID"],
          parkID: mediaData["parkID"],
        )));
  }

  Widget _wrapAsWindow(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: child,
      ),
    );
  }

  LatLng _convertLatLng(oldLatLng.LatLng input) {
    return LatLng(input.latitude, input.longitude);
  }
}
