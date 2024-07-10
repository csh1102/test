class CarData {
  String UID;
  String ownerUID;
  String matriculation;
  String chagerType;
  CarData(
      {required this.matriculation,
      required this.chagerType,
      required this.UID,
      required this.ownerUID});

      
Map<String, dynamic> toJson() => {
        'UID': UID,
        'ownerUID': ownerUID,
        'matriculation': matriculation,
        'chagerType': chagerType,
      };


  static fromJson(Map<String, dynamic> json) {
    return CarData(
      UID: json['UID'],
      ownerUID: json['ownerUID'],
      matriculation: json['matriculation'],
      chagerType: json['chagerType'],
    );
  }

  

}