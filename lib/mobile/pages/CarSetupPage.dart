import 'dart:io';

import 'package:amplify/mobile/components/costum_text_field.dart';
import 'package:amplify/models/car_model.dart';
import 'package:amplify/models/charger_type.dart';
import 'package:amplify/models/chargers_types.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/media_query_helpers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CarSetupPage extends StatefulWidget {
  @override
  _CarSetupPageState createState() => _CarSetupPageState();
}

class _CarSetupPageState extends State<CarSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matriculationController = TextEditingController();
  GeoPoint? _geoPoint;
  String? _addressError;
  File _image1 = File("assets/images/profileImagePlaceHolder.png");
  bool _isImage1Picked = false;
  File _image2 = File("assets/images/profileImagePlaceHolder.png");
  bool _isImage2Picked = false;

  ChargerConnectionType _selectedChargerType = ChargerConnectionType.level1;

  void _submit() {
    String matriculation = _matriculationController.text;
    String newUID = Uuid().v4();

    CarData _newCar = CarData(
      UID: newUID,
      ownerUID: Auth().currentUserUID,
      matriculation: matriculation,
      chagerType: _selectedChargerType.toString(),
    );

    // Save to Firestore or perform other actions
    FirebaseFirestore.instance.collection('Cars').doc(_newCar.UID).set(
          _newCar.toJson(),
        );
    print("passou");

    //ADD images to storage
    if (_isImage1Picked) _uploadImage(_newCar.UID, _image1);
    if (_isImage2Picked) _uploadImage(_newCar.UID, _image2);

    // Clear the form
    _matriculationController.clear();
    setState(() {
      _geoPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "New Car",
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
                          "Setup the details of your car to display in the marketplace.",
                        )),
                  ],
                ),
                SizedBox(height: displayHeight(context) * 0.06),
                Container(
                  height: displayHeight(context) * 0.25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              pickImage1();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: displayHeight(context) * 0.25,
                                width: displayWidth(context) * 0.4,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
                                  image: DecorationImage(
                                    image: FileImage(_image1), // placeholder
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: !_isImage1Picked
                                    ? Image.asset(
                                        "assets/images/pickImageIcon.png",
                                        scale: 6,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _isImage1Picked,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isImage1Picked = false;
                                      _image1 = File(
                                          "assets/images/profileImagePlaceHolder.png");
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    size: 24, // Adjust the size as needed
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(children: [
                        GestureDetector(
                          onTap: () {
                            pickImage2();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: displayHeight(context) * 0.25,
                              width: displayWidth(context) * 0.4,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  width: 2,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                image: DecorationImage(
                                  image: FileImage(_image2), // placeholder
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: !_isImage2Picked
                                  ? Image.asset(
                                      "assets/images/pickImageIcon.png",
                                      scale: 6,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _isImage2Picked,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isImage2Picked = false;
                                    _image2 = File(
                                        "assets/images/profileImagePlaceHolder.png");
                                  });
                                },
                                icon: const Icon(
                                  Icons.remove_circle,
                                  size: 24, // Adjust the size as needed
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.06),
                CostumTextField(
                    textController: _matriculationController,
                    hintText: "Matriculation",
                    isPassword: false),
                SizedBox(height: displayHeight(context) * 0.03),
                Container(
                  width: displayWidth(context) * 0.9,
                  height: displayHeight(context) * 0.24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
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
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Charger Type",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: ChargerConnectionType.values.map((type) {
                          return ChoiceChip(
                            backgroundColor:
                                Colors.white, // Selected chip color
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8), // Unselected chip color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.all(10),
                            labelPadding: const EdgeInsets.all(2),
                            label: Text(type.toString().split('.').last),
                            selected: _selectedChargerType == type,
                            onSelected: (selected) {
                              setState(() {
                                _selectedChargerType = type;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.06),
                Container(
                  width: displayWidth(context) * 0.9,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.all(Radius.circular(30)),
                  ),
                  child: TextButton(
                      onPressed: () async {
                        if (_matriculationController.text.isNotEmpty) {
                          _submit();
                          Navigator.pop(context);
                        } else {}
                      },
                      child: Text(
                        "Add" + " " + _matriculationController.text,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontSize: 20),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _matriculationController.dispose();
    super.dispose();
  }

  Future pickImage1() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => _image1 = imageTemp);
      setState(() => _isImage1Picked = true);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImage2() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => _image2 = imageTemp);
      setState(() => _isImage2Picked = true);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _uploadImage(String carUID, File image) async {
    final _firebaseStorage = FirebaseStorage.instance;
    await _firebaseStorage
        .ref()
        .child("car_pictures/$carUID.jpg")
        .putFile(image);
  }
}
