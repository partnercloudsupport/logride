import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/check_in_manager.dart';
import 'package:log_ride/widgets/home_icon.dart';
import 'package:log_ride/ui/check_in_dialog.dart';

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

      if(checkInData.park == null){
        print("Park Data is null");
        return;
      }

      print(checkInData.park.parkName);
      print(checkInData.checkedInToday ? "Checked In" : "Not checked in");

      if (!checkInData.checkedInToday) {
        await _openCheckInDialog();
      }
    }
  }

  Future<bool> _openCheckInDialog() async {
    // Display alert dialog
    bool shouldCheckIn = await showDialog<bool>(context: context, builder: (BuildContext context) {
      return CheckInDialog(
          park: checkInData.park
      );
    });
    if(shouldCheckIn){
      print("We should check in");
      widget.manager.checkIn(checkInData.park.id);
      print("Manager has checked in, now to have the thing open");
      widget.onTap(checkInData.park.id);
    }
    return true;
  }

  @override
  void initState() {
    widget.manager.listenable.addListener(_checkInStatusChanged);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (checkInData.park != null)
        ? HomeIconButton(
            decoration: Container(
              constraints: BoxConstraints.expand(),
              child: Icon(
                FontAwesomeIcons.mapMarkerAlt,
                color: Colors.white,
                size: 60.0,
              ),
            ),
            onTap: () async {
              if(widget.onTap != null){
                if(!checkInData.checkedInToday) {
                  await _openCheckInDialog();
                  return;
                } else {
                  widget.onTap(checkInData.park.id);
                }
              } else {
                print("User tapped on the check-in icon, but there isn't a response callback established");
              }
            },
          )
        : HomeIconButton();
  }
}
