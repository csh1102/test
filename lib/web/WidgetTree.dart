import 'package:amplify/web/pages/HomePageLogedin.dart';
import 'package:amplify/web/pages/HomePageLogedout.dart';
import 'package:flutter/material.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/firebase_users.dart';

import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePageLogedin();
        } else {
          return const HomePageLogedout();
        }
      },
    );
  }
}
