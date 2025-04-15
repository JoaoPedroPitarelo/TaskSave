
class CategoryVo {
  // Atributos
  final String id;
  final String description;
  final String color;
  final bool activate;
  
  // Construtor
  const CategoryVo({
    required this.id, 
    required this.description, 
    required this.color,
    required this.activate
  });

  factory CategoryVo.fromJson(Map<String, dynamic> json) { 
    return CategoryVo(
      id: json['id'], 
      description: json['description'], 
      color: json['color'],
      activate: json['ativo']
    );
  }
} 