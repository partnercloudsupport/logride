import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as oldLatLng;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../data/fbdb_manager.dart';
import '../widgets/content_frame.dart';
import '../widgets/side_strike_text.dart';
import '../widgets/embedded_map_entry.dart';
import '../ui/standard_page_structure.dart';
import '../widgets/stored_image_widget.dart';
import '../data/attraction_structures.dart';
import '../data/park_structures.dart';

enum _DetailsType { PARK_DETAILS, ATTRACTION_DETAILS }

class DetailsPage extends StatefulWidget {
  DetailsPage({this.db, this.data, this.userData});

  final BaseDB db;
  final dynamic data;
  final FirebaseAttraction userData;

  /*
  final Map<DetailsType, dynamic> detailsMap;
  final Map<HeaderText, String> headerText;
  */

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  _DetailsType _type;

  @override
  void initState() {
    super.initState();
    if (widget.data is BluehostAttraction) {
      _type = _DetailsType.ATTRACTION_DETAILS;
    } else if (widget.data is BluehostPark) {
      _type = _DetailsType.PARK_DETAILS;
    } else {
      throw FormatException("Improper data structure passed to details page.");
    }
  }

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

  Widget _buildDetailsCard(context) {
    Widget mapWidget = Container();
    if (_type == _DetailsType.PARK_DETAILS)
      mapWidget = _buildMapSection(context);

    Widget mediaWidget = Container();
    if (_type == _DetailsType.ATTRACTION_DETAILS)
      mediaWidget = _buildMediaSection(context);

    Widget statusRow = Container();
    statusRow = _buildStatusSection(context);

    List<Widget> furtherDetails = [Container()];
    furtherDetails = _buildFurtherDetails(context);

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
                mapWidget,
                mediaWidget,
                // Status Section
                statusRow,
              ]
                ..addAll(furtherDetails)
                //..add(userData),
            ),
          )
        ],
      ),
    ));
  }

  Widget _buildTitleBar(BuildContext context) {
    String titleText = (_type == _DetailsType.PARK_DETAILS)
        ? (widget.data as BluehostPark).parkName
        : (widget.data as BluehostAttraction).attractionName;
    if (titleText == null) titleText = "No Title";

    String subtitleText = (_type == _DetailsType.PARK_DETAILS)
        ? (widget.data as BluehostPark).type
        : (widget.data as BluehostAttraction).typeLabel;
    if (subtitleText == null) subtitleText = "No Type";

    return Column(
      children: <Widget>[
        AutoSizeText(
          titleText,
          maxLines: 1,
          style: Theme.of(context).textTheme.headline,
        ),
        SideStrikeText(
          bodyText: Text(
            subtitleText,
            textScaleFactor: 1.75,
          ),
          strikeColor: Theme.of(context).primaryColor,
          strikeThickness: 4.0,
        )
      ],
    );
  }

  Widget _buildMapSection(BuildContext context) {
    BluehostPark park = widget.data as BluehostPark;

    // We really only need to extract the main pin, which is the title, subtitle
    // and location of the park.
    Map<List<String>, oldLatLng.LatLng> data = {
      [park.parkName, park.type]: park.location
    };

    // Convert the old, non-google latlng to google's simpler latlng
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

  LatLng _convertLatLng(oldLatLng.LatLng input) {
    return LatLng(input.latitude, input.longitude);
  }

  Widget _buildMediaSection(BuildContext context) {
    BluehostAttraction attraction = widget.data as BluehostAttraction;
    return Container(
        height: 250,
        child: _wrapAsWindow(FirebaseAttractionImage(
          attractionID: attraction.attractionID,
          parkID: attraction.parkID,
        )));
  }

  Widget _wrapAsWindow(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[300], offset: Offset(0, 4), blurRadius: 5)
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: child,
        ),
      ),
    );
  }

  /// Opening is always displayed if present, and closed is displayed only when active is false
  Widget _buildStatusSection(BuildContext context) {

    int openingYear = widget.data?.yearOpen ?? 0;
    int closingYear = widget.data?.yearClosed ?? 0;
    bool active = widget.data?.active ?? 0;
    bool seasonal = widget.data?.seasonal ?? 0;

    Widget _leftStatus = _buildYearStatusColumn(openingYear, "Opening Year");

    Widget _rightStatus;

    if (!active) {
      _rightStatus = _buildYearStatusColumn(closingYear, "Closing Year");
    } else if (seasonal) {
      _rightStatus = _buildAttractionOperationColumn("Seasonal Operation");
    } else {
      _rightStatus = _buildAttractionOperationColumn("Active Operation");
    }

    Widget _statusContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[_leftStatus, _rightStatus],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Divider(),
        _statusContent,
        Divider(),
      ],
    );
  }

  /// If year == 0, we'll display "unknown" as our year
  Widget _buildYearStatusColumn(int year, String bottom) {
    String topString = (year == 0) ? "Unknown" : year.toString();

    return Column(
      children: <Widget>[
        Text(
          topString,
          textScaleFactor: 1.8,
        ),
        Text(
          bottom,
          textScaleFactor: 1.0,
        )
      ],
    );
  }

  Widget _buildAttractionOperationColumn(String display) {
    display = display.replaceAll(" ", "\n");
    return Text(
      display,
      textScaleFactor: 1.4,
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildFurtherDetails(BuildContext context) {
    List<Widget> details = List<Widget>();

    if(_type == _DetailsType.PARK_DETAILS){
      BluehostPark park = widget.data as BluehostPark;
      if(park.parkCity != "")
        details.add(_furtherDetailsTextEntry("City", park.parkCity));
      if(park.parkCountry != "")
        details.add(_furtherDetailsTextEntry("Country", park.parkCountry));
      if(park.previousNames != "")
        details.add(_furtherDetailsTextEntry("Former Names", park.previousNames));
      if(park.website != "")
        details.add(_furtherDetailsEntry( "Website", _urlTextButton(context, "Park Website", park.website)));
      return details;
    }

    if(_type == _DetailsType.ATTRACTION_DETAILS) {
      BluehostAttraction attraction = widget.data as BluehostAttraction;
      if(attraction.manufacturer != "")
        details.add(_furtherDetailsTextEntry("Manufacturer", attraction.manufacturer));
      if(attraction.additionalContributors != "")
        details.add(_furtherDetailsTextEntry("Additional Contributors", attraction.additionalContributors));
      if(attraction.formerNames != "")
        details.add(_furtherDetailsTextEntry("Former Names", attraction.formerNames));
      if(attraction.model != "")
        details.add(_furtherDetailsTextEntry("Model", attraction.model));
      if(attraction.height != 0)
        details.add(_furtherDetailsTextEntry("Height", "${attraction.height} ft"));
      if(attraction.liftHeight != 0.0)
        details.add(_furtherDetailsTextEntry("Lift Height", "${attraction.liftHeight} ft"));
      if(attraction.dropHeight != 0.0)
        details.add(_furtherDetailsTextEntry("Drop Height", "${attraction.dropHeight} ft"));
      if(attraction.maxSpeed != 0)
        details.add(_furtherDetailsTextEntry("Max Speed", "${attraction.maxSpeed} mph"));
      if(attraction.length != 0)
        details.add(_furtherDetailsTextEntry("Length", "${attraction.length} ft"));
      if(attraction.attractionDuration != 0)
        details.add(_furtherDetailsTextEntry("Duration", "${attraction.attractionDuration ~/ 60}m ${attraction.attractionDuration % 60}s"));
      if(attraction.capacity != 0)
        details.add(_furtherDetailsTextEntry("Capacity", "${attraction.capacity} pph"));
      if(attraction.inversions != 0)
        details.add(_furtherDetailsTextEntry("Inversions", "${attraction.inversions}"));
      if(attraction.cost != 0)
        details.add(_furtherDetailsTextEntry("Cost", NumberFormat.compactCurrency(symbol: "\$").format(attraction.cost)));
      if(attraction.previousParkLabel != "")
        details.add(_furtherDetailsTextEntry("Previous Park Label", "${attraction.previousParkLabel}"));
      if(attraction.attractionLink != "")
        details.add(_furtherDetailsEntry("Website", _urlTextButton(context, "Attraction Site", attraction.attractionLink)));
      if(attraction.modifyBy != "")
        details.add(_furtherDetailsTextEntry("Entry Last Modified by", attraction.modifyBy));
      return details;
    }

    return details;
  }

  Widget _furtherDetailsTextEntry(String leftText, String rightText) {
    return _furtherDetailsEntry(leftText, Text(rightText, textAlign: TextAlign.right,));
  }

  Widget _furtherDetailsEntry(String leftText, Widget right){
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                leftText,
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
              child: Container(
                  alignment: Alignment.centerRight, child: right))
        ],
      ),
    );
  }

  Widget _urlTextButton(BuildContext context, String text, String url){
    return InkWell(
      onTap: () async {
        if(await canLaunch(url)){
          await launch(url);
        }
      },
      child: Text(text, style: TextStyle(color: Theme.of(context).primaryColor),),
    );
  }
  /*
  DateTime firstTime;
  DateTime lastTime;

  @override
  void initState() {
    super.initState();
    firstTime = widget.detailsMap[DetailsType.FIRST_TIME] ?? DateTime.fromMillisecondsSinceEpoch(0);
    lastTime = widget.detailsMap[DetailsType.LAST_TIME] ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

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
                _buildStatusSection(context),
              ]..addAll(_buildFurtherDetails(context)),
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
          maxLines: 1,
          style: Theme.of(context).textTheme.headline,
        ),
        SideStrikeText(
          bodyText: Text(
            widget.headerText[HeaderText.TYPE] ?? "Placeholder Type",
            textScaleFactor: 1.75,
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

  /// The status section's data is recieved as three keys - Opening, Closed, and Status
  /// The status is compressed into a double digit - tens place containing the seasonal bool
  /// and the ones place containing the active bool.
  /// Opening is always displayed if present, and closed is displayed only when active is false
  Widget _buildStatusSection(BuildContext context) {
    int openingYear = widget.detailsMap[DetailsType.OPENING_DATE] ?? 0;
    int closingYear = widget.detailsMap[DetailsType.CLOSING_DATE] ?? 0;
    int onesPlace = (widget.detailsMap[DetailsType.STATUS] ?? 0) %
        10; // Ones place - active/defunct
    int tensPlace = (widget.detailsMap[DetailsType.STATUS] ?? 0) ~/
        10; // tens place - seasonal/normal
    bool active = (onesPlace == 1);
    bool seasonal = (tensPlace == 1);

    Widget _leftStatus = _buildYearStatusColumn(openingYear, "Opening Year");

    Widget _rightStatus;

    if (!active) {
      _rightStatus = _buildYearStatusColumn(closingYear, "Closing Year");
    } else if (seasonal) {
      _rightStatus = _buildAttractionOperationColumn("Seasonal Operation");
    } else {
      _rightStatus = _buildAttractionOperationColumn("Active Operation");
    }

    Widget _statusContent = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[_leftStatus, _rightStatus],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Divider(),
        _statusContent,
        Divider(),
      ],
    );
  }

  /// If year == 0, we'll display "unknown" as our year
  Widget _buildYearStatusColumn(int year, String bottom) {
    String topString = (year == 0) ? "Unknown" : year.toString();

    return Column(
      children: <Widget>[
        Text(
          topString,
          textScaleFactor: 1.8,
        ),
        Text(
          bottom,
          textScaleFactor: 1.0,
        )
      ],
    );
  }

  Widget _buildAttractionOperationColumn(String display) {
    display = display.replaceAll(" ", "\n");
    return Text(
      display,
      textScaleFactor: 1.4,
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildFurtherDetails(BuildContext context) {
    List<Widget> entries = List<Widget>();

    // Return nothing if we've got nothing
    if (!widget.detailsMap.containsKey(DetailsType.FURTHER_DETAILS))
      return entries;

    // Each entry has a title and its data. Put those together into rows.1
    Map<String, Widget> furtherDetails =
        widget.detailsMap[DetailsType.FURTHER_DETAILS];
    furtherDetails.forEach((title, data) {
      entries.add(Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Expanded(
                child: Container(alignment: Alignment.centerRight, child: data))
          ],
        ),
      ));
    });

    return entries;
  }

  Widget _buildEditableDate(bool first, DateTime original){
    return InkWell(
      onTap: () => _showDatePicker(first),
      child: Text(
        DateFormat.yMMMMd("en_US").format(target),
        textAlign: TextAlign.right,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  void _showDatePicker(bool first, DateTime target){
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        initialYear: target.year,
        initialMonth: target.month,
        initialDate: target.day,
        locale: 'en_US',
        dateFormat: 'mmm-dd-yyyy', onConfirm: (year, month, date) {
          DateTime newDateTime = DateTime.utc(year, month, date);
          if(mounted){
            widget.
          }
        });
  }

  Widget _wrapAsWindow(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[300], offset: Offset(0, 4), blurRadius: 5)
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: child,
        ),
      ),
    );
  }

  LatLng _convertLatLng(oldLatLng.LatLng input) {
    return LatLng(input.latitude, input.longitude);
  }*/
}
