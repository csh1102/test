import 'package:amplify/web/widgets/NavigationBarLogOut.dart';
import 'package:flutter/material.dart';
//import 'package:amplify/web/widgets/NavigationBar.dart';

import 'package:amplify/web/pages/HomePageLogedout.dart';
import 'package:amplify/web/widgets/NavigationBarLogin.dart';
import 'package:amplify/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:amplify/web/pages/LoginPage.dart';

class HomePageLogedout extends StatelessWidget {
  const HomePageLogedout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 249, 1),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const NavigationBarLogOut(),
            _buildSection(title: 'Inicio', height: 200),
            _buildSection(title: 'Sponsors', height: 200),
            _buildSection(title: 'Team', height: 200),
            _buildSection(title: 'Market', height: 200),
            _buildSection(title: 'Contactos', height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required double height}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
