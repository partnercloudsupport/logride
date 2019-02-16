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
  bool _showingDialog = false;

  void _checkInStatusChanged() async {
    if (!widget.manager.listenable.value.isEqualTo(checkInData)) {
      print("User's check-in status has changed");
      setState(() {
        checkInData = widget.manager.listenable.value;
      });

      if(checkInData.park == null){
        print("User is not currently located in/near a park.");
        return;
      }

      print(checkInData.checkedInToday ? "User has previously checked in today" : "User has not previously checked in today");

      if (!checkInData.checkedInToday) {
        await _openCheckInDialog();
      }
    }
  }

  Future<bool> _openCheckInDialog() async {
    if(_showingDialog) return false;
    _showingDialog = true;
    // Display alert dialog
    bool shouldCheckIn = await showDialog<bool>(context: context, builder: (BuildContext context) {
      return CheckInDialog(
          park: checkInData.park
      );
    });
    _showingDialog = false;
    if(shouldCheckIn){
      print("User wants to check in to park ${checkInData.park.parkName}");
      widget.manager.checkIn(checkInData.park.id);
      print("Manager has checked in to the park, opening the park page.");
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
            decoration: FontAwesomeIcons.mapMarkerAlt,
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
