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
  int rideType = 1;
  int yearOpen;
  int yearClosed;
  String inactivePeriods;
  bool active = true;
  bool upcoming = false;
  bool seasonal = false;
  bool scoreCard = false;
  String manufacturer;
  String additionalContributors;
  String formerNames;
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
    newAttraction.rideType = num.parse(json["RideType"]);
    newAttraction.yearOpen = num.parse(json["YearOpen"]);
    newAttraction.yearClosed = num.parse(json["YearClosed"]);
    newAttraction.inactivePeriods = json["inactivePeriods"];

    if (json["Active"] == "1" || json["Active"] == "2") {
      newAttraction.active = true;

      if (json["Active"] == "2") {
        newAttraction.upcoming = true;
      }
    } else {
      newAttraction.active = false;
      newAttraction.upcoming = false;
    }

    if(json["dateClose"][0] != "0"){
      newAttraction.closingDay = DateTime.parse(json["dateClose"]);
    } else {
      newAttraction.closingDay = null;
    }

    if(json["dateOpen"][0] != "0"){
      newAttraction.openingDay = DateTime.parse(json["dateOpen"]);
    } else {
      newAttraction.openingDay = null;
    }

    newAttraction.seasonal = (json["Seasonal"] == "1");
    newAttraction.scoreCard = (json["ScoreCard"] == "1");
    newAttraction.manufacturer = json["Manufacturer"];
    newAttraction.additionalContributors = json["additionalContributors"];
    newAttraction.formerNames = json["FormerNames"];
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

  FirebaseAttraction toNewFirebaseAttraction() {
    FirebaseAttraction newAttraction =
        FirebaseAttraction(rideID: this.attractionID);
    return newAttraction;
  }
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
