import 'dart:async';
import 'dart:convert';
import 'package:log_ride/data/attraction_structures.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';
import 'package:log_ride/data/webfetcher.dart';

class ParksManager {
  ParksManager({this.db, this.wf});

  final BaseDB db;
  final WebFetcher wf;

  List<BluehostPark> allParksInfo;
  Map<int, String> attractionTypes;

  bool searchInitialized = false;

  /// init returns true once all web data has been fetched for parks
  Future<bool> init() async {
    // Things to do:
    // Get allParks from bluehost
    allParksInfo = await wf.getAllParkData();

    // Since we're relying on this for the attraction building, we'll wait for
    // you too.
    attractionTypes = await wf.getAttractionTypesMap();

    // Go through and set-up the allParksInfo to match the user database.
    // The 'filled' tag is used in the all-parks-search to show the user they
    // have that park.
    db.getEntryAtPath(path: DatabasePath.PARKS, key: "").then((snap) async {
      if (snap == null) {
        print("User has no data currently. Returning.");
        searchInitialized = true;
        return;
      }
      Map<dynamic, dynamic> values = jsonDecode(jsonEncode(snap));
      for (int i = 0; i < values.keys.length; i++) {
        int entryID = num.parse(values.keys.elementAt(i));
        BluehostPark targetPark = getBluehostParkByID(allParksInfo, entryID);

        // This part appears to take the longest. I'm going to let it run async
        // And just prevent the user from viewing the attraction page until
        // the attractions != null
        wf
            .getAllAttractionData(
                parkID: targetPark.id, rideTypes: attractionTypes, allParks: allParksInfo)
            .then((list) {
          targetPark.attractions = list;
        });
        targetPark.filled = true;
      }
      searchInitialized = true;
    });

    print("ParksManager has been initialized");
    return true;
  }

  Future<bool> addParkToUser(num targetParkID) async {
    // Find if we already have the park
    bool exists = await db.doesEntryExistAtPath(
        path: DatabasePath.PARKS, key: targetParkID.toString());
    if (exists) return false; // If the park is already there, ignore it

    print("Adding a new park to our user.");

    // Get our targeted park, calculate ride
    BluehostPark targetPark = getBluehostParkByID(allParksInfo, targetParkID);
    targetPark.attractions = await wf.getAllAttractionData(
        parkID: targetParkID, rideTypes: attractionTypes, allParks: allParksInfo);

    print("We are adding ${targetPark.parkName} to our user");

    FirebasePark translated = targetPark.toNewFirebaseEntry();

    if(!targetPark.active) {
      // If a park is defunct, show defunct attractions since all attractions will be defunct
      translated.showDefunct = true;
      print("This park is defunct, so we've enabled showDefunct by default.");
    }

    translated.updateAttractionCount(targetPark: targetPark);

    // Push the translated park into the database
    db.setEntryAtPath(
        path: DatabasePath.PARKS,
        key: targetParkID.toString(),
        payload: translated.toMap());

    print("Park added successfully");

    return true;
  }

  void removeParkFromUserData(num targetID) async {
    // Very simple. Just deleting the entry entirely.
    db.removeEntryFromPath(path: DatabasePath.PARKS, key: targetID.toString());
    // And remove the 'filled' tag from the appropriate bluehost park
    getBluehostParkByID(allParksInfo, targetID).filled = false;
    // And remove the attraction data for the user's parks
    db.removeEntryFromPath(path: DatabasePath.ATTRACTIONS, key: targetID.toString());
    // And remove ignored data for the user's parks
    db.removeEntryFromPath(path: DatabasePath.IGNORE, key: targetID.toString());
  }

  void addParkToFavorites(num targetID) async {
    // Check to see if we're already in favorites
    bool isInFavorites = await db.getEntryAtPath(
        path: DatabasePath.PARKS, key: targetID.toString() + "/favorite");
    if (isInFavorites) return;

    // We need to set the park's favorite flag
    db.setEntryAtPath(
        path: DatabasePath.PARKS,
        key: targetID.toString() + "/favorite",
        payload: true);
  }

  void removeParkFromFavorites(num targetID) async {
    // Check to see if we're actually in favorites
    bool isInFavorites = (await db.getEntryAtPath(
        path: DatabasePath.PARKS, key: targetID.toString() + "/favorite"));
    if (!isInFavorites) return;

    // Set the favorite flag for the park
    db.setEntryAtPath(
        path: DatabasePath.PARKS,
        key: targetID.toString() + "/favorite",
        payload: false);
  }

  void updateAttractionCount(
      FirebasePark targetFBPark,
      List<int> ignoredAttractionIDs,
      List<FirebaseAttraction> userAttractionData) {
    BluehostPark targetBHPark =
        getBluehostParkByID(allParksInfo, targetFBPark.parkID);
    targetFBPark.updateAttractionCount(
        targetPark: targetBHPark,
        userData: userAttractionData,
        ignored: ignoredAttractionIDs);

    db.updateEntryAtPath(
        path: DatabasePath.PARKS,
        key: targetFBPark.parkID.toString(),
        payload: targetFBPark.toMap());
  }
}
