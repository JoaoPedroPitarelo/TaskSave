class CategoryVo {
  final int id;
  final String description;
  final String color;
  final bool isDefault;
  final bool activate;
  final int position;

  const CategoryVo({
    required this.id, 
    required this.description, 
    required this.color,
    required this.isDefault,
    required this.activate,
    required this.position
  });

  factory CategoryVo.fromJson(Map<String, dynamic> json) { 
    return CategoryVo(
      id: json['id'],
      description: json['description'],
      color: json['color'],
      isDefault: json['isDefault'],
      activate: json['ativo'],
      position: json['position']
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryVo &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 