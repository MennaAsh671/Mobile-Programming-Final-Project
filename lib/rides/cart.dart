import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../payment/payment.dart';
import '../user/usermodel.dart';

class CartPage extends StatefulWidget {

  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? userid = FirebaseAuth.instance.currentUser!.uid;
  UserModel? user;

  Future<List<Map<String, dynamic>>> getUserRequests() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('Users').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers = querySnapshot.docs;

    List<Map<String, dynamic>> allRides = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> driver in drivers) {
      QuerySnapshot<Map<String, dynamic>> ridesSnapshot = await driver.reference
          .collection('Requested Rides')
          .where('user', isEqualTo: userid)
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> rides = ridesSnapshot.docs;

      // Add rides data to the list only if not already present
      for (QueryDocumentSnapshot<Map<String, dynamic>> ride in rides) {
        if (!allRides.any((existingRide) => existingRide['rideId'] == ride['rideId'])) {
          allRides.add(ride.data());
        }
      }
    }

    return allRides;
  }


  void _showValidSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
        title: const Text('Cart'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUserRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> driverRequests = snapshot.data ?? [];
            if (driverRequests.isNotEmpty) {
              return ListView(
                padding: EdgeInsets.all(16.0),
                children: driverRequests.map((request) {
                  return Card(
                    elevation: 3.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('From: ${request['pickup']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('Destination: ${request['destination']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('Price: ${request['price']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('Checkpoint: ${request['meeting-point']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('Date: ${request['date']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('Time: ${request['time']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text('Ride Status: ${request['status']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ]),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(125.0),
                                  ),
                                ),
                                onPressed: () {

                                // Check the ride status and navigate accordingly
                                // widget.rideReference.get().then((freshSnap) {
                                  String status = request['status'];

                                  if (status == 'pending') {
                                    // Show a message or perform an action for pending status
                                    _showErrorSnackBar('Please wait for the driver to confirm the ride.');
                                  } else if (status == 'confirmed') {
                                    _showValidSnackBar("You Ride is Accepted please Choose Your payment Method");
                                    // Navigate to the payment page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PaymentPage()),
                                    );
                                  } else if (status == 'rejected') {
                                    // Show a message or perform an action for rejected status
                                    _showErrorSnackBar('Sorry, the ride has been rejected by the driver.');
                                  }
                              },
                              child: const Text("Pay for Ride"),
                            )
                        ],
                      ),
                    ]
                      ),),
                  );
                }).toList(),
              );
            } else {
              return Center(child: Text('No requests available'));
            }
          }
        },
      ),
    );
  }
}
