import 'package:amplify/models/charger_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HouseData {
  String houseUID;
  String houseName;
  String ownerUID;
  bool isOccupied;
  GeoPoint address;
  double? price;
  ChargerData charger;

  HouseData({
    required this.houseUID,
    required this.houseName,
    required this.ownerUID,
    required this.isOccupied,
    required this.address,
    required this.price,
    required this.charger,
  });

  Map<String, dynamic> toJson() => {
        'HouseUID': houseUID,
        'HouseName': houseName,
        'OwnerUID': ownerUID,
        'IsOccupied': isOccupied,
        'Address': address,
        'Price': price,
        'Charger': charger.toJson(),
      };

  static HouseData fromJson(Map<String, dynamic> json) {
    return HouseData(
      houseUID: json['HouseUID'],
      houseName: json['HouseName'],
      ownerUID: json['OwnerUID'],
      isOccupied: json['IsOccupied'],
      address: json['Address'],
      price: json['Price'],
      charger: ChargerData.fromJson(json['Charger']),
    );
  }
}
