import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/manufacturer_structures.dart';
import 'package:log_ride/data/model_structures.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/ride_type_structures.dart';

enum WebLocation {
  ALL_PARKS,
  PARK_ATTRACTIONS,
  SPECIFIC_ATTRACTION,
  ATTRACTION_TYPES,
  SUBMISSION_LOG,
  NEWS,
  MANUFACTURERS,
  MODELS,
}

enum SubmissionType { ATTRACTION_NEW, PARK, IMAGE }

const _VERSION_URL = "Version2.1";

class WebFetcher {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final Map _serverURLS = {
    WebLocation.ALL_PARKS:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/parksdbservice.php",
    WebLocation.PARK_ATTRACTIONS:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/attractiondbservice.php?parkid=",
    WebLocation.SPECIFIC_ATTRACTION:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/getAttractionDetails.php?rideID=",
    WebLocation.ATTRACTION_TYPES:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/attractionTypes.php",
    WebLocation.NEWS:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/newsfeedDownload.php",
    WebLocation.MANUFACTURERS:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/manufacturerDownload.php",
    WebLocation.MODELS:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/modelDownload.php?manID=",
    SubmissionType.ATTRACTION_NEW:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/usersuggestservice.php",
    SubmissionType.IMAGE:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/submitPhotoUpload.php",
    SubmissionType.PARK:
        "https://www.beingpositioned.com/theparksman/LogRide/$_VERSION_URL/suggestParkUploadtoApprove.php",
  };

  Future<List<BluehostPark>> getAllParkData() async {
    List<BluehostPark> data = List<BluehostPark>();

    final response = await http.get(_serverURLS[WebLocation.ALL_PARKS]);

    if (response.statusCode == 200) {
      List<dynamic> decoded = json.decode(response.body);

      for (int i = 0; i < decoded.length; i++) {
        BluehostPark park = BluehostPark.fromJson(decoded[i]);
        if (park == null) {
          print(
              "There was an error parsing the park with the following data: ${decoded[i]}");
        }
        data.add(park);
      }
    }

    data.sort(
        (a, b) => a.parkName.toLowerCase().compareTo(b.parkName.toLowerCase()));

    return data;
  }

  Future<List<BluehostAttraction>> getAllAttractionData(
      {num parkID,
      List<RideType> rideTypes,
      List<BluehostPark> allParks}) async {
    List<BluehostAttraction> data = List<BluehostAttraction>();

    final response = await http
        .get(_serverURLS[WebLocation.PARK_ATTRACTIONS] + parkID.toString());

    if (response.statusCode == 200) {
      List<dynamic> decoded = jsonDecode(response.body);
      for (int i = 0; i < decoded.length; i++) {
        BluehostAttraction newAttraction =
            BluehostAttraction.fromJson(decoded[i]);
        _fixBluehostAttractionText(newAttraction);

        // Get our type label, or leave it blank if it doesn't exist
        RideType rideType =
            findRideTypeByID(rideTypes, newAttraction.rideTypeID);
        newAttraction.typeLabel = rideType?.label ?? "";
        newAttraction.rideType = rideType ?? findRideTypeByID(rideTypes, 0);
        if (newAttraction.previousParkID != 0) {
          newAttraction.previousParkLabel =
              getBluehostParkByID(allParks, newAttraction.previousParkID)
                  .parkName;
        }

        data.add(newAttraction);
      }
    }

    data.sort((a, b) => a.attractionName
        .toLowerCase()
        .compareTo(b.attractionName.toLowerCase()));

    return data;
  }

