import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../data/park_structures.dart';
import '../widgets/interface_button.dart';

class ParkSettingsPage extends StatefulWidget {
  ParkSettingsPage({this.userData, this.parkData});

  final FirebasePark userData;
  final BluehostPark parkData;

  @override
  _ParkSettingsPageState createState() => _ParkSettingsPageState();
}

class ParkSettingsData {
  bool showSeasonal = true;
  bool showDefunct = false;
  bool tally = false;
}

class _ParkSettingsPageState extends State<ParkSettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ParkSettingsData _data = ParkSettingsData();

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
            key: this._formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                      _buildButtons(context)
                    ],
                  ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                "Settings",
                style: Theme.of(context).textTheme.headline,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(15.0),
            ),
            constraints: BoxConstraints.expand(height: 4.0),
          ),
        )
      ],
    );
  }

  List<Widget> _buildEntries(BuildContext context) {
    List<Widget> entries = <Widget>[
      FormField(
        builder: (FormFieldState<bool> state) {
          return SwitchListTile.adaptive(
            value: state.value,
            onChanged: (value) => state.didChange(value),
            title: Text("Experience Tally"),
            activeColor: Theme.of(context).primaryColor,
          );
        },
        initialValue: widget.userData.incrementorEnabled,
        onSaved: (value) {
          _data.tally = value;
        },
      ),
      FormField(
          builder: (FormFieldState<bool> state) {
            return SwitchListTile.adaptive(
              value: state.value,
              onChanged: (value) => state.didChange(value),
              title: Text("Show Seasonal Attractions"),
              activeColor: Theme.of(context).primaryColor,
            );
          },
          initialValue: widget.userData.showSeasonal,
          onSaved: (value) {
            _data.showSeasonal = value;
          }),
      FormField(
        builder: (FormFieldState<bool> state) {
          return SwitchListTile.adaptive(
            value: state.value,
            onChanged: (value) => state.didChange(value),
            title: Text("Show Defunct Attractions"),
            activeColor: Theme.of(context).primaryColor,
          );
        },
        initialValue: widget.userData.showDefunct,
        onSaved: (value) {
          _data.showDefunct = value;
        },
      ),
      InterfaceButton(
        text: "Submit New Attraction".toUpperCase(),
        onPressed: () => print("Submit new attraction called"),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
      ),
    ];
    return entries;
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        InterfaceButton(
          icon: Icon(FontAwesomeIcons.times, color: Colors.grey[600]),
          onPressed: () => Navigator.of(context).pop(),
        ),
        InterfaceButton(
          icon: Icon(FontAwesomeIcons.check,
              color: Theme.of(context).primaryColor),
          onPressed: submit,
        )
      ],
    );
  }

  void submit() {
    _formKey.currentState.save();
    Navigator.of(context).pop(_data);
  }
}