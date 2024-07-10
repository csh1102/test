import 'package:amplify/models/house_model.dart';
import 'package:amplify/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHouses {
  final CollectionReference homeRef =
      FirebaseFirestore.instance.collection('Homes');
  String currentUserUID = Auth().currentUserUID;

  Future<List<HouseData>> getUsersHouse(String userUID) async {
    List<HouseData> houses = [];

    try {
      QuerySnapshot querySnapshot = await homeRef
          .where('OwnerUID', isEqualTo: userUID)
          .get();

      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data() != null &&
            documentSnapshot.data() is Map<String, dynamic>) {
          HouseData house = HouseData.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);

          houses.add(house);
        } else {
          print('Invalid data for document: ${documentSnapshot.id}');
        }
      }
    } catch (e) {
      print('Error fetching user houses: $e');
    }

    return houses;
  }


  Future<void> reserveService(String houseUID, String userUID, DateTime startTime, DateTime endTime, DateTime day) async {
  await FirebaseFirestore.instance
      .collection('Homes').doc(houseUID)
      .collection('Calendar')
      .doc(day.toString())
      .set({
        'intervalos': {
          startTime.toString(): {'endTime': endTime.toString()}
        }
      }, SetOptions(merge: true));
}


  Future<Map<String, DateTime>> obterReservasPorDia(String dia) async {
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection('Calendar')
      .doc(dia)
      .get();

  if (docSnapshot.exists) {
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> intervalos = data['intervalos'] as Map<String, dynamic>;
    return intervalos.map((key, value) => MapEntry(key, DateTime.parse(value['endTime'])));
  } else {
    return {};
  }
}

  Future<void> deleteHouse(String houseUID) async {
    print(houseUID);
    try {
      await homeRef.doc(houseUID).delete();
    } catch (e) {
      print('Error deleting house: $e');
    }
  }
  Future<bool> deleteAllMyHomes(String userUID) async {
    QuerySnapshot querySnapshot = await homeRef
        .where('ownerUID', isEqualTo: userUID)
        .get();
    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      await homeRef.doc(documentSnapshot.id).delete();
    }
    return true;
  }

  Future<Map<String, dynamic>> getHouseData(String houseUID) async {
    final DocumentSnapshot documentSnapshot = await homeRef.doc(houseUID).get();
    return documentSnapshot.data() as Map<String, dynamic>;
  }

  Future<String?> getHouseName(String houseUID) async {
    final data = await getHouseData(houseUID);
    return data['HouseName'];
  }

  Future<String?> getConnectionType(String houseUID) async {
    final data = await getHouseData(houseUID);
    final chargerData = data['Charger'] as Map<String, dynamic>?;
    return chargerData?['ConnectionType'];
  }

  Future<bool> changeHomeData(Map<String, dynamic> homeData) async {
    final DocumentSnapshot homeDoc = await homeRef.doc(homeData['UID']).get();
    if (homeDoc.exists) {
      await homeRef.doc(homeData['UID']).set(homeData);
      return true;
    } else {
      return false;
    }
  }

  Future<int?> getSpeed(String houseUID) async {
    final data = await getHouseData(houseUID);
    final chargerData = data['Charger'] as Map<String, dynamic>?;
    return chargerData?['Speed'];
  }

  Future<int?> getVoltage(String houseUID) async {
    final data = await getHouseData(houseUID);
    final chargerData = data['Charger'] as Map<String, dynamic>?;
    return chargerData?['Voltage'];
  }

  Future<bool?> getIsOccupied(String houseUID) async {
    final data = await getHouseData(houseUID);
    return data['IsOccupied'];
  }

  Future<double?> getPrice(String houseUID) async {
    final data = await getHouseData(houseUID);
    return data['Price'];
  }

  Future<String?> getOwnerUID(String houseUID) async {
    final data = await getHouseData(houseUID);
    return data['OwnerUID'];
  }

  addHome({required String homeUID, required String ownerUID, required Map<String, dynamic> homeData}) {
    homeRef.doc(homeUID).set(homeData);
  }
}
