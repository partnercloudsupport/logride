import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

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
  void addEntryToPath({DatabasePath path, String userID, String key, Map<String, dynamic> payload});
  void removeEntryFromPath({DatabasePath path, String userID, String key});
  void setEntryAtPath({DatabasePath path, String userID, String key, dynamic payload});
  Future<bool> doesEntryExistAtPath({DatabasePath path, String userID, String key});
}

class DatabaseManager implements BaseDB {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  
  DatabaseReference _getReference(DatabasePath path){
    String childPath = _databasePathStrings[path];
    return _firebaseDatabase.reference().child(childPath);
  }

  Query getSortedQueryForUser({DatabasePath path, String userID, String key}){
    return _getReference(path).child(userID).orderByChild(key);
  }

  void addEntryToPath({DatabasePath path, String userID, String key, Map<String, dynamic> payload}){
    _getReference(path).child(userID).child(key).set(payload);
  }

  void removeEntryFromPath({DatabasePath path, String userID, String key}){
    _getReference(path).child(userID).child(key).remove();
  }

  void setEntryAtPath({DatabasePath path, String userID, String key, dynamic payload}){
    _getReference(path).child(userID).child(key).set(payload);
  }

  Future<bool> doesEntryExistAtPath({DatabasePath path, String userID, String key}) {
    return _getReference(path).child(userID).child(key).once().then((DataSnapshot snapshot) {
      return snapshot.value != null;
    });
  }
}