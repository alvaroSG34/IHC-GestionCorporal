class Paciente {
  final int id;
  final String nombre;
  final String sexo;
  final DateTime fechaNacimiento;
  final String? telefono;

  Paciente({
    required this.id,
    required this.nombre,
    required this.sexo,
    required this.fechaNacimiento,
    this.telefono,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      sexo: json['sexo'] as String,
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      telefono: json['telefono'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'telefono': telefono,
    };
  }
}
