import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/config/api.dart';
import 'package:frontend/models/home_modal.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
class HomeResult{
  final bool success;
  final HomeData? data;
  final String? errorMessage;
  const HomeResult({
    required this.success,
    this.data,
    this.errorMessage
  });
}
class HomeService {
  // GET /api/home  — requires JWT
  static Future<HomeResult> fetchHomeData() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return const HomeResult(
          success:      false,
          errorMessage: 'Not authenticated.',
        );
      }

      final response = await http
          .get(
            Uri.parse(Api.home),
            headers: {
              'Content-Type':  'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Api.timeout);

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && json['success'] == true) {
        return HomeResult(
          success: true,
          data:    HomeData.fromJson(json),
        );
      }

      return HomeResult(
        success:      false,
        errorMessage: json['message'] as String? ?? 'Failed to load data.',
      );
    } on TimeoutException {
      return const HomeResult(
        success: false, errorMessage: 'Connection timed out.');
    } on SocketException {
      return const HomeResult(
        success: false, errorMessage: 'No internet connection.');
    } catch (_) {
      return const HomeResult(
        success: false, errorMessage: 'Something went wrong.');
    }
  }
}
