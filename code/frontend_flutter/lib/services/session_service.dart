import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usuario.dart';

class SessionService {
  SessionService({FlutterSecureStorage? almacenamiento})
    : _almacenamiento = almacenamiento ?? const FlutterSecureStorage();

  static const _llaveToken = 'sesion.access_token';
  static const _llaveUsuario = 'sesion.usuario';
  final FlutterSecureStorage _almacenamiento;

  Future<void> guardarSesion({
    required String token,
    required Usuario usuario,
  }) async {
    await _almacenamiento.write(key: _llaveToken, value: token);
    await _almacenamiento.write(
      key: _llaveUsuario,
      value: jsonEncode(usuario.toJson()),
    );
  }

  Future<String?> obtenerToken() async {
    try {
      return await _almacenamiento.read(key: _llaveToken);
    } catch (_) {
      await _limpiarSesionCorrupta();
      return null;
    }
  }

  Future<Usuario?> obtenerUsuario() async {
    try {
      final datos = await _almacenamiento.read(key: _llaveUsuario);
      if (datos == null || datos.isEmpty) return null;
      return Usuario.fromJson(jsonDecode(datos) as Map<String, dynamic>);
    } catch (_) {
      await _limpiarSesionCorrupta();
      return null;
    }
  }

  Future<bool> haySesion() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, String>> encabezadosAutenticados() async {
    final token = await obtenerToken();
    if (token == null || token.isEmpty) {
      throw StateError('no hay sesion activa');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> cerrarSesion() async {
    await _limpiarSesionCorrupta();
  }

  Future<void> _limpiarSesionCorrupta() async {
    await _almacenamiento.delete(key: _llaveToken);
    await _almacenamiento.delete(key: _llaveUsuario);
  }
}
