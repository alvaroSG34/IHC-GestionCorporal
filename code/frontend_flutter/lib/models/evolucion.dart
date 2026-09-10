enum MetricaEvolucion { peso, imc, masaMuscular }

extension MetricaEvolucionX on MetricaEvolucion {
  String get apiValue => switch (this) {
    MetricaEvolucion.peso => 'peso',
    MetricaEvolucion.imc => 'imc',
    MetricaEvolucion.masaMuscular => 'masa_muscular',
  };

  String get etiqueta => switch (this) {
    MetricaEvolucion.peso => 'Peso',
    MetricaEvolucion.imc => 'IMC',
    MetricaEvolucion.masaMuscular => 'Masa muscular',
  };

  String get unidad => switch (this) {
    MetricaEvolucion.peso => 'kg',
    MetricaEvolucion.imc => 'kg/m\u00b2',
    MetricaEvolucion.masaMuscular => '%',
  };

  static MetricaEvolucion fromApi(String value) => switch (value) {
    'peso' => MetricaEvolucion.peso,
    'imc' => MetricaEvolucion.imc,
    'masa_muscular' => MetricaEvolucion.masaMuscular,
    _ => throw FormatException('M\u00e9trica no reconocida: $value'),
  };
}

enum PeriodoEvolucion {
  ultimas3,
  ultimoMes,
  ultimos3Meses,
  todoHistorial,
  personalizado,
}

extension PeriodoEvolucionX on PeriodoEvolucion {
  String get apiValue => switch (this) {
    PeriodoEvolucion.ultimas3 => 'ultimas_3',
    PeriodoEvolucion.ultimoMes => 'ultimo_mes',
    PeriodoEvolucion.ultimos3Meses => 'ultimos_3_meses',
    PeriodoEvolucion.todoHistorial => 'todo_historial',
    PeriodoEvolucion.personalizado => 'personalizado',
  };

  String get etiqueta => switch (this) {
    PeriodoEvolucion.ultimas3 => '\u00daltimas 3 evaluaciones',
    PeriodoEvolucion.ultimoMes => '\u00daltimo mes',
    PeriodoEvolucion.ultimos3Meses => '\u00daltimos 3 meses',
    PeriodoEvolucion.todoHistorial => 'Todo el historial',
    PeriodoEvolucion.personalizado => 'Rango personalizado',
  };

  static PeriodoEvolucion fromApi(String value) => switch (value) {
    'ultimas_3' => PeriodoEvolucion.ultimas3,
    'ultimo_mes' => PeriodoEvolucion.ultimoMes,
    'ultimos_3_meses' => PeriodoEvolucion.ultimos3Meses,
    'todo_historial' => PeriodoEvolucion.todoHistorial,
    'personalizado' => PeriodoEvolucion.personalizado,
    _ => throw FormatException('Per\u00edodo no reconocido: $value'),
  };
}

class PacienteEvolucion {
  const PacienteEvolucion({required this.id, required this.nombre});

  final int id;
  final String nombre;

  factory PacienteEvolucion.fromJson(Map<String, dynamic> json) {
    return PacienteEvolucion(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

class PuntoEvolucion {
  const PuntoEvolucion({
    required this.numeroEvaluacion,
    required this.fecha,
    required this.valor,
  });

  final int numeroEvaluacion;
  final DateTime fecha;
  final double valor;

  factory PuntoEvolucion.fromJson(Map<String, dynamic> json) {
    return PuntoEvolucion(
      numeroEvaluacion: json['nro_evaluacion'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      valor: (json['valor'] as num).toDouble(),
    );
  }
}

class ResumenEvolucion {
  const ResumenEvolucion({
    required this.valorInicial,
    required this.valorActual,
    required this.cambio,
    required this.cantidadEvaluaciones,
  });

  final double? valorInicial;
  final double? valorActual;
  final double? cambio;
  final int cantidadEvaluaciones;

  factory ResumenEvolucion.fromJson(Map<String, dynamic> json) {
    double? numero(dynamic valor) => valor is num ? valor.toDouble() : null;

    return ResumenEvolucion(
      valorInicial: numero(json['valor_inicial']),
      valorActual: numero(json['valor_actual']),
      cambio: numero(json['cambio']),
      cantidadEvaluaciones: json['cantidad_evaluaciones'] as int,
    );
  }
}

class Evolucion {
  const Evolucion({
    required this.paciente,
    required this.metrica,
    required this.unidad,
    required this.periodo,
    required this.resumen,
    required this.puntos,
  });

  final PacienteEvolucion paciente;
  final MetricaEvolucion metrica;
  final String unidad;
  final PeriodoEvolucion periodo;
  final ResumenEvolucion resumen;
  final List<PuntoEvolucion> puntos;

  factory Evolucion.fromJson(Map<String, dynamic> json) {
    return Evolucion(
      paciente: PacienteEvolucion.fromJson(
        json['paciente'] as Map<String, dynamic>,
      ),
      metrica: MetricaEvolucionX.fromApi(json['metrica'] as String),
      unidad: json['unidad'] as String,
      periodo: PeriodoEvolucionX.fromApi(json['periodo'] as String),
      resumen: ResumenEvolucion.fromJson(
        json['resumen'] as Map<String, dynamic>,
      ),
      puntos: (json['puntos'] as List<dynamic>)
          .map(
            (punto) => PuntoEvolucion.fromJson(punto as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
