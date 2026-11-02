import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/app_user.dart';

class AuthNotifier extends ChangeNotifier {
  static const _kToken = 'auth_token';
  final Dio _dio;
  final SharedPreferences _prefs;
  AppUser? _user;
  String? _token;
  AuthNotifier(this._dio, this._prefs);
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool has(Role role) => _user != null && _user!.role.level >= role.level;

  Future<void> restore() async {
    final savedToken = _prefs.getString(_kToken);
    if (savedToken == null) return;

    _token = savedToken;
    setGlobalToken(savedToken);

    try {
      final response = await _dio.post('/api/collections/users/auth-refresh');
      _user = AppUser.fromJson(response.data['record']);
      notifyListeners();
    } catch (e) {
      await logout();
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _dio.post(
      '/api/collections/users/auth-with-password',
      data: {'identity': email, 'password': password},
    );

    _token = response.data['token'];
    setGlobalToken(_token);
    _user = AppUser.fromJson(response.data['record']);

    await _prefs.setString(_kToken, _token!);
    notifyListeners();
  }

  Future<void> register(String email, String password, String name) async {
    final userRes = await _dio.post(
      '/api/collections/users/records',
      data: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
        'name': name,
        'role': 'owner',
      },
    );
    final userId = userRes.data['id'];
    final ownerRes = await _dio.post('/api/collections/owners/records', data: {
      'fullName': name,
      'phone': '',
      'email': email,
    });
    final ownerId = ownerRes.data['id'];
    await _dio.patch(
      '/api/collections/users/records/$userId',
      data: {'ownerId': ownerId},
    );

    await login(email, password);
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    setGlobalToken(null);
    await _prefs.remove(_kToken);
    notifyListeners();
  }
}