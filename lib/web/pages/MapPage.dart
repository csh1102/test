import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../widgets/NavigationBarLogin.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markers = {};
  List<Property> _properties = [];
  List<Property> _visibleProperties = [];
  GoogleMapController? _mapController;
  bool _isPopupVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchPropertiesFromFirebase();
  }

  Future<void> _fetchPropertiesFromFirebase() async {
    CollectionReference collection =
        FirebaseFirestore.instance.collection('Homes');
    QuerySnapshot querySnapshot = await collection.get();
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    List<Property> properties = documents.map((doc) {
      GeoPoint geoPoint = doc['Address'];
      Marker marker = Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        infoWindow: InfoWindow(title: doc['HouseName']),
      );
      _markers.add(marker);
      return Property(
        name: doc['HouseName'],
        id: doc.id,
        price: doc['Price'],
        geoPoint: geoPoint,
      );
    }).toList();

    setState(() {
      _properties = properties;
      _updateVisibleProperties();
    });
  }

  void _updateVisibleProperties() async {
    if (_mapController == null) return;

    LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();
    List<Property> visibleProperties = _properties.where((property) {
      return visibleRegion.contains(
          LatLng(property.geoPoint.latitude, property.geoPoint.longitude));
    }).toList();

    setState(() {
      _visibleProperties = visibleProperties;
    });
  }

  void _showPopup(BuildContext context) {
    setState(() {
      _isPopupVisible = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevents back button from closing the dialog
          child: AlertDialog(
            title: Text('Atenção'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Só está disponível na versão web.'),
                SizedBox(height: 10),
                Text('Click below to download the APK.'),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _launchURL(),
                  child: Text(
                    'download',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _isPopupVisible = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isPopupVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 249, 1),
      body: Column(
        children: <Widget>[
          NavigationBarU(),
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: PropertyListWidget(properties: _visibleProperties, onTap: _showPopup),
                ),
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      GoogleMapWidget(
                        markers: _markers,
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _updateVisibleProperties();
                        },
                        onCameraMove: (position) {
                          _updateVisibleProperties();
                        },
                      ),
                      if (_isPopupVisible)
                        Positioned.fill(
                          child: AbsorbPointer(
                            absorbing: true,
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PropertyListWidget extends StatelessWidget {
  final List<Property> properties;
  final Function(BuildContext) onTap;

  PropertyListWidget({required this.properties, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onTap(context),
          child: Card(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        properties[index].name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5), // Espaçamento entre o nome e o preço
                      Text(
                        properties[index].price.toString(), // Assumindo que o preço é um número, converta para string
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 5), // Espaçamento entre o preço e o geoPoint
                      Text(
                        'Lat: ${properties[index].geoPoint.latitude}, Lng: ${properties[index].geoPoint.longitude}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class GoogleMapWidget extends StatelessWidget {
  final CameraPosition _initialPosition =
      CameraPosition(target: LatLng(38.71667, -9.13333), zoom: 12);
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;
  final Function(CameraPosition) onCameraMove;

  GoogleMapWidget({
    required this.markers,
    required this.onMapCreated,
    required this.onCameraMove,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      markers: markers,
      onMapCreated: onMapCreated,
      onCameraMove: onCameraMove,
    );
  }
}

class Property {
  final String id;
  final GeoPoint geoPoint;
  final String name;
  final double? price;

  Property({
    required this.name,
    required this.price,
    required this.id,
    required this.geoPoint,
  });
}

void _launchURL() async {
  const url = 'https://google.com'; // Insira o link para download do APK aqui
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launch(String url) async {
  // Placeholder implementation
  // Use the url_launcher package to launch the URL in your actual implementation
  print('Launching URL: $url');
}

Future<bool> canLaunch(String url) async {
  // Placeholder implementation
  // Use the url_launcher package to check URL capability in your actual implementation
  return true;
}
