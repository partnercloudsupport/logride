import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/back_button.dart';

const API_KEY = "AIzaSyDA8ZiyR1TeQtQHWEKj5T__5U4FJyya5V8";

class EmbeddedMapEntry extends StatefulWidget {
  EmbeddedMapEntry({this.markers, this.center});

  final Map<List<String>, LatLng> markers;
  final LatLng center;

  @override
  _EmbeddedMapEntryState createState() => _EmbeddedMapEntryState();
}

class _EmbeddedMapEntryState extends State<EmbeddedMapEntry> {
  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    widget.markers.forEach((textData, position) {
      mapController.addMarker(MarkerOptions(
          position: position,
          infoWindowText: InfoWindowText(textData[0], textData[1]),
          icon: BitmapDescriptor.defaultMarker));
    });
    mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: widget.center, zoom: 15.0)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          options: GoogleMapOptions(
              cameraPosition: CameraPosition(target: widget.center, zoom: 15.0),
              mapType: MapType.satellite),
        ),
        GestureDetector(
          onTap: _openFullMap,
          child: Container(constraints: BoxConstraints.expand()),
          behavior: HitTestBehavior.opaque,
        )
      ],
    );
  }

  void _openFullMap() {
    print("Tap");
    Navigator.of(context).push(MaterialPageRoute<void>(
        maintainState: true,
        builder: (BuildContext context) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  options: GoogleMapOptions(mapType: MapType.satellite),
                ),
                RoundBackButton()
              ],
            ),
          );
        }));
  }
}
