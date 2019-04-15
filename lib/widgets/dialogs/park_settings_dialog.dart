import 'package:flutter/material.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/dialogs/dialog_frame.dart';

enum ParkSettingsCategory { SHOW_SEASONAL, SHOW_DEFUNCT, TALLY }

class ParkSettingsDialog extends StatefulWidget {
  ParkSettingsDialog(
      {this.userData, this.parkData, this.callback, this.submissionCallback});

  final FirebasePark userData;
  final BluehostPark parkData;
  final Function(ParkSettingsCategory key, dynamic data) callback;
  final Function(dynamic, bool) submissionCallback;

  @override
  _ParkSettingsDialogState createState() => _ParkSettingsDialogState();
}

class _ParkSettingsDialogState extends State<ParkSettingsDialog> {

  bool tally;
  bool seasonal;
  bool defunct;

  @override
  void initState() {
    tally = widget.userData.incrementorEnabled;
    seasonal = widget.userData.showSeasonal;
    if (widget.parkData.active == true) {
      defunct = widget.userData.showDefunct;
    } else {
      defunct = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildParkSettings(context);
  }

  Widget _buildParkSettings(BuildContext context) {
    return DialogFrame(
        title: "Settings",
        content: _buildEntries(context)
    );
  }

  List<Widget> _buildEntries(BuildContext context) {
    List<Widget> entries = <Widget>[
      SwitchListTile.adaptive(
        value: tally,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              tally = value;
            });
          }
          widget.callback(ParkSettingsCategory.TALLY, value);
        },
        title: Text("Experience Tally"),
        activeColor: Theme.of(context).primaryColor,
      ),
      SwitchListTile.adaptive(
        value: seasonal,
        onChanged: (value) {
          if (mounted) {
            setState(() {
              seasonal = value;
            });
          }
          widget.callback(ParkSettingsCategory.SHOW_SEASONAL, value);
        },
        title: Text("Show Seasonal Attractions"),
        activeColor: Theme.of(context).primaryColor,
      ),
      FormField(
        builder: (FormFieldState<bool> state) {
          return SwitchListTile.adaptive(
            value: state.value,
            onChanged: (!widget.parkData.active) ? null : (value) {
               if (mounted) {
                  state.didChange(value);
                }
                widget.callback(ParkSettingsCategory.SHOW_DEFUNCT, value);
            },
            title: Text("Show Defunct Attractions"),
            activeColor: Theme.of(context).primaryColor,
          );
        },
        initialValue: widget.userData.showDefunct,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InterfaceButton(
          text: "Submit New Attraction".toUpperCase(),
          onPressed: () {
            widget.submissionCallback(null, true);
          },
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
        ),
      ),
    ];
    return entries;
  }

  void submit() {
    Navigator.of(context).pop();
  }
}
