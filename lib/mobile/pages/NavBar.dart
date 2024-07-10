import 'dart:ui';

import 'package:amplify/mobile/components/costum_appBar.dart';
import 'package:amplify/mobile/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _bottomBarIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: costumAppBar(context),
        body: Stack(children: [
      Center(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _bottomBarIndex = index;
            });
          },
          children: const <Widget>[
            HomePage(),
          ],
        ),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 228, 255, 237).withOpacity(0.5),
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 15, 15, 15).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            height: 80,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: GNav(
                  gap: 8,
                  iconSize: 25,
                  selectedIndex: _bottomBarIndex,
                  onTabChange: (index) {
                    setState(() {
                      _bottomBarIndex = index;
                      _pageController.jumpToPage(index);
                    });
                  },
                  color: const Color.fromARGB(255, 41, 41, 41),
                  activeColor: const Color.fromARGB(255, 41, 41, 41),
                  tabs: const [
                    GButton(
                      icon: Icons.home,
                      text: "Home",
                      textStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 41, 41, 41),
                      ),
                    ),
                    GButton(
                      icon: Icons.search_rounded,
                      text: "Find",
                      textStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 41, 41, 41),
                      ),
                    ),
                    GButton(
                      icon: Icons.inbox,
                      text: "Inbox",
                      textStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 41, 41, 41),
                      ),
                    ),
                    GButton(
                      icon: Icons.history,
                      text: "History",
                      textStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 41, 41, 41),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    ]));
  }
}
