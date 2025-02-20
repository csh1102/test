import 'package:flutter/material.dart';

class NavigationBar extends StatelessWidget {
  const NavigationBar({required Key key})
      : super(key: key); // só funciona com required

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          SizedBox(
            height: 80,
            width: 150,
            child: Image.asset('assets/logo.png'),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _NavBarItem('Home'),
              SizedBox(
                width: 60,
              ),
              _NavBarItem('About'),
              SizedBox(
                width: 60,
              ),
              _NavBarItem('Contact'),
            ],
          )
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String title;
  const _NavBarItem(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }
}
