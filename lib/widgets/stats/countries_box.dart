import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:log_ride/widgets/shared/embedded_map_entry.dart';

class CountriesBox extends StatelessWidget {
  CountriesBox({this.mapData, this.countries});

  final Map<List<String>, LatLng> mapData;
  final num countries;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: <Widget>[
            Text(
              countries.toString(),
              style: TextStyle(
                  fontSize: 32, textBaseline: TextBaseline.alphabetic),
            ),
            Text(
              " VISITED COUNTRIES",
              textAlign: TextAlign.left,
              style: TextStyle(
                  textBaseline: TextBaseline.alphabetic,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[300],
                    offset: Offset(0, 4),
                    blurRadius: 5)
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
                height: 200,
                child: TranslatedMapEntry(
                  center: LatLng(0, 0),
                  markers: mapData,
                  generateCenter: (mapData.length > 0),
                )),
          ),
        ),
      ],
    );
  }
}
