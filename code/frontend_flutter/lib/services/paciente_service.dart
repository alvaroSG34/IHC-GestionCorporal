import 'dart:convert';
import 'package:http/http.dart' as http;
import '../consts/api_constants.dart';
import '../models/paciente.dart';

class PacienteService {
  Future<Paciente> getPaciente(int pacienteId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pacientes/$pacienteId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Paciente.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Error al cargar paciente: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>?> getUltimaEvaluacion(int pacienteId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/evaluaciones/paciente/$pacienteId/ultimaevaluacion'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(
      'Error al cargar la ultima evaluacion: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<Paciente>> getPacientes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pacientes/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);

      return decoded.map((json) => Paciente.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al cargar pacientes: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Paciente> createPaciente({
    required String nombre,
    required String sexo,
    required DateTime fechaNacimiento,
    String? telefono,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pacientes/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'sexo': sexo,
        'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T').first,
        'telefono': telefono,
      }),
    );

    if (response.statusCode == 201) {
      return Paciente.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear paciente: ${response.body}');
    }
  }

  Future<void> updatePaciente({
    required int pacienteId,
    required String nombre,
    required String sexo,
    required DateTime fechaNacimiento,
    String? telefono,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/pacientes/$pacienteId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'sexo': sexo,
        'fecha_nacimiento': fechaNacimiento.toIso8601String().split('T').first,
        'telefono': telefono,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar paciente: ${response.body}');
    }
  }

  Future<void> deletePaciente(int pacienteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pacientes/$pacienteId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar paciente: ${response.body}');
    }
  }
}
