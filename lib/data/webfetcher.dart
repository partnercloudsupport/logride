import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'park_structures.dart';
import 'attraction_structures.dart';

enum WebLocation {
  ALL_PARKS,
  PARK_ATTRACTIONS,
  SPECIFIC_ATTRACTION
}

class WebFetcher {
  final Map _serverURLS = {
    WebLocation.ALL_PARKS: "http://www.beingpositioned.com/theparksman/parksdbservice.php",
    WebLocation.PARK_ATTRACTIONS: "http://www.beingpositioned.com/theparksman/attractiondbservice.php?parkid=",
    WebLocation.SPECIFIC_ATTRACTION: "http://www.beingpositioned.com/theparksman/getAttractionDetails.php?rideID="
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

  Future<List<Attraction>> getAllAttractionData({num parkID}) async{
    List<Attraction> data = List<Attraction>();

    final response = await http.get(_serverURLS[WebLocation.PARK_ATTRACTIONS] + parkID.toString());

    if(response.statusCode == 200){
      List<dynamic> decoded = jsonDecode(response.body);
      for(int i =0; i < decoded.length; i++){
        data.add(Attraction.fromJson(decoded[i]));
      }
    }

    return data;
  }

  Future<Attraction> getSingleAttractionData({num attractionID}) async{
    final response = await http.get(_serverURLS[WebLocation.SPECIFIC_ATTRACTION] + attractionID.toString());

    if(response.statusCode == 200){
      return Attraction.fromJson(jsonDecode(response.body));
    }

    return null;
  }
}
