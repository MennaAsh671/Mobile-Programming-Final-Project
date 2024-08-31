import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'drivermodel.dart';

class DriverController {
  final _db = FirebaseFirestore.instance;

  static Future<String?> getDriverUID() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Check if the driver is signed in
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      print('Driver UID: $uid');
      return uid;
    } else {
      print('Driver is not signed in');
      return null;
    }
  }

  Future<void> addDriverData(DriverModel driver) async {
    String? uid = await getDriverUID();

    if (uid != null) {
      _db
          .collection('Drivers')
          .doc(uid)
          .set(DriverModel.toJson(driver))
          .then((value) {
        print("Data inserted for UID: $uid");
      }).catchError((error) {
        print("Error adding data: $error");
      });
    } else {
      print("Driver UID not available. Cannot add Driver data.");
    }
  }

  Future<DriverModel?> getDriverData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> driverSnapshot =
      await _db.collection('Drivers').doc(uid).get();

      if (driverSnapshot.exists) {
        DriverModel driver = DriverModel.fromSnapshot(driverSnapshot);
        print('Driver data found for UID: $uid: $driver');
        return driver;
      } else {
        print('No user found with $uid id');
        return null;
      }
    } catch (error) {
      print('Error $error');
      return null;
    }
  }
}