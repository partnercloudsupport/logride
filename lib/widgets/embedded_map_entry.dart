import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  void _onMapCreated(GoogleMapController controller){
    mapController = controller;
    widget.markers.forEach((textData, position){
      mapController.addMarker(MarkerOptions(
          position: position,
          infoWindowText: InfoWindowText(textData[0], textData[1]),
          icon: BitmapDescriptor.defaultMarker
      ));
    });
  }


  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        onMapCreated: _onMapCreated,
        options: GoogleMapOptions(
          cameraPosition: CameraPosition(target: widget.center, zoom: 15.0),
          mapType: MapType.satellite
        ),
    );
  }
}
