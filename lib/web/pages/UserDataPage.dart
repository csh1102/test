import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user_model.dart';
import '../../services/firebase_users.dart';
import '../../services/helpers.dart';
import '../widgets/NavigationBarLogin.dart';
import 'LoginPage.dart';

class Userdatapage extends StatefulWidget {
  const Userdatapage({super.key});

  @override
  _UserdatapageState createState() => _UserdatapageState();
}

class _UserdatapageState extends State<Userdatapage> {
  File? _image;
  DateTime? _selectedDate;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  int _selectedGender = 1;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? useri = FirebaseAuth.instance.currentUser;
    if (useri == null) {
      Future.delayed(
        const Duration(seconds: 1),
            () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ),
      );
      return;
    }
    UserData temp = await FirebaseUsers().getUserData(useri.uid);
    setState(() {
      _selectedDate = temp.dateOfBirth;
      birthDateController.text = _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : '';
      firstNameController.text = temp.firstName;
      lastNameController.text = temp.lastName;
      if (temp.gender == 'Male') {
        _selectedGender = 1;
      } else if (temp.gender == 'Female') {
        _selectedGender = 2;
      } else {
        _selectedGender = 3;
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        birthDateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _saveImageUrlToFirestore(String imageUrl, String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'profileImage': imageUrl,
    });
  }

  Future<void> _submitData() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    dynamic dateOfBirth = dateToFirebase(_selectedDate!);
    int gender = _selectedGender;

    try {
      User? useri = FirebaseAuth.instance.currentUser;
      if (useri != null) {
        String? imageUrl;
        if (_image != null) {
          imageUrl = await _uploadImageToFirebase(_image!);
          await _saveImageUrlToFirestore(imageUrl, useri.uid);
        }

        await FirebaseUsers().updateUserData(useri.uid, {
          'FirstName': firstName,
          'LastName': lastName,
          'DateOfBirth': dateOfBirth,
          'gender': gender == 1 ? 'Male' : gender == 2 ? 'Female' : 'Other',
          if (imageUrl != null) 'profileImage': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data successfully updated!'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update data: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      appBar: AppBar(
        title: const NavigationBarU(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      maxLines: 1,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the First Name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      maxLines: 1,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Last Name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Gender', style: TextStyle(fontSize: 16.0)),
                  GenderSwitcher(
                    onGenderSelected: (int gender) {
                      setState(() {
                        _selectedGender = gender;
                      });
                    },
                    selectedGender: _selectedGender,
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: birthDateController,
                          decoration: InputDecoration(
                            labelText: 'Birth Date',
                            hintText: _selectedDate == null
                                ? 'Select your birth date'
                                : DateFormat.yMd().format(_selectedDate!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _submitData,
                        child: const Text('Confirm'),
                      ),
                      const SizedBox(width: 16.0),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Column(
              children: [
                _image == null
                    ? Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.person, size: 100, color: Colors.grey),
                )
                    : Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Upload Photo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GenderSwitcher extends StatefulWidget {
  final Function(int) onGenderSelected;
  final int selectedGender;

  const GenderSwitcher({required this.onGenderSelected, required this.selectedGender});

  @override
  _GenderSwitcherState createState() => _GenderSwitcherState();
}

class _GenderSwitcherState extends State<GenderSwitcher> {
  late List<bool> isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = [
      widget.selectedGender == 1,
      widget.selectedGender == 2,
      widget.selectedGender == 3,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(10.0),
        borderColor: Colors.blue,
        selectedBorderColor: Colors.blue,
        fillColor: Colors.blue.withOpacity(0.2),
        selectedColor: Colors.blue,
        onPressed: (int index) {
          setState(() {
            for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
              isSelected[buttonIndex] = buttonIndex == index;
            }
            widget.onGenderSelected(index + 1);
          });
        },
        isSelected: isSelected,
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Male'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Female'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Other'),
          ),
        ],
      ),
    );
  }
}
