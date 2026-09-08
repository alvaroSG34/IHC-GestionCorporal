import 'dart:convert';
import 'package:http/http.dart' as http;
import '../consts/api_constants.dart';
import '../models/usuario.dart';

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(_getErrorMessage(response, 'Error al iniciar sesion'));
  }

  Future<AuthResponse> registrar(RegistroRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(_getErrorMessage(response, 'Error al registrar usuario'));
  }

  String _getErrorMessage(http.Response response, String defaultMessage) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
        return '$defaultMessage: ${decoded['detail']}';
      }
    } catch (_) {
      return '$defaultMessage: ${response.statusCode}';
    }

    return '$defaultMessage: ${response.statusCode}';
  }
}
