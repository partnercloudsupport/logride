import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong/latlong.dart' as old;
import 'package:log_ride/widgets/shared/back_button.dart';

const API_KEY = "AIzaSyDA8ZiyR1TeQtQHWEKj5T__5U4FJyya5V8";

class EmbeddedMapEntry extends StatefulWidget {
  EmbeddedMapEntry({this.markers, this.center, this.zoom = 15.0});

  final Map<List<String>, LatLng> markers;
  final LatLng center;
  final double zoom;

  @override
  _EmbeddedMapEntryState createState() => _EmbeddedMapEntryState();
}

class _EmbeddedMapEntryState extends State<EmbeddedMapEntry> {
  GoogleMapController mapController;

  Set<Marker> markers;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;


    mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: widget.center, zoom: widget.zoom)));
  }


  @override
  void initState() {

    markers = Set<Marker>();

    widget.markers.forEach((textData, position) {
      markers.add(Marker(
          position: position,
          infoWindow: InfoWindow(
            title: textData[0],
            snippet: textData[1]
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(128),
        markerId: MarkerId("${textData[0]}${position.latitude.floor()}${position.longitude.floor()}")
      ));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: widget.center, zoom: widget.zoom),
          mapType: MapType.normal,
          markers: markers,
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
    Navigator.of(context).push(MaterialPageRoute<void>(
        maintainState: true,
        builder: (BuildContext context) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.satellite,
                  markers: markers,
                  initialCameraPosition: CameraPosition(target: widget.center, zoom: widget.zoom),
                ),
                RoundBackButton()
              ],
            ),
          );
        }));
  }
}

class TranslatedMapEntry extends StatelessWidget {
  TranslatedMapEntry({this.center, this.markers, this.generateCenter = true});

  final old.LatLng center;
  final Map<List<String>, old.LatLng> markers;
  final bool generateCenter;

  @override
  Widget build(BuildContext context) {

    LatLng generatedCenter;

    if(generateCenter) {
      generatedCenter = calculateCenter(markers.values.toList());
    } else {
      generatedCenter = LatLng(center.latitude, center.longitude);
    }

    return EmbeddedMapEntry(
      center: generatedCenter,
      zoom: 1.0,
      markers: markers.map((text, loc) {
        return MapEntry<List<String>, LatLng>(
          text,
          LatLng(loc.latitude, loc.longitude)
        );
      }),
    );
  }
}

const double _DISCOVER_RADIUS = 5e3;

/// Selects a point from pointsToFit with the most points surrounding it in [_DISCOVER_RADIUS] km
LatLng calculateCenter(List<old.LatLng> pointsToFit) {
  Map<old.LatLng, List<old.LatLng>> pointScores = Map<old.LatLng, List<old.LatLng>>();
  old.Distance pathDistance = old.Distance();

  // Go through and tally points - we're attempting to find the
  pointsToFit.forEach((point) {
    pointScores[point] = List<old.LatLng>();
    pointsToFit.forEach((target) {
      double calculatedKM = pathDistance.as(old.LengthUnit.Kilometer, point, target);
      if(calculatedKM < _DISCOVER_RADIUS)
        pointScores[point].add(target);
    });
  });

  int maxScore = 0;
  old.LatLng maxPoint;
  pointScores.forEach((point, neighbors) {
    if(neighbors.length > maxScore){
      maxScore = neighbors.length;
      maxPoint = point;
    }
  });

  // Taking the point with the most neighbors, we try to find the middle of all the neighbors
  double sumLat = 0.0, sumLong = 0.0;
  pointScores[maxPoint].forEach((neighbor) {
    sumLat += neighbor.latitude;
    sumLong += neighbor.longitude;
  });



  return LatLng(sumLat / maxScore, sumLong / maxScore);
}