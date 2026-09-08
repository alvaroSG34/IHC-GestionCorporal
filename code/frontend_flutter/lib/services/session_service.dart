import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  SessionService({FlutterSecureStorage? almacenamiento})
    : _almacenamiento = almacenamiento ?? const FlutterSecureStorage();

  static const _llaveToken = 'sesion.access_token';
  final FlutterSecureStorage _almacenamiento;

  Future<void> guardarToken(String token) {
    return _almacenamiento.write(key: _llaveToken, value: token);
  }

  Future<String?> obtenerToken() {
    return _almacenamiento.read(key: _llaveToken);
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

  Future<void> cerrarSesion() {
    return _almacenamiento.delete(key: _llaveToken);
  }
}
