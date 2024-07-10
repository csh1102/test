import 'dart:io';

import 'package:amplify/mobile/pages/AccountSetup.dart';
import 'package:amplify/mobile/pages/AddHousesPage.dart';
import 'package:amplify/mobile/pages/HomePage.dart';
import 'package:amplify/mobile/pages/LoginAndRegisterPage.dart';
import 'package:amplify/mobile/pages/NavBar.dart';
import 'package:amplify/mobile/pages/VerifyEmailPage.dart';
import 'package:amplify/models/user_model.dart';
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
          return FutureBuilder(
            future:
                FirebaseUsers().getUserHasSetupAccount(Auth().currentUser!.uid),
            builder: ((context, AsyncSnapshot<bool> userData) {
              if (userData.connectionState == ConnectionState.waiting) {
                //loading page
                return Scaffold(
                  body: Center(
                    child: SizedBox(
                      height: 320,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 300,
                        height: 300,
                      ),
                    ),
                  ),
                );
              } else {
                if (userData.data == true) {
                  return HomePage();
                } else {
                  return VerifyEmailPage();
                  // return AddHousePage(
                  //     currentUserData: UserData(
                  //       UID: Auth().currentUserUID,
                  //       email: Auth().currentUser!.email!,
                  //       firstName: "",
                  //       lastName: "",
                  //       hasSetupAccount: false,
                  //       dateOfBirth: DateTime.now(),
                  //       sex: "",
                  //     ),
                  //     profileImage: File(""));
                }
              }
            }),
          );
        } else {
          return const LoginAndRegisterPage();
        }
      },
    );
  }
}
