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
    homeNameController.clear();
    latController.clear();
    lngController.clear();
    speedController.clear();
    voltageController.clear();
    sliderValue = 0.0;
    selectedCharger = chargerTypes[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Home'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: homeNameController,
                          decoration: const InputDecoration(labelText: 'Home\'s name'),
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
                        Text('Price: ${sliderValue.toStringAsFixed(2)}'),
                        Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: 10000.0,
                          divisions: 1000,
                          label: sliderValue.toStringAsFixed(2),
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                            });
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
                        Column(
                          children: [
                            TextField(
                              controller: speedController,
                              decoration: const InputDecoration(labelText: 'Speed Of Charger'),
                            ),
                            TextField(
                              controller: voltageController,
                              decoration: const InputDecoration(labelText: 'Voltage Of Charger'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: latController,
                          decoration: const InputDecoration(labelText: 'Latitude'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty || double.tryParse(value) == null) {
                              return 'Please enter a valid latitude';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: lngController,
                          decoration: const InputDecoration(labelText: 'Longitude'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty || double.tryParse(value) == null) {
                              return 'Please enter a valid longitude';
                            }
                            return null;
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
                    if (_validateForm(homeNameController, latController, lngController, speedController, voltageController)) {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Usuário não autenticado.'),
                        ));
                        return;
                      }
                      final Uuid uuid = const Uuid();
                      String homeUID = uuid.v4();
                      String ownerUID = user.uid;
                      double lat = double.parse(latController.text);
                      double lng = double.parse(lngController.text);
                      GeoPoint address = GeoPoint(lat, lng);
                      Map<String, dynamic> homeData = {
                        'HouseUID': homeUID,
                        'HouseName': homeNameController.text,
                        'OwnerUID': ownerUID,
                        'IsOccupied': false,
                        'Address': address,
                        'Price': double.parse(sliderValue.toStringAsFixed(3)),
                        'Charger': {
                          'ConnectionType': selectedCharger,
                          'Voltage': double.parse(voltageController.text),
                          'Speed': double.parse(speedController.text),
                        },
                      };
                      try {
                        await FirebaseFirestore.instance.collection('Homes').doc(homeUID).set(homeData);

                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Casa adicionada com sucesso!'),
                        ));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Ocorreu um erro ao adicionar a casa: $e'),
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

  void _editHome(Map<String, dynamic> home) {
    homeNameController.text = home['HouseName'];
    latController.text = home['Address'].latitude.toString();
    lngController.text = home['Address'].longitude.toString();
    speedController.text = home['Charger']['Speed'].toString();
    voltageController.text = home['Charger']['Voltage'].toString();
    sliderValue = home['Price'];
    selectedCharger = home['Charger']['ConnectionType'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Home Data'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                child: SingleChildScrollView(
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: homeNameController,
                          decoration: const InputDecoration(labelText: 'Home\'s name'),
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
                        Text('Price: ${sliderValue.toStringAsFixed(2)}'),
                        Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: 10000.0,
                          divisions: 1000,
                          label: sliderValue.toStringAsFixed(2),
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                            });
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
                        Column(
                          children: [
                            TextField(
                              controller: speedController,
                              decoration: const InputDecoration(labelText: 'Speed Of Charger'),
                            ),
                            TextField(
                              controller: voltageController,
                              decoration: const InputDecoration(labelText: 'Voltage Of Charger'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: latController,
                          decoration: const InputDecoration(labelText: 'Latitude'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty || double.tryParse(value) == null) {
                              return 'Please enter a valid latitude';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: lngController,
                          decoration: const InputDecoration(labelText: 'Longitude'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty || double.tryParse(value) == null) {
                              return 'Please enter a valid longitude';
                            }
                            return null;
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
                    if (_validateForm(homeNameController, latController, lngController, speedController, voltageController)) {
                      Map<String, dynamic> homeData = {
                        'HouseUID': home['HouseUID'],
                        'HouseName': homeNameController.text,
                        'OwnerUID': home['OwnerUID'],
                        'IsOccupied': home['IsOccupied'],
                        'Address': GeoPoint(double.parse(latController.text), double.parse(lngController.text)),
                        'Price': sliderValue,
                        'Charger': {
                          'ConnectionType': selectedCharger,
                          'Voltage': double.parse(voltageController.text),
                          'Speed': double.parse(speedController.text),
                        },
                      };
                      try {
                        await FirebaseFirestore.instance.collection('Homes').doc(home['HouseUID']).update(homeData);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Casa editada com sucesso!'),
                        ));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Ocorreu um erro ao editar a casa: $e'),
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

  Future<void> _deleteHome(String houseUID, int index) async {
    try {
      await FirebaseFirestore.instance.collection('Homes').doc(houseUID).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Casa excluída com sucesso!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao excluir a casa: $e'),
      ));
    }
  }

  bool _validateForm(
      TextEditingController homeNameController,
      TextEditingController latController,
      TextEditingController lngController,
      TextEditingController speedController,
      TextEditingController voltageController) {
    if (homeNameController.text.isEmpty) {
      return false;
    }
    if (latController.text.isEmpty || double.tryParse(latController.text) == null) {
      return false;
    }
    if (lngController.text.isEmpty || double.tryParse(lngController.text) == null) {
      return false;
    }
    if (speedController.text.isEmpty || double.tryParse(speedController.text) == null) {
      return false;
    }
    if (voltageController.text.isEmpty || double.tryParse(voltageController.text) == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text('Usuário não autenticado.'),
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
            return const Center(child: Text('Não tens casas cadastradas.'));
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
    );
  }
}
