import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/config/api.dart';
import 'package:frontend/models/profile_modal.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ProfileResult {
  final bool success;
  final CitizenProfile? profile;
  final CitizenStats? stats;
  final String? error;

  const ProfileResult({
    required this.success,
    this.profile,
    this.stats,
    this.error,
  });
}

class ActionResult {
  final bool success;
  final String? message;

  const ActionResult({
    required this.success,
    this.message,
  });
}

class ProfileService {
  static Future<Map<String, String>> headers() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  static Future<ProfileResult> getProfile() async {
    try {
      final r = await http
          .get(
            Uri.parse(Api.profile),
            headers: await headers(),
          )
          .timeout(Api.timeout);
      final d = _safeDecode(r.body);

      if (r.statusCode == 200 && d['success'] == true) {
        return ProfileResult(
          success: true,
          profile: CitizenProfile.fromJson(
            d['profile'] as Map<String, dynamic>,
          ),
          stats: CitizenStats.fromJson(
            d['stats'] as Map<String, dynamic>,
          ),
        );
      }

      return ProfileResult(
        success: false,
        error: d['message'] as String? ?? 'Failed to load profile',
      );
    } on TimeoutException {
      return const ProfileResult(
        success: false,
        error: 'Request timed out. Please try again.',
      );
    } on SocketException {
      return const ProfileResult(
        success: false,
        error: 'No internet connection. Please check your connection and try again.',
      );
    } catch (e) {
      return ProfileResult(
        success: false,
        error: 'Something went wrong: $e',
      );
    }
  }

  static Future<ActionResult> changePassword({
    required String current,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final r = await http
          .patch(
            Uri.parse('${Api.profile}/password'),
            headers: await headers(),
            body: jsonEncode({
              'currentPassword': current,
              'newPassword': newPassword,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(Api.timeout);
      final d = _safeDecode(r.body);
      return ActionResult(
        success: d['success'] as bool? ?? (r.statusCode >= 200 && r.statusCode < 300),
        message: d['message'] as String? ??
            (r.statusCode >= 200 && r.statusCode < 300
                ? 'Password updated successfully.'
                : 'Failed to update password.'),
      );
    } on TimeoutException {
      return const ActionResult(
        success: false,
        message: 'Request timed out. Please try again.',
      );
    } on SocketException {
      return const ActionResult(
        success: false,
        message: 'No internet connection. Please check your connection and try again.',
      );
    } catch (e) {
      return ActionResult(
        success: false,
        message: 'Something went wrong: $e',
      );
    }
  }
}