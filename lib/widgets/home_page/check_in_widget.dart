import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/check_in_manager.dart';
import 'package:shimmer/shimmer.dart';

/*
  This pretty much all needs to be gutted
  The UI needs to be totally altered to fit the new layout, with a card appearing
  at the top of the home page proclaiming the good news of the user's geolocation

 */

class CheckInWidget extends StatefulWidget {
  CheckInWidget({this.manager, this.onTap});

  final CheckInManager manager;
  final Function(int id) onTap;

  @override
  _CheckInWidgetState createState() => _CheckInWidgetState();
}

class _CheckInWidgetState extends State<CheckInWidget> {
  CheckInData checkInData = CheckInData(null, false);

  void _checkInStatusChanged() async {
    if (!widget.manager.listenable.value.isEqualTo(checkInData)) {
      print("User's check-in status has changed");
      setState(() {
        checkInData = widget.manager.listenable.value;
      });

      if (checkInData.park == null) {
        print("User is not currently located in/near a park.");
        return;
      }

      print(checkInData.checkedInToday
          ? "User has previously checked in today"
          : "User has not previously checked in today");

      if (!checkInData.checkedInToday) {
        //await _openCheckInDialog();
      }
    }
  }

  Future<bool> _handleCheckIn() async {
    print("User wants to check in to park ${checkInData.park.parkName}");
    widget.manager.checkIn(checkInData.park.id);
    print("Manager has checked in to the park, opening the park page.");
    widget.onTap(checkInData.park.id);

    return true;
  }

  @override
  void initState() {
    widget.manager.listenable.addListener(_checkInStatusChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      key: ValueKey("Empty"),
    );

    if (checkInData.park != null) {
      content = GestureDetector(
        onTap: () => _handleCheckIn(),
        child: _CheckInTile(
          name: checkInData.park.parkName,
          checkedIn: checkInData.checkedInToday,
          key: ValueKey(checkInData.park.parkName),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: content,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SizeTransition(
          child: child,
          axis: Axis.vertical,
          sizeFactor: animation,
        );
      },
    );
  }
}

class _CheckInTile extends StatelessWidget {
  _CheckInTile({this.name = "", this.checkedIn = false, Key key})
      : super(key: key);

  final String name;
  final bool checkedIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).primaryColor,
              highlightColor: Theme.of(context).accentColor,
              period: Duration(seconds: 3),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          name,
                          style: Theme.of(context).textTheme.subhead,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          checkedIn ? "Tap to Open" : "Tap to Check-In...",
                          style: Theme.of(context).textTheme.subtitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Icon(
                      checkedIn
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.mapMarkerAlt,
                      color: Theme.of(context).primaryColor,
                      size: 32.0,
                    )
                  ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Divider(
            height: 0.0,
            color: Colors.black38,
          ),
        )
      ],
    );
  }
}
