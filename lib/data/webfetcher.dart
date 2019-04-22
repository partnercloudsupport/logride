import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

enum WebLocation {
  ALL_PARKS,
  PARK_ATTRACTIONS,
  SPECIFIC_ATTRACTION,
  ATTRACTION_TYPES,
  SUBMISSION_LOG
}

enum SubmissionType {
  ATTRACTION_NEW,
  ATTRACTION_MODIFY,
  PARK,
  IMAGE
}

const _VERSION_URL = "Version1.2.1";

class WebFetcher {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final Map _serverURLS = {
    WebLocation.ALL_PARKS: "http://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/parksdbservice.php",
    WebLocation.PARK_ATTRACTIONS: "http://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/attractiondbservice.php?parkid=",
    WebLocation.SPECIFIC_ATTRACTION: "http://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/getAttractionDetails.php?rideID=",
    WebLocation.ATTRACTION_TYPES: "http://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/attractionTypes.php",
    SubmissionType.ATTRACTION_NEW: "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/usersuggestservice.php",
    SubmissionType.ATTRACTION_MODIFY: "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/modifyAttracion.php",
    SubmissionType.IMAGE: "http://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/submitPhotoUpload.php",
    SubmissionType.PARK: "http://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/suggestParkUploadtoApprove.php",
  };

  Future<List<BluehostPark>> getAllParkData() async {
    List<BluehostPark> data = List<BluehostPark>();

    final response = await http.get(_serverURLS[WebLocation.ALL_PARKS]);

    if(response.statusCode == 200){

      List<dynamic> decoded = json.decode(response.body);

      for(int i = 0; i < decoded.length; i++){
        BluehostPark park = BluehostPark.fromJson(decoded[i]);
        if(park == null) {
          print("There was an error parsing the park with the following data: ${decoded[i]}");
        }
        data.add(park);
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

  void submitAttractionData(BluehostAttraction attr, BluehostPark park, {String username, String uid, bool isNewAttraction = false}) async {

    // Status Calculations
    int activeStatus = attr.active ? 1 : 0;
    if(attr.upcoming) activeStatus = 2;

    // Date Calculations - if it's null, we replace it with 0000-00-00
    String formattedDateOpen = "0000-00-00";
    if(attr.openingDay != null){
      formattedDateOpen = DateFormat("yyyy'-'MM'-'dd").format(attr.openingDay);
    }

    // Prepare payload
    var body = jsonEncode(({
      "parknum": park.id,
      "ride": attr.attractionName,
      "open": attr.yearOpen ?? 0,
      "dateOpen":formattedDateOpen,
      "close": attr.yearClosed ?? 0,
      "yearsInactive": attr.inactivePeriods ?? "",
      "type": attr.rideType ?? 0,
      "park": park.parkName ?? "",
      "rideID": isNewAttraction ? 0 : attr.attractionID,
      "active": activeStatus,
      "seasonal": attr.seasonal ? 1 : 0,
      "manufacturer": attr.manufacturer ?? "",
      "manID": 0, /// TODO: Implement Manufacturer ID
      "notes": attr.notes ?? "",
      "modify": isNewAttraction ? 0 : 1,
      "scoreCard": attr.scoreCard ? 1 : 0,
      "formerNames": attr.formerNames ?? "",
      "model": attr.model ?? "",
      "model_id": 0, // TODO: Implement Model ID
      "height": attr.height ?? 0,
      "maxSpeed": attr.maxSpeed ?? 0,
      "length": attr.length ?? 0,
      "duration": attr.attractionDuration ?? 0,
      "email": username,
      "token": await _firebaseMessaging.getToken(),
      "userID": uid
    }));

    print(body);
    // Issue request
    http.post(_serverURLS[SubmissionType.ATTRACTION_NEW], body: body, headers: {"Content-Type": "application/json"}).then((response) {
      print("[${response.statusCode}]: ${response.body}");
    });
    // State result
  }

  void submitParkData(BluehostPark newPark, {String username, String uid}) async {
    var body = {
      "name": newPark.parkName ?? "",
      "type": newPark.type ?? "",
      "city": newPark.parkCity ?? "",
      "count": newPark.parkCountry ?? "",
      "lat": newPark.location?.latitude ?? 0,
      "long": newPark.location?.longitude ?? 0,
      "open": newPark.yearOpen ?? 0,
      "closed": newPark.yearClosed ?? 0,
      "defunct": !newPark.active ? 1 : 0,
      "prevName": newPark.previousNames ?? "",
      "seasonal": newPark.seasonal ? 1 : 0,
      "userName": username ?? "",
      "website": newPark.website ?? "",
      "userID": uid ?? "",
      "token": await _firebaseMessaging.getToken()
    };

    print(body);

    http.post(_serverURLS[SubmissionType.PARK], body: json.encode(body)).then((response){
      print("[${response.statusCode}]: ${response.body}");
    });
  }

  Future<int> submitAttractionImage({int rideId, int parkId, String photoArtist, String rideName, String parkName}) async {
    var body = {
      "rideID": rideId,
      "parkID": parkId,
      "photoArtist": photoArtist,
      "rideName": rideName,
      "parkName": parkName
    };

    print(body);

    return await http.post(_serverURLS[SubmissionType.IMAGE], body: json.encode(body)).then((response) => response.statusCode);
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