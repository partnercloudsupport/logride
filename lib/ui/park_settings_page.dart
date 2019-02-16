import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/widgets/interface_button.dart';

enum ParkSettingsCategory { SHOW_SEASONAL, SHOW_DEFUNCT, TALLY }

class ParkSettingsPage extends StatefulWidget {
  ParkSettingsPage({this.userData, this.parkData, this.callback});

  final FirebasePark userData;
  final BluehostPark parkData;
  final Function(ParkSettingsCategory key, dynamic data) callback;

  @override
  _ParkSettingsPageState createState() => _ParkSettingsPageState();
}

class _ParkSettingsPageState extends State<ParkSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent, body: _buildParkSettings(context));
  }

  Widget _buildParkSettings(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          child: Container(
            constraints: BoxConstraints.expand(),
          ),
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
        ),
        Center(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildTitleBar(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: _buildEntries(context),
                        ),
                      ),
                    ],
                  ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          color: Theme.of(context).primaryColor,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Settings",
              style: Theme.of(context).textTheme.headline.apply(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildEntries(BuildContext context) {
    List<Widget> entries = <Widget>[
      FormField(
        builder: (FormFieldState<bool> state) {
          return SwitchListTile.adaptive(
            value: state.value,
            onChanged: (value) {
              state.didChange(value);
              widget.callback(ParkSettingsCategory.TALLY, value);
            },
            title: Text("Experience Tally"),
            activeColor: Theme.of(context).primaryColor,
          );
        },
        initialValue: widget.userData.incrementorEnabled,
      ),
      FormField(
        builder: (FormFieldState<bool> state) {
          return SwitchListTile.adaptive(
            value: state.value,
            onChanged: (value) {
              state.didChange(value);
              widget.callback(ParkSettingsCategory.SHOW_SEASONAL, value);
            },
            title: Text("Show Seasonal Attractions"),
            activeColor: Theme.of(context).primaryColor,
          );
        },
        initialValue: widget.userData.showSeasonal,
      ),
      FormField(
        builder: (FormFieldState<bool> state) {
          return SwitchListTile.adaptive(
            value: state.value,
            onChanged: (value) {
              state.didChange(value);
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
          onPressed: () => print(
              "Submit new attraction called"), // TODO: Submit new attraction page
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
