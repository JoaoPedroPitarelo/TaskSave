enum PriorityEnum {
  // Valores desse enum
  high("Alto"),
  medium("Médio"),
  low("Baixo"),
  neutral("Neutro");

  // Atributo interno
  final String description;

  // Construtor
  const PriorityEnum(this.description);
}