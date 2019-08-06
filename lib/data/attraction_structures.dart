import 'package:log_ride/data/ride_type_structures.dart';

class FirebaseAttraction {
  final int rideID;
  int numberOfTimesRidden = 0;
  DateTime firstRideDate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime lastRideDate = DateTime.fromMillisecondsSinceEpoch(0);

  // Note: This variable is NOT assigned or stored in the standard firebase map
  // This is from a different portion, and is managed by the attraction list
  // page's logic
  bool ignored = false;

  FirebaseAttraction({this.rideID});

  factory FirebaseAttraction.fromMap(Map<String, dynamic> map) {
    FirebaseAttraction newAttraction =
        FirebaseAttraction(rideID: map["rideID"]);
    newAttraction.numberOfTimesRidden = map["numberOfTimesRidden"] ?? 0;

    // DateTime is defined as seconds since epoch on iOS. It's milliseconds since epoch on flutter. We need to fix this, so we multiply by 1000
    newAttraction.firstRideDate = DateTime.fromMillisecondsSinceEpoch(
        ((map["firstRideDate"] as num) * 1000).toInt());
    newAttraction.lastRideDate = DateTime.fromMillisecondsSinceEpoch(
        ((map["lastRideDate"] as num) * 1000).toInt());

    return newAttraction;
  }

  Map toMap() {
    return {
      "rideID": this.rideID,
      "numberOfTimesRidden": this.numberOfTimesRidden,
      "firstRideDate": this.firstRideDate.millisecondsSinceEpoch /
          1000, // Again, milliseconds since epoch -> seconds since epoch
      "lastRideDate": this.lastRideDate.millisecondsSinceEpoch / 1000,
    };
  }
}

class BluehostAttraction {
  String attractionName;
  int attractionID;
  int parkID;
  int rideTypeID = 1;
  RideType rideType;
  int yearOpen;
  int yearClosed;
  List<String> inactivePeriods;
  bool active = true;
  bool upcoming = false;
  bool seasonal = false;
  bool scoreCard = false;
  String manufacturer;
  int manufacturerID;
  List<String> additionalContributors;
  List<String> formerNames;
  String model;
  int modelID;
  num height;
  num liftHeight;
  num dropHeight;
  num dropSpeed;
  num maxSpeed;
  num length;
  num attractionDuration;
  num capacity;
  num inversions;
  num cost;
  num previousParkID;
  String previousParkLabel = "";
  String photoArtist;
  String photoLink;
  String ccType;
  String attractionLink;
  List<num> sourceIDs;
  String modifyBy;
  String notes;
  DateTime lastUpdated;
  DateTime created;
  DateTime openingDay;
  DateTime closingDay;

  // This is established by the webfetcher using data taken from the server.
  // Note: this isn't from the same bluehost request as the rest of the
  // attraction data.
  String typeLabel;

  BluehostAttraction({this.attractionID});

  factory BluehostAttraction.fromJson(Map<String, dynamic> json) {
    BluehostAttraction newAttraction =
        BluehostAttraction(attractionID: num.parse(json["RideID"]));

    newAttraction.attractionName = json["Name"];
    newAttraction.parkID = num.parse(json["ParkID"]);
    newAttraction.rideTypeID = num.parse(json["RideType"]);
    newAttraction.yearOpen = num.parse(json["YearOpen"]);
    newAttraction.yearClosed = num.parse(json["YearClosed"]);

    // Add line breaks to additional contributors
    String formattedInactivePeriods = json["inactivePeriods"];
    String splitPattern;
    if (formattedInactivePeriods.contains(",")) {
      splitPattern = ", ";
    } else {
      splitPattern = ";";
    }
    newAttraction.inactivePeriods =
        (formattedInactivePeriods == null || formattedInactivePeriods == "")
            ? List<String>()
            : formattedInactivePeriods.split(splitPattern);

    if (json["Active"] == "1" || json["Active"] == "2") {
      newAttraction.active = true;

      if (json["Active"] == "2") {
        newAttraction.upcoming = true;
      }
    } else {
      newAttraction.active = false;
      newAttraction.upcoming = false;
    }

    if (json["dateClose"][0] != "0") {
      newAttraction.closingDay = DateTime.parse(json["dateClose"]);
    } else {
      newAttraction.closingDay = null;
    }

    if (json["dateOpen"][0] != "0") {
      newAttraction.openingDay = DateTime.parse(json["dateOpen"]);
    } else {
      newAttraction.openingDay = null;
    }

    newAttraction.seasonal = (json["Seasonal"] == "1");
    newAttraction.scoreCard = (json["ScoreCard"] == "1");
    newAttraction.manufacturer = json["Manufacturer"];
    newAttraction.manufacturerID = num.parse(json["manufacturer_id"]);

    // Add line breaks to additional contributors
    String formattedAdditionalContributors = json["additionalContributors"];
    newAttraction.additionalContributors =
        (formattedAdditionalContributors == null ||
                formattedAdditionalContributors == "")
            ? List<String>()
            : formattedAdditionalContributors.split(";");

    // Add line breaks to former names
    String formattedFormerNames = json["FormerNames"];
    newAttraction.formerNames =
        (formattedFormerNames == null || formattedFormerNames == "")
            ? List<String>()
            : formattedFormerNames.split(";");

    newAttraction.model = json["model"];
    newAttraction.modelID = num.parse(json["model_id"]);
    newAttraction.height = num.parse(json["height"]);
    newAttraction.liftHeight = num.parse(json["lift_height"]);
    newAttraction.dropHeight = num.parse(json["drop_height"]);
    newAttraction.maxSpeed = num.parse(json["maxSpeed"]);
    newAttraction.length = num.parse(json["length"]);
    newAttraction.attractionDuration = num.parse(json["attractionDuration"]);
    newAttraction.capacity = num.parse(json["capacity"]);
    newAttraction.inversions = num.parse(json["inversions"]);
    newAttraction.cost = num.parse(json["cost"]);
    newAttraction.previousParkID = num.parse(json["previousLocation"]);
    newAttraction.photoArtist = json["photoArtist"];
    newAttraction.photoLink = json["photoLink"];
    newAttraction.ccType = json["CCType"];
    newAttraction.attractionLink = json["attractionLink"];

    if (json["sourceIDs"] != "") {
      List<String> sourceIDStrings = json["sourceIDs"].toString().split(",");
      List<num> sourceIDInts = List<num>();
      sourceIDStrings.forEach((e) {
        sourceIDInts.add(num.parse(e));
      });
      newAttraction.sourceIDs = sourceIDInts;
    }

    newAttraction.modifyBy = json["modifyBy"];
    newAttraction.notes = json["Notes"];

    newAttraction.lastUpdated = DateTime.parse(json["DateTime_LastUpdated"]);
    newAttraction.created = DateTime.parse(json["DateTime_Created"]);

    return newAttraction;
  }

