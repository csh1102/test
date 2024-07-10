import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:amplify/services/firebase_users.dart';
import 'package:amplify/services/firebase_houses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeInfo extends StatefulWidget {
  final Marker marker;

  HomeInfo({required this.marker});

  @override
  _HomeInfoState createState() => _HomeInfoState();
}

class _HomeInfoState extends State<HomeInfo> {
  FirebaseUsers _firebaseUsers = FirebaseUsers();
  FirebaseHouses _firebaseHouses = FirebaseHouses();
  double _currentBalance = 0.0;
  Map<String, dynamic>? _houseData;
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _intervals = [];
  Set<DateTime> _occupiedIntervals = Set<DateTime>();

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
    _fetchHouseData();
    _generateIntervals();
  }

  Future<void> _fetchUserBalance() async {
    final userUID = _firebaseUsers.currentUserUID;
    final balance = await _firebaseUsers.getUserBalance(userUID);
    setState(() {
      _currentBalance = balance;
    });
  }

  Future<void> _fetchHouseData() async {
    final homeId = widget.marker.markerId.value;
    final houseData = await _firebaseHouses.getHouseData(homeId);
    setState(() {
      _houseData = houseData;
      _generateIntervals();
    });
  }

  void _generateIntervals() {
    final now = DateTime.now();
    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    final intervals = <DateTime>[];

    for (var time = startOfDay; time.isBefore(endOfDay); time = time.add(Duration(minutes: 30))) {
      if (time.isAfter(now) || !_isToday(startOfDay)) {
        intervals.add(time);
      }
    }

    setState(() {
      _intervals = intervals;
      _fetchOccupiedIntervals();
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _fetchOccupiedIntervals() async {
    final homeId = widget.marker.markerId.value;
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Homes')
        .doc(homeId)
        .collection('Calendar')
        .doc(_formatDateForFirestore(_selectedDate))
        .get();

    if (docSnapshot.exists) {
      final Map<String, dynamic>? intervals = docSnapshot.data()?['intervalos'];
      if (intervals != null) {
        final occupiedIntervals = intervals.keys.map((key) => DateTime.parse(key)).toSet();
        setState(() {
          _occupiedIntervals = occupiedIntervals;
        });
      }
    }
  }

  Future<void> _rentHouse(DateTime startTime, DateTime endTime) async {
    final rentalMinutes = 30; // Cada intervalo tem 30 minutos
    final homeId = widget.marker.markerId.value;
    final homeData = await _firebaseHouses.getHouseData(homeId);

    if (homeData == null) return;

    final pricePerMinute = homeData['Price'] as double;
    final totalPrice = rentalMinutes * pricePerMinute;

    final userUID = _firebaseUsers.currentUserUID;
    final userBalance = await _firebaseUsers.getUserBalance(userUID);

    if (totalPrice > userBalance) {
      _showDialog('Saldo insuficiente', 'Você não tem saldo suficiente para essa reserva.');
    } else {
      // Verifica se o intervalo já está ocupado
      final isIntervalOccupied = _occupiedIntervals.contains(startTime);

      if (isIntervalOccupied) {
        // Intervalo já está ocupado, não faz nada
      } else {
        final newBalance = userBalance - totalPrice;
        await _firebaseUsers.updateUserBalance(userUID, newBalance);
        await _reserveService(homeId, userUID, startTime, endTime, _selectedDate);
        setState(() {
          _currentBalance = newBalance;
        });
        _showDialog('Reserva bem sucedida', 'Saldo restante: ${newBalance.toStringAsFixed(2)}');
      }
    }
  }

  Future<void> _reserveService(String houseUID, String userUID, DateTime startTime, DateTime endTime, DateTime day) async {
    final startTimestamp = Timestamp.fromDate(startTime);
    final endTimestamp = Timestamp.fromDate(endTime);

    await FirebaseFirestore.instance
        .collection('Homes')
        .doc(houseUID)
        .collection('Calendar')
        .doc(_formatDateForFirestore(day)) // Use a formatted date for document ID
        .set({
      'intervalos': {
        startTime.toString(): {
          'endTime': endTime.toString(),
          'userUID': userUID, // Incluir o userUID aqui
        }
      }
    }, SetOptions(merge: true));
  }

  String _formatDateForFirestore(DateTime date) {
    // Format date as 'yyyy-MM-dd'
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatOccupancyStatus(bool isOccupied) {
    return isOccupied ? 'ocupado' : 'livre';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00C853), // Green lime color
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.marker.infoWindow.title ?? 'Detalhes da Casa', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _houseData == null
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detalhes da Casa:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 10),
            _buildHouseDetailSection('Nome', _houseData!['HouseName']),
            _buildHouseDetailSection('Tipo de Conexão', _houseData!['Charger']['ConnectionType']),
            _buildHouseDetailSection('Velocidade', _houseData!['Charger']['Speed']),
            _buildHouseDetailSection('Voltagem', _houseData!['Charger']['Voltage']),
            _buildHouseDetailSection('Ocupação', _formatOccupancyStatus(_houseData!['IsOccupied'])),
            _buildHouseDetailSection('Preço', _houseData!['Price']),
            _buildHouseDetailSection('ID do Proprietário', _houseData!['OwnerUID']),
            SizedBox(height: 20),
            Text('Seu Saldo: $_currentBalance', style: TextStyle(fontSize: 18, color: Colors.black)),
            SizedBox(height: 20),
            _buildDateSelector(),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _intervals.length,
                itemBuilder: (context, index) {
                  final intervalStart = _intervals[index];
                  final intervalEnd = intervalStart.add(Duration(minutes: 30));
                  final isOccupied = _occupiedIntervals.contains(intervalStart);
                  return ElevatedButton(
                    onPressed: isOccupied ? null : () => _rentHouse(intervalStart, intervalEnd),
                    child: Text('${DateFormat.Hm().format(intervalStart)} - ${DateFormat.Hm().format(intervalEnd)}'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: isOccupied ? Colors.grey : Color(0xFF00C853),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseDetailSection(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text('$title:', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
          ),
          Expanded(
            flex: 2,
            child: Text(value.toString(), style: TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(10, (index) {
          final date = DateTime.now().add(Duration(days: index));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedDate = date;
                  _generateIntervals();
                });
              },
              child: Text(DateFormat('dd/MM').format(date)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: date == _selectedDate ? Color(0xFF00C853) : Colors.grey,
              ),
            ),
          );
        }),
      ),
    );
  }
}
