import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/paciente.dart';

class PacienteService {
  static const String _baseUrl = 'https://ihc-gestioncorporal.onrender.com';

  Future<List<Paciente>> getPacientes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pacientes/'),
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
      Uri.parse('$_baseUrl/pacientes/'),
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
}
