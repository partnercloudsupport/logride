import '../data/fbdb_manager.dart';
import '../data/park_structures.dart';
import '../data/webfetcher.dart';

class ParksManager {
  ParksManager({this.db, this.wf});

  final BaseDB db;
  final WebFetcher wf;

  List<BluehostPark> allParksInfo;
  //List<Park> userParks; // Display lists are managed by FirebaseAnimatedLists, but we keep track of its contents on our own, too.

  void init() async {
    // Things to do:
    // Get allParks from bluehost
    allParksInfo = await wf.getAllParkData();

    // Go through and set-up the allParksInfo to match the user database.
    // The 'filled' tag is used in the all-parks-search to show the user they
    // have that park.
    db.getEntryAtPath(path: DatabasePath.PARKS, key: "").then((snap) {
      //print(snap.value);
      Map entries = Map.from(snap);
      for(int i = 0; i < entries.keys.length; i++) {
        int entryID = num.parse(entries.keys.elementAt(i));
        getBluehostParkByID(allParksInfo, entryID).filled = true;
      }
    });
  }

  void addParkToUser(num targetParkID) async {
    // Find if we already have the park
    bool exists = await db.doesEntryExistAtPath(path: DatabasePath.PARKS, key: targetParkID.toString());
    if (exists)
      return; // If the park is already there, ignore it

    // Get our targeted park, translate it into one that firebase can read
    BluehostPark targetPark = getBluehostParkByID(allParksInfo, targetParkID);
    FirebasePark translated = targetPark.toNewFirebaseEntry();

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
    bool isInFavorites = await db.getEntryAtPath(path: DatabasePath.PARKS, key: targetID.toString() + "/favorite");
    if(isInFavorites) return;

    // We need to set the park's favorite flag
    db.setEntryAtPath(path: DatabasePath.PARKS, key: targetID.toString() + "/favorite", payload: true);
  }

  void removeParkFromFavorites(num targetID) async {
    // Check to see if we're actually in favorites
    bool isInFavorites = await db.getEntryAtPath(path: DatabasePath.PARKS, key: targetID.toString() + "/favorite");
    if(!isInFavorites) return;

    // Set the favorite flag for the park
    db.setEntryAtPath(path: DatabasePath.PARKS, key: targetID.toString() + "/favorite", payload: false);
  }
}
