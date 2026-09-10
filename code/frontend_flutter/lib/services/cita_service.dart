import 'dart:convert';

import 'package:http/http.dart' as http;

import '../consts/api_constants.dart';
import '../models/cita.dart';
import 'session_service.dart';

class CitaService {
  Future<AgendaCitas> getAgenda() async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/citas/agenda'),
      headers: await _encabezados(),
    );
    if (respuesta.statusCode == 200) {
      return AgendaCitas.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception('No se pudo cargar la agenda.');
  }

  Future<Cita> getCita(int citaId) async => _respuestaCita(
    await http.get(
      Uri.parse('$baseUrl/citas/$citaId'),
      headers: await _encabezados(),
    ),
  );

  Future<Cita> crearCita({
    required int pacienteId,
    required DateTime fechaHora,
    required String tipoConsulta,
    String? observacion,
  }) async => _respuestaCita(
    await http.post(
      Uri.parse('$baseUrl/citas/'),
      headers: await _encabezados(),
      body: jsonEncode(
        _datos(pacienteId, fechaHora, tipoConsulta, observacion),
      ),
    ),
    esperado: 201,
  );

  Future<Cita> actualizarCita({
    required int citaId,
    required int pacienteId,
    required DateTime fechaHora,
    required String tipoConsulta,
    String? observacion,
  }) async => _respuestaCita(
    await http.put(
      Uri.parse('$baseUrl/citas/$citaId'),
      headers: await _encabezados(),
      body: jsonEncode(
        _datos(pacienteId, fechaHora, tipoConsulta, observacion),
      ),
    ),
  );

  Future<Cita> cancelarCita(int citaId) async => _respuestaCita(
    await http.patch(
      Uri.parse('$baseUrl/citas/$citaId/cancelar'),
      headers: await _encabezados(),
    ),
  );

  Map<String, dynamic> _datos(
    int pacienteId,
    DateTime fechaHora,
    String tipoConsulta,
    String? observacion,
  ) => {
    'paciente_id': pacienteId,
    'fecha_hora': fechaHora.toIso8601String(),
    'tipo_consulta': tipoConsulta.trim(),
    'observacion': observacion?.trim().isEmpty ?? true
        ? null
        : observacion!.trim(),
  };

  Cita _respuestaCita(http.Response respuesta, {int esperado = 200}) {
    if (respuesta.statusCode == esperado) {
      return Cita.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
    }
    final detalle = _detalleError(respuesta.body);
    throw Exception(detalle ?? 'No se pudo guardar la cita.');
  }

  String? _detalleError(String cuerpo) {
    try {
      return (jsonDecode(cuerpo) as Map<String, dynamic>)['detail'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _encabezados() {
    return SessionService().encabezadosAutenticados();
  }
}
