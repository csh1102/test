import 'package:firebase_auth/firebase_auth.dart';

///
///This class hold all function of Firebase Authethication
///////////////////////////////////////////////////////////

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Getter for current user
  User? get currentUser => _firebaseAuth.currentUser;

  ///Getter to the current user UID
  String get currentUserUID => _firebaseAuth.currentUser!.uid;

  ///
  ///Stream that listens to changes in the AuthState, when a user loggs in or out
  ///
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  ///
  ///Function to sign in with email and password
  ///
  Future<void> singInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  ///
  ///Function to register a new user with given email and passowrd
  ///
  Future<void> createUserWithEmailAndPassowrd({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  ///
  ///Function that sign out the user
  ///
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  ///
  ///Function that returns a future bool, true when the user has email verified, false otherwise
  ///
  Future<bool> getUserHasEmailVerified() async {
    return currentUser!.emailVerified;
  }
}