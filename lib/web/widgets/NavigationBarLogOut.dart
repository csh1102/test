import 'package:amplify/web/pages/HomePageLogedout.dart';
import 'package:amplify/web/pages/LoginPage.dart';
import 'package:amplify/web/pages/MapPage.dart';
import 'package:amplify/web/pages/Market.dart';
import 'package:flutter/material.dart';

class NavigationBarLogOut extends StatelessWidget {
  const NavigationBarLogOut({Key? key});

  @override
  Widget build(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      margin: EdgeInsets.only(top: statusBarHeight + 20),
      child: Center(
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Color.fromARGB(255, 223, 223, 223),
              width: 0.5,
            ),
          ),
          child: Row(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  'Amplify',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 50),
              GestureDetector(
                onTap: () {
                  // Navegar para a página de SignUp/Log in
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageLogedout()),
                  );
                },
                child: _NavBarItem('Home'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  // Navegar para a página de SignUp/Log in
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: _NavBarItem('Map'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  // Navegar para a página de SignUp/Log in
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: _NavBarItem('Market'),
              ),
              SizedBox(width: 20),
              _NavBarItem('About Us'),
              Spacer(),
              GestureDetector(
                onTap: () {
                  // Navegar para a página de SignUp/Log in
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                  color: Colors.blue, // Add color here
                  
                  borderRadius: BorderRadius.circular(4.5),
                  ),
                  child: const _NavBarItem(
                    'Sign Up/Log in',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  
                ),
              ),
              const SizedBox(width: 30),
              Image.asset(
                'assets/images/logo.png',
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String title;
  final TextStyle? style; // Add the 'style' named parameter
  const _NavBarItem(
    this.title, {
    Key? key,
    this.style, // Define the 'style' named parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: style ?? const TextStyle( // Use the 'style' named parameter
        fontSize: 14,
        color: Color.fromARGB(255, 1, 53, 95),
      ),
    );
  }
}
