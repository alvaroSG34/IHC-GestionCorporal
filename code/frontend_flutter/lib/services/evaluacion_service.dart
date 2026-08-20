import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/evaluacion.dart';

class EvaluacionService {
  static const String _baseUrl = 'http://10.0.2.2:8000';

  Future<List<Evaluacion>> getEvaluaciones(int pacienteId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/evaluaciones/paciente/$pacienteId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      return decoded.map((json) => Evaluacion.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al cargar evaluaciones: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
