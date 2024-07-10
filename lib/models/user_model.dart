import 'package:amplify/services/helpers.dart';

class UserData {
  String UID;
  String email;
  bool hasSetupAccount = false;
  String firstName;
  String lastName;
  DateTime dateOfBirth;
  String gender;
  double balance;
  double kwhCharged = 0.0;
  int role = 0;

  UserData({
    required this.UID,
    required this.email,
    required this.hasSetupAccount,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.kwhCharged = 0.0,
    this.role = 0,
    this.balance = 0.0,
  });

  Map<String, dynamic> toJson() => {
        'UID': UID,
        'Email': email,
        'HasSetupAccount': hasSetupAccount,
        'FirstName': firstName,
        'LastName': lastName,
        'DateOfBirth': dateToFirebase(dateOfBirth),
        'gender': gender,
        'Balance': balance,
        'kwhCharged': kwhCharged,
        'role': role
      };

  ///
  ///We are getting one at a time, is this stil necessary?
  ///
  static fromJson(Map<String, dynamic> json) {
    print(json);
    return UserData(
      UID: json['UID'],
      email: json['Email'],
      hasSetupAccount: json['HasSetupAccount'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      dateOfBirth: dateFromFirebase(json['DateOfBirth']),
      gender: json['gender'],
      balance: json['Balance'],
      kwhCharged: json['kwhCharged'],
      role: json['role'],
    );
  }
}