  factory BluehostAttraction.copy(BluehostAttraction attr) {
    BluehostAttraction newAttraction =
        BluehostAttraction(attractionID: attr.attractionID);

    newAttraction.attractionName = attr.attractionName;
    newAttraction.parkID = attr.parkID;
    newAttraction.rideTypeID = attr.rideTypeID;
    newAttraction.typeLabel = attr.typeLabel;
    newAttraction.rideType = attr.rideType;
    newAttraction.yearOpen = attr.yearOpen;
    newAttraction.yearClosed = attr.yearClosed;

    newAttraction.inactivePeriods = attr.inactivePeriods;

    newAttraction.active = attr.active;
    newAttraction.upcoming = attr.upcoming;

    newAttraction.closingDay = attr.closingDay;

    newAttraction.openingDay = attr.openingDay;

    newAttraction.seasonal = attr.seasonal;
    newAttraction.scoreCard = attr.scoreCard;
    newAttraction.manufacturer = attr.manufacturer;
    newAttraction.manufacturerID = attr.manufacturerID;

    newAttraction.additionalContributors = attr.additionalContributors;
    newAttraction.formerNames = attr.formerNames;

    newAttraction.model = attr.model;
    newAttraction.modelID = attr.modelID;
    newAttraction.height = attr.height;
    newAttraction.liftHeight = attr.liftHeight;
    newAttraction.dropHeight = attr.dropHeight;
    newAttraction.maxSpeed = attr.maxSpeed;
    newAttraction.length = attr.length;
    newAttraction.attractionDuration = attr.attractionDuration;
    newAttraction.capacity = attr.capacity;
    newAttraction.inversions = attr.inversions;
    newAttraction.cost = attr.cost;
    newAttraction.previousParkID = attr.previousParkID;
    newAttraction.photoArtist = attr.photoArtist;
    newAttraction.photoLink = attr.photoLink;
    newAttraction.ccType = attr.ccType;
    newAttraction.attractionLink = attr.attractionLink;

    newAttraction.sourceIDs = attr.sourceIDs;

    newAttraction.modifyBy = attr.modifyBy;
    newAttraction.notes = attr.notes;

    newAttraction.lastUpdated = attr.lastUpdated;
    newAttraction.created = attr.created;

    return newAttraction;
  }

  FirebaseAttraction toNewFirebaseAttraction() {
    FirebaseAttraction newAttraction =
        FirebaseAttraction(rideID: this.attractionID);
    return newAttraction;
  }
}

class AttractionBundle {
  AttractionBundle({this.firebase, this.bluehost, this.parkName});
  FirebaseAttraction firebase;
  BluehostAttraction bluehost;
  String parkName;
}

FirebaseAttraction getFirebaseAttractionFromList(
    List<FirebaseAttraction> toSearch, int attractionID) {
  for (int i = 0; i < toSearch.length; i++) {
    if (toSearch[i].rideID == attractionID) return toSearch[i];
  }
  return null;
}

BluehostAttraction getBluehostAttractionFromList(
    List<BluehostAttraction> toSearch, int attractionID) {
  for (int i = 0; i < toSearch.length; i++) {
    if (toSearch[i].attractionID == attractionID) return toSearch[i];
  }
  return null;
}
