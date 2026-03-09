class ZoneModel {
  final int id;
  final String name;
  final String? description;
  const ZoneModel({
    required this.id,
    required this.name,
    this.description
  });
  factory ZoneModel.fromJson(Map<String, dynamic> json){
    return ZoneModel(
      id: json['zone_id'] as int,
      name: json['zone_name'] as String,
      description: json['description'] as String?
       );
  }
  String get label{
    if(description != null && description!.isEmpty){
      return '$name - $description';
    }
    return name;
  }
}