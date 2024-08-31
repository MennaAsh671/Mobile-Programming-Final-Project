import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:untitled2/driver/drivermodel.dart';
import 'package:untitled2/user/usermodel.dart';
import 'authentication/login.dart';

class ProfilePage extends StatefulWidget {
  final bool isDriver;

  const ProfilePage({Key? key, required this.isDriver}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  DriverModel? driver;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection(widget.isDriver ? 'Drivers' : 'Users')
            .doc(currentUser.uid)
            .get();

        if (widget.isDriver) {
          setState(() {
            driver = DriverModel(
              name: userSnapshot['Name'],
              mobile: userSnapshot['Phone'],
              email: userSnapshot['Email'],
              password: userSnapshot['Password'],
            );
          });
        } else{
          setState(() {
            user = UserModel(
              name: userSnapshot['Name'],
              mobile: userSnapshot['Phone'],
              email: userSnapshot['Email'],
              password: userSnapshot['Password'],
            );
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.purpleAccent,
        title: const Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purpleAccent,
              child: Icon(Icons.account_circle_sharp, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildInfoCard('Name', widget.isDriver ? driver?.name : user?.name),
            _buildInfoCard('Mobile', widget.isDriver ? driver?.mobile : user?.mobile),
            _buildInfoCard('Email', widget.isDriver ? driver?.email : user?.email),
            _buildInfoCard('User Type', widget.isDriver ? 'Driver' : 'Passenger'),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        hoverColor: Colors.purpleAccent,
        onPressed: () {
          FirebaseAuth.instance.signOut().then((value) {
            showSnackBar("Logged Out");
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => const LogInPage(),
            ));
          }).onError((error, stackTrace) {
            print('Error: ${error.toString()}');
          });
        },
        child: const Icon(Icons.login_outlined),
      ),
    );
  }

  Widget _buildInfoCard(String title, String? value) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value ?? '',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void showSnackBar(String message) {
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
}
