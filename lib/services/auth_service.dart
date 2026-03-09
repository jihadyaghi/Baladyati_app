import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/config/api.dart';
import 'package:frontend/models/zone_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/citizen_model.dart';
class AuthResult {
  final bool          success;
  final String?       token;
  final CitizenModel? citizen;
  final String?       errorMessage;
  const AuthResult({
    required this.success,
    this.token,
    this.citizen,
    this.errorMessage,
  });
}
class ZonesResult {
  final bool           success;
  final List<ZoneModel> zones;
  final String?        errorMessage;

  const ZonesResult({
    required this.success,
    this.zones = const [],
    this.errorMessage,
  });
}
class AuthService {
  static const _storage  = FlutterSecureStorage();
  static const _tokenKey = 'baladiyati_token';
  static Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String dateOfBirth, // format: YYYY-MM-DD
    required int    zoneId,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Api.register),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firstName':       firstName.trim(),
              'lastName':        lastName.trim(),
              'phone':           phone.trim(),
              'dateOfBirth':     dateOfBirth,
              'zoneId':          zoneId,
              'password':        password,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(Api.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        final token   = data['token']   as String;
        final citizen = CitizenModel.fromJson(
            data['citizen'] as Map<String, dynamic>);

        await _storage.write(key: _tokenKey, value: token);

        return AuthResult(success: true, token: token, citizen: citizen);
      }

      return AuthResult(
        success:      false,
        errorMessage: data['message'] as String? ??
            'Registration failed. Please try again.',
      );
    } on TimeoutException {
      return const AuthResult(
          success: false,
          errorMessage: 'Connection timed out. Check your internet.');
    } on SocketException {
      return const AuthResult(
          success: false,
          errorMessage: 'No internet connection.');
    } catch (_) {
      return const AuthResult(
          success: false,
          errorMessage: 'Something went wrong. Please try again.');
    }
  }
  static Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Api.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone':    phone.trim(),
              'password': password,
            }),
          )
          .timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        final token   = data['token']   as String;
        final citizen = CitizenModel.fromJson(
            data['citizen'] as Map<String, dynamic>);
        await _storage.write(key: _tokenKey, value: token);

        return AuthResult(success: true, token: token, citizen: citizen);
      }
      return AuthResult(
        success:      false,
        errorMessage: data['message'] as String? ??
            'Login failed. Please try again.',
      );
    } on TimeoutException {
      return const AuthResult(
        success:      false,
        errorMessage: 'Connection timed out. Check your internet.',
      );
    } on SocketException {
      return const AuthResult(
        success:      false,
        errorMessage: 'No internet connection. Please check your network.',
      );
    } catch (_) {
      return const AuthResult(
        success:      false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }
  static Future<ZonesResult> fetchZones() async {
    try {
      final response = await http
          .get(Uri.parse(Api.zones))
          .timeout(Api.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final zones = (data['zones'] as List)
            .map((z) => ZoneModel.fromJson(z as Map<String, dynamic>))
            .toList();
        return ZonesResult(success: true, zones: zones);
      }

      return const ZonesResult(
          success: false, errorMessage: 'Could not load zones.');
    } catch (_) {
      return const ZonesResult(
          success: false, errorMessage: 'Could not load zones.');
    }
  }
  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      http.post(
        Uri.parse(Api.logout),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer $token',
        },
      ).catchError((_) {});
    }
    await _storage.delete(key: _tokenKey);
  }
}
