import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart' as oldLatLng;
import 'package:url_launcher/url_launcher.dart';

import 'package:log_ride/animations/slide_in_transition.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/widgets/content_frame.dart';
import 'package:log_ride/widgets/embedded_map_entry.dart';
import 'package:log_ride/widgets/side_strike_text.dart';
import 'package:log_ride/widgets/stored_image_widget.dart';
import 'package:log_ride/widgets/photo_credit_text.dart';
import 'package:log_ride/widgets/title_bar_icon.dart';
import 'package:log_ride/ui/attraction_scorecard_page.dart';
import 'package:log_ride/ui/standard_page_structure.dart';

enum _DetailsType { PARK_DETAILS, ATTRACTION_DETAILS }

class DetailsPage extends StatefulWidget {
  DetailsPage({this.db, this.data, this.userData, this.dateChangeHandler});

  final BaseDB db;
  final dynamic data;
  final FirebaseAttraction userData;
  final Function(bool first, DateTime newTime) dateChangeHandler;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  _DetailsType _type;

  DateTime firstRide;
  DateTime lastRide;

  @override
  void initState() {
    super.initState();
    if (widget.data is BluehostAttraction) {
      _type = _DetailsType.ATTRACTION_DETAILS;
      if (widget.userData.firstRideDate.millisecondsSinceEpoch != 0)
        firstRide = widget.userData.firstRideDate;
      if (widget.userData.lastRideDate.millisecondsSinceEpoch != 0)
        lastRide = widget.userData.lastRideDate;
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
        resizeToAvoidBottomPadding: false,
        body: StandardPageStructure(
          iconFunction: () => Navigator.of(context).pop(),
          iconDecoration: FontAwesomeIcons.info,
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

    List<Widget> userDetails = [Container()];
    userDetails = _buildUserDetails(context);

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
                ..addAll(userDetails),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildTitleBar(BuildContext context) {
    // Empty container must match the size of the built widget so the expanded thing
    // doesn't look odd
    Widget _leftIcon = Container(
      height: 26.0,
      width: 50,
    );
    Widget _rightIcon = Container(
      height: 26.0,
      width: 50,
    );
    String titleText;
    String subtitleText;

    if (_type == _DetailsType.PARK_DETAILS) {
      BluehostPark parkData = (widget.data as BluehostPark);
      titleText = parkData.parkName;
      subtitleText = parkData.type;
    } else if (_type == _DetailsType.ATTRACTION_DETAILS) {
      BluehostAttraction attractionData = (widget.data as BluehostAttraction);
      titleText = attractionData.attractionName;
      subtitleText = attractionData.typeLabel;

      if (attractionData.scoreCard) {
        _leftIcon = TitleBarIcon(
          icon: FontAwesomeIcons.medal,
          onTap: () {
            showDialog(context: context, builder: (BuildContext context) {
              return AttractionScorecardPage(
                  attraction: attractionData, db: widget.db);
            });
          },
        );
      }

      _rightIcon = TitleBarIcon(
        icon: FontAwesomeIcons.pencilAlt,
        onTap: () => print("Edit"), // TODO: Call up attraction edit page
      );
    }

    if (titleText == null || titleText == "") titleText = "Missing Title";
    if (subtitleText == null) subtitleText = "Missing Subtitle";

    Widget sText = AutoSizeText(
      subtitleText,
      style: TextStyle(fontSize: 20.0),
    );

    if (subtitleText == "") {
      sText = null;
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _leftIcon,
            Expanded(
              child: AutoSizeText(
                titleText,
                maxLines: 2,
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center,
              ),
            ),
            _rightIcon
          ],
        ),
        SideStrikeText(
          bodyText: sText,
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

    Widget _credit;
    if (_type == _DetailsType.ATTRACTION_DETAILS) {
      _credit = PhotoCreditText(
        photoUrl: attraction.photoLink,
        username: attraction.photoArtist,
        ccType: attraction.ccType,
        style: TextStyle(color: Colors.white),
      );
    }

    return Container(
        height: 250,
        child: _wrapAsWindow(FirebaseAttractionImage(
          attractionID: attraction.attractionID,
          parkID: attraction.parkID,
          overlay: _credit,
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

    if (_type == _DetailsType.PARK_DETAILS) {
      BluehostPark park = widget.data as BluehostPark;
      if (park.parkCity != "")
        details.add(_furtherDetailsTextEntry("City", park.parkCity));
      if (park.parkCountry != "")
        details.add(_furtherDetailsTextEntry("Country", park.parkCountry));
      if (park.previousNames != "")
        details
            .add(_furtherDetailsTextEntry("Former Names", park.previousNames));
      if (park.website != "")
        details.add(_furtherDetailsEntry(
            "Website", _urlTextButton(context, "Park Website", park.website)));
      return details;
    }

    if (_type == _DetailsType.ATTRACTION_DETAILS) {
      BluehostAttraction attraction = widget.data as BluehostAttraction;
      if (attraction.manufacturer != "")
        details.add(
            _furtherDetailsTextEntry("Manufacturer", attraction.manufacturer));
      if (attraction.additionalContributors != "")
        details.add(_furtherDetailsTextEntry(
            "Additional Contributors", attraction.additionalContributors));
      if (attraction.formerNames != "")
        details.add(
            _furtherDetailsTextEntry("Former Names", attraction.formerNames));
      if (attraction.model != "")
        details.add(_furtherDetailsTextEntry("Model", attraction.model));
      if (attraction.height != 0)
        details
            .add(_furtherDetailsTextEntry("Height", "${attraction.height} ft"));
      if (attraction.liftHeight != 0.0)
        details.add(_furtherDetailsTextEntry(
            "Lift Height", "${attraction.liftHeight} ft"));
      if (attraction.dropHeight != 0.0)
        details.add(_furtherDetailsTextEntry(
            "Drop Height", "${attraction.dropHeight} ft"));
      if (attraction.maxSpeed != 0)
        details.add(_furtherDetailsTextEntry(
            "Max Speed", "${attraction.maxSpeed} mph"));
      if (attraction.length != 0)
        details
            .add(_furtherDetailsTextEntry("Length", "${attraction.length} ft"));
      if (attraction.attractionDuration != 0)
        details.add(_furtherDetailsTextEntry("Duration",
            "${attraction.attractionDuration ~/ 60}m ${attraction.attractionDuration % 60}s"));
      if (attraction.capacity != 0)
        details.add(
            _furtherDetailsTextEntry("Capacity", "${attraction.capacity} pph"));
      if (attraction.inversions != 0)
        details.add(
            _furtherDetailsTextEntry("Inversions", "${attraction.inversions}"));
      if (attraction.cost != 0)
        details.add(_furtherDetailsTextEntry(
            "Cost",
            NumberFormat.compactCurrency(symbol: "\$")
                .format(attraction.cost)));
      if (attraction.previousParkLabel != "")
        details.add(_furtherDetailsTextEntry(
            "Previous Park Label", "${attraction.previousParkLabel}"));
      if (attraction.attractionLink != "")
        details.add(_furtherDetailsEntry(
            "Website",
            _urlTextButton(
                context, "Attraction Site", attraction.attractionLink)));
      if (attraction.modifyBy != "")
        details.add(_furtherDetailsTextEntry(
            "Entry Last Modified by", attraction.modifyBy));
      if (attraction.notes != "")
        details.add(_longDetailsEntry("Notes", attraction.notes));
      return details;
    }

    return details;
  }

  Widget _furtherDetailsTextEntry(String leftText, String rightText) {
    return _furtherDetailsEntry(
        leftText,
        Text(
          rightText,
          textAlign: TextAlign.right,
        ));
  }

  Widget _furtherDetailsEntry(String leftText, Widget right) {
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
              child: Container(alignment: Alignment.centerRight, child: right))
        ],
      ),
    );
  }

  Widget _longDetailsEntry(String title, String content) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(7.5)),
            constraints: BoxConstraints(minHeight: 100.0),
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(content),
            ),
          ),
        ]));
  }

  Widget _urlTextButton(BuildContext context, String text, String url) {
    return InkWell(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  List<Widget> _buildUserDetails(BuildContext context) {
    // Only attractions have user visitation data
    if (_type != _DetailsType.ATTRACTION_DETAILS) return <Widget>[Container()];
    // We can't display anything if we don't have anything
    if (widget.userData == null) return <Widget>[Container()];

    List<Widget> userDetails = <Widget>[];
    if (firstRide != null)
      userDetails.add(
          _furtherDetailsEntry("First Ridden", _editableDate(true, firstRide)));
    if (lastRide != null)
      userDetails.add(
          _furtherDetailsEntry("Last Ridden", _editableDate(true, lastRide)));

    return userDetails;
  }

  Widget _editableDate(bool first, DateTime date) {
    return InkWell(
      onTap: () => _showDatePicker(first, date),
      child: Text(
        DateFormat.yMMMMd("en_US").format(date),
        textAlign: TextAlign.right,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  void _showDatePicker(bool first, DateTime initialDate) {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        initialYear: initialDate.year,
        initialMonth: initialDate.month,
        initialDate: initialDate.day,
        locale: 'en_US',
        dateFormat: 'mmm-dd-yyyy', onConfirm: (year, month, date) {
      DateTime newDateTime = DateTime.utc(year, month, date);
      if (widget.dateChangeHandler != null)
        widget?.dateChangeHandler(first, newDateTime);
      if (mounted)
        setState(() {
          if (first) {
            firstRide = newDateTime;
          } else {
            lastRide = newDateTime;
          }
        });
    });
  }
}
