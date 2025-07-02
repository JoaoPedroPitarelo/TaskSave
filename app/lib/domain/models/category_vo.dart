
class CategoryVo {
  final int id;
  final String description;
  final String color;
  final bool isDefault;
  final bool activate;
  
  const CategoryVo({
    required this.id, 
    required this.description, 
    required this.color,
    required this.isDefault,
    required this.activate
  });

  factory CategoryVo.fromJson(Map<String, dynamic> json) { 
    return CategoryVo(
      id: json['id'],
      description: json['description'],
      color: json['color'],
      isDefault: json['isDefault'],
      activate: json['ativo']
    );
  }
} 