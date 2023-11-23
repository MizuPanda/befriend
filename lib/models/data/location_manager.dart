import 'dart:async';

import 'package:background_location/background_location.dart';
import 'package:flutter/cupertino.dart';

class LocationManager {
  void startLocationService() async {
    await BackgroundLocation.setAndroidNotification(
      title: "Location Tracking",
      message: "Tracking location in background",
      icon: "@mipmap/ic_launcher",
    );

    await BackgroundLocation.startLocationService();
    scheduleLocationFetch();
  }

  void scheduleLocationFetch() {
    var now = DateTime.now();
    var nextFetch = now.minute < 30
        ? DateTime(now.year, now.month, now.day, now.hour, 30)
        : DateTime(now.year, now.month, now.day, now.hour + 1, 0);

    var delay = nextFetch.difference(now);
    Timer(delay, () {
      fetchLocation();
      scheduleLocationFetch(); // Schedule the next fetch
    });
  }

  void fetchLocation() {
    BackgroundLocation.getLocationUpdates((location) {
      debugPrint("Latitude: ${location.latitude}, Longitude: ${location.longitude}");
      // Handle location update (e.g., send to server)
    });
  }

  Future<void> stopLocation() async {
    BackgroundLocation.stopLocationService();
  }
}