enum ChargerConnectionType {
  level1, // Level 1 Charger: Standard household plug (NEMA 5-15)
  level2J1772, // Level 2 Charger: J1772 (Type 1) - Standard for North America
  level2Type2, // Level 2 Charger: Type 2 (Mennekes) - Standard for Europe
  dcFastChademo, // DC Fast Charger: CHAdeMO - Used by Nissan and Mitsubishi
  dcFastCCS, // DC Fast Charger: CCS (Combined Charging System) - Used by most American and European manufacturers
  dcFastTesla, // DC Fast Charger: Tesla Supercharger - Proprietary connector for Tesla vehicles
  teslaWallConnector, // Tesla Wall Connector (Level 2)
}

extension ChargerConnectionTypeDescription on ChargerConnectionType {
  String get description {
    switch (this) {
      case ChargerConnectionType.level1:
        return "Level 1";
      case ChargerConnectionType.level2J1772:
        return "level2J1772";
      case ChargerConnectionType.level2Type2:
        return "level2Type2";
      case ChargerConnectionType.dcFastChademo:
        return "dcFastChademo";
      case ChargerConnectionType.dcFastCCS:
        return "dcFastCCS";
      case ChargerConnectionType.dcFastTesla:
        return "dcFastTesla";
      case ChargerConnectionType.teslaWallConnector:
        return "teslaWallConnector";
      default:
        return "";
    }
  }

  static ChargerConnectionType fromString(String description) {
    return ChargerConnectionType.values.firstWhere(
      (e) => e.description == description,
      orElse: () => throw ArgumentError("Invalid charger connection type description"),
    );
  }
}