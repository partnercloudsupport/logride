import 'package:log_ride/data/auth_manager.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/user_structure.dart';

class AccountDeleter {
  static Future<bool> deleteAccount(
      BaseAuth auth, BaseDB db, LogRideUser user) async {
    db.storeUserID(user.uuid);

    // Things to delete:
    // All Parks List
    db.removeEntryFromPath(path: DatabasePath.PARKS, key: "");
    // Attractions List
    db.removeEntryFromPath(path: DatabasePath.ATTRACTIONS, key: "");
    // Day-in-park (Todo)

    // Ignore List
    db.removeEntryFromPath(path: DatabasePath.IGNORE, key: "");

    // Score-Card list
    db.removeEntryFromPath(path: DatabasePath.SCORECARD, key: "");

    // Stats-list
    db.removeEntryFromPath(path: DatabasePath.STATS, key: "");

    // Users
    db.removeEntryFromPath(path: DatabasePath.USER_DETAILS, key: "");

    return true;
  }
}
