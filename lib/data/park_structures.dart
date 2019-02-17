import 'package:latlong/latlong.dart';
import 'package:log_ride/data/attraction_structures.dart';

class FirebasePark {
  bool checkedInToday = false;
  bool favorite = false;
  bool incrementorEnabled = false;
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
    FirebasePark newPark = FirebasePark(parkID: data["parkID"]);
    newPark.checkedInToday = data["checkedInToday"];
    newPark.favorite = data["favorite"];
    newPark.incrementorEnabled = data["incrementorEnabled"];
    newPark.lastDayVisited = DateTime.fromMillisecondsSinceEpoch(
        ((data["lastDayVisited"] as num).toDouble() * 1000).toInt());
    newPark.location = data["location"];
    newPark.name = data["name"];
    newPark.numberOfCheckIns = data["numberOfCheckIns"];
    newPark.ridesRidden = data["ridesRidden"];
    newPark.numDefunctRidden = data["defunctRidden"] ?? 0;
    newPark.numSeasonalRidden = data["seasonalRidden"] ?? 0;
    newPark.showDefunct = data["showDefunct"];
    newPark.showSeasonal = data["showSeasonal"] ?? false;
    newPark.totalRides = data["totalRides"];
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

/// Returns the number of favorite parks inside the list to search
int countFavoriteParks(List<FirebasePark> listToSearch) {
  int numFaves = 0;
  for (int i = 0; i < listToSearch.length; i++) {
    if (listToSearch[i].favorite) numFaves++;
  }
  return numFaves;
}
