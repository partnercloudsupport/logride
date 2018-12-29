import 'attraction_structures.dart';
import 'package:latlong/latlong.dart';

class Park {
  FirebasePark userData;
  BluehostPark serverData;

  List<Attraction> attractions;
}

class FirebasePark {
  bool checkedInToday = false;
  bool favorite = false;
  bool incrementorEnabled = false;
  DateTime lastDayVisited = DateTime.fromMillisecondsSinceEpoch(0);
  String location = "";
  String name = "";
  int numberOfCheckIns = 0;
  final int parkID;
  int ridesRidden = 0;
  bool showDefunct = false;
  int totalRides = 0;

  FirebasePark({this.parkID, this.name, this.location});

  factory FirebasePark.fromMap(Map<String, dynamic> data){
    FirebasePark newPark = FirebasePark(parkID: data["parkID"]);
    newPark.checkedInToday = data["checkedInToday"];
    newPark.favorite = data["favorite"];
    newPark.incrementorEnabled = data["incrementorEnabled"];
    newPark.lastDayVisited = DateTime.fromMicrosecondsSinceEpoch(data["lastDayVisited"]);
    newPark.location = data["location"];
    newPark.name = data["name"];
    newPark.numberOfCheckIns = data["numberOfCheckIns"];
    newPark.ridesRidden = data["ridesRidden"];
    newPark.showDefunct = data["showDefunct"];
    newPark.totalRides = data["totalRides"];
    return newPark;
  }

  Map toMap(){
    return {
      "parkID": this.parkID,
      "checkedInToday": this.checkedInToday,
      "favorite": this.favorite,
      "incrementorEnabled": this.incrementorEnabled,
      "lastDayVisited": this.lastDayVisited.millisecondsSinceEpoch,
      "location": this.location,
      "name": this.name,
      "numberOfCheckIns": this.numberOfCheckIns,
      "ridesRidden": this.ridesRidden,
      "showDefunct": this.showDefunct,
      "totalRides": this.totalRides
    };
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

  bool filled = false; // Used to document whether data has been filled for it or not


  BluehostPark({this.id});

  factory BluehostPark.fromJson(Map<String, dynamic> json) {
    BluehostPark newParkData = BluehostPark(id: num.parse(json["id"]));

    newParkData.parkName = json["Name"];
    newParkData.parkCity = json["City"];
    newParkData.parkCountry = json["Country"];
    newParkData.active = bool.fromEnvironment(json["Active"]);
    newParkData.yearOpen = num.parse(json["YearOpen"]);
    newParkData.yearClosed = num.parse(json["YearClosed"]);
    newParkData.location = LatLng(num.parse(json["Latitude"]), num.parse(json["Longitude"]));
    newParkData.previousNames = json["PreviousNames"];
    newParkData.type = json["Type"];
    newParkData.seasonal = bool.fromEnvironment(json["Seasonal"]);
    newParkData.website = json["website"];
    newParkData.username = json["userName"];
    newParkData.created = DateTime.parse(json["DateTime_Created"]);
    newParkData.lastUpdated = DateTime.parse(json["DateTime_LastUpdated"]);

    return newParkData;
  }

  FirebasePark toNewFirebaseEntry(){
    FirebasePark newPark = FirebasePark(parkID: this.id, name: this.parkName, location: this.parkCity);
    return newPark;
  }
}

/// Returns the [BluehostPark] which matches the provided [idToSearchFor].
/// Returns null if target is not present
BluehostPark getBluehostParkByID(List<BluehostPark> listToSearch, num idToSearchFor){
  for(int i = 0; i < listToSearch.length; i++){
    if(listToSearch[i].id == idToSearchFor) {
      return listToSearch[i];
    }
  }
  // No park found by that ID, returning null
  return null;
}

/// Returns the [FirebasePark] which matches the provided id.
/// Returns null if target is not present
FirebasePark getFirebasePark(List<FirebasePark> listToSearch, num idToSearchFor){
  for(int i = 0; i< listToSearch.length; i++){
    if(listToSearch[i].parkID == idToSearchFor) {
      return listToSearch[i];
    }
  }

  return null;
}

/// Returns the number of favorite parks inside the list to search
int countFavoriteParks(List<FirebasePark> listToSearch){
  int numFaves = 0;
  for(int i = 0; i < listToSearch.length; i++){
    if(listToSearch[i].favorite) numFaves++;
  }
  return numFaves;
}
