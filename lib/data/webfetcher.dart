import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'park_structures.dart';
import 'attraction_structures.dart';

enum WebLocation {
  ALL_PARKS,
  PARK_ATTRACTIONS,
  SPECIFIC_ATTRACTION,
  ATTRACTION_TYPES,
}

class WebFetcher {
  final Map _serverURLS = {
    WebLocation.ALL_PARKS: "http://www.beingpositioned.com/theparksman/parksdbservice.php",
    WebLocation.PARK_ATTRACTIONS: "http://www.beingpositioned.com/theparksman/attractiondbservice.php?parkid=",
    WebLocation.SPECIFIC_ATTRACTION: "http://www.beingpositioned.com/theparksman/getAttractionDetails.php?rideID=",
    WebLocation.ATTRACTION_TYPES: "http://www.beingpositioned.com/theparksman/attractionTypes.php"
  };

  Future<List<BluehostPark>> getAllParkData() async {
    List<BluehostPark> data = List<BluehostPark>();

    final response = await http.get(_serverURLS[WebLocation.ALL_PARKS]);

    if(response.statusCode == 200){
      List<dynamic> decoded = json.decode(response.body);

      for(int i = 0; i < decoded.length; i++){
        data.add(BluehostPark.fromJson(decoded[i]));
      }
    }

    return data;
  }

  Future<List<BluehostAttraction>> getAllAttractionData({num parkID, Map<int, String> rideTypes}) async{
    List<BluehostAttraction> data = List<BluehostAttraction>();

    final response = await http.get(_serverURLS[WebLocation.PARK_ATTRACTIONS] + parkID.toString());

    if(response.statusCode == 200){
      List<dynamic> decoded = jsonDecode(response.body);
      for(int i =0; i < decoded.length; i++){
        BluehostAttraction newAttraction = BluehostAttraction.fromJson(decoded[i]);

        // Get our type label, or leave it blank if it doesn't exist
        newAttraction.typeLabel = rideTypes[newAttraction.rideType] ?? "";

        data.add(newAttraction);
      }
    }

    return data;
  }

  Future<BluehostAttraction> getSingleAttractionData({num attractionID}) async{
    final response = await http.get(_serverURLS[WebLocation.SPECIFIC_ATTRACTION] + attractionID.toString());

    if(response.statusCode == 200){
      return BluehostAttraction.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  Future<Map<int, String>> getAttractionTypesMap() async {
    final response = await http.get(_serverURLS[WebLocation.ATTRACTION_TYPES]);

    if(response.statusCode == 200){
      // The map from the PHP script has the keys as strings, but they're really ints
      // We need to convert that first before we return it
      return (jsonDecode(response.body) as Map).map((key, value) {
        return MapEntry<int, String>(int.parse(key), value);
      });
    }

    return null;
  }
}
