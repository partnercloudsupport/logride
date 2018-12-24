import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'park_structures.dart';
import 'attraction_structures.dart';

/// getWebData returns a list containing all the park data that I can currently
///  access from the single link I have.
Future<List<ParkData>> getSimpleParkData() async {
  // Establish retrieval of data - code will async hang until this is good
  final response = await http.get(
      'http://www.beingpositioned.com/theparksman/parksdbservice.php');

  // Establish data variables
  List<ParkData> data = new List<ParkData>();

  // Handle response
  if (response.statusCode == 200) {
    // JSON.decode returns dynamic, but we expect a list of dynamic stuff
    List<dynamic> decoded = json.decode(response.body);

    // We get from the url list of map<string, dynamic>. Iterate and create here
    for (int i = 0; i < decoded.length; i++) {
      data.add(ParkData.fromJson(decoded[i]));
      data[i].filled = false;
    }
    return data;
  } else {
    throw Exception("failed to load data");
  }
}

Future<List<ParkData>> getFullParkData(List<num> visitedParkIDs, List<ParkData> allSimpleParks) async {
  List<ParkData> builtData = List<ParkData>();


  for(int i = 0; i < visitedParkIDs.length; i++){
    ParkData toBuild = getParkByID(allSimpleParks, visitedParkIDs[i]);
    await populateParkData(toBuild);
    builtData.add(toBuild);
  }

  return builtData;
}

/// Gets all web data used at initialization. Returns a map with two keys,
/// "global" - all parks, does not include information on attractions
/// "visited" - all parks the user has visited, includes attraction info
Future<Map<String, dynamic>> fetchInitialWebData() async {
  // Fetch from global list first
  List<ParkData> simpleGlobal = await getSimpleParkData();

  // Fetch from firebase
  // TODO: IMPLEMENT FIREBASE - INIT DATA FETCH
  print("THOMAS: IMPLEMENT FIREBASE WHEN LOADING INIT STUFF.");
  print("USING TEMP VARIABLES UNTIL FIREBASE IS IMPLEMENTED.");
  List<num> favoriteParkIds = []; // [33, 59, 69, 138, 178];
  List<num> visitedParkIds = [];//[33, 45, 51, 59, 69, 75, 83, 138, 178];

  // Fetch information pertaining to the user's visited parks.
  List<ParkData> visitedParks = List<ParkData>();
  visitedParks = await getFullParkData(visitedParkIds, simpleGlobal);

  // Assign 'favourite' status to the user's parks
  for(int i = 0; i < favoriteParkIds.length; i++){
    getParkByID(visitedParks, favoriteParkIds[i]).favorite = true;
  }

  // Set attraction counts as appropriate for each attraction from web
  // TODO: IMPLEMENT FIREBASE - Get attraction experience counts

  return {
    "global": simpleGlobal,
    "visited": visitedParks
  };
}

Future populateParkData(ParkData park) async{

  final String baseURL = "http://www.beingpositioned.com/theparksman/attractiondbservice.php?parkid=";

  final response = await http.get(baseURL + park.parkID.toString());
  if(response.statusCode == 200){
    List<Attraction> parkAttractions = List<Attraction>();
    List<dynamic> decoded = json.decode(response.body);

    int j;
    for(j = 0; j < decoded.length; j++){
      parkAttractions.add(Attraction.fromJson(decoded[j]));
      if(!parkAttractions[j].active){
        park.numDefunct++;
      }
    }

    park.attractions = parkAttractions;
    park.numAttractions = j;
  }
}