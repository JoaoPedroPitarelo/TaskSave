enum ReminderTypeNum {
  until_deadline("Até o prazo"),
  before_deaddine("Antes do prazo"),
  dead_line_Day("Dia do prazo");

  final String description;


  const ReminderTypeNum(this.description);
}