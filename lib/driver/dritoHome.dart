import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:untitled2/profile.dart';
import 'package:intl/intl.dart';
import '../authentication/login.dart';
import 'driRequests.dart';


const List<String> gates = <String>['To: Gate 3', 'To: Gate 4'];

String? timeValue ="Time";
String? destValue ="Gate";

class DriverHeadingToHome extends StatefulWidget {
  const DriverHeadingToHome({Key? key, }) : super(key: key);

  @override
  State<DriverHeadingToHome> createState() => _DriverHeadingToHomeState();
}

class _DriverHeadingToHomeState extends State<DriverHeadingToHome> {

  final TextEditingController dropOffController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController meetingPointController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future<void> saveRideDetailsToFirestore() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Add the ride details to Firestore
      DocumentReference rideReference = await FirebaseFirestore.instance.
      collection('Drivers').doc(userId).collection('HeadingToHome').add({
        'pickupLocation':destValue ,
        'destination': dropOffController.text,
        'price': priceController.text,
        'meeting-point': meetingPointController.text,
        'date': dateController.text,
        'time': timeValue,
        'driver-id':userId,
      });

      // Get the ID of the added ride
      String rideId = rideReference.id;

      // Update the ride document with its ID
      await rideReference.update({'rideId': rideId});

      _showValidSnackBar('Ride added successfully');
    } catch (error) {
      print('Error adding ride to Firestore: $error');
      _showErrorSnackBar('Failed to add ride');
    }
  }

  DateTime? selectedTime;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate, // Allow the current date to be selected
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purpleAccent,
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: const ColorScheme.light(primary: Colors.purpleAccent).copyWith(secondary: Colors.purpleAccent),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = DateFormat('MM/dd/yyyy').format(selectedDate!);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purpleAccent,
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: const ColorScheme.light(primary:  Colors.purpleAccent).copyWith(secondary: Colors.purpleAccent),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && _isTimeWithinBounds(picked)) {
      setState(() {
        selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          picked.hour,
          picked.minute,
        );

        timeValue = DateFormat('hh:mm a').format(selectedTime!);
      });
    }
  }

  bool _isTimeWithinBounds(TimeOfDay time) {

    const int upperBoundHour =17;
    const int lowerBoundMinute = 30;
    int selectedHour = time.hour;
    int selectedMinute = time.minute;

    return (selectedHour == upperBoundHour && selectedMinute == lowerBoundMinute);
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
        title: const Text("Ride Details"),
        centerTitle: true,
        backgroundColor:  Colors.purpleAccent,
      ),
      body: SingleChildScrollView(child:
      Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.network(
                  height: 90,
                  "https://images.squarespace-cdn.com/content/v1/63e5684aaad4456c034f4e0b/1675978865626-8YIKS0S7YM0AR2C3SDO5/carpool_car_logo_pink_large.png"),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Heading to Home:", style: TextStyle(fontSize: 20, ),),
            ),
            const SizedBox(height: 3,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const Text("PickUp: ",style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                    const SizedBox(width: 100,),
                    SizedBox(
                      width: 150,
                      height: 80,
                        child: DropdownMenu<String>(
                          initialSelection: gates.first,
                          onSelected: (String? value) {
                            setState(() {
                              destValue = value!;
                            });
                          },
                          dropdownMenuEntries: gates.map<DropdownMenuEntry<String>>((String value) {
                            return DropdownMenuEntry<String>(value: value, label: value);
                          }).toList(),
                        ),
                      ),
                  ],
                ),
                // const SizedBox(width: 5,),
                Padding(
                  padding: const EdgeInsets.only(right:15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text("Destination: ",style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                      const SizedBox(width: 65,),
                      SizedBox(
                        width: 150,
                        height: 80,
                        child: TextField(
                        controller: dropOffController,
                        decoration: const InputDecoration(
                          hintText: 'ex..Maadi',
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                        ),
                      ),
                      )
                    ],),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text("Fare:",style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),),
                const SizedBox(width: 42,),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      hintText: 'Your trip Fare',
                      border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: 300,
              height: 80,
              child: TextField(
                controller: meetingPointController,
                decoration: const InputDecoration(
                  hintText: 'Nearest Drop Off Point',
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0)),
                ),
              ),
            ),

            // SizedBox(height: 10,),

            SizedBox(
              width: 300,
              height: 80,
              child:TextField(
                controller: dateController,
                onTap: () => _selectDate(context), // Call the date picker when the text field is tapped
                decoration: const InputDecoration(
                  hintText: 'Add Ride date',
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0)),
                ),
              ),
            ),

            //SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Add Ride time:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () => _selectTime(context), // Call the time picker when the user taps the text
                  child: SizedBox(
                    width: 150,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2.0)),
                      ),
                      child: Text(
                        selectedTime != null ? DateFormat('hh:mm a').format(selectedTime!) : 'Select Time',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                )
              ],),
            const SizedBox(height: 10,),


            // SizedBox(height: 10,),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
              onPressed: () {
                saveRideDetailsToFirestore();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => Cart()), // Navigate to second screen
                // );
              },
              child: const Text("Add Your Ride"),
            ),
          ],
        ),
      ),),

    );
  }
}