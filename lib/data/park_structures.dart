import 'package:latlong/latlong.dart';
import 'package:log_ride/data/attraction_structures.dart';

class FirebasePark {
  bool checkedInToday = false;
  bool favorite = false;
  bool incrementorEnabled = true;

  /// inFavorites is used in the parksList to determine the location of the list
  /// entry (is this park listed in the favorites section?)
  bool inFavorites = false;

  DateTime lastDayVisited = DateTime.fromMillisecondsSinceEpoch(0);
  String location = "";
  String name = "";
  int numberOfCheckIns = 0;
  int numDefunctRidden = 0;
  int numSeasonalRidden = 0;
  final int parkID;
  int ridesRidden = 0;
  bool showDefunct = true;
  bool showSeasonal = true;
  int totalRides = 0;

  FirebasePark({this.parkID, this.name, this.location});

  factory FirebasePark.fromMap(Map<String, dynamic> data) {
    // Bringing this math out here prevents issues when parks have nothing for their data
    num lastDayVisitedTime = (data["lastDayVisited"] as num ?? 0);
    lastDayVisitedTime *= 1000;
    lastDayVisitedTime = lastDayVisitedTime.toInt();


    FirebasePark newPark = FirebasePark(parkID: data["parkID"]);
    newPark.checkedInToday = data["checkedInToday"] ?? false;
    newPark.favorite = data["favorite"] ?? false;
    newPark.incrementorEnabled = data["incrementorEnabled"] ?? false;
    newPark.lastDayVisited = DateTime.fromMillisecondsSinceEpoch(lastDayVisitedTime);
    newPark.location = data["location"] ?? "";
    newPark.name = data["name"] ?? "";
    newPark.numberOfCheckIns = data["numberOfCheckIns"] ?? 0;
    newPark.ridesRidden = data["ridesRidden"] ?? 0;
    newPark.numDefunctRidden = data["defunctRidden"] ?? 0;
    newPark.numSeasonalRidden = data["seasonalRidden"] ?? 0;
    newPark.showDefunct = data["showDefunct"] ?? true;
    newPark.showSeasonal = data["showSeasonal"] ?? true;
    newPark.totalRides = data["totalRides"] ?? 0;
    return newPark;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "parkID": this.parkID,
      "checkedInToday": this.checkedInToday,
      "favorite": this.favorite,
      "incrementorEnabled": this.incrementorEnabled,
      "lastDayVisited": (this.lastDayVisited.millisecondsSinceEpoch / 1000.0),
      "location": this.location,
      "name": this.name,
      "numberOfCheckIns": this.numberOfCheckIns,
      "ridesRidden": this.ridesRidden,
      "defunctRidden": this.numDefunctRidden,
      "seasonalRidden": this.numSeasonalRidden,
      "showDefunct": this.showDefunct,
      "showSeasonal": this.showSeasonal,
      "totalRides": this.totalRides
    };
  }

  @override
  String toString() {
    return "[[PARK] id: $parkID, name: $name]";
  }

  void updateAttractionCount(
      {BluehostPark targetPark,
      List<FirebaseAttraction> userData,
      List<int> ignored}) {
    if (targetPark == null) {
      this.numDefunctRidden = 0;
      this.numSeasonalRidden = 0;
      this.ridesRidden = 0;
      this.totalRides = 0;
      return;
    }
    // Create an empty list so the search doesn't fail
    if (userData == null) userData = List<FirebaseAttraction>();
    if (ignored == null) ignored = List<int>();

    int numAttractions = 0;
    int numRidden = 0;
    int numDefunctRidden = 0;
    int numSeasonalRidden = 0;

    for (int i = 0; i < targetPark.attractions.length; i++) {
      BluehostAttraction serverAttraction = targetPark.attractions[i];
      FirebaseAttraction userAttraction = getFirebaseAttractionFromList(
          userData, serverAttraction.attractionID);

      // If it's ignored, it doesn't contribute to total ride count
      if (ignored.contains(serverAttraction.attractionID)) continue;

      // It's effectively ignored too if it's an upcoming attraction
      if (serverAttraction.upcoming) continue;

      // If it's defunct, it only adds to the defunct count if it's been ridden
      if (!serverAttraction.active) {
        // If the park is defunct, add the defunct attraction to the total number of attractions
        if (!targetPark.active) {
          numAttractions++;
        }

        if ((userAttraction?.numberOfTimesRidden ?? -1) > 0) {
          numDefunctRidden++;
        }
        continue;
      }

      if (serverAttraction.seasonal) {
        if ((userAttraction?.numberOfTimesRidden ?? -1) > 0) {
          numSeasonalRidden++;
        }
        continue;
      }

      // Add to the total count, but only add to the ridden count if it's actually been ridden
      numAttractions++;
      if ((userAttraction?.numberOfTimesRidden ?? -1) > 0) numRidden++;
    }

    this.numDefunctRidden = numDefunctRidden;
    this.numSeasonalRidden = numSeasonalRidden;
    this.ridesRidden = numRidden;
    this.totalRides = numAttractions;

    if (!targetPark.active) {
      this.ridesRidden = numDefunctRidden;
    }

    // Parks names can update in the bluehost - we need to make sure we update the
    // firebase ones to match
    this.name = targetPark.parkName;
    this.location = targetPark.parkCity;
  }
}

