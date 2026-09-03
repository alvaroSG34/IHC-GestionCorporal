class Paciente {
  final int id;
  final String nombre;
  final String sexo;
  final DateTime fechaNacimiento;
  final String? telefono;
  final bool esta_activo;

  Paciente({
    required this.id,
    required this.nombre,
    required this.sexo,
    required this.fechaNacimiento,
    this.telefono,
    required this.esta_activo,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      sexo: json['sexo'] as String,
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      telefono: json['telefono'] as String?,
      esta_activo: json['esta_activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'telefono': telefono,
      'esta_activo': esta_activo,
    };
  }
}
