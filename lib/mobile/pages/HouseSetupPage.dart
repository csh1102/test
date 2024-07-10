import 'dart:io';

import 'package:amplify/mobile/components/costum_text_field.dart';
import 'package:amplify/models/charger_type.dart';
import 'package:amplify/models/chargers_types.dart';
import 'package:amplify/models/house_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/media_query_helpers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_webservice/places.dart' as places;
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:uuid/uuid.dart';

class HouseSetupPage extends StatefulWidget {
  @override
  _HouseSetupPageState createState() => _HouseSetupPageState();
}

class _HouseSetupPageState extends State<HouseSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  GeoPoint? _geoPoint;
  String? _addressError;
  File _image1 = File("assets/images/profileImagePlaceHolder.png");
  bool _isImage1Picked = false;
  File _image2 = File("assets/images/profileImagePlaceHolder.png");
  bool _isImage2Picked = false;

  final places.GoogleMapsPlaces _places = places.GoogleMapsPlaces(
      apiKey: 'AIzaSyDrnY80rvRZxEam_28G9U5RTSxY1hA9duo');

  ChargerConnectionType _selectedChargerType = ChargerConnectionType.level1;
  int _voltage = 20;
  int _speed = 5;

  Future<void> _pickAddress(String address) async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(address);
      if (locations.isNotEmpty) {
        geocoding.Location location = locations.first;
        setState(() {
          _geoPoint = GeoPoint(location.latitude, location.longitude);
        });
      }
    } catch (e) {
      setState(() {
        _addressError = 'Error: Could not retrieve location';
      });
      print('Error: $e');
    }
  }

  Future<List<String>> _getAddressSuggestions(String query) async {
    if (query.isEmpty) return [];
    try {
      final response = await _places.autocomplete(query, types: ['geocode']);
      if (response.isOkay) {
        // print('Response predictions: ${response.predictions}');
        return response.predictions
            .map((p) => p.description)
            .whereType<String>() // Filter out any null values
            .toList();
      } else {
        // print('Error: ${response.errorMessage}');
        return [];
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      return [];
    }
  }

  void _submit() {
    String houseName = _houseNameController.text;
    GeoPoint? address = _geoPoint;
    double? price = double.tryParse(_priceController.text);

    HouseData _newHouse = HouseData(
        houseUID: Uuid().v4(),
        houseName: houseName,
        ownerUID: Auth().currentUserUID,
        isOccupied: false,
        address: address!,
        price: price,
        charger: ChargerData(
            connectionType: _selectedChargerType,
            voltage: _voltage.toDouble(),
            speed: _speed.toDouble()));

    // Save to Firestore or perform other actions
    FirebaseFirestore.instance.collection('Homes').doc(_newHouse.houseUID).set(
          _newHouse.toJson(),
        );
    print("passou");

    //ADD images to storage
    if (_isImage1Picked) _uploadImage(_newHouse.houseUID, _image1);
    if (_isImage2Picked) _uploadImage(_newHouse.houseUID, _image2);

    // Clear the form
    _houseNameController.clear();
    _addressController.clear();
    _priceController.clear();
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
                        "New House",
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
                          "Setup the details of your house to display in the marketplace.",
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
                    textController: _houseNameController,
                    hintText: "House name",
                    isPassword: false),
                SizedBox(height: displayHeight(context) * 0.03),
                Container(
                  height: displayHeight(context) * 0.074,
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
                  child: TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _addressController,
                      decoration: InputDecoration(
                        border: InputBorder.none, // Remove the underline
                        errorText: _addressError,
                        contentPadding: const EdgeInsets.all(20),
                        hintText: "Address",
                        hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 178, 178, 178)),
                      ),
                    ),
                    suggestionsCallback: _getAddressSuggestions,
                    itemBuilder: (context, String suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (String suggestion) {
                      _addressController.text = suggestion;
                      _pickAddress(suggestion);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                ),
                if (_geoPoint != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                        'Selected Location: ${_geoPoint!.latitude}, ${_geoPoint!.longitude}'),
                  ),
                SizedBox(height: displayHeight(context) * 0.03),
                CostumTextField(
                    textController: _priceController,
                    hintText: "Price per minute",
                    isPassword: false),
                SizedBox(height: displayHeight(context) * 0.04),
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
                SizedBox(height: displayHeight(context) * 0.03),
                Container(
                  width: displayWidth(context) * 0.9,
                  height: displayHeight(context) * 0.12,
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
                          "Voltage (Watts)",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      NumberPicker(
                        axis: Axis.horizontal,
                        value: _voltage,
                        minValue: 0,
                        maxValue: 500,
                        onChanged: (value) => setState(() => _voltage = value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.03),
                Container(
                  width: displayWidth(context) * 0.9,
                  height: displayHeight(context) * 0.12,
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
                          "Speed (Km in an hour)",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      NumberPicker(
                        axis: Axis.horizontal,
                        value: _speed,
                        minValue: 0,
                        maxValue: 200,
                        onChanged: (value) => setState(() => _speed = value),
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
                        if (_addressController.text.isNotEmpty &&
                            _houseNameController.text.isNotEmpty) {
                          _submit();
                          Navigator.pop(context);
                        } else {}
                      },
                      child: Text(
                        "Add" + " " + _houseNameController.text,
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
    _houseNameController.dispose();
    _addressController.dispose();
    _priceController.dispose();
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

  void _uploadImage(String houseUUID, File image) async {
    final _firabaseStorage = FirebaseStorage.instance;
    await _firabaseStorage
        .ref()
        .child("house_pictures/$houseUUID.jpg")
        .putFile(image);
  }
}
