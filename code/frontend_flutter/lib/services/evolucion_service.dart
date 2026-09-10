import 'dart:convert';

import 'package:http/http.dart' as http;

import '../consts/api_constants.dart';
import '../models/evolucion.dart';
import 'session_service.dart';

class EvolucionService {
  Future<Map<String, String>> _encabezados() =>
      SessionService().encabezadosAutenticados();

  Future<Evolucion> getEvolucion({
    required int pacienteId,
    required MetricaEvolucion metrica,
    required PeriodoEvolucion periodo,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final parametros = <String, String>{
      'metrica': metrica.apiValue,
      'periodo': periodo.apiValue,
    };
    if (desde != null) parametros['desde'] = _fechaApi(desde);
    if (hasta != null) parametros['hasta'] = _fechaApi(hasta);

    final uri = Uri.parse(
      '$baseUrl/evolucion/paciente/$pacienteId',
    ).replace(queryParameters: parametros);
    final respuesta = await http.get(uri, headers: await _encabezados());

    if (respuesta.statusCode == 200) {
      return Evolucion.fromJson(
        jsonDecode(respuesta.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      'Error al cargar la evoluci\u00f3n: ${respuesta.statusCode} - ${respuesta.body}',
    );
  }

  Future<Map<MetricaEvolucion, Evolucion>> getResumen(int pacienteId) async {
    final resultados = await Future.wait(
      MetricaEvolucion.values.map(
        (metrica) => getEvolucion(
          pacienteId: pacienteId,
          metrica: metrica,
          periodo: PeriodoEvolucion.todoHistorial,
        ),
      ),
    );
    return Map.fromEntries(
      resultados.map((resultado) => MapEntry(resultado.metrica, resultado)),
    );
  }

  String _fechaApi(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '$anio-$mes-$dia';
  }
}
