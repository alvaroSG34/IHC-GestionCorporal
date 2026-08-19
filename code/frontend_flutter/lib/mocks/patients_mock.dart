class Evaluacion {
  DateTime fechaEvaluacion;
  double peso;

  Evaluacion({required this.fechaEvaluacion, required this.peso});
}

class Paciente {
  String identificador;
  String nombre;
  String sexo;
  DateTime fechaNacimiento;
  List<Evaluacion> evaluaciones;

  Paciente({
    required this.identificador,
    required this.nombre,
    required this.sexo,
    required this.fechaNacimiento,
    required this.evaluaciones,
  });
}

final List<Paciente> pacientesMock = [
  Paciente(
    identificador: 'p01',
    nombre: 'Ana Maria Flores',
    sexo: 'Femenino',
    fechaNacimiento: DateTime(1992, 4, 18),
    evaluaciones: [
      Evaluacion(fechaEvaluacion: DateTime(2026, 8, 5), peso: 62.4),
    ],
  ),
  Paciente(
    identificador: 'p02',
    nombre: 'Carlos Eduardo Vargas',
    sexo: 'Masculino',
    fechaNacimiento: DateTime(1987, 11, 2),
    evaluaciones: [
      Evaluacion(fechaEvaluacion: DateTime(2026, 8, 6), peso: 81.7),
    ],
  ),
  Paciente(
    identificador: 'p03',
    nombre: 'Lucia Beatriz Rojas',
    sexo: 'Femenino',
    fechaNacimiento: DateTime(1998, 1, 27),
    evaluaciones: [
      Evaluacion(fechaEvaluacion: DateTime(2026, 8, 8), peso: 55.9),
    ],
  ),
  Paciente(
    identificador: 'p04',
    nombre: 'Diego alejandro Mendoza',
    sexo: 'Masculino',
    fechaNacimiento: DateTime(1979, 7, 14),
    evaluaciones: [
      Evaluacion(fechaEvaluacion: DateTime(2026, 8, 10), peso: 94.3),
    ],
  ),
  Paciente(
    identificador: 'p05',
    nombre: 'Sofia Valentina quiroga',
    sexo: 'Femenino',
    fechaNacimiento: DateTime(2001, 9, 30),
    evaluaciones: [
      Evaluacion(fechaEvaluacion: DateTime(2026, 8, 12), peso: 68.1),
    ],
  ),
];
