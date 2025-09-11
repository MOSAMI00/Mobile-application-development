class CategoryModel {
  final int? id;
  final String name;
  final bool enabled;

  CategoryModel({this.id, required this.name, this.enabled = true});

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    enabled: (map['enabled'] as int) == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'enabled': enabled ? 1 : 0,
  };
}
