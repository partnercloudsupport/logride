import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
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

  ParksManagerStream _streamController = ParksManagerStream();
  Stream<ParksManagerEvent> parksManagerStream;

  void init() {
    parksManagerStream = _streamController.stream;
    asyncInit();
  }

  /// init returns true once all web data has been fetched for parks
  Future<bool> asyncInit() async {
    // Things to do:
    // Get allParks from bluehost
    allParksInfo = await wf.getAllParkData();

    // Since we're relying on this for the attraction building, we'll wait for
    // you too.
    attractionTypes = await wf.getAttractionTypesMap();

    // Go through and set-up the allParksInfo to match the user database.
    // The 'filled' tag is used in the all-parks-search to show the user they
    // have that park.
    List<Future<bool>> parkFutures = <Future<bool>>[];
    db.getEntryAtPath(path: DatabasePath.PARKS, key: "").then((snap) async {
      if (snap == null) {
        print("User has no data currently. Returning.");
        _streamController
            .add(ParksManagerEvent(ParksManagerEventType.INITIALIZED));
        return;
      }

      Map<dynamic, dynamic> values = jsonDecode(jsonEncode(snap));
      for (int i = 0; i < values.keys.length; i++) {
        int entryID = num.tryParse(values.keys.elementAt(i));
        if (entryID == null) {
          print(
              "ERROR: Key value at index $i for adding user's attractions is not a number");
          continue;
        }
        BluehostPark targetPark = getBluehostParkByID(allParksInfo, entryID);

        // This part appears to take the longest. I'm going to let it run async
        // And just prevent the user from viewing the attraction page until
        // the attractions != null
        parkFutures.add(wf
            .getAllAttractionData(
                parkID: targetPark.id,
                rideTypes: attractionTypes,
                allParks: allParksInfo)
            .then((list) {
          targetPark.attractions = list;
          print("Park Loaded, id: ${targetPark.id}");
          return true;
        }));
        targetPark.filled = true;
      }

      Stream joinedStream = Stream.fromFutures(parkFutures);
      joinedStream.listen((d) {}, onDone: () {
        _streamController
            .add(ParksManagerEvent(ParksManagerEventType.ATTRACTIONS_FETCHED));
        _streamController
            .add(ParksManagerEvent(ParksManagerEventType.INITIALIZED));
      });
    });

    _streamController
        .add(ParksManagerEvent(ParksManagerEventType.PARKS_FETCHED));
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
        parkID: targetParkID,
        rideTypes: attractionTypes,
        allParks: allParksInfo);

    print("We are adding ${targetPark.parkName} to our user");

    FirebasePark translated = targetPark.toNewFirebaseEntry();

    translated.updateAttractionCount(targetPark: targetPark);

    // Push the translated park into the database
    db.setEntryAtPath(
        path: DatabasePath.PARKS,
        key: targetParkID.toString(),
        payload: translated.toMap());

    print("Park added successfully");

    FirebaseAnalytics().logEvent(
        name: "add_new_park", parameters: {"parkName": translated.name});

    return true;
  }

  void removeParkFromUserData(num targetID) async {
    // Very simple. Just deleting the entry entirely.
    db.removeEntryFromPath(path: DatabasePath.PARKS, key: targetID.toString());
    // And remove the 'filled' tag from the appropriate bluehost park
    getBluehostParkByID(allParksInfo, targetID).filled = false;
    // And remove the attraction data for the user's parks
    db.removeEntryFromPath(
        path: DatabasePath.ATTRACTIONS, key: targetID.toString());
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

enum ParksManagerEventType {
  UNINITIALIZED,
  INITIALIZING,
  PARKS_FETCHED,
  ATTRACTIONS_FETCHED,
  INITIALIZED,
  ERROR
}

class ParksManagerEvent {
  ParksManagerEvent(this.type);
  ParksManagerEventType type;
}

class ParksManagerStream {
  StreamController<ParksManagerEvent> _streamController;

  ParksManagerStream() {
    _streamController = StreamController.broadcast();
  }

  void dispose() {
    _streamController.close();
  }

  void add(ParksManagerEvent event) => _streamController.add(event);

  Stream get stream => _streamController.stream;
}
