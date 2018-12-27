import 'attraction_structures.dart';
import 'package:latlong/latlong.dart';

class BasicPark {
  final int parkID;
  String name;
  String location;
  bool checkedInToday;
  bool favorite;
  bool incrementorEnabled;
  DateTime lastDayVisited;
  int numberOfCheckIns;
  int ridesRidden;
  bool showDefunct;
  int totalRides;

  BasicPark({this.parkID});

  factory BasicPark.fromJson(Map<String, dynamic> json){
    BasicPark newPark = BasicPark(parkID: json["parkID"]);
    newPark.name = json["name"];
    newPark.location = json["location"];
    newPark.checkedInToday = json["checkedInToday"];
    newPark.favorite = json["favorite"];
    newPark.incrementorEnabled = json["incrementorEnabled"];
    newPark.lastDayVisited = DateTime.fromMillisecondsSinceEpoch(json["lastDayVisited"]);
    newPark.numberOfCheckIns = json["numberOfCheckIns"];
    newPark.ridesRidden = json["ridesRidden"];
    newPark.showDefunct = json["showDefunct"];
    newPark.totalRides = json["totalRides"];
    return newPark;
  }

  Map<String, dynamic> toMap(){
    return {
      "parkID": this.parkID,
      "name": this.name,
      "location": this.location,
      "checkedInToday": this.checkedInToday,
      "favorite": this.favorite,
      "incrementorEnabled": this.incrementorEnabled,
      "lastDayVisited": this.lastDayVisited.millisecondsSinceEpoch,
      "numberOfCheckIns": this.numberOfCheckIns,
      "ridesRidden": this.ridesRidden,
      "showDefunct": this.showDefunct,
      "totalRides": this.totalRides
    };
  }
}

/// Used to hold data pertaining to parks
class ParkData {
  final num parkID;
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

  num numAttractions = 0;
  num numDefunct = 0;
  num numRidden = 0;
  List<Attraction> attractions;

  bool favorite = false;

  ParkData({
      this.parkID});

  factory ParkData.fromJson(Map<String, dynamic> json) {
    ParkData newParkData = ParkData(parkID: num.parse(json["id"]));

    newParkData.parkName = json["Name"];
    newParkData.parkCity = json["City"];
    newParkData.parkCountry = json["Country"];
    newParkData.active = (json["Active"] == "1");
    newParkData.yearOpen = num.parse(json["YearOpen"]);
    newParkData.yearClosed = num.parse(json["YearClosed"]);
    newParkData.location = LatLng(num.parse(json["Latitude"]), num.parse(json["Longitude"]));
    newParkData.previousNames = json["PreviousNames"];
    newParkData.type = json["Type"];
    newParkData.seasonal = (json["Seasonal"] == "1") ?? false;
    newParkData.website = json["website"];
    newParkData.username = json["userName"];
    newParkData.created = DateTime.parse(json["DateTime_Created"]);
    newParkData.lastUpdated = DateTime.parse(json["DateTime_LastUpdated"]);

    newParkData.filled = true; // Yup, we've filled the data

    return newParkData;
  }

  /// Resets all values to initial, excluding identifying information like name, id, and city
  void reset(){
    parkCountry = null;
    active = null;
    yearOpen = null;
    yearClosed = null;
    location = null;
    previousNames = null;
    type = null;
    seasonal = null;
    website = null;
    username = null;
    created = null;
    lastUpdated = null;
    attractions = null;
    filled = false;
    numAttractions = 0;
    numDefunct = 0;
    numRidden = 0;
  }
}

/// Returns the [ParkData] which matches the provided [idToSearchFor].
/// Returns null if target is not present
ParkData getParkByID(List<ParkData> listToSearch, num idToSearchFor){
  for(int i = 0; i < listToSearch.length; i++){
    if(listToSearch[i].parkID == idToSearchFor) {
      return listToSearch[i];
    }
  }
  // No park found by that ID, returning null
  return null;
}

/// Returns the number of favorite parks inside the list to search
int countFavoriteParks(List<ParkData> listToSearch){
  int numFaves = 0;
  for(int i = 0; i < listToSearch.length; i++){
    if(listToSearch[i].favorite) numFaves++;
  }
  return numFaves;
}
