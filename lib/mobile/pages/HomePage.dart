import 'dart:async';
import 'package:amplify/mobile/pages/Profile.dart';
import 'package:amplify/mobile/pages/Settings.dart';
import 'package:amplify/models/chargers_types.dart';
import 'package:amplify/services/helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify/services/firebase_users.dart';
import 'HomeInfo.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];
  final List<Map<String, dynamic>> _visibleMarkersWithDistance = [];
  final ScrollController _scrollController = ScrollController();
  CameraPosition? _lastPosition;
  CameraPosition? _currentPosition;
  late Position _currentPositionGPS;
  bool _isGPSEnabled = false;
  String _distanceText = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  Marker? _currentLocationMarker;
  ChargerConnectionType? _selectedConnectionType;
  Marker? _selectedMarker;
  final PanelController _panelController = PanelController();
  FirebaseUsers _firebaseUsers = FirebaseUsers();
  double _currentBalance = 0.0;

  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _getCurrentLocation();
    _fetchHomesFromFirestore();
    _fetchUserBalance();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _updateDistances();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserBalance() async {
    String userUID = _firebaseUsers.currentUserUID;
    double balance = await _firebaseUsers.getUserBalance(userUID);
    setState(() {
      _currentBalance = balance;
    });
  }

  void _initializeMarkers() {
    final points = List.generate(
      20,
      (index) => LatLng(
        37.42796133580664 + index * 0.01,
        -122.085749655962 + index * 0.01,
      ),
    );

    setState(() {
      _markers.addAll(points.asMap().entries.map((entry) {
        int index = entry.key;
        LatLng point = entry.value;
        return Marker(
          markerId: MarkerId(point.toString()),
          position: point,
          infoWindow: InfoWindow(
            title: 'Ponto ${index + 1}',
          ),
          onTap: () => _focusOnMarker(entry.value),
        );
      }).toList());

      _updateVisibleMarkers();
    });
  }

  Future<void> _fetchHomesFromFirestore() async {
    final homesCollection = FirebaseFirestore.instance.collection('Homes');
    final snapshot = await homesCollection.get();
    final homes = snapshot.docs;

    setState(() {
      _markers.clear();
      for (var home in homes) {
        final data = home.data();
        final chargerData = data['Charger'] as Map<String, dynamic>?;
        if (_selectedConnectionType != null && chargerData != null && chargerData['ConnectionType'] != _selectedConnectionType!.description) {
          continue;
        }
        final latLng = _geoPointToLatLng(data['Address']);
        late Marker marker;
        marker = Marker(
          markerId: MarkerId(home.id),
          position: latLng,
          infoWindow: InfoWindow(
            title: data['HouseName'] ?? 'Sem Nome',
            snippet: 'Price: ${data['Price']?.toString() ?? 'N/A'}',
          ),
          onTap: () {
            _selectedMarker = marker;
            _focusOnMarker(latLng);
          },
        );
        _markers.add(marker);
      }
      _updateVisibleMarkers();
    });
  }

  LatLng _geoPointToLatLng(GeoPoint geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  void _updateVisibleMarkers() async {
    final GoogleMapController controller = await _controller.future;
    LatLngBounds visibleRegion = await controller.getVisibleRegion();
    setState(() {
      _visibleMarkersWithDistance.clear();
      for (var marker in _markers) {
        if (visibleRegion.contains(marker.position)) {
          _visibleMarkersWithDistance.add({
            'marker': marker,
            'distance': _getDistanceText(marker.position),
          });
        }
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPositionGPS = position;
      _isGPSEnabled = true;
      _updateVisibleMarkers();
    });
  }

  Future<void> _calculateDistance(LatLng point) async {
    if (!_isGPSEnabled) {
      await _getCurrentLocation();
    }

    double distance = Geolocator.distanceBetween(
      _currentPositionGPS.latitude,
      _currentPositionGPS.longitude,
      point.latitude,
      point.longitude,
    );

    setState(() {
      _distanceText = 'Distância: ${distance.toStringAsFixed(2)} metros';
    });
  }

  Future<void> _focusOnMarker(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    _lastPosition = _currentPosition; // Save the current position
    await controller.animateCamera(CameraUpdate.newLatLngZoom(position, 16.0));
    _calculateDistance(position); // Calculate distance on marker focus
    _animationController.forward();
  }

  Future<void> _resetCameraPosition() async {
    final GoogleMapController controller = await _controller.future;
    if (_lastPosition != null) {
      await controller.animateCamera(CameraUpdate.newCameraPosition(_lastPosition!));
      _animationController.reverse();
    }
  }

  void _showCurrentLocation() async {
    await _getCurrentLocation();
    final GoogleMapController controller = await _controller.future;
    final currentPosition = LatLng(_currentPositionGPS.latitude, _currentPositionGPS.longitude);
    setState(() {
      if (_currentLocationMarker != null) {
        _markers.remove(_currentLocationMarker);
      }
      _currentLocationMarker = Marker(
        markerId: MarkerId('currentLocation'),
        position: currentPosition,
        infoWindow: InfoWindow(title: 'Current Location'),
      );
      _markers.add(_currentLocationMarker!);
    });
    controller.animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 16.0));
    _updateVisibleMarkers();
  }

  void _updateDistances() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (_isGPSEnabled) {
        setState(() {
          _updateVisibleMarkers();
        });
      }
    });
  }

  String _getDistanceText(LatLng point) {
    if (!_isGPSEnabled) {
      return 'Calculando...';
    }

    double distance = Geolocator.distanceBetween(
      _currentPositionGPS.latitude,
      _currentPositionGPS.longitude,
      point.latitude,
      point.longitude,
    );

    return '${distance.toStringAsFixed(2)} metros';
  }

  void _onMapTapped(LatLng position) {
    _panelController.close();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _zoomIn() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(37.7749, -122.4194),
                      zoom: 12.0,
                    ),
                    mapType: MapType.normal,
                    markers: Set<Marker>.of(_markers),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    onCameraMove: (CameraPosition position) {
                      _currentPosition = position;
                      _updateVisibleMarkers();
                    },
                    onTap: _onMapTapped,
                  ),
                  SlidingUpPanel(
                    minHeight: 100,
                    maxHeight: 400,
                    controller: _panelController,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                    panel: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Nearby Locations",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 41, 41, 41),
                              fontSize: 20,
                            ),
                          ),
                        ),
                        DropdownButton<ChargerConnectionType>(
                          hint: Text('Select Charger Type'),
                          value: _selectedConnectionType,
                          onChanged: (ChargerConnectionType? newValue) {
                            setState(() {
                              _selectedConnectionType = newValue;
                              _fetchHomesFromFirestore();
                            });
                          },
                          items: ChargerConnectionType.values.map((ChargerConnectionType type) {
                            return DropdownMenuItem<ChargerConnectionType>(
                              value: type,
                              child: Text(type.description),
                            );
                          }).toList(),
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _visibleMarkersWithDistance.length,
                              itemBuilder: (context, index) {
                                final marker = _visibleMarkersWithDistance[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.lime,
                                  child: ListTile(
                                    leading: Icon(Icons.location_on, color: const Color.fromARGB(255, 11, 239, 19)),
                                    title: Text(
                                      marker['marker'].infoWindow.title ?? 'Ponto ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${marker['marker'].position.latitude}, ${marker['marker'].position.longitude} - Distância: ${marker['distance']} - Price: ${marker['marker'].infoWindow.snippet}',
                                    ),
                                    onTap: () => _focusOnMarker(marker['marker'].position),
                                    trailing: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedMarker = marker['marker'];
                                        });
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => HomeInfo(
                                            marker: _selectedMarker!,
                                          ),
                                        ));
                                      },
                                      child: Text('Alugar'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 188, 246, 54),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.black,
                          size: 30,
                        ),
                        onPressed: () {
                          _openDrawer();
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          onPressed: _zoomIn,
                          mini: true,
                          backgroundColor: Color.fromARGB(255, 188, 246, 54),
                          child: const Icon(Icons.zoom_in, color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        FloatingActionButton(
                          onPressed: _zoomOut,
                          mini: true,
                          backgroundColor: Color.fromARGB(255, 188, 246, 54),
                          child: const Icon(Icons.zoom_out, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 90,
                    child: FadeTransition(
                      opacity: _animation,
                      child: FloatingActionButton(
                        onPressed: _resetCameraPosition,
                        mini: true,
                        backgroundColor: Color.fromARGB(255, 188, 246, 54),
                        child: const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                  if (_distanceText.isNotEmpty)
                    Positioned(
                      top: 80,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _distanceText,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/logo.png',
                  ),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: const Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 41, 41, 41),
                  fontSize: 20),
              ),
              onTap: () {
                goToPage(context, SettingsPage());
              },
            ),
            ListTile(
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 41, 41, 41),
                  fontSize: 20),
              ),
              onTap: () {
                goToPage(context, Profile());
              },
            ),
          ],
        ),
      ),
    );
  }
}
