import 'package:amplify/web/WidgetTree.dart';
import 'package:amplify/web/pages/BalancePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:amplify/web/pages/UserDataPage.dart';
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
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WidgetTree(),
    );
  }
}