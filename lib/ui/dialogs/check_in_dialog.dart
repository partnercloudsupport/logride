import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/shared/side_strike_text.dart';

class CheckInDialog extends StatelessWidget {
  CheckInDialog({this.park});

  final BluehostPark park;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Container(constraints: BoxConstraints.expand(),),
            onTap: () => Navigator.of(context).pop(false),
          ),
          SafeArea(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Header
                      _buildDialogHeader(context),
                      // Park Welcome
                      _buildParkWelcome(context),
                      // Check-in Prompt
                      _buildCheckInPrompt(context),
                      // Buttons
                      _buildButtonsRow(context)
                    ],
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      //color: Theme.of(context).primaryColor,
      child: SideStrikeText(
        bodyText: Text(
          "WELCOME TO",
          textScaleFactor: 1.2,
          textAlign: TextAlign.center,
        ),
        strikeColor: Theme.of(context).primaryColor,
        strikeThickness: 5.0,
      ),
    );
  }

  Widget _buildParkWelcome(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        park.parkName,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),
        maxLines: 2,
        overflow: TextOverflow.fade,
      ),
    );
  }

  Widget _buildCheckInPrompt(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        "Would you like to check in?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget _buildButtonsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        InterfaceButton(
          icon: Icon(
            FontAwesomeIcons.times,
            color: Colors.grey[600],
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        InterfaceButton(
          icon: Icon(
            FontAwesomeIcons.check,
            color: Colors.white,
          ),
          color: Theme.of(context).primaryColor,
          onPressed: () => Navigator.of(context).pop(true),
        )
      ],
    );
  }
}
