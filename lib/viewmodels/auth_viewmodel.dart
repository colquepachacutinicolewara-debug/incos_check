// viewmodels/auth_viewmodel.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/usuario_model.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;

  Usuario? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthViewModel(this._authService);

  // Getters
  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Inicializar usuario actual
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = 'Error al inicializar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Iniciar sesión
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmailPassword(email, password);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _currentUser = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = 'Error al cerrar sesión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.changePassword(currentPassword, newPassword);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restablecer contraseña
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar permisos
  Future<bool> hasPermission(String permission) async {
    return await _authService.currentUserHasPermission(permission);
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}