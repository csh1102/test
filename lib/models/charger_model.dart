import 'package:amplify/models/chargers_types.dart';

class ChargerData {
  ChargerConnectionType connectionType;
  double voltage;
  double speed; //in km of ramge per hour

  ChargerData({
    required this.connectionType,
    required this.voltage,
    required this.speed,
  });

  Map<String, dynamic> toJson() => {
        'ConnectionType': connectionType.description,
        'Voltage': voltage,
        'Speed': speed,
      };

  static fromJson(Map<String, dynamic> json) {
    return ChargerData(
      connectionType:
          ChargerConnectionTypeDescription.fromString(json['ConnectionType']),
      voltage: json['Voltage'],
      speed: json['Speed'],
    );
  }
}
