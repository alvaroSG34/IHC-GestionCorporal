import 'dart:convert';

import 'package:http/http.dart' as http;

import '../consts/api_constants.dart';
import '../models/comidas_dia.dart';
import '../models/dieta.dart';
import 'session_service.dart';

class DietaService {
  Future<Alimento> actualizarAlimento({
    required int alimentoId,
    required String nombre,
    required String porcion,
    required int calorias,
  }) async {
    final respuesta = await http.patch(
      Uri.parse('$baseUrl/dietas/alimentos/$alimentoId'),
      headers: await SessionService().encabezadosAutenticados(),
      body: jsonEncode({
        'nombre': nombre.trim(),
        'porcion': porcion.trim(),
        'calorias': calorias,
      }),
    );
    if (respuesta.statusCode == 200) {
      return Alimento.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      _detalleError(respuesta.body) ?? 'No se pudo actualizar el alimento.',
    );
  }

  Future<void> eliminarAlimento(int alimentoId) async {
    final respuesta = await http.delete(
      Uri.parse('$baseUrl/dietas/alimentos/$alimentoId'),
      headers: await SessionService().encabezadosAutenticados(),
    );
    if (respuesta.statusCode != 200) {
      throw Exception(
        _detalleError(respuesta.body) ?? 'No se pudo eliminar el alimento.',
      );
    }
  }

  Future<Comida> agregarAlimento({
    required int dietaId,
    required String diaSemana,
    required String tipo,
    required String nombre,
    required String porcion,
    required int calorias,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/dietas/$dietaId/comidas/$diaSemana/$tipo/alimentos'),
      headers: await SessionService().encabezadosAutenticados(),
      body: jsonEncode({
        'nombre': nombre.trim(),
        'porcion': porcion.trim(),
        'calorias': calorias,
      }),
    );
    if (respuesta.statusCode == 201) {
      return Comida.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      _detalleError(respuesta.body) ?? 'No se pudo guardar el alimento.',
    );
  }

  Future<ComidasDia> getComidasDelDia({
    required int dietaId,
    required String diaSemana,
  }) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/dietas/$dietaId/comidas/$diaSemana'),
      headers: await SessionService().encabezadosAutenticados(),
    );
    if (respuesta.statusCode == 200) {
      return ComidasDia.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      _detalleError(respuesta.body) ?? 'No se pudieron cargar las comidas.',
    );
  }

  Future<Dieta> crearDieta({
    required int pacienteId,
    required String nombre,
    required String objetivo,
    required int caloriasDiarias,
    required DateTime fechaInicio,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$baseUrl/dietas/'),
      headers: await SessionService().encabezadosAutenticados(),
      body: jsonEncode({
        'paciente_id': pacienteId,
        'nombre': nombre.trim(),
        'objetivo': objetivo.trim(),
        'calorias_diarias': caloriasDiarias,
        'fecha_inicio': fechaInicio.toIso8601String().split('T').first,
      }),
    );
    if (respuesta.statusCode == 201) {
      return Dieta.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
    }
    throw Exception(
      _detalleError(respuesta.body) ?? 'No se pudo crear la dieta.',
    );
  }

  Future<Dieta?> getDietaActiva(int pacienteId) async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/dietas/paciente/$pacienteId/activa'),
      headers: await SessionService().encabezadosAutenticados(),
    );
    if (respuesta.statusCode == 200) {
      return Dieta.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
    }
    if (respuesta.statusCode == 404) return null;
    throw Exception(
      _detalleError(respuesta.body) ?? 'No se pudo cargar la dieta.',
    );
  }

  String? _detalleError(String cuerpo) {
    try {
      return (jsonDecode(cuerpo) as Map<String, dynamic>)['detail'] as String?;
    } catch (_) {
      return null;
    }
  }
}
