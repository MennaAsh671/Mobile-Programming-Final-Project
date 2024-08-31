import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../user/usermodel.dart';

class DriverRidesRequested extends StatefulWidget {
  const DriverRidesRequested({Key? key}) : super(key: key);

  @override
  _DriverRidesRequestedState createState() => _DriverRidesRequestedState();
}

class _DriverRidesRequestedState extends State<DriverRidesRequested> {
  String? driverId = FirebaseAuth.instance.currentUser!.uid;
  UserModel? user;

  Future<List<Map<String, dynamic>>> getDriverRequests() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('Users').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers = querySnapshot.docs;

    List<Map<String, dynamic>> allRides = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> driver in drivers) {
      QuerySnapshot<Map<String, dynamic>> ridesSnapshot = await driver.reference
          .collection('Requested Rides')
          .where('driverId', isEqualTo: driverId)
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> rides = ridesSnapshot.docs;

      // Add rides data to the list
      allRides.addAll(rides.map((ride) => ride.data()));
    }

    return allRides;
  }

  Future<UserModel?> _fetchUserData(String userId) async { //to display every passenger detail with the ride
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      return UserModel(
        name: userSnapshot['Name'],
        mobile: userSnapshot['Phone'],
        email: userSnapshot['Email'],
        password: userSnapshot['Password'],
      );
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
  Future<void> acceptRideRequest(String rideId, Map<String, dynamic> request) async {
    try {
      // Query to get all documents in the 'Requested Rides' collection with the specified rideId
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('Users/${request['user']}/Requested Rides')
          .where('rideId', isEqualTo: rideId)
          .get();

      // Update each document with the specified rideId to set the status to 'confirmed'
      for (QueryDocumentSnapshot<Map<String, dynamic>> document in querySnapshot.docs) {
        await document.reference.update({'status': 'confirmed'});
      }
      // You may want to perform additional actions here

      print('Ride requests accepted successfully');
    } catch (error) {
      print('Error accepting ride requests: $error');
    }
  }


  Future<void> rejectRideRequest(String rideId, Map<String, dynamic> request) async {
    try {
      // Query to get all documents in the 'Requested Rides' collection with the specified rideId
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('Users/${request['user']}/Requested Rides')
          .where('rideId', isEqualTo: rideId)
          .get();

      // Update each document with the specified rideId to set the status to 'confirmed'
      for (QueryDocumentSnapshot<Map<String, dynamic>> document in querySnapshot.docs) {
        await document.reference.update({'status': 'rejected'});
      }
      print('Ride requests is rejected ');

    } catch (error) {
      print('Error rejecting ride request: $error');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requested Rides"),
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getDriverRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> driverRequests = snapshot.data ?? [];
            if (driverRequests.isNotEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: driverRequests.map((request) {
                  // Get the user ID from the 'Requested Rides' document
                  String userId = request['user'];
                  return FutureBuilder<UserModel?>(
                    future: _fetchUserData(userId),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (userSnapshot.hasError) {
                        return Text('Error: ${userSnapshot.error}');
                      } else {
                        UserModel? userData = userSnapshot.data;
                        return Card(
                          elevation: 3.0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Name: ${userData?.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                    Text('Mobile Number: ${userData?.mobile}', style: const TextStyle(fontSize: 15,)),
                                    Text('From: ${request['destination']}', style: const TextStyle(fontSize: 15)),
                                    Text('Destination: ${request['pickup']}', style: const TextStyle(fontSize: 15)),
                                    Text('Fare: ${request['price']}', style: const TextStyle(fontSize: 15)),
                                    Text('Meeting point: ${request['meeting-point']}', style: const TextStyle(fontSize: 15)),
                                    Text('Date: ${request['date']}', style: const TextStyle(fontSize: 15)),
                                    Text('Time: ${request['time']}', style: const TextStyle(fontSize: 15)),
                                  ],
                                ),
                                const SizedBox(width: 30),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(125.0),
                                        ),
                                        backgroundColor: Colors.purple,
                                      ),
                                      onPressed: () async {
                                        //When the driver accepts the ride request
                                        await acceptRideRequest(request['rideId'],request);
                                      },
                                      child: const Text("Accept"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(125.0),
                                        ),
                                        backgroundColor: Colors.grey,
                                      ),
                                      onPressed: () async {
                                        //When the driver rejects the ride request
                                        await rejectRideRequest(request['rideId'],request);
                                      },
                                      child: const Text("Decline"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              );
            } else {
              return const Center(child: Text('No requests available'));
            }
          }
        },
      ),
    );
  }
}
