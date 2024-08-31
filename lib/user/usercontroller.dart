import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled2/user/usermodel.dart';

class UserController {
  final _db = FirebaseFirestore.instance;

  static Future<String?> getUserUID() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Check if the user is signed in
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      print('User UID: $uid');
      return uid;
    } else {
      print('User is not signed in');
      return null;
    }
  }

  Future<void> addUserData(UserModel user) async {
    String? uid = await getUserUID();

    if (uid != null) {
      _db
          .collection('Users')
          .doc(uid)
          .set(UserModel.toJson(user))
          .then((value) {
        print("Data inserted for UID: $uid");
      }).catchError((error) {
        print("Error adding data: $error");
      });
    } else {
      print("User UID not available. Cannot add user data.");
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
      await _db.collection('Users').doc(uid).get();

      if (userSnapshot.exists) {
        UserModel user = UserModel.fromSnapshot(userSnapshot);
        print('User data found for UID: $uid: $user');
        return user;
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
