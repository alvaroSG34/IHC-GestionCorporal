class Evaluacion {
  final int id;
  final int nro_evaluacion;
  final int altura;
  final double peso;
  final double imc;
  final double masa_muscular;
  final String? observacion;
  final DateTime fechaRegistro;
  final int pacienteId;
  final bool esta_activo;

  Evaluacion({
    required this.id,
    required this.nro_evaluacion,
    required this.altura,
    required this.peso,
    required this.imc,
    required this.masa_muscular,
    required this.observacion,
    required this.fechaRegistro,
    required this.pacienteId,
    required this.esta_activo,
  });

  factory Evaluacion.fromJson(Map<String, dynamic> json) {
    return Evaluacion(
      id: json['id'] as int,
      nro_evaluacion: json['nro_evaluacion'] as int,
      altura: json['altura'] as int,
      peso: json['peso'] as double,
      imc: (json['imc'] as num).toDouble(),
      masa_muscular: json['masa_muscular'] as double,
      observacion: json['observacion'] as String?,
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
      pacienteId: json['paciente_id'] as int,
      esta_activo: json['esta_activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nro_evaluacion': nro_evaluacion,
      'altura': altura,
      'peso': peso,
      'imc': imc,
      'masa_muscular': masa_muscular,
      'observacion': observacion,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'paciente_id': pacienteId,
      'esta_activo': esta_activo,
    };
  }
}
