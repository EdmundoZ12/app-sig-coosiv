import 'dart:convert';

// Funciones para parsear el JSON
DataModel dataModelFromJson(String str) => DataModel.fromJson(json.decode(str));
String dataModelToJson(DataModel data) => json.encode(data.toJson());

// Modelo principal para los datos
class DataModel {
  final int id;
  final List<ServiceAccount> serviceAccounts;
  final Address startingPoint;
  final String? name;

  DataModel({
    required this.id,
    required this.serviceAccounts,
    required this.startingPoint,
    this.name,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
        id: json["id"],
        serviceAccounts: List<ServiceAccount>.from(
            json["serviceAccounts"].map((x) => ServiceAccount.fromJson(x))),
        startingPoint: Address.fromJson(json["startingPoint"]),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "serviceAccounts": List<dynamic>.from(serviceAccounts.map((x) => x.toJson())),
        "startingPoint": startingPoint.toJson(),
        "name": name,
      };
}


// Modelo para ServiceAccount
class ServiceAccount {
  final int accountNumber;
  final String name;
  final Address address;
  final String notes;
  final String category;

  ServiceAccount({
    required this.accountNumber,
    required this.name,
    required this.address,
    required this.notes,
    required this.category,
  });

  factory ServiceAccount.fromJson(Map<String, dynamic> json) => ServiceAccount(
        accountNumber: json["accountNumber"],
        name: json["name"],
        address: Address.fromJson(json["address"]),
        notes: json["notes"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "accountNumber": accountNumber,
        "name": name,
        "address": address.toJson(),
        "notes": notes,
        "category": category,
      };
}


// Modelo para Address
class Address {
  final double latitude;
  final double longitude;
  final String? description;

  Address({
    required this.latitude,
    required this.longitude,
    this.description,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "description": description,
      };
}
