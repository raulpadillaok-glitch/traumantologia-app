import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'db_service.dart';
import 'theme_service.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;

  AuthService() {
    _loadSession();
  }

  void _loadSession() {
    // Optionally load last logged in user from SharedPreferences or Hive
    // For now we'll start logged out
  }

  Future<bool> login(String email, String password) async {
    final box = Hive.box(DBService.usersBoxName);
    for (var value in box.values) {
      final user = User.fromJson(Map<String, dynamic>.from(value));
      if (user.email == email && user.password == password) {
        _currentUser = user;
        themeService.setTheme(user.themeName);
        notifyListeners();
        return true;
      }
    }
    
    // Fallback test user
    if (email == 'test@test.com' && password == '123456') {
      final testUser = User(id: 'test_user', name: 'Usuario Prueba', email: email, password: password, role: 'user', themeName: 'Oscuro');
      await box.put(testUser.id, testUser.toJson());
      _currentUser = testUser;
      themeService.setTheme(testUser.themeName);
      notifyListeners();
      return true;
    }

    // Fallback admin user
    if (email == 'admin@test.com' && password == '123456') {
      final adminUser = User(id: 'admin_user', name: 'Administrador', email: email, password: password, role: 'admin', themeName: 'Oscuro');
      await box.put(adminUser.id, adminUser.toJson());
      _currentUser = adminUser;
      themeService.setTheme(adminUser.themeName);
      notifyListeners();
      return true;
    }
    
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final box = Hive.box(DBService.usersBoxName);
      
      // Check if user exists
      final users = box.values.map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList();
      if (users.any((u) => u.email == email)) {
        return false; // Email already registered
      }

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        password: password,
      );

      await box.put(newUser.id, newUser.toJson());
      
      // Asignar ejercicios por defecto a este usuario nuevo
      await DBService.seedExercisesForUser(newUser.id);
      
      _currentUser = newUser;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUser(String newName, String newPassword, {String? themeName}) async {
    if (_currentUser == null) return;
    
    final updatedUser = User(
      id: _currentUser!.id,
      name: newName.isNotEmpty ? newName : _currentUser!.name,
      email: _currentUser!.email,
      password: newPassword.isNotEmpty ? newPassword : _currentUser!.password,
      role: _currentUser!.role,
      themeName: themeName ?? _currentUser!.themeName,
    );

    final box = Hive.box(DBService.usersBoxName);
    await box.put(updatedUser.id, updatedUser.toJson());
    _currentUser = updatedUser;
    
    if (themeName != null) {
      themeService.setTheme(themeName);
    }
    
    notifyListeners();
  }
}

// Global instance for simple access without provider for this demo
final authService = AuthService();
