import 'package:amplify/web/pages/RequestSupportPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:amplify/web/pages/HomePageLogedin.dart';
import 'package:amplify/web/pages/MapPage.dart';
import 'package:amplify/web/pages/Market.dart';
import 'package:amplify/web/pages/ProfilePage.dart';

import '../../models/user_model.dart';
import '../../services/firebase_users.dart';
import '../pages/ExecuteRequestPage.dart';

class NavigationBarU extends StatefulWidget {
  const NavigationBarU({Key? key}) : super(key: key);

  @override
  _NavigationBarUState createState() => _NavigationBarUState();
}
class _NavigationBarUState extends State<NavigationBarU> {
  int role = 0;
  @override
  void initState() {
    super.initState();
    loadRole();
  }
  void loadRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    UserData temp = UserData(
      UID: 'a',
      email: 'a',
      hasSetupAccount: true,
      firstName: 'a',
      lastName: 'a',
      dateOfBirth: DateTime.now(),
      gender: 'a',
      role:0
    );
    if (user != null) {
      temp = await FirebaseUsers().getUserData(user.uid);
    }
    setState(() {
      role = temp.role;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(role == 4){
      return NavigationBarSupport();
    }else{
      return NavigationBarUser();
    }
  }
}
class NavigationBarUser extends StatelessWidget {
  const NavigationBarUser({Key? key}) : super(key: key);

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageLogedin()),
                  );
                },
                child: _NavBarItem('Home'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
                child: _NavBarItem('Map'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Market()),
                  );
                },
                child: _NavBarItem('Market'),
              ),
              Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestSupportPage()),
                  );
                },
                child: Icon(
                  Icons.help,
                  size: 30,
                  color: Color.fromARGB(255, 1, 53, 95),
                ),
              ),SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Color.fromARGB(255, 1, 53, 95),
                ),
              ),
              const SizedBox(width: 30),
            ],
          ),
        ),
      ),
    );
  }
}
class NavigationBarSupport extends StatelessWidget {
  const NavigationBarSupport({Key? key}) : super(key: key);

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomePageLogedin()),
                  );
                },
                child: _NavBarItem('Home'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
                child: _NavBarItem('Map'),
              ),

              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Market()),
                  );
                },
                child: _NavBarItem('Market'),
              ),
              SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExecuteRequestPage()),
                  );
                },
                child: _NavBarItem('RespondRequest'),
              ),
              Expanded(child: SizedBox()),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestSupportPage()),
                  );
                },
                child: Icon(
                  Icons.help,
                  size: 30,
                  color: Color.fromARGB(255, 1, 53, 95),
                ),
              ),SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Color.fromARGB(255, 1, 53, 95),
                ),
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
  const _NavBarItem(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: Color.fromARGB(255, 1, 53, 95),
      ),
    );
  }
}
