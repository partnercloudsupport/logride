import 'package:firebase_database/firebase_database.dart';

enum DatabasePath {
  USER_DETAILS,
  USER_PERSONAL_LISTS,
  STATS,
  SCORECARD,
  IGNORE,
  FAVORITES,
  ATTRACTIONS,
  PARKS
}

Map<DatabasePath, String> _databasePathStrings = {
  DatabasePath.USER_DETAILS: "users/details",
  DatabasePath.USER_PERSONAL_LISTS: "user-created-list",
  DatabasePath.STATS: "stats-list",
  DatabasePath.SCORECARD: "score-card-list",
  DatabasePath.IGNORE: "ignore-list",
  DatabasePath.FAVORITES: "favorite-parks-list",
  DatabasePath.ATTRACTIONS: "attractions-list",
  DatabasePath.PARKS: "all-parks-list"
};

abstract class BaseDB {
  Query getSortedQueryForUser({DatabasePath path, String userID, String key});
  Query getFilteredQuery({DatabasePath path, String userID, String key, dynamic value});
  Query getQueryForUser({DatabasePath path, String userID, String key});
  void setEntryAtPath({DatabasePath path, String userID, String key, dynamic payload});
  void removeEntryFromPath({DatabasePath path, String userID, String key});
  Future<bool> doesEntryExistAtPath({DatabasePath path, String userID, String key});
  Future<dynamic> getEntryAtPath({DatabasePath path, String userID, String key});
  Stream<Event> getLiveEntryAtPath({DatabasePath path, String userID, String key});
  void storeUserID(String userID);
  void clearUserID();
}

class DatabaseManager implements BaseDB {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  String _savedID;

  void storeUserID(String userID){
    _savedID = userID ?? null;
  }

  void clearUserID(){
    _savedID = null;
  }
  
  DatabaseReference _getReference(DatabasePath path){
    String childPath = _databasePathStrings[path];
    return _firebaseDatabase.reference().child(childPath);
  }

  Query getSortedQueryForUser({DatabasePath path, String userID, String key}){
    return _getReference(path).child(userID ?? _savedID).orderByChild(key);
  }

  Query getFilteredQuery({DatabasePath path, String userID, String key, dynamic value}){
    return _getReference(path).child(userID ?? _savedID).orderByChild(key).equalTo(value);
  }

  Query getQueryForUser({DatabasePath path, String userID, String key}) {
    return _getReference(path).child(userID ?? _savedID).orderByKey();
  }

  void removeEntryFromPath({DatabasePath path, String userID, String key}){
    _getReference(path).child(userID ?? _savedID).child(key).remove();
  }

  void setEntryAtPath({DatabasePath path, String userID, String key, dynamic payload}){
    _getReference(path).child(userID ?? _savedID).child(key).set(payload);
  }

  Future<bool> doesEntryExistAtPath({DatabasePath path, String userID, String key}) {
    return _getReference(path).child(userID ?? _savedID).child(key).once().then((DataSnapshot snapshot) {
      return snapshot.value != null;
    });
  }

  Future<dynamic> getEntryAtPath({DatabasePath path, String userID, String key}) {
    return _getReference(path).child(userID ?? _savedID).child(key).once().then((DataSnapshot snapshot) {
      return snapshot.value;
    });
  }

  Stream<Event> getLiveEntryAtPath({DatabasePath path, String userID, String key}) {
    return _getReference(path).child(userID ?? _savedID).child(key).onValue;
  }

  Stream<Event> getLiveChildrenChanges({DatabasePath path, String userID, String key}) {
    return _getReference(path).child(userID ?? _savedID).child(key).onChildChanged;
  }

}