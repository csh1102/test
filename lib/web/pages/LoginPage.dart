import 'package:amplify/models/user_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:amplify/web/pages/HomePageLogedin.dart';
import 'package:amplify/web/pages/MyCarsSetup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRegistering = false;
  bool showForgotPasswordForm = false;
  bool _passwordsMatch = true;
  bool agreedToTOS = false;

  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void toggleForm() {
    setState(() {
      isRegistering = !isRegistering;
      showForgotPasswordForm = false;
      _registerEmailController.clear();
      _registerPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void showForgotPassword() {
    setState(() {
      showForgotPasswordForm = !showForgotPasswordForm;
    });
  }

  Future<void> _signIn() async {
    try {
      await Auth().singInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePageLogedin()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Invalid Email";
          break;
        case "user-not-found":
          errorMessage = "User doesn't exist";
          break;
        case "wrong-password":
          errorMessage = "Wrong Password";
          break;
        default:
          errorMessage = "An unknown error occurred";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    }
  }

  Future<void> _register() async {
    setState(() {
      _passwordsMatch =
          _registerPasswordController.text == _confirmPasswordController.text;
    });

    if (!_passwordsMatch) return;

    if (!agreedToTOS) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('You must agree to the Terms of Service and Privacy Policy'),
      ));
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
      );

      final newUser = UserData(
        UID: userCredential.user!.uid,
        email: _registerEmailController.text,
        firstName: '',
        lastName: '',
        dateOfBirth: DateTime.now(),
        gender: '',
        balance: 0,
        role: 0,
        kwhCharged: 0,
        hasSetupAccount: false,
      );

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyCars()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case "invalid-email":
          errorMessage = "Invalid Email";
          break;
        case "email-already-in-use":
          errorMessage = "An account with this email already exists";
          break;
        case "weak-password":
          errorMessage = "Password is not safe enough";
          break;
        default:
          errorMessage = "An unknown error occurred";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lado esquerdo
          Expanded(
            child: Container(
              color: Colors.blue,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Save Energy, Charge Spots and Mobility',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Join the new electric Charging Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lado direito
          Expanded(
            child: Container(
              color: const Color.fromRGBO(250, 250, 246, 1),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: showForgotPasswordForm
                        ? _buildForgotPasswordForm()
                        : isRegistering
                            ? _buildRegisterForm()
                            : _buildLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Login in your Amplify account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          hintText: 'Email',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _passwordController,
        decoration: const InputDecoration(
          hintText: 'Password',
          border: OutlineInputBorder(),
        ),
        obscureText: true,
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: showForgotPassword,
            child: Text('Forgot Password'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.lightBlue,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _signIn,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 25),
          ),
          child: Text('Login'),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Don't have an account? "),
          TextButton(
            onPressed: toggleForm,
            child: Text('Register'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.lightBlue,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildForgotPasswordForm() {
    final TextEditingController _resetEmailController = TextEditingController();

    return [
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Reset your password",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _resetEmailController,
        decoration: const InputDecoration(
          hintText: 'Email',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: showForgotPassword,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 25),
          ),
          child: Text('Reset Password and back to Login'),
        ),
      ),
    ];
  }

  List<Widget> _buildRegisterForm() {
    return [
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Setup your Amplify account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _registerEmailController,
        decoration: const InputDecoration(
          hintText: 'Email',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _registerPasswordController,
        decoration: const InputDecoration(
          hintText: 'Password',
          border: OutlineInputBorder(),
        ),
        obscureText: true,
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _confirmPasswordController,
        decoration: InputDecoration(
          hintText: 'Confirm password',
          border: OutlineInputBorder(),
          errorText: _passwordsMatch ? null : "Passwords do not match",
        ),
        obscureText: true,
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Checkbox(
            value: agreedToTOS,
            onChanged: (bool? value) {
              setState(() {
                agreedToTOS = value ?? false;
              });
            },
          ),
          Text('I have read and agree to '),
          GestureDetector(
            onTap: () {
              // Logic to show terms of service
            },
            child: const Text(
              'Terms of Service',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(' and '),
          GestureDetector(
            onTap: () {
              // Logic to show privacy policy
            },
            child: const Text(
              'Privacy Policy',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _register,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(vertical: 25),
          ),
          child: Text('Register'),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Already have an account? '),
          TextButton(
            onPressed: toggleForm,
            child: Text('Login'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.lightBlue,
            ),
          ),
        ],
      ),
    ];
  }
}
