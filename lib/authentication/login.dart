import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:untitled2/authentication/signup.dart';
import 'package:untitled2/rides/riderequest.dart';
import 'package:untitled2/user/usercontroller.dart';
import '../driver/drivercontroller.dart';
import '../driver/driverpage.dart';


class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _showPassword = false;
  bool isDriver = false;

  TextEditingController emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  void _toggleIsDriver() {
    setState(() {
      isDriver = !isDriver;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 70, // Image radius
                backgroundImage: NetworkImage("https://www.shutterstock.com/image-vector/carsharing-service-linear-vector-icon-260nw-1121559743.jpg",
                ),
              )
            ),
            const Text(
              "CarPool App",
              style: TextStyle(
                fontSize: 24,
                color: Colors.purpleAccent,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _toggleIsDriver,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(125.0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isDriver ? Icons.check_circle : Icons.circle),
                    const SizedBox(width: 8),
                    const Text("Are You A Driver?"),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  floatingLabelStyle: const TextStyle(color: Colors.purpleAccent),
                  focusedBorder: OutlineInputBorder(
                // width: 0.0 produces a thin "hairline" border
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.purple, width: 0.0),
              ), border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),

                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  floatingLabelStyle: const TextStyle(color: Colors.purpleAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      color:Colors.purpleAccent,
                      _showPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  focusedBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.purple, width: 0.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text.trim();
                String password = _passwordController.text.trim();

                if (isDriver) {
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                      email: '$email.driver', password: password)
                      .then((value) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DriverPage()),
                    );
                    String? uid = await DriverController.getDriverUID();
                    DriverController().getDriverData(uid!);
                    // UserController().getUserData(
                    //     UserController.getUserUID() as String);
                   _showValidSnackBar("Welcome Back..!");
                  }).onError((error, stackTrace) {
                    print('error ${error.toString()}');
                    _showErrorSnackBar('Wrong credentials... Please Try again');
                  });
                } else {
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: _passwordController.text).then((value) async {
                    _showValidSnackBar("Welcome Back..!");
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const RideRequestPage()),);
                    String? uid = await UserController.getUserUID();
                    UserController().getUserData(uid!);
                  }).onError((error, stackTrace) {
                    print('error ${error.toString()}'
                    );
                    _showErrorSnackBar('Wrong credentials... Please Try again');
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(125.0),
                ),
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 18,
                color: Colors.purpleAccent,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(125.0),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => const SignUpPage(),
                  ),);
                  },
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],),
      ),
    );
  }
}
