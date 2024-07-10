import 'dart:io';
import 'dart:async';
import 'package:amplify/mobile/pages/AddHousesPage.dart';
import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/helpers.dart';
import 'package:amplify/services/media_query_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AccountSetup extends StatefulWidget {
  const AccountSetup({Key? key}) : super(key: key);

  @override
  State<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  File profileImage = File("assets/images/profileImagePlaceHolder.png");
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  bool _hasPickedDate = false;
  String datePickerHintText = "Enter your date of birth";
  DateTime datePicked = DateTime.now();
  bool sexSelected = true;
  String _errorMessage = "";
  Position? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Container(
            height: displayHeight(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 50, 14, 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Welcome",
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
                            "We are thrilled to have you in our community!",
                          )),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Now let's get started by setting up your profile",
                          ))
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: displayHeight(context) * 0.22,
                          width: displayHeight(context) * 0.22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                            image: DecorationImage(
                                image: FileImage(profileImage),
                                fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(width: displayWidth(context) * 0.02),
                        Container(
                          height: displayHeight(context) * 0.05,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
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
                          child: TextButton(
                              onPressed: () {
                                pickImage();
                              },
                              child: const Text(
                                "Upload Photo",
                                style: TextStyle(fontSize: 12),
                              )),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _genreSelectionButton(true),
                        _genreSelectionButton(false),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: displayHeight(context) * 0.074,
                          width: displayWidth(context) * 0.45,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                topLeft: Radius.circular(30),
                                bottomLeft: Radius.circular(30)),
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
                          child: TextField(
                            controller: _firstNameController,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              hintText: "First Name",
                              hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 178, 178, 178)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          height: displayHeight(context) * 0.074,
                          width: displayWidth(context) * 0.45,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
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
                          child: TextField(
                            controller: _lastNameController,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              hintText: "Last Name",
                              hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 178, 178, 178)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                    child: Container(
                      height: displayHeight(context) * 0.074,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(30)),
                        color: Theme.of(context).colorScheme.tertiary,
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
                      child: TextField(
                        readOnly: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(20),
                          hintText: datePickerHintText,
                          hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: !_hasPickedDate
                                  ? const Color.fromARGB(255, 178, 178, 178)
                                  : Theme.of(context).colorScheme.primary),
                          border: InputBorder.none,
                        ),
                        onTap: () async {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) => Container(
                                    height: 250,
                                    child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        maximumDate: DateTime(
                                            DateTime.now().year - 18,
                                            DateTime.now().month,
                                            DateTime.now().day),
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        initialDateTime: DateTime(
                                            DateTime.now().year - 18,
                                            DateTime.now().month,
                                            DateTime.now().day),
                                        onDateTimeChanged: (DateTime newDate) {
                                          setState(() {
                                            datePicked = newDate;
                                            if (datePicked == DateTime.now()) {
                                              return;
                                            } else {
                                              setState(() {
                                                _hasPickedDate = true;
                                                datePickerHintText =
                                                    "${datePicked.day} / ${datePicked.month} / ${datePicked.year}";
                                              });
                                            }
                                          });
                                        }),
                                  ));
                        },
                      ),
                    ),
                  ),
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                        fontSize: 12, color: Color.fromARGB(255, 212, 97, 88)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Auth().signOut();
                            },
                            child: const Text(
                              "Sign out",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 212, 97, 88),
                              ),
                            )),
                        Container(
                          width: displayWidth(context) * 0.3,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(30)),
                          ),
                          child: TextButton(
                              onPressed: () async {
                                if (!_advancePageCheck()) {
                                  setState(() {
                                    _errorMessage = "Missing information";
                                  });
                                } else {
                                  await _getCurrentPosition();
                                  setState(() {
                                    _errorMessage = "";
                                  });
                                  _createUserAndNavigate();
                                }
                              },
                              child: Text(
                                "Next",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontSize: 16),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector _genreSelectionButton(bool sex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          sexSelected = sex;
        });
      },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.decelerate,
          height: 45,
          width: sexSelected == sex
              ? MediaQuery.of(context).size.width * 0.6
              : MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
              color: sexSelected == sex
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(30),
              border: sexSelected == sex
                  ? null
                  : Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 3)),
          child: Icon(
            sex ? Icons.male : Icons.female,
            size: 35,
            color: sexSelected == sex
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.secondary,
          )),
    );
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => profileImage = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  bool _advancePageCheck() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _hasPickedDate;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  void _createUserAndNavigate() async {
    // Cria o usuário com as características especificadas
    UserData newUser = UserData(
      UID: Auth().currentUser!.uid,
      email: Auth().currentUser!.email!,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      dateOfBirth: datePicked,
      gender: sexSelected ? "Male" : "Female",
      hasSetupAccount: true,
    );

    // Adiciona o usuário ao Firestore
    final json = newUser.toJson();
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(Auth().currentUser!.uid.toString())
        .set(json);

    // Navega para a página AddHousePage
    goToPage(
        context,
        AddHousePage(
            currentUserData: newUser, profileImage: profileImage));
  }
}
