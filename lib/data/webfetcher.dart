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
    WebLocation.ALL_PARKS: "http://www.beingpositioned.com/theparksman/LogRide/Version1.0.5/parksdbservice.php",
    WebLocation.PARK_ATTRACTIONS: "http://www.beingpositioned.com/theparksman/LogRide/Version1.0.5/attractiondbservice.php?parkid=",
    WebLocation.SPECIFIC_ATTRACTION: "http://www.beingpositioned.com/theparksman/LogRide/Version1.0.5/getAttractionDetails.php?rideID=",
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

  Future<List<BluehostAttraction>> getAllAttractionData({num parkID, Map<int, String> rideTypes, List<BluehostPark> allParks}) async{
    List<BluehostAttraction> data = List<BluehostAttraction>();

    final response = await http.get(_serverURLS[WebLocation.PARK_ATTRACTIONS] + parkID.toString());

    if(response.statusCode == 200){
      List<dynamic> decoded = jsonDecode(response.body);
      for(int i =0; i < decoded.length; i++){
        BluehostAttraction newAttraction = BluehostAttraction.fromJson(decoded[i]);
        _fixBluehostText(newAttraction);

        // Get our type label, or leave it blank if it doesn't exist
        newAttraction.typeLabel = rideTypes[newAttraction.rideType] ?? "";
        if(newAttraction.previousParkID != 0){
          newAttraction.previousParkLabel = getBluehostParkByID(allParks, newAttraction.previousParkID).parkName;
        }

        data.add(newAttraction);
      }
    }

    return data;
  }

  Future<BluehostAttraction> getSingleAttractionData({num attractionID}) async{
    final response = await http.get(_serverURLS[WebLocation.SPECIFIC_ATTRACTION] + attractionID.toString());

    if(response.statusCode == 200){
      BluehostAttraction createdAttraction = BluehostAttraction.fromJson(jsonDecode(response.body));
      _fixBluehostText(createdAttraction);
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

String rosettaStoneDecode(String input, {bool insertAmpersands = true, bool insertSpaces = true}){
  String result = input;
  if(insertAmpersands) result = result.replaceAll("!A?", "&");
  if(insertSpaces) result = result.replaceAll("_", " ");

  return result;
}

/// This is used to swap specific characters out that couldn't be used in standard web GET requests.
/// These characters were swapped by the original app during the submission process, which used
/// GET requests. These alternate characters were stored in the database. Now we
/// must filter them out for the text to be readable.
void _fixBluehostText(BluehostAttraction toFix){
  if(toFix.attractionName != null) toFix.attractionName = rosettaStoneDecode(toFix.attractionName);
  if(toFix.manufacturer != null) toFix.manufacturer = rosettaStoneDecode(toFix.manufacturer, insertSpaces: false);
  return;
}