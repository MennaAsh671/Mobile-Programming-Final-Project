import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled2/rides/ridemodel.dart';
import '/profile.dart';
import '../rides/cart.dart';
import '../authentication/login.dart';
import '../payment/payment.dart';
import 'orderhistory.dart';

class RideRequestPage extends StatefulWidget {
  const RideRequestPage({super.key});

  @override
  State<RideRequestPage> createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage> {

  String selectedSection = 'Faculty';
  bool DisableTimeConstraint = false; // Use this flag to override time constraints

  List<Ride> selectedRides = [];
  List<String> requestedRideIds = []; // List to store ride IDs that the user has already requested

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

  Future<void> addRideToRequestedRides(Ride ride, String driverId, String rideId) async {
    try {
      // Check if the ride ID is already in the requestedRideIds list
      if (requestedRideIds.contains(rideId)) {
        _showErrorSnackBar('You have already requested this ride..Wait For Driver Confirmation');
        return; // Exit the function if the ride has already been requested
      }

      // Add the ride ID to the requestedRideIds list
      requestedRideIds.add(rideId);

      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String userRequestedRidesPath = 'Users/${currentUser.uid}/Requested Rides';

        // Add the ride to the "Requested Rides" collection with additional details
        // DocumentReference rideRef
         await FirebaseFirestore.instance.collection(userRequestedRidesPath).add({
          'pickup': ride.pickup,
          'destination': ride.destination,
          'price': ride.fare,
          'meeting-point': ride.meetingPoint,
          'date': ride.date,
          'time': ride.time,
          'driverId': driverId,
          'rideId': rideId,
          'user': currentUser.uid,
          'status': 'pending', // You can set an initial status
        });

        _showValidSnackBar('Ride added to Requested Rides');

        // Navigate to CartPage and pass the ride reference
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(),
          ),
        );
      } else {
        _showErrorSnackBar('User not signed in');
      }
      _addToSelectedRides(ride);
    } catch (error) {
      print('Error adding ride to Requested Rides: $error');
      _showErrorSnackBar('Failed to add ride');
    }
  }

  void _addToSelectedRides(Ride ride) {
    setState(() {
      selectedRides.add(ride);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
        title: const Text("Welcome"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purpleAccent,
              ),
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage(isDriver: false)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_edu_sharp),
              title: const Text('Order History'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment Method'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
            ),

            Column(
              children: [
                const Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SizedBox(height: 300),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      _showValidSnackBar("LoggedOut");
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const LogInPage(),
                      ));
                    }).onError((error, stackTrace) {
                      print('error ${error.toString()}');
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top:12.0),
              child: Image.network(
                  height: 90,
                  "https://images.squarespace-cdn.com/content/v1/63e5684aaad4456c034f4e0b/1675978865626-8YIKS0S7YM0AR2C3SDO5/carpool_car_logo_pink_large.png"),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('TURN OFF Time Constraint'),
                  Switch(
                    value: DisableTimeConstraint,
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        DisableTimeConstraint = value;
                      });
                    },
                    activeColor: Colors.purpleAccent,
                    inactiveThumbColor: Colors.grey,
                  ),
                ],
              ),
            ),
            Center(
              child: ListTile(
                title: const Padding(
                  padding: EdgeInsets.only(left: 130.0,bottom: 13.0),
                  child: Text('Available Rides'),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left:12.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedSection = 'HeadingToFaculty';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedSection == 'HeadingToFaculty'
                              ? Colors.purpleAccent
                              : Colors.grey,
                        ),
                        child: const Text('Heading to Faculty'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedSection = 'HeadingToHome';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedSection == 'HeadingToHome' ? Colors.purpleAccent : Colors.grey,
                        ),
                        child: const Text('Leaving Faculty to Home'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child:StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Drivers').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Text('No available rides');
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var driverDocument = snapshot.data!.docs[index];
                      var driverId = driverDocument.id;
                      // Adjust the below widget structure according to your ride data structure
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('Drivers').doc(driverId).collection(selectedSection).snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> rideSnapshot) {
                          if (rideSnapshot.hasError) {
                            return Text('Error: ${rideSnapshot.error}');
                          }

                          if (rideSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (rideSnapshot.data!.docs.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: const Center(child: Text('',style:TextStyle(fontSize: 10))),
                            );
                          }

                          // Display the list of rides for this driver and selected section
                          return Column(
                            children: rideSnapshot.data!.docs.map((rideDocument) {
                              var rideData = rideDocument.data() as Map<String, dynamic>;
                              // Check if the ride has been requested
                              bool isRequested = requestedRideIds.contains(rideData['rideId']);
                              if (selectedSection == 'HeadingToFaculty') {
                                try {
                                  DateTime rideDateTime = DateFormat('MM/dd/yyyy hh:mm a').parse('${rideData['date']} ${rideData['time']}');
                                  DateTime deadline = DateTime(
                                    rideDateTime.year,
                                    rideDateTime.month,
                                    rideDateTime.day - 1, // Previous day
                                    22, // 10:00 PM
                                  );

                                  if (DateTime.now().isAfter(deadline) && !DisableTimeConstraint) {
                                    // Ride time constraint for heading to home
                                    return Container(); // Don't render the card
                                  }
                                } catch (e) {
                                  print('Error parsing date or time: $e');
                                  print('Date: ${rideData['date']}');
                                  print('Time: ${rideData['time']}');
                                  return Container(); // Don't render the card
                                }

                              }else if (selectedSection == 'HeadingToHome') {
                                try {
                                  DateTime rideDateTime = DateFormat('MM/dd/yyyy hh:mm a').parse('${rideData['date']} ${rideData['time']}');
                                  DateTime deadline = DateTime(
                                    rideDateTime.year,
                                    rideDateTime.month,
                                    rideDateTime.day ,
                                    13,
                                  );

                                  if (DateTime.now().isAfter(deadline) && !DisableTimeConstraint) {
                                    return Container();
                                  }
                                } catch (e) {
                                  print('Error parsing date or time: $e');
                                  print('Date: ${rideData['date']}');
                                  print('Time: ${rideData['time']}');
                                  return Container();
                                }
                              }
                              // Render the card only if the ride has not been requested
                              //to avoid multi requests of the same ride
                              if (!isRequested) {
                              return ListTile(
                                leading: const Icon(Icons.drive_eta_rounded),
                                title: Text('Pickup: ${rideData['pickupLocation']}'),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blueGrey,
                                  ),
                                  onPressed: () async {
                                    Ride ride = Ride(
                                      pickup: rideData['pickupLocation'],
                                      destination: rideData['destination'],
                                      fare: rideData['price'],
                                      meetingPoint: rideData['meeting-point'],
                                      date: rideData['date'],
                                      time: rideData['time'],
                                    );

                                    // Call the function to add the ride to requested rides and navigate to CartPage
                                    await addRideToRequestedRides(ride, driverId, rideDocument.id);

                                    // Remove the ride from the UI by updating the state
                                    setState(() {
                                      rideSnapshot.data!.docs.remove(rideDocument);
                                    }); },
                                  child: const Text("Request", style: TextStyle(color: Colors.white)),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Destination: ${rideData['destination']}'),
                                    Text('Price: ${rideData['price']}'),
                                    Text('Meeting Point: ${rideData['meeting-point']}'),
                                    Text('Date: ${rideData['date']}'),
                                    Text('Time: ${rideData['time']}'),
                                  ],
                                ),
                                // Add more fields as needed
                                onTap: () {
                                  _showErrorSnackBar("Tap Request Button to Request");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CartPage(),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container(); // Don't render the card if the ride has been requested
                              }

                            }).toList(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
