import 'package:amplify/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_users.dart';
import '../widgets/NavigationBarLogin.dart';
import 'LoginPage.dart';

class Mycarbonpage extends StatefulWidget {
  @override
  _MycarbonpageState createState() => _MycarbonpageState();
}

class _MycarbonpageState extends State<Mycarbonpage> {
  double kwh = 0;
  double savedCarbon = 0; //kg

  @override
  void initState() {
    super.initState();
    _loadCarbon();
  }

  Future<void> _loadCarbon() async {
    User? temp = FirebaseAuth.instance.currentUser;

    if (temp == null || temp.uid == null) {
      Future.delayed(
        Duration(seconds: 1),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        ),
      );
      return;
    }

    try {
      dynamic loadedCarbon = await FirebaseUsers().getkwhCharged(temp.uid);
      setState(() {
        kwh = loadedCarbon;
        savedCarbon = kwh * 0.39 * 0.75;
      });
    } catch (e) {
      print('Failed to load carbon data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      appBar: AppBar(
        title: const NavigationBarU(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('../../assets/images/img.png'),
                height: 200,
                width: 200,
              ),
              const SizedBox(height: 20),
              Text(
                'Through our application, you have charged:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$kwh kWh',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),//kwh
              const SizedBox(height: 30),
              Text(
                'Total carbon saved:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$savedCarbon kg',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              Text(
                'According to statistics, if electricity were generated solely from non-renewable sources, it would emit 750 grams of carbon dioxide per kilowatt-hour at average. In Portugal, non-renewable energy accounts for 39% of the energy mix, resulting in emissions of approximately 292.5 grams of CO2 per kilowatt-hour of electricity consumed. In contrast, solar power generation emits nearly negligible amounts of carbon. By using our application, you can reduce carbon emissions to nearly zero because our program relies entirely on solar energy, which is 100% renewable.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
