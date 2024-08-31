import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled2/driver/drivermodel.dart';
import 'package:untitled2/rides/riderequest.dart';
import 'package:untitled2/user/usercontroller.dart';
import 'package:untitled2/user/usermodel.dart';
import '../databaseHelper.dart';
import '../driver/drivercontroller.dart';
import '../driver/driverpage.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  bool _showPassword = false;
  bool isDriver = false;

  List<Map> myList = [];
  DatabaseHelper myDb = DatabaseHelper();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future Reading_Database() async {
    List<Map> response = await myDb.reading('''SELECT * FROM 'TABLE1' ''');
    myList = [];
    myList.addAll(response);
    setState(() {});
  }

  Future<void> _signup() async {
    String email = emailController.text.trim();
    String password = _passwordController.text.trim();

    // Check if the email contains the allowed domain
    if (email.endsWith('@eng.asu.edu.eg') && _validateInput()) {
      if (isDriver) {
           FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email:  "$email.driver", password: password)
            .then((value) async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DriverPage()),
          );
          String? uid = await DriverController.getDriverUID();

          // Create a UserModel instance
          DriverModel driver = DriverModel(
            id: uid,
            name: nameController.text,
            email: emailController.text,
            mobile: mobileController.text,
            password: _passwordController.text,
          );
          // Add user data to Firestore
          await DriverController().addDriverData(driver);
          DriverController().getDriverData(uid!);
          _showValidSnackBar("Account Created Successfully");
        }).catchError((error) {
          // Handle authentication errors here
          print('Error: $error');
        }
        );
           // Save user data to SQLite
           await myDb.writing({
             'name': nameController.text,
             'mobile': mobileController.text,
             'password': password,
             'email': emailController.text,
           });
           Reading_Database();
           setState(() {});
      }
      else {
        FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: email, password: password)
            .then((value) async {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => const RideRequestPage()),);
          String? uid = await UserController.getUserUID();

          // Create a UserModel instance
          UserModel user = UserModel(
            id: uid,
            name: nameController.text,
            email: emailController.text,
            mobile: mobileController.text,
            password: _passwordController.text,
          );

          // Add user data to Firestore
          await UserController().addUserData(user);
          UserController().getUserData(uid!);
          _showValidSnackBar("Account Created Successfully");
        }).catchError(
              (error) {
            // Handle authentication errors here
            print('Error: $error');
          },
        );
        // Save user data to SQLite
        await myDb.writing({
          'name': nameController.text,
          'mobile': mobileController.text,
          'password': password,
          'email': emailController.text,
        });
        Reading_Database();
        setState(() {});
      }
    } else if (!email.endsWith('@eng.asu.edu.eg')) {
     _showErrorSnackBar('Invalid email domain. Please use @eng.asu.edu.eg');
    }
    else {
      _showErrorSnackBar('Please fill in all fields!');
    }
  }

  bool _validateInput() {
    return nameController.text.isNotEmpty &&
        mobileController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
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
  void initState() {
    Reading_Database();
    super.initState();
    myDb.checking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Image.network(
                "https://static.vecteezy.com/system/resources/previews/019/896/008/original/male-user-avatar-icon-in-flat-design-style-person-signs-illustration-png.png",
                height: 100,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
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
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: mobileController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: "Email with @eng.asu.edu.eg",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: confirmPasswordController, // Confirm Password
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(125.0),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 }
