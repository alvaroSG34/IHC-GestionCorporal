class Dieta {
  const Dieta({
    required this.id,
    required this.pacienteId,
    required this.nombre,
    required this.objetivo,
    required this.caloriasDiarias,
    required this.fechaInicio,
    required this.estaActiva,
  });

  final int id;
  final int pacienteId;
  final String nombre;
  final String objetivo;
  final int caloriasDiarias;
  final DateTime fechaInicio;
  final bool estaActiva;

  factory Dieta.fromJson(Map<String, dynamic> json) => Dieta(
    id: json['id'] as int,
    pacienteId: json['paciente_id'] as int,
    nombre: json['nombre'] as String,
    objetivo: json['objetivo'] as String,
    caloriasDiarias: json['calorias_diarias'] as int,
    fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
    estaActiva: json['esta_activa'] as bool,
  );
}
