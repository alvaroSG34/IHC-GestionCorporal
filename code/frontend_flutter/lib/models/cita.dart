enum EstadoCita {
  programada('programada'),
  cancelada('cancelada');

  const EstadoCita(this.apiValue);
  final String apiValue;

  factory EstadoCita.fromJson(String value) => EstadoCita.values.firstWhere(
    (estado) => estado.apiValue == value,
    orElse: () => EstadoCita.programada,
  );

  String get etiqueta =>
      this == EstadoCita.programada ? 'Programada' : 'Cancelada';
}

class PacienteCita {
  const PacienteCita({required this.id, required this.nombre});

  final int id;
  final String nombre;

  factory PacienteCita.fromJson(Map<String, dynamic> json) =>
      PacienteCita(id: json['id'] as int, nombre: json['nombre'] as String);
}

class Cita {
  const Cita({
    required this.id,
    required this.paciente,
    required this.fechaHora,
    required this.tipoConsulta,
    required this.observacion,
    required this.estado,
    required this.fechaCreacion,
  });

  final int id;
  final PacienteCita paciente;
  final DateTime fechaHora;
  final String tipoConsulta;
  final String? observacion;
  final EstadoCita estado;
  final DateTime fechaCreacion;

  factory Cita.fromJson(Map<String, dynamic> json) => Cita(
    id: json['id'] as int,
    paciente: PacienteCita.fromJson(json['paciente'] as Map<String, dynamic>),
    fechaHora: DateTime.parse(json['fecha_hora'] as String),
    tipoConsulta: json['tipo_consulta'] as String,
    observacion: json['observacion'] as String?,
    estado: EstadoCita.fromJson(json['estado'] as String),
    fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
  );
}

class AgendaCitas {
  const AgendaCitas({
    required this.hoy,
    required this.proximas,
    required this.anteriores,
  });

  final List<Cita> hoy;
  final List<Cita> proximas;
  final List<Cita> anteriores;

  factory AgendaCitas.fromJson(Map<String, dynamic> json) => AgendaCitas(
    hoy: _citas(json['hoy']),
    proximas: _citas(json['proximas']),
    anteriores: _citas(json['anteriores']),
  );

  List<Cita> get todas => [...hoy, ...proximas, ...anteriores];

  static List<Cita> _citas(dynamic value) => (value as List<dynamic>)
      .map((item) => Cita.fromJson(item as Map<String, dynamic>))
      .toList();
}
