import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final String password;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
  });

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return UserModel(
        id: document.id,
        name: data['Name'] ?? '',
        email: data['Email'] ?? '',
        mobile: data['Phone'] ?? '',
        password: data['Password'] ?? '',
      );
    } else {
      return emptyUser();
    }
  }

  static emptyUser() {
    return {
      "Name": ' ',
      "Email": ' ',
      "Phone": ' ',
      "Password": ' ',
    };
  }

  static Map<String, dynamic> toJson(UserModel user) {
    return {
      "Name": user.name,
      "Email": user.email,
      "Phone": user.mobile,
      "Password": user.password,
    };
  }
}