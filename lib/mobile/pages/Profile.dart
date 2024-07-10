import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:amplify/mobile/pages/AddCarPage.dart';
import 'package:amplify/mobile/pages/AddHousesPage.dart';
import 'package:amplify/mobile/pages/PersonalData.dart';
import 'package:amplify/mobile/pages/LoginAndRegisterPage.dart';
import 'package:amplify/mobile/pages/HomePage.dart';
import 'package:amplify/mobile/pages/AddBalance.dart';
import 'package:amplify/mobile/pages/changeCard.dart';
import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/firebase_users.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _userName = 'Loading...';
  late File _profileImage;
  UserData _currentUserData = UserData(UID: '', email: '', hasSetupAccount: false, firstName: '', lastName: '', dateOfBirth: DateTime.now(), gender: '');
  final FirebaseUsers _firebaseUsers = FirebaseUsers();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String userUID = Auth().currentUserUID;
      String fullName = await _firebaseUsers.getUserFullName(userUID);
      UserData currentUserData = await _firebaseUsers.getUserData(userUID);
      setState(() {
        _currentUserData = currentUserData;
        // Assuming profile image URL is fetched and converted to File
        
        _profileImage = File('assets/images/logo.png');
        _userName = fullName;
      });
    } catch (e) {
      setState(() {
        _userName = 'Error fetching name';
      });
      print('Error fetching user data: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Color.fromARGB(255, 158, 251, 77), // Verde
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  backgroundColor: Color.fromARGB(255, 169, 169, 169), // Cinzento
                  child: _profileImage == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Color.fromARGB(255, 255, 255, 255), // Branco
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Text(
                _userName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0), // Preto
                ),
              ),
              SizedBox(height: 30),
              buildButton(
                context: context,
                icon: Icons.lock,
                label: 'Dados Pessoais',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DadosPessoais()),
                  );
                },
                backgroundColor: Color.fromARGB(255, 192, 192, 192), // Cinzento claro
                textColor: Color.fromARGB(255, 0, 0, 0), // Preto
              ),
              buildButton(
                context: context,
                icon: Icons.account_balance_wallet,
                label: 'Carregar conta',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => addBalance()),
                  );
                },
                backgroundColor: Color.fromARGB(255, 192, 192, 192), // Cinzento claro
                textColor: Color.fromARGB(209, 6, 0, 0), // Preto
              ),
              buildButton(
                context: context,
                icon: Icons.directions_car,
                label: 'Gerir Carros',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddCarPage(
                          currentUserData: _currentUserData,
                          profileImage: _profileImage,
                        )),
                  );
                },
                backgroundColor: Color.fromARGB(255, 192, 192, 192), // Cinzento claro
                textColor: Color.fromARGB(209, 6, 0, 0), // Preto
              ),
              buildButton(
                context: context,
                icon: Icons.home,
                label: 'Gerir Casas',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddHousePage(
                              currentUserData: _currentUserData,
                              profileImage: _profileImage,
                            )),
                  );
                },
                backgroundColor: Color.fromARGB(255, 192, 192, 192), // Cinzento claro
                textColor: Color.fromARGB(209, 6, 0, 0), // Preto
              ),
              buildButton(
                context: context,
                icon: Icons.help_outline,
                label: 'Ajuda',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()), // Ação para Ajuda
                  );
                },
                backgroundColor: Color.fromARGB(255, 192, 192, 192), // Cinzento claro
                textColor: Color.fromARGB(255, 0, 0, 0), // Preto
              ),
              Spacer(),
              buildButton(
                context: context,
                icon: Icons.logout,
                label: 'Log Out',
                onPressed: () {
                  Auth().signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginAndRegisterPage()),
                  );
                },
                backgroundColor: Color.fromARGB(255, 255, 0, 0), // Vermelho
                textColor: Color.fromARGB(255, 255, 255, 255), // Branco
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 15),
          elevation: 5,
          shadowColor: Colors.black54,
          animationDuration: Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
