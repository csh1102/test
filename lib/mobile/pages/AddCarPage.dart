import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/models/user_model.dart';
import 'package:amplify/models/car_model.dart';
import 'package:amplify/services/firebase_users.dart';
import 'package:amplify/mobile/pages/CarSetupPage.dart';
import 'package:amplify/mobile/pages/HomePage.dart';
import 'package:amplify/services/helpers.dart';
import 'package:amplify/services/media_query_helpers.dart';

class AddCarPage extends StatefulWidget {
  final UserData currentUserData;
  final File profileImage;

  AddCarPage({
    Key? key,
    required this.currentUserData,
    required this.profileImage,
  }) : super(key: key);

  @override
  State<AddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  List<CarData> cars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      List<CarData> loadedCars =
          await FirebaseUsers().getUserCars(Auth().currentUser!.uid);
      setState(() {
        cars = loadedCars;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cars: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Add Cars",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 34,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Here you can add any of your cars that you want to display in the marketplace.",
                      ),
                    ),
                  ],
                ),
                isLoading
                    ? Container(
                        height: displayHeight(context) * 0.35,
                        child: const CircularProgressIndicator(),
                      )
                    : cars.isNotEmpty
                        ? Container(
                            height: displayHeight(context) * 0.4,
                            child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: cars.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30)),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: const Offset(0, 0),
                                          blurRadius: 8.0,
                                          spreadRadius: 0.5,
                                          color: const Color.fromARGB(
                                                  255, 59, 59, 59)
                                              .withOpacity(0.2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 120, // Adjust height as needed
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/logo.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cars[index].matriculation,
                                                    style: const TextStyle(
                                                      fontSize: 18.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    cars[index].chagerType,
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () async {
                                                  await FirebaseUsers()
                                                      .deleteCar(
                                                          cars[index].UID);
                                                  _loadCars();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              goToPage(context, CarSetupPage());
                            },
                            child: Container(
                              height: displayHeight(context) * 0.35,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(150)),
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 0),
                                    blurRadius: 8.0,
                                    spreadRadius: 0.5,
                                    color: const Color.fromARGB(
                                            255, 59, 59, 59)
                                        .withOpacity(0.1),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/images/addHouseIcon.png",
                                scale: 4,
                              ),
                            ),
                          ),
                Column(
                  children: [
                    Visibility(
                      visible: cars.isNotEmpty,
                      child: Column(
                        children: [
                          Container(
                            width: displayWidth(context) * 0.8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(30)),
                            ),
                            child: TextButton(
                              onPressed: () {
                                goToPage(context, CarSetupPage());
                              },
                              child: Text(
                                "Add more cars",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: displayWidth(context) * 0.8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(30)),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                _updateUserData();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: Text(
                                "Finish setup",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: cars.isEmpty,
                      child: Container(
                        width: displayWidth(context) * 0.3,
                        height: displayHeight(context) * 0.1,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Add later",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateUserData() {
    UserData newUser = UserData(
      UID: Auth().currentUser!.uid,
      email: Auth().currentUser!.email!,
      firstName: widget.currentUserData.firstName,
      lastName: widget.currentUserData.lastName,
      dateOfBirth: widget.currentUserData.dateOfBirth,
      gender: widget.currentUserData.gender,
      hasSetupAccount: true,
    );

    final json = newUser.toJson();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(Auth().currentUser!.uid.toString())
        .update(json);

    _uploadImage();
  }

  void _uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    await _firebaseStorage
        .ref()
        .child("ProfilePictures/" +
            Auth().currentUser!.uid.toString() +
            ".jpg")
        .putFile(widget.profileImage);
  }
}
