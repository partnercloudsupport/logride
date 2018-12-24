class Attraction {
  String attractionName;
  final int attractionID;
  int parkID;
  int rideType;
  int yearOpen;
  int yearClosed;
  bool active;
  bool scoreCard;
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
  String photoArtist;
  String photoLink;
  String ccType;
  String attractionLink;
  List<num> sourceIDs;
  String modifyBy;
  String notes;
  DateTime lastUpdated;
  DateTime created;

  num timesExperienced;
  List<num> scores;

  Attraction({this.attractionID});

  factory Attraction.fromJson(Map<String, dynamic> json){

    Attraction newAttraction = Attraction(attractionID: num.parse(json["RideID"]));

    newAttraction.attractionName = json["Name"];
    newAttraction.parkID = num.parse(json["ParkID"]);
    newAttraction.rideType = num.parse(json["RideType"]);
    newAttraction.yearOpen = num.parse(json["YearOpen"]);
    newAttraction.yearClosed = num.parse(json["YearClosed"]);

    newAttraction.active = (json["Active"] == "1");
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

    if(json["sourceIDs"] != ""){
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
}