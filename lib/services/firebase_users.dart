import 'dart:convert';
import 'dart:io';
import 'package:amplify/models/car_model.dart';
import 'package:crypto/crypto.dart';
import 'package:amplify/services/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/user_model.dart';
import 'auth.dart';

class FirebaseUsers {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('Users');

  final CollectionReference carsRef =
      FirebaseFirestore.instance.collection('Cars');

  final CollectionReference requestRef =
  FirebaseFirestore.instance.collection('Requests');
  String currentUserUID = Auth().currentUserUID;



  Future<UserData> getUserData(String userUID) async {
    final DocumentSnapshot userDoc = await usersRef.doc(userUID).get();

    return UserData.fromJson(userDoc.data() as Map<String, dynamic>)
        as UserData;
  }

  Stream<UserData> getUserDataStream(String userUID) {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userUID);

    return userDoc
        .snapshots()
        .map((document) => UserData.fromJson(document.data()!));
  }

  Future<String> getProfileImageURL(String userUID) async {
    final imageURL = await FirebaseStorage.instance
        .ref()
        .child("ProfilePictures/" + userUID + ".jpg")
        .getDownloadURL();

    return imageURL;
  }

  Stream<QuerySnapshot> allUsersStream() {
    return usersRef.snapshots();
  }

  Future<List<UserData>> allUsersList() async {
    List<UserData> allUsers = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Users').get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      UserData user =
          UserData.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      allUsers.add(user);
    }

    return allUsers;
  }

  Stream<QuerySnapshot> orderedUsersStream(bool applyDistanceFilter,
      bool applyEloFilter, bool applyGamesPlayedFilter, bool applyAgeFilter) {
    Query query = FirebaseFirestore.instance.collection('Users');

    if (applyDistanceFilter) {
      query = query.orderBy('Location', descending: true);
    }

    if (applyEloFilter) {
      query = query.orderBy('ELO', descending: true);
    }

    if (applyGamesPlayedFilter) {
      query = query.orderBy('GamesPlayed', descending: true);
    }

    if (applyAgeFilter) {
      query = query.orderBy('DateOfBirth.Year', descending: false);
    }

    return query.snapshots();
  }

  Future<String> getUserFullName(String userUID) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userUID).get();

    return userDoc.get('FirstName') + ' ' + userDoc.get('LastName');
  }

  Future<String> getUserBio(String userUID) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userUID).get();

    return userDoc.get('Biography');
  }

  Future<DateTime> getUserDateOfBirth(String userUID) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userUID).get();

    return dateFromFirebase(userDoc.get('DateOfBirth'));
  }

  Future<bool> getUserHasSetupAccount(String userUID) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userUID).get();

    return userDoc.get('HasSetupAccount');
  }

  Future<void> changePassword(
      String userUID, String currentPassword, String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);

      final bytes = utf8.encode(newPassword);
      final digest = sha256.convert(bytes);
      final hashedPassword = digest.toString();

      await usersRef.doc(userUID).update({'password': hashedPassword});
    } on FirebaseAuthException catch (e) {
      throw Exception('Error changing password: ${e.message}');
    }
  }
  Future<bool> updateUserData(
      String userUID, Map<String, dynamic> userData) async {
    try {
      await usersRef.doc(userUID).update(userData);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Método para obter o balance do usuário
  Future<double> getUserBalance(String userUID) async {
    final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userUID).get();
    return userDoc.get('Balance');
  }

  // Método para atualizar o balance do usuário
  Future<void> updateUserBalance(String userUID, double newBalance) async {
    await FirebaseFirestore.instance.collection('Users').doc(userUID).update({
      'Balance': newBalance,
    });
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> saveImageUrlToFirestore(String imageUrl, String userId) async {
    await usersRef.doc(userId).update({
      'profileImage': imageUrl,
    });
  }

  Future<bool> addCar(
      {required Map<String, dynamic> carData}) async {
    final DocumentSnapshot carDoc =
        await FirebaseFirestore.instance.collection('Cars').doc(carData['UID']).get();
    if (carDoc.exists) {
      return false; //user already has a car
    } else {
      await carsRef.doc(carData['UID']).set(carData);
      //changeRole(carData['ownerUID'], 0);
      return true;
    }
  }

  Future<List<CarData>> getUserCars(String userUID) async {
    List<CarData> cars = [];
    QuerySnapshot querySnapshot = await carsRef
        .where('ownerUID', isEqualTo: userUID)
        .get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      CarData car =
          CarData.fromJson(documentSnapshot.data() as Map<String, dynamic>);
      cars.add(car);
    }
    return cars;
  }
  Future<void> deleteCar(String carUID) async {
    try {
      await carsRef.doc(carUID).delete();
    } catch (e) {
      print('Error deleting car: $e');
    }
  }
  Future<bool> deleteUser(String userUID) async {
    try {
      await usersRef.doc(userUID).delete();
      await carsRef.doc(userUID).delete();
      await requestRef.doc(userUID).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  Future<List<dynamic>> getGivenHelpRequests(String userUID) async {
    List<dynamic> requests = [];
    QuerySnapshot querySnapshot =
    await requestRef.where('userUID', isEqualTo: userUID).get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      requests.add(documentSnapshot.data());
    }
    return requests;
  }

  Future<double> getkwhCharged(String userUID) async {
    final DocumentSnapshot userDoc =
    await usersRef.doc(userUID).get();
    return userDoc.get('kwhCharged');
  }

  Future<void> respond(String uuid, Map<String, dynamic> response) async {
    await requestRef.doc(uuid).update(response);
  }
  Future<void> addkwhCharged(String userUID, double amount) async {
    final DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('Users').doc(userUID).get();
    await usersRef
        .doc(userUID)
        .update({'kwhCharged': userDoc.get('kwhCharged') + amount});
  }

  Future<void> changeRole(String userUID, int action) async {
    DocumentSnapshot userDoc = await usersRef.doc(userUID).get();
    if (action == 0) {
      // action addCar
      if (userDoc['role'] == 0) {
        await usersRef.doc(userUID).update({'role': 1});
      } else if (userDoc['role'] == 2) {
        await usersRef.doc(userUID).update({'role': 3});
      }
    } else if (action == 1) {
      //action addHome
      if (userDoc['role'] == 0) {
        await usersRef.doc(userUID).update({'role': 2});
      } else if (userDoc['role'] == 1) {
        await usersRef.doc(userUID).update({'role': 3});
      }
    }
  }
  Future<List<dynamic>> getAllHelpRequests(String userUID) async {
    // if ((await getUserData(userUID)).role != 4) {
    //   throw Exception('User is not an admin');
    // }
    List<dynamic> requests = [];
    String twoDaysAgo =
    DateTime.now().subtract(Duration(days: 2)).toIso8601String();
    QuerySnapshot querySnapshot = await requestRef
        .where('timeStamp', isGreaterThanOrEqualTo: twoDaysAgo)
        .get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      requests.add(documentSnapshot.data());
    }
    return requests;
  }
  Future<bool> askForHelp(
      String uuid, String userUID, String problem, String request) async {
    try {
      await requestRef.doc(uuid).set({
        'uuid': uuid,
        'userUID': userUID,
        'problem': problem,
        'request': request,
        'timeStamp': DateTime.now().toIso8601String(),
        'response': ''
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> countUserReservations(String userUID) async {
    int count = 0;

    try {
      // Consulta para obter todas as casas
      QuerySnapshot housesSnapshot = await _db.collection('houses').get();

      // Itera sobre cada casa
      for (QueryDocumentSnapshot house in housesSnapshot.docs) {
        // Consulta para obter os agendamentos (calendários) da casa atual
        QuerySnapshot calendarSnapshot = await _db
            .collection('Homes')
            .doc(house.id)
            .collection('Calendar') // Substitua 'Calendar' pelo nome da coleção de agendamentos
            .where('userUID', isEqualTo: userUID)
            .get();

        // Incrementa o contador com o número de reservas encontradas na casa atual
        count += calendarSnapshot.size;
      }

    } catch (e) {
      print('Erro ao contar reservas: $e');
    }

    return count;
  }
}

  

