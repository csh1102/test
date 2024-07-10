import 'dart:async';
import 'dart:io';
import 'package:amplify/mobile/pages/AddCarPage.dart';
import 'package:amplify/mobile/pages/AddCardPage.dart';
import 'package:amplify/mobile/pages/HomePage.dart';
import 'package:amplify/mobile/pages/HouseSetupPage.dart';
import 'package:amplify/models/house_model.dart';
import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/firebase_houses.dart';
import 'package:amplify/services/helpers.dart';
import 'package:amplify/services/media_query_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class AddHousePage extends StatefulWidget {
  UserData currentUserData;
  File profileImage;
  AddHousePage(
      {Key? key, required this.currentUserData, required this.profileImage})
      : super(key: key);

  @override
  State<AddHousePage> createState() => _AddHousePageState();
}

class _AddHousePageState extends State<AddHousePage> {
  List<HouseData> houses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                      "Add Houses",
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
                      "Here you can add any of your houses that you want to display in the marketplace.",
                    ),
                  ),
                ],
              ),
              FutureBuilder(
                future: FirebaseHouses().getUsersHouse(Auth().currentUser!.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<List<HouseData>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: displayHeight(context) * 0.35,
                        child: const CircularProgressIndicator());
                  } else {
                    if (snapshot.data!.isNotEmpty) {
                      houses = snapshot.data!;
                      return Container(
                        height: displayHeight(context) * 0.4,
                        child: ListView.builder(
                          itemCount: houses.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 0),
                                      blurRadius: 8.0,
                                      spreadRadius: 0.5,
                                      color: const Color.fromARGB(255, 59, 59, 59)
                                          .withOpacity(0.2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 120, // Adjust height as needed
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/logo.png'), // Replace with your image path
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
                                                houses[index].houseName,
                                                style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              FutureBuilder(
                                                future: getAddressFromGeoPoint(
                                                    houses[index].address),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String?>
                                                        snapshot) {
                                                  if (snapshot.connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const Text("Loading...");
                                                  } else {
                                                    return Text(
                                                      snapshot.data.toString(),
                                                      style: const TextStyle(
                                                          fontSize: 14.0),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () async {
                                              await FirebaseHouses().deleteHouse(
                                                  houses[index].houseUID);
                                              _loadHouses();
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
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          goToPage(context, HouseSetupPage());
                        },
                        child: Container(
                          height: displayHeight(context) * 0.35,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(150)),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 0),
                                blurRadius: 8.0,
                                spreadRadius: 0.5,
                                color:
                                    const Color.fromARGB(255, 59, 59, 59).withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/images/addHouseIcon.png",
                            scale: 4,
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              Column(
                children: [
                  Visibility(
                    visible: houses.isNotEmpty,
                    child: Column(
                      children: [
                        Container(
                          width: displayWidth(context) * 0.8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                          ),
                          child: TextButton(
                            onPressed: () {
                              goToPage(context, HouseSetupPage());
                            },
                            child: Text(
                              "Add more houses",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
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
                            borderRadius: const BorderRadius.all(Radius.circular(30)),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              _updateUserData();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: Text(
                              "Finish setup",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: houses.isEmpty,
                    child: Container(
                      width: displayWidth(context) * 0.3,
                      height: displayHeight(context) * 0.1,
                      child: TextButton(
                        onPressed: () {},
                        child: TextButton(
                          child: const Text(
                            "Add later",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCarPage(
                                  currentUserData: widget.currentUserData,
                                  profileImage: widget.profileImage,
                                ),
                              ),
                            );
                          },
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
    final _firabaseStorage = FirebaseStorage.instance;
    await _firabaseStorage
        .ref()
        .child("ProfilePictures/" + Auth().currentUser!.uid.toString() + ".jpg")
        .putFile(widget.profileImage);
  }

  Future<String?> getAddressFromGeoPoint(GeoPoint geoPoint) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        geoPoint.latitude,
        geoPoint.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return placemark.locality;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching address: $e');
      return null;
    }
  }

  void _loadHouses() async {
    List<HouseData> loadedHouses =
        await FirebaseHouses().getUsersHouse(Auth().currentUser!.uid);
    setState(() {
      houses = loadedHouses;
    });
  }
}
