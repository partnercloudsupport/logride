import 'dart:async';
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
  void init();
  Query getSortedQueryForUser({DatabasePath path, String key, String orderBy});
  Query getFilteredQuery({DatabasePath path, String key, dynamic value});
  Query getSortedFilteredQuery({DatabasePath path, String key, dynamic value, String orderBy});
  Query getQueryForUser({DatabasePath path, String key});
  void setEntryAtPath({DatabasePath path, String key, dynamic payload});
  void updateEntryAtPath(
      {DatabasePath path, String key, Map<String, dynamic> payload});
  void removeEntryFromPath({DatabasePath path, String key});
  Future<bool> doesEntryExistAtPath({DatabasePath path, String key});
  Future<dynamic> getEntryAtPath({DatabasePath path, String key});
  Stream<Event> getLiveEntryAtPath({DatabasePath path, String key});
  Stream<Event> getLiveChildrenChanges({DatabasePath path, String key});
  void performTransaction({DatabasePath path, String key, Function(MutableData transaction) transactionHandler});
  void storeUserID(String userID);
  void clearUserID();
}

class DatabaseManager implements BaseDB {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  String _savedID;

  void init() {
    //_firebaseDatabase.setPersistenceEnabled(true);
  }

  void storeUserID(String userID) {
    _savedID = userID ?? null;
  }

  void clearUserID() {
    _savedID = null;
  }

  DatabaseReference _getReference(DatabasePath path) {
    String childPath = _databasePathStrings[path];
    return _firebaseDatabase.reference().child(childPath);
  }

  Query getSortedQueryForUser({DatabasePath path, String key, String orderBy}) {
    return _getReference(path).child(_savedID).child(key).orderByChild(orderBy);
  }

  Query getFilteredQuery({DatabasePath path, String key, dynamic value}) {
    return _getReference(path).child(_savedID).orderByChild(key).equalTo(value);
  }

  Query getSortedFilteredQuery({DatabasePath path, String key, dynamic value, String orderBy}) {
    return _getReference(path).child(_savedID).orderByChild(key).equalTo(value).orderByChild(orderBy);
  }

  Query getQueryForUser({DatabasePath path, String key}) {
    return _getReference(path).child(_savedID).child(key).orderByKey();
  }

  void removeEntryFromPath({DatabasePath path, String key}) {
    _getReference(path).child(_savedID).child(key).remove();
  }

  void setEntryAtPath({DatabasePath path, String key, dynamic payload}) {
    _getReference(path).child(_savedID).child(key).set(payload);
  }

  void updateEntryAtPath(
      {DatabasePath path, String key, Map<String, dynamic> payload}) {
    _getReference(path).child(_savedID).child(key).update(payload);
  }

  Future<bool> doesEntryExistAtPath({DatabasePath path, String key}) {
    return _getReference(path)
        .child(_savedID)
        .child(key)
        .once()
        .then((DataSnapshot snapshot) {
      return snapshot.value != null;
    });
  }

  Future<dynamic> getEntryAtPath({DatabasePath path, String key}) {
    return _getReference(path)
        .child(_savedID)
        .child(key)
        .once()
        .then((DataSnapshot snapshot) {
      return snapshot.value;
    });
  }

  Stream<Event> getLiveEntryAtPath({DatabasePath path, String key}) {
    return _getReference(path).child(_savedID).child(key).onValue;
  }

  Stream<Event> getLiveChildrenChanges({DatabasePath path, String key}) {
    return _getReference(path).child(_savedID).child(key).onChildChanged;
  }

  void performTransaction({DatabasePath path, String key, Function(MutableData transaction) transactionHandler}){
    _getReference(path).child(_savedID).child(key).runTransaction((MutableData transaction) async {
      return transactionHandler(transaction);
    });
  }
}
