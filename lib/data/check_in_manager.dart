import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:log_ride/data/fbdb_manager.dart';
import 'package:log_ride/data/park_structures.dart';

const double _CHECK_IN_RANGE = 1609;

class CheckInManager {
  final BaseDB db;
  final List<BluehostPark> serverParks;
  final CheckInListenable listenable =
      CheckInListenable(CheckInData(null, false));
  final Function(int parkID) addPark;

  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 15,
      timeInterval: 1000); // Wait one minute between check-in thing

  CheckInManager({this.db, this.serverParks, this.addPark}) {
    geolocator.getPositionStream(locationOptions).listen(_positionUpdate);
  }

  void _positionUpdate(Position position) async {
    print("position update");
    // Get the user's position...
    LatLng userPosition = _positionToLatLng(position);
    Map<BluehostPark, double> closestParks = Map<BluehostPark, double>();

    // Find the parks within check_in_range
    serverParks.forEach((park) {
      double userDistance = Distance().distance(userPosition, park.location);
      if (userDistance <= _CHECK_IN_RANGE) {
        // We're within check-in range for this park!
        closestParks[park] = userDistance;
      }
    });

    // If we don't have any parks within check-in-range, give up
    if (closestParks.length == 0) {
      listenable.value = CheckInData(null, false);
      return;
    }

    // Otherwise, find the closest park
    double closestDistance =
        _CHECK_IN_RANGE * 10; // Just get it silly far away. Just to be safe
    BluehostPark closestPark;
    closestParks.forEach((park, distance) {
      if (distance < closestDistance) {
        closestDistance = distance;
        closestPark = park;
      }
    });

    // Now that we have our closest park, we need to see if the user has already been there today
    DateTime today = DateTime.now();
    DateTime midnight = DateTime(today.year, today.month, today.day, 0);

    bool hasCheckedInToday = await db
        .getEntryAtPath(
            path: DatabasePath.PARKS, key: "${closestPark.id}/lastDayVisited")
        .then((value) async {
      // If there's no user data for checking in at this park, we know they haven't checked in today
      if (value == null) {
        return false;
      } else {
        // We've got data for the last day visited - now we see if the last day was within the last day
        double secondsSinceEpoch = (value as int)
            .toDouble(); // Again, time is stored in the firebase in seconds thanks to the iOS app
        DateTime lastDayVisited = DateTime.fromMillisecondsSinceEpoch(
            (secondsSinceEpoch * 1000).toInt());
        DateTime lastMidnightVisited = DateTime(
            lastDayVisited.year, lastDayVisited.month, lastDayVisited.day, 0);

        Duration difference = midnight.difference(lastMidnightVisited);

        bool checkedInToday = (difference.inHours >= 24) ? false : true;

        db.setEntryAtPath(
            path: DatabasePath.PARKS,
            key: "${closestPark.id}/checkedInToday",
            payload: false);

        return checkedInToday;
      }
    });

    // Establish a new value for our listenable
    listenable.value = CheckInData(closestPark, hasCheckedInToday);
    return;
  }

  void checkIn(int parkID) async {
    DateTime now = DateTime.now();
    DateTime midnight = DateTime(now.year, now.month, now.day, 0);

    // If the park hasn't been used before, add it to the user's data (properly)
    bool exists = await db.doesEntryExistAtPath(
        path: DatabasePath.PARKS, key: parkID.toString());
    if (!exists) {
      await addPark(parkID);
    }

    // Get the number of times the user has checked in to this park
    int checkinCount = (await db.getEntryAtPath(
            path: DatabasePath.PARKS, key: "$parkID/numberOfCheckIns") as int ??
        0);

    // Update accordingly
    db.updateEntryAtPath(path: DatabasePath.PARKS, key: "$parkID", payload: {
      "checkedInToday": true,
      "lastDayVisited": midnight.millisecondsSinceEpoch / 1000,
      "numberOfCheckIns": checkinCount + 1
    });

    listenable.value.checkedInToday = true;
    FirebaseAnalytics().logEvent(
        name: "check_into_park",
        parameters: {"parkName": listenable.value.park.parkName});
  }
}

class CheckInListenable extends ValueNotifier<CheckInData> {
  CheckInListenable(CheckInData value) : super(value);
}

class CheckInData {
  BluehostPark park;
  bool checkedInToday;
  CheckInData(this.park, this.checkedInToday);

  bool isEqualTo(CheckInData other) {
    return (park == other.park && checkedInToday == other.checkedInToday);
  }
}

LatLng _positionToLatLng(Position position) {
  return LatLng(position.latitude, position.longitude);
}