/// Used to hold data pertaining to parks
class BluehostPark {
  final num id;
  String parkName;
  String parkCity;
  String parkCountry;
  String initials;
  bool active;
  num yearOpen;
  num yearClosed;
  LatLng location;
  String previousNames;
  String type;
  bool seasonal;
  String website;
  String username;
  DateTime created;
  DateTime lastUpdated;

  bool filled =
      false; // Used to document whether data has been filled for it or not

  List<BluehostAttraction> attractions;

  BluehostPark({this.id});

  factory BluehostPark.fromJson(Map<String, dynamic> json) {
    BluehostPark newParkData = BluehostPark(id: num.parse(json["id"]));

    newParkData.parkName = json["Name"];
    newParkData.parkCity = json["City"];
    newParkData.parkCountry = json["Country"];
    newParkData.active = (json["Active"] == "1");
    newParkData.yearOpen = num.parse(json["YearOpen"]);
    newParkData.yearClosed = num.parse(json["YearClosed"]);
    newParkData.location =
        LatLng(num.parse(json["Latitude"]), num.parse(json["Longitude"]));
    newParkData.previousNames = json["PreviousNames"];
    newParkData.type = json["Type"];
    newParkData.seasonal = (json["Seasonal"] == "1");
    newParkData.website = json["website"];
    newParkData.username = json["userName"];
    newParkData.created = DateTime.parse(json["DateTime_Created"]);
    newParkData.lastUpdated = DateTime.parse(json["DateTime_LastUpdated"]);

    newParkData.initials = "";
    newParkData.parkName.split(" ").forEach((String word) {
      // Prevent improper names from crashing the app
      if(word.length == 0 || word == null){
        return;
      }
      newParkData.initials += word[0];
    });

    newParkData.initials = newParkData.initials.replaceAll(RegExp("[^a-zA-Z]"), "");
    // Single letter initials are removed.
    if(newParkData.initials.length <= 1) {
      newParkData.initials = "";
    }

    return newParkData;
  }

  FirebasePark toNewFirebaseEntry() {
    FirebasePark newPark = FirebasePark(
        parkID: this.id, name: this.parkName, location: this.parkCity);
    return newPark;
  }
}

/// Returns the [BluehostPark] which matches the provided [idToSearchFor].
/// Returns null if target is not present
BluehostPark getBluehostParkByID(
    List<BluehostPark> listToSearch, num idToSearchFor) {
  for (int i = 0; i < listToSearch.length; i++) {
    if (listToSearch[i].id == idToSearchFor) {
      return listToSearch[i];
    }
  }
  // No park found by that ID, returning null
  return null;
}

/// Returns the [FirebasePark] which matches the provided id.
/// Returns null if target is not present
FirebasePark getFirebasePark(
    List<FirebasePark> listToSearch, num idToSearchFor) {
  for (int i = 0; i < listToSearch.length; i++) {
    if (listToSearch[i].parkID == idToSearchFor) {
      return listToSearch[i];
    }
  }

  return null;
}

/// Returns the index of the park that matches the given id.
/// Returns -1 if it cannot be found.
int getFirebaseParkIndex(List<FirebasePark> listToSearch, num idToSearchFor) {
  for (int i = 0; i < listToSearch.length; i++){
    if(listToSearch[i] == null) continue;
    if(listToSearch[i].parkID == idToSearchFor){
      return i;
    }
  }

  return -1;
}

/// Returns the number of favorite parks inside the list to search
int countFavoriteParks(List<FirebasePark> listToSearch) {
  int numFaves = 0;
  for (int i = 0; i < listToSearch.length; i++) {
    if (listToSearch[i].favorite) numFaves++;
  }
  return numFaves;
}
