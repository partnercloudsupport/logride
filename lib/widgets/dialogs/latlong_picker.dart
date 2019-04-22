import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:log_ride/widgets/forms/submission_decoration.dart';
import 'package:log_ride/widgets/shared/interface_button.dart';
import 'package:log_ride/widgets/shared/styled_dialog.dart';

class LatLongPicker extends StatefulWidget {
  @override
  _LatLongPickerState createState() => _LatLongPickerState();
}

class _LatLongPickerState extends State<LatLongPicker> {
  LatLng selected;
  LatLng cameraPos;

  Set<Marker> markers = Set<Marker>();

  void submit() {
    if (selected != null) {
      Navigator.of(context).pop(selected);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StyledDialog(
              title: "No Location Set",
              body: "Please set a location before submitting",
              actionText: "Ok",
            );
          });
    }
  }

  void _cameraPositionCallback(CameraPosition position) {
    if (position.target == cameraPos) return;

    if (mounted) {
      setState(() {
        cameraPos = position.target;
      });
    }
  }

  void _setLocationCallback() {
    if (selected == cameraPos) return;

    print("Location Callback");

    if (mounted) {
      markers.clear();
      setState(() {
        markers.add(Marker(
          markerId: MarkerId("Target"),
          icon: BitmapDescriptor.defaultMarker,
          position: cameraPos,
        ));
        selected = cameraPos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          // Base Level: Progress Bar
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),

          // Second Level: Map
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition:
                CameraPosition(target: LatLng(0.0, 0.0), zoom: 1.0),
            onCameraMove: _cameraPositionCallback,
            markers: markers,
            compassEnabled: false,
            tiltGesturesEnabled: false,
          ),

          // Third Level: Centered Targeting Icon
          Center(
            child: Icon(FontAwesomeIcons.crosshairs,
                color: Colors.white, size: 32.0),
          ),

          // Finally: UI Level, including the buttons and display
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 32.0, horizontal: 32.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // Top Group: Display of current camera and targeted coords
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Top: Camera Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            // Icon
                            Icon(FontAwesomeIcons.crosshairs,
                                color: Theme.of(context).primaryColor),
                            // Text
                            Text(
                              (cameraPos != null)
                                  ? "${cameraPos.latitude.toStringAsFixed(8)}, ${cameraPos.longitude.toStringAsFixed(8)}"
                                  : "",
                              textAlign: TextAlign.right,
                            )
                          ],
                        ),

                        // Horizontal Separator
                        Divider(),

                        // Bottom: Set Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            // Icon
                            Icon(FontAwesomeIcons.mapMarkerAlt,
                                color: Theme.of(context).primaryColor),
                            // Text
                            Text(
                              (selected != null)
                                  ? "${selected.latitude.toStringAsFixed(8)}, ${selected.longitude.toStringAsFixed(8)}"
                                  : "",
                              textAlign: TextAlign.right,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                // Padding in the center
                Expanded(child: Container()),

                // Bottom Group: Buttons (Set location, confirm, cancel)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40.0,
                          child: InterfaceButton(
                            text: "SET LOCATION",
                            onPressed: () => _setLocationCallback(),
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            InterfaceButton(
                              icon: Icon(
                                FontAwesomeIcons.times,
                                color: Colors.grey[600],
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            InterfaceButton(
                              icon: Icon(
                                FontAwesomeIcons.check,
                                color: (selected != null) ? Colors.white : Colors.grey[600],
                              ),
                              color: (selected != null) ? Theme.of(context).primaryColor : null,
                              onPressed: submit,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LatLongField extends StatelessWidget {
  LatLongField({this.title, this.onSaved});

  final String title;
  final Function(List<double>) onSaved;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: submissionDecoration(),
      child: FormField<LatLng>(
        initialValue: null,
        onSaved: (d) => onSaved([d.latitude, d.longitude]),
        builder: (FormFieldState<LatLng> state) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // Open Dialog
              dynamic result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LatLongPicker();
                  });
              if (result != state.value) {
                state.didChange(result);
              }
            },
            child: Container(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .apply(fontWeightDelta: -1, color: Colors.grey[700]),
                  ),
                  Text(
                    (state.value == null)
                        ? ""
                        : "${state.value.latitude.toStringAsFixed(6)}, ${state.value.longitude.toStringAsFixed(6)}",
                    style: Theme.of(context).textTheme.title.apply(
                        fontWeightDelta: -1,
                        color: Theme.of(context).primaryColor),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
