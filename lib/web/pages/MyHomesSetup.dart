import 'package:amplify/web/pages/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../widgets/NavigationBarLogin.dart';

class MyHomes extends StatefulWidget {
  const MyHomes({Key? key}) : super(key: key);

  @override
  _MyHomesState createState() => _MyHomesState();
}

class _MyHomesState extends State<MyHomes> {
  final TextEditingController homeNameController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController speedController = TextEditingController();
  final TextEditingController voltageController = TextEditingController();
  double sliderValue = 0.0;
  String selectedCharger = 'Level 1';
  final List<String> chargerTypes = [
    'Level 1',
    'Level2J1772',
    'Level2Type2',
    'dcFastChademo',
    'dcFastCCS',
    'dcFastTesla',
    'teslaWallConnector'
  ];

  void _addHome(BuildContext context) {
    // Implementação do método _addHome
    // ...

    // Código existente do método _addHome
  }

  void _editHome(Map<String, dynamic> home) {
    // Implementação do método _editHome
    // ...

    // Código existente do método _editHome
  }

  Future<void> _deleteHome(String houseUID, int index) async {
    // Implementação do método _deleteHome
    // ...

    // Código existente do método _deleteHome
  }


  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Usuário não autenticado.'),
        ),
        appBar: AppBar(
          title: const NavigationBarU(),
          actions: [
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      appBar: AppBar(
        title: const NavigationBarU(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Homes')
            .where('OwnerUID', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Não tens casas.'));
          }

          final homes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: homes.length,
            itemBuilder: (context, index) {
              final home = homes[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Text(home['HouseName']),
                subtitle: Text('Address: Lat: ' +
                    home['Address'].latitude.toString() +
                    ', Lng: ' +
                    home['Address'].longitude.toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editHome(home);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteHome(home['HouseUID'], index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addHome(context),
        child: Text('Add House'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        width: double.infinity,
        color: Colors.grey[300],
        child: ElevatedButton(
          onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  },
  child: Text('Login'),
),
        ),
      );
    
  }
}
