enum ReminderTypeNum {
  // Valores de desse enum
  untilDeadLine("Até o prazo"),
  beforeDeadLine("Antes do prazo"),
  deadlineDay("Dia do prazo");

  // Atributo interno
  final String description;

  // Construtor 
  const ReminderTypeNum(this.description);
}