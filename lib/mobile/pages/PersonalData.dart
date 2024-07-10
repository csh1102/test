import 'package:amplify/mobile/pages/ChangePasswordPage.dart';
import 'package:amplify/services/firebase_users.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DadosPessoais extends StatefulWidget {
  @override
  _DadosPessoaisState createState() => _DadosPessoaisState();
}

class _DadosPessoaisState extends State<DadosPessoais> {
  String _userName = 'Loading...';
  String _email = 'Loading...';
  String _phoneNumber = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userUID = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userUID).get();
        setState(() {
          _userName = userDoc['FirstName'] + ' ' + userDoc['LastName'];
          _email = userDoc['Email'];
          _phoneNumber = userDoc['UID'];
        });
      }
    } catch (e) {
      setState(() {
        _userName = 'Error fetching name';
        _email = 'Error fetching email';
        _phoneNumber = 'Error fetching phone number';
      });
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Informações do Usuário'),
        backgroundColor: Color.fromARGB(221, 174, 171, 171),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoSection('User Name', _userName),
            SizedBox(height: 20),
            _buildInfoSection('Email', _email),
            SizedBox(height: 20),
            _buildInfoSection('Nº Telemóvel', _phoneNumber),
            SizedBox(height: 40),
            _buildActionButton('Alterar password', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordPage()),
              );
            }),
            SizedBox(height: 20),
            _buildActionButton('Alterar (arranjar ideia)', () {
              // Lógica para outra ação
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(31, 98, 0, 0),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        padding: EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: DadosPessoais(),
  ));
}