import '../data/fbdb_manager.dart';
import '../data/park_structures.dart';
import '../data/attraction_structures.dart';
import '../data/webfetcher.dart';
import 'dart:convert';

class ParksManager {
  ParksManager({this.db, this.wf});

  final BaseDB db;
  final WebFetcher wf;

  List<BluehostPark> allParksInfo;
  Map<int, String> attractionTypes;
  //List<Park> userParks; // Display lists are managed by FirebaseAnimatedLists, but we keep track of its contents on our own, too.

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
    await db.getEntryAtPath(path: DatabasePath.PARKS, key: "").then((snap) async {
      Map<dynamic, dynamic> values = jsonDecode(jsonEncode(snap));
      for (int i = 0; i < values.keys.length; i++) {
        int entryID = num.parse(values.keys.elementAt(i));
        BluehostPark targetPark = getBluehostParkByID(allParksInfo, entryID);

        targetPark.attractions = await wf.getAllAttractionData(
            parkID: targetPark.id, rideTypes: attractionTypes);
        targetPark.filled = true;
      }
    });

    print("ParksManager has been initialized");
    return true;
  }

  void addParkToUser(num targetParkID) async {
    // Find if we already have the park
    bool exists = await db.doesEntryExistAtPath(
        path: DatabasePath.PARKS, key: targetParkID.toString());
    if (exists) return; // If the park is already there, ignore it

    // Get our targeted park, calculate ride
    BluehostPark targetPark = getBluehostParkByID(allParksInfo, targetParkID);
    targetPark.attractions =
        await wf.getAllAttractionData(parkID: targetParkID, rideTypes: attractionTypes);

    FirebasePark translated = targetPark.toNewFirebaseEntry();

    translated.updateAttractionCount(targetPark: targetPark);

    // Push the translated park into the database
    db.setEntryAtPath(
        path: DatabasePath.PARKS,
        key: targetParkID.toString(),
        payload: translated.toMap());
  }

  void removeParkFromUserData(num targetID) async {
    // Very simple. Just deleting the entry entirely.
    db.removeEntryFromPath(path: DatabasePath.PARKS, key: targetID.toString());
    // And remove the 'filled' tag from the appropriate bluehost park
    getBluehostParkByID(allParksInfo, targetID).filled = false;
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
}
