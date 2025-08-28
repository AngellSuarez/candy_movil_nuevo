import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  //verificar si el login esta autenticado
  Future<void> checkLogin(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(username, password);

    if (result['success']) {
      _isAuthenticated = true;
      _user = result['data'];
    } else {
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  //verificacion del logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _isAuthenticated = false;
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  //obtener perfil
  Future<void> conseguirUsuario() async {
    final result = await _authService.conseguirPerfil();

    if (result['success']) {
      _user = result['data'];
      _isAuthenticated = true;
    } else {
      _user = null;
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}
