class DataListModel {
  final int id;
  final String name;

  DataListModel({required this.id, required this.name});

  // Factory constructor para crear instancias desde un mapa o JSON
  factory DataListModel.fromJson(Map<String, dynamic> json) {
    return DataListModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
