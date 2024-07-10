import 'dart:io';

import 'package:amplify/services/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyDrnY80rvRZxEam_28G9U5RTSxY1hA9duo',
    appId: 'girabola-c75b9',
    messagingSenderId:
        '866853878742', // Use the Sender ID from Firebase Console
    projectId: 'girabola-c75b9',
    storageBucket: 'girabola-c75b9.appspot.com',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: Platform.isIOS
          //used to override bold text on iphone, only run the mediaquery builder when in IOS,because when it runs in android, it lags a
          ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(boldText: false),
                child: child!,
              )
          : null,
      useInheritedMediaQuery: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 41, 41, 41),
          secondary: Color.fromARGB(255, 222, 255, 105),
          tertiary: const Color.fromARGB(255, 255, 255, 255),
        ),
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
            elevation: 0 ,
            toolbarHeight: 60, //chango to mediaQuery
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 41, 41, 41),
              fontWeight: FontWeight.w900,
            ),
            toolbarTextStyle: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 41, 41, 41),
              fontWeight: FontWeight.w900,
            )),
      ),
      home: const WidgetTree(),
    );
  }
}