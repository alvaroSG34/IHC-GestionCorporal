import 'dart:convert';
import 'package:http/http.dart' as http;
import '../consts/api_constants.dart';
import '../models/evaluacion.dart';

class EvaluacionService {
  Future<Evaluacion> getEvaluacion(int evaluacionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/evaluaciones/$evaluacionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Evaluacion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al cargar evaluacion: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<Evaluacion>> getEvaluaciones(int pacienteId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/evaluaciones/paciente/$pacienteId'),
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

  Future<Evaluacion> createEvaluacion({
    required int paciente,
    required int altura,
    required double peso,
    required double masa,
    String? observacion,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/evaluaciones/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'altura': altura,
        'peso': peso,
        'masa_muscular': masa,
        'observacion': observacion,
        'paciente_id': paciente,
      }),
    );

    if (response.statusCode == 201) {
      return Evaluacion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear Evaluacion: ${response.body}');
    }
  }

  Future<Evaluacion> updateEvaluacion({
    required int evaluacionId,
    required int paciente,
    required int altura,
    required double peso,
    required double masa,
    String? observacion,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/evaluaciones/$evaluacionId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'altura': altura,
        'peso': peso,
        'masa_muscular': masa,
        'observacion': observacion,
        'paciente_id': paciente,
      }),
    );

    if (response.statusCode == 200) {
      return Evaluacion.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar Evaluacion: ${response.body}');
    }
  }

  Future<void> deleteEvaluacion(int evaluacionId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/evaluaciones/$evaluacionId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar Evaluacion: ${response.body}');
    }
  }
}
