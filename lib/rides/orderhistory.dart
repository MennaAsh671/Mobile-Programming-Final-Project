// TODO:
/*
all orders created by the user before
connected to the database and get the requested rides from it
In the database:
- all rides from driver appears to user (available rides screen)
- all previously requested rides from a specific user ( order history screen )
- all the rides requested from the account of the user logged in added to cart  ( cart screen )

- in the driver page the added rides appears in the same screen for each driver
 and sent to the database and the user fetch all the rides with the details requested
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../user/usermodel.dart';

class OrderHistoryPage extends StatefulWidget {
  // final List<Ride> selectedRides;
  // final DocumentReference rideReference; // Pass the ride reference

  const OrderHistoryPage({Key? key}) : super(key: key);

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  String? userid = FirebaseAuth.instance.currentUser!.uid;
  UserModel? user;

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await FirebaseFirestore.instance.collection('Users').get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> drivers = querySnapshot.docs;

    List<Map<String, dynamic>> allRides = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> driver in drivers) {
      QuerySnapshot<Map<String, dynamic>> ridesSnapshot = await driver.reference
          .collection('Requested Rides')
          .where('user', isEqualTo: userid)
          .where('status', isEqualTo: 'confirmed') // filter by status
          .get();

      List<QueryDocumentSnapshot<Map<String, dynamic>>> rides = ridesSnapshot.docs;
      // Add rides data to the list
      allRides.addAll(rides.map((ride) => ride.data()));
    }

    return allRides;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
        title: const Text('Order History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getOrderHistory(),
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
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('From: ${request['pickup']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('Destination: ${request['destination']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('Price: ${request['price']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('Meeting Point: ${request['meeting-point']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('Date: ${request['date']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  Text('Time: ${request['time']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ]
                      ),),
                  );
                }).toList(),
              );
            } else {
              return Center(child: Text('No Previous Accepted Ride'));
            }
          }
        },
      ),
    );
  }
}