  Future<BluehostAttraction> getSingleAttractionData({num attractionID}) async {
    final response = await http.get(
        _serverURLS[WebLocation.SPECIFIC_ATTRACTION] + attractionID.toString());

    if (response.statusCode == 200) {
      BluehostAttraction createdAttraction =
          BluehostAttraction.fromJson(jsonDecode(response.body));
      _fixBluehostAttractionText(createdAttraction);
      return BluehostAttraction.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  Future<List<RideType>> getAttractionTypes() async {
    final response = await http.get(_serverURLS[WebLocation.ATTRACTION_TYPES]);

    if (response.statusCode == 200) {
      // The map from the PHP script has the keys as strings, but they're really ints
      // We need to convert that first before we return it
      List<RideType> types = List<RideType>();

      (jsonDecode(response.body) as Map).forEach((key, value) {
        types.add(RideType(id: int.parse(key), label: value));
      });

      types.sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

      // Unknown shall sit at the top
      types.insert(0, RideType(id: 0, label: ""));

      return types;
    }

    return null;
  }

  Future<int> submitAttractionData(BluehostAttraction attr, BluehostPark park,
      {String username, String uid, bool isNewAttraction = false}) async {
    // Status Calculations
    int activeStatus = attr.active ? 1 : 0;
    if (attr.upcoming) activeStatus = 2;

    // Date Calculations - if it's null, we replace it with 0000-00-00
    String formattedDateOpen = "0000-00-00";
    if (attr.openingDay != null) {
      formattedDateOpen = DateFormat("yyyy'-'MM'-'dd").format(attr.openingDay);
    }

    // Prepare payload
    var body = jsonEncode(({
      "parknum": park.id,
      "ride": attr.attractionName,
      "open": attr.yearOpen ?? 0,
      "dateOpen": formattedDateOpen,
      "close": attr.yearClosed ?? 0,
      "yearsInactive": (attr.inactivePeriods == null)
          ? ""
          : attr.inactivePeriods.join(
              ", "), // TODO - Switch to traditional semicolon line-breaks once iOS gets up to speed
      "type": attr.rideType?.id ?? 0,
      "park": park.parkName ?? "",
      "rideID": isNewAttraction ? 0 : attr.attractionID,
      "active": activeStatus,
      "seasonal": attr.seasonal ? 1 : 0,
      "manufacturer": attr.manufacturer ?? "",
      "manID": (attr.manufacturerID != null)
          ? (attr.manufacturerID < 0) ? 0 : attr.manufacturerID
          : 0,
      "notes": attr.notes ?? "",
      "modify": isNewAttraction ? 0 : 1,
      "scoreCard": attr.scoreCard ? 1 : 0,
      "formerNames":
          (attr.formerNames == null) ? "" : attr.formerNames.join(";"),
      "addContributors": (attr.additionalContributors == null)
          ? ""
          : attr.additionalContributors.join(";"),
      "model": attr.model ?? "",
      "model_id":
          (attr.modelID != null) ? (attr.modelID < 0) ? 0 : attr.modelID : 0,
      "inversions": attr.inversions ?? 0,
      "height": attr.height ?? 0,
      "dropHeight": attr.dropHeight ?? 0,
      "liftHeight": attr.liftHeight ?? 0,
      "maxSpeed": attr.maxSpeed ?? 0,
      "length": attr.length ?? 0,
      "duration": attr.attractionDuration ?? 0,
      "capacity": attr.capacity ?? 0,
      "email": username,
      "token": await _firebaseMessaging.getToken(),
      "userID": uid
    }));

    // Issue request
    return await http.post(_serverURLS[SubmissionType.ATTRACTION_NEW],
        body: body,
        headers: {"Content-Type": "application/json"}).then((response) {
      print("[${response.statusCode}]: ${response.body}");
      return response.statusCode;
    });
    // State result
  }

  Future<int> submitParkData(BluehostPark newPark,
      {String username, String uid}) async {
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

    return await http
        .post(_serverURLS[SubmissionType.PARK], body: json.encode(body))
        .then((response) {
      print("[${response.statusCode}]: ${response.body}");
      return response.statusCode;
    });
  }

  Future<int> submitAttractionImage(
      {int rideId,
      int parkId,
      String photoArtist,
      String rideName,
      String parkName}) async {
    var body = {
      "rideID": rideId,
      "parkID": parkId,
      "photoArtist": photoArtist,
      "rideName": rideName,
      "parkName": parkName
    };

    print(body);

    return await http
        .post(_serverURLS[SubmissionType.IMAGE], body: json.encode(body))
        .then((response) => response.statusCode);
  }

  /*
  Future<List<BluehostNews>> getNews(bool activeOnly) async {
    String args = activeOnly ? "?showOnlyActive=1" : "";

    final response = await http.get(_serverURLS[WebLocation.NEWS] + args);

    if (response.statusCode == 200) {
      List<dynamic> decoded = jsonDecode(response.body);
      for (int i = 0; i < decoded.length; i++) {}
    }
  }*/

  Future<List<Manufacturer>> getAllManufacturers() async {
    final List<Manufacturer> manufacturers = List<Manufacturer>();

    http.Response response =
        await http.get(_serverURLS[WebLocation.MANUFACTURERS]);

    if (response.statusCode == 200) {
      List<dynamic> decoded = jsonDecode(response.body);
      decoded.forEach((m) {
        Manufacturer manufacturer = Manufacturer.fromJson(m);
        if (manufacturer == null)
          return; // Something happened with the parsing of data, skip it
        _fixBluehostManufacturerText(manufacturer);
        manufacturers.add(manufacturer);
      });
    }

    manufacturers
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return manufacturers;
  }

  /// Returns all models belonging to a specific manufacturer ID
  Future<List<Model>> getAllModels(int manufacturerID) async {
    final List<Model> models = List<Model>();

    http.Response response = await http
        .get(_serverURLS[WebLocation.MODELS] + manufacturerID.toString());

    if (response.statusCode == 200) {
      List<dynamic> decoded = jsonDecode(response.body);

      decoded.forEach((m) {
        Model model = Model.fromJson(m);
        if (model == null) return; // Issue with model decoding
        models.add(model);
      });
    }

    models.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return models;
  }
}

String rosettaStoneDecode(String input,
    {bool insertAmpersands = true, bool insertSpaces = true}) {
  String result = input;
  if (insertAmpersands) result = result.replaceAll("!A?", "&");
  if (insertSpaces) result = result.replaceAll("_", " ");

  return result;
}

/// This is used to swap specific characters out that couldn't be used in standard web GET requests.
/// These characters were swapped by the original app during the submission process, which used
/// GET requests. These alternate characters were stored in the database. Now we
/// must filter them out for the text to be readable.
void _fixBluehostAttractionText(BluehostAttraction toFix) {
  if (toFix.attractionName != null)
    toFix.attractionName = rosettaStoneDecode(toFix.attractionName);
  if (toFix.manufacturer != null)
    toFix.manufacturer =
        rosettaStoneDecode(toFix.manufacturer, insertSpaces: false);
  return;
}

void _fixBluehostManufacturerText(Manufacturer toFix) {
  if (toFix.name != null) toFix.name = rosettaStoneDecode(toFix.name);
  if (toFix.country != null) toFix.country = rosettaStoneDecode(toFix.country);
  if (toFix.altName != null) toFix.altName = rosettaStoneDecode(toFix.altName);
  if (toFix.notes != null) toFix.notes = rosettaStoneDecode(toFix.notes);
  return;
}
