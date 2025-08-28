import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = 'https://angelsuarez.pythonanywhere.com/api/';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  //login
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await secureStorage.write(key: 'access_token', value: data['access']);
      await secureStorage.write(key: 'refresh_token', value: data['refresh']);
      await secureStorage.write(
        key: 'user_id',
        value: data['user_id'].toString(),
      );
      await secureStorage.write(key: 'rol', value: data['rol']);

      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': 'Credenciales incorrectas o error del servicor',
      };
    }
  }

  //perfil
  Future<Map<String, dynamic>> conseguirPerfil() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) {
      return {'success': false, 'message': 'No hay token de acceso'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/user/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      return {'success': true, 'data': user};
    } else {
      return {
        'success': false,
        'message': 'Error al obtener la información de perfil',
      };
    }
  }

  //logout
  Future<Map<String, dynamic>> logout() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) {
      return {'success': false, 'message': 'No hay token de acceso'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      await secureStorage.deleteAll();
      return {'success': true, 'message': 'Cierre de sesión exitoso'};
    } else {
      return {'success': false, 'message': 'Error al cerrar sesión'};
    }
  }

  //register
  Future<bool> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/auth/register/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al registrar el usuario',
      );
    }
  }

  //recuperacion de contraseña

  //solicitud del codigo
  Future<Map<String, dynamic>> solicitarCodigoRecuperacion(
    String correo,
  ) async {
    final response = await http.post(
      Uri.parse(
        'https://angelsuarez.pythonanywhere.com/api/auth/password/reset-request/',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo}),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Código enviado a su correo'};
    } else {
      return {'success': false, 'message': 'Error al enviar el código'};
    }
  }

  //confirmar el codigo y cambiar la contraseña
  Future<Map<String, dynamic>> confirmarResetPassword({
    required String correo,
    required String codigo,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/reset-confirm/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'codigo': codigo,
        'nueva_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Contraseña actualizada correctamente',
      };
    } else {
      return {
        'success': false,
        'message': 'Error al confirmar el reset: ${response.body}',
      };
    }
  }
}
