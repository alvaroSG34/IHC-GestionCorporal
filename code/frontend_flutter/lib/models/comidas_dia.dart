class Alimento {
  const Alimento({
    required this.id,
    required this.nombre,
    required this.porcion,
    required this.calorias,
    this.observacion,
  });

  final int id;
  final String nombre;
  final String porcion;
  final int calorias;
  final String? observacion;

  factory Alimento.fromJson(Map<String, dynamic> json) => Alimento(
    id: json['id'] as int,
    nombre: json['nombre'] as String,
    porcion: json['porcion'] as String,
    calorias: json['calorias'] as int,
    observacion: json['observacion'] as String?,
  );
}

class Comida {
  const Comida({
    required this.id,
    required this.diaSemana,
    required this.tipo,
    required this.alimentos,
    required this.totalCalorias,
  });

  final int id;
  final String diaSemana;
  final String tipo;
  final List<Alimento> alimentos;
  final int totalCalorias;

  factory Comida.fromJson(Map<String, dynamic> json) => Comida(
    id: json['id'] as int,
    diaSemana: json['dia_semana'] as String,
    tipo: json['tipo'] as String,
    alimentos: (json['alimentos'] as List<dynamic>)
        .map((alimento) => Alimento.fromJson(alimento as Map<String, dynamic>))
        .toList(),
    totalCalorias: json['total_calorias'] as int,
  );
}

class ComidasDia {
  const ComidasDia({
    required this.dietaId,
    required this.diaSemana,
    this.desayuno,
    this.almuerzo,
    this.cena,
  });

  final int dietaId;
  final String diaSemana;
  final Comida? desayuno;
  final Comida? almuerzo;
  final Comida? cena;

  factory ComidasDia.fromJson(Map<String, dynamic> json) => ComidasDia(
    dietaId: json['dieta_id'] as int,
    diaSemana: json['dia_semana'] as String,
    desayuno: json['desayuno'] == null
        ? null
        : Comida.fromJson(json['desayuno'] as Map<String, dynamic>),
    almuerzo: json['almuerzo'] == null
        ? null
        : Comida.fromJson(json['almuerzo'] as Map<String, dynamic>),
    cena: json['cena'] == null
        ? null
        : Comida.fromJson(json['cena'] as Map<String, dynamic>),
  );
}
