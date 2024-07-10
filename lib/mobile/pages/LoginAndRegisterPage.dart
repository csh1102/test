import 'package:amplify/mobile/components/costum_text_field.dart';
import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/services/media_query_helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class LoginAndRegisterPage extends StatefulWidget {
  const LoginAndRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginAndRegisterPage> createState() => _LoginAndRegisterPageState();
}

class _LoginAndRegisterPageState extends State<LoginAndRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isRegsiterPage = false;
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 70, 0, 10),
                  child: Container(
                    //is this container necessary?
                    child: Image.asset(
                      "assets/images/logo.png",
                      scale: 2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    child: CostumTextField(
                        textController: _emailController,
                        hintText: "Enter your email",
                        isPassword: false),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Container(
                    child: CostumTextField(
                        textController: _passwordController,
                        hintText: "Enter your password",
                        isPassword: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _isRegsiterPage ? 1 : 0,
                    curve: Curves.easeInOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      height: !_isRegsiterPage ? 0 : 60,
                      curve: Curves.easeInOutCirc,
                      child: CostumTextField(
                          textController: _passwordConfirmController,
                          hintText: "Confirm your password",
                          isPassword: true),
                    ),
                  ),
                ),
                SizedBox(height: displayHeight(context) * 0.03),
                Text(
                  _errorMessage,
                  style:
                      const TextStyle(color: Color.fromARGB(255, 212, 97, 88)),
                ),
                SizedBox(height: displayHeight(context) * 0.01),
                Container(
                  //here a container is necessary to ajust button size
                  width: displayWidth(context) * 0.9,
                  height: displayHeight(context) * 0.06,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (!_isRegsiterPage) {
                        if (_emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty) {
                          _errorMessage = "";
                          _singIn();
                        } else {
                          setState(() {
                            _errorMessage =
                                "Please fill in all the required fields";
                          });
                        }
                      } else {
                        _nextPageCheck();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: AnimatedCrossFade(
                      //is it good?
                      crossFadeState: _isRegsiterPage
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 600),
                      firstChild: const Text(
                        "Sign in",
                        style: TextStyle(
                            //why doesnt button style from Theme() work here?
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w900),
                      ),
                      secondChild: const Text(
                        "Create Account",
                        style: TextStyle(
                            //why doesnt button style from Theme() work here?
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(!_isRegsiterPage
                        ? "Don't have an account?"
                        : "Already have an account?"),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegsiterPage = !_isRegsiterPage;
                            _errorMessage = "";
                            _emailController.text = "";
                            _passwordController.text = "";
                            _passwordConfirmController.text = "";
                          });
                        },
                        child: Text(
                          _isRegsiterPage ? "Sign in" : "Create Account",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w900),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _singIn() async {
    try {
      await Auth().singInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        setState(() {
          _errorMessage = "Invalid Email";
        });
      } else if (e.code == "user-not-found") {
        setState(() {
          _errorMessage = "User doesn't exist";
        });
      } else if (e.code == "wrong-password") {
        setState(() {
          _errorMessage = "Wrong Password";
        });
      }
    }
  }

  Future<void> _createUser() async {
    try {
      final newUser = UserData(
        UID: '',
        email: '',
        hasSetupAccount: false,
        firstName: '',
        lastName: '',
        dateOfBirth: DateTime.now(),
        gender: '',
      );

      await Auth().createUserWithEmailAndPassowrd(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final json = newUser.toJson();
      FirebaseFirestore.instance
          .collection('Users')
          .doc(Auth().currentUser!.uid.toString())
          .set(json);
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        setState(() {
          _errorMessage = "Invalid Email";
        });
      } else if (e.code == "email-already-in-use") {
        setState(() {
          _errorMessage = "An account with this email already exists";
        });
      } else if (e.code == "weak-password") {
        setState(() {
          _errorMessage = "Password is not safe enough";
        });
      }
    }
  }

  void _nextPageCheck() {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _passwordConfirmController.text.isNotEmpty) {
      if (EmailValidator.validate(_emailController.text)) {
        if (_passwordController.text == _passwordConfirmController.text) {
          setState(() {
            _errorMessage = '';
          });
          _createUser();
        } else {
          setState(() {
            _errorMessage = "Passwords don't match";
          });
        }
      } else {
        setState(() {
          _errorMessage = "E-mail is not valid";
        });
      }
    } else {
      setState(() {
        _errorMessage = "Please fill in all the required fields";
      });
    }
  }
}
