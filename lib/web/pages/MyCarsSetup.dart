import 'package:amplify/web/pages/MyHomesSetup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../widgets/NavigationBarLogin.dart';

class MyCars extends StatefulWidget {
  const MyCars({Key? key}) : super(key: key);

  @override
  _MyCarsState createState() => _MyCarsState();
}

class _MyCarsState extends State<MyCars> {
  final TextEditingController matriculationController = TextEditingController();
  final TextEditingController chargerTypeController = TextEditingController();
  final List<String> chargerTypes = [
    'Level 1',
    'Level2J1772',
    'Level2Type2',
    'dcFastChademo',
    'dcFastCCS',
    'dcFastTesla',
    'teslaWallConnector'
  ];

  void _addCar(BuildContext context) {
    final TextEditingController addMatriculationController = TextEditingController();
    String selectedCharger = chargerTypes[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Car'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: addMatriculationController,
                          decoration: const InputDecoration(labelText: 'Car\'s Matriculation'),
                          maxLines: 1,
                          maxLength: 100,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a matriculation';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Charger Type'),
                          value: selectedCharger,
                          items: chargerTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedCharger = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    if (_validateForm(addMatriculationController)) {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Usuário não autenticado.'),
                        ));
                        return;
                      }
                      final Uuid uuid = const Uuid();
                      String carUID = uuid.v4(); // Use um identificador único para o carro
                      String ownerUID = user.uid; // Use o identificador do proprietário
                      Map<String, dynamic> carData = {
                        'chargerType': selectedCharger,
                        'matriculation': addMatriculationController.text,
                        'OwnerUID': ownerUID,
                        'UID': carUID,
                      };
                      try {
                        await FirebaseFirestore.instance
                            .collection('Cars')
                            .doc(carUID)
                            .set(carData);

                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Carro adicionado com sucesso!'),
                        ));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Ocorreu um erro ao adicionar o carro: $e'),
                        ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Por favor, preencha todos os campos corretamente.'),
                      ));
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editCar(Map<String, dynamic> car) {
    final TextEditingController editMatriculationController = TextEditingController(text: car['matriculation']);
    String selectedCharger = car['chargerType'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Car Data'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: editMatriculationController,
                          decoration: const InputDecoration(labelText: 'Car\'s matriculation'),
                          maxLines: 1,
                          maxLength: 100,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Charger Type'),
                          value: selectedCharger,
                          items: chargerTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedCharger = newValue!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    Map<String, dynamic> carData = {
                      'OwnerUID': car['OwnerUID'],
                      'matriculation': editMatriculationController.text,
                      'chargerType': selectedCharger,
                      'UID': car['UID'],
                    };
                    FirebaseFirestore.instance
                        .collection('Cars')
                        .doc(car['UID'])
                        .update(carData);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCar(String carUID) async {
    try {
      await FirebaseFirestore.instance.collection('Cars').doc(carUID).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carro excluído com sucesso!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao excluir o carro: $e'),
      ));
    }
  }

  bool _validateForm(TextEditingController controller) {
    return controller.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: NavigationBarU(),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Cars')
                    .where('OwnerUID', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('Não tens carros na garagem.');
                  } else {
                    List<Map<String, dynamic>> userCars = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    return ListView.builder(
                      itemCount: userCars.length,
                      itemBuilder: (context, index) {
                        final car = userCars[index];
                        return ListTile(
                          title: Text('Matriculation: ' + car['matriculation']),
                          subtitle: Text('Charger Type: ' + car['chargerType']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _editCar(car);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteCar(car['UID']);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addCar(context),
              child: Text('Adicionar Carro'),
            ),
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomes()),
    );
  },
  child: Text('Next to MyHomes'),
),
          ],
        ),
      ),
    );
  }
}
