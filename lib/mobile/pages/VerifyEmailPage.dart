import 'dart:async';
import 'package:amplify/mobile/pages/AccountSetup.dart';
import 'package:amplify/mobile/pages/HomePage.dart';
import 'package:amplify/mobile/pages/NavBar.dart';
import 'package:amplify/services/auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _emailIsVerified = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _emailIsVerified = Auth().currentUser!.emailVerified;

    if (!_emailIsVerified) {
      _sendEmailVerification();

      timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        _updateEmailIsVerified();
      });
    }
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _emailIsVerified
      ? AccountSetup()
      : Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 280),
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  strokeWidth: 5,
                ),
                const SizedBox(height: 180),
                Text("Please verify your email",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _sendEmailVerification();
                      },
                      child: Text(
                        "Re-send email",
                        // style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                    const Text(
                      "/",
                    ),
                    TextButton(
                      onPressed: () {
                        Auth().signOut();
                      },
                      child: Text(
                        "Sign Out",
                        // style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );

  ///--------------//---------------//---------------//----------------

  ///
  ///Auxiliar methods
  ///

  ///
  ///Send an email with a link for the user to verify his account
  ///
  Future _sendEmailVerification() async {
    return await Auth().currentUser!.sendEmailVerification();
  }

  ///
  ///Is called every 4 seconds to check if the user already verified his account
  ///
  Future _updateEmailIsVerified() async {
    Auth().currentUser!.reload();
    setState(() {
      _emailIsVerified = Auth().currentUser!.emailVerified;
    });

    if (_emailIsVerified) {
      timer!.cancel();
    }
  }
}
