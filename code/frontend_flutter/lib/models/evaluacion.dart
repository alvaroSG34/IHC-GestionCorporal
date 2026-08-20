class Evaluacion {
  final int id;
  final double peso;
  final DateTime fechaRegistro;
  final int pacienteId;

  Evaluacion({
    required this.id,
    required this.peso,
    required this.fechaRegistro,
    required this.pacienteId,
  });

  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      id: json['id'] as int,
      peso: json['peso'] as double,
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
      pacienteId: json['paciente_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'peso': peso,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'pacienteId': pacienteId,
    };
  }
}
