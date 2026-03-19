import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/config/api.dart';
import 'package:frontend/models/notification_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
class NotificationResult{
  final bool success;
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? errorMessage;
  const NotificationResult({
    required this.success,
    this.notifications = const [],
    this.unreadCount = 0,
    this.errorMessage
  });
}
class NotificationService {
  static Future<Map<String,String>> headers() async{
    final token = await AuthService.getToken();
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  //Get all notifications
  static Future<NotificationResult> getNotification() async{
    try{
      final response = await http.get(Uri.parse(Api.notifications),headers: await headers()).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true){
        final list = (data['notifications'] as List).map((n)=>AppNotification.fromJason(n as Map<String, dynamic>)).toList();
        return NotificationResult(
          success: true,
          notifications: list,
          unreadCount: data['unreadCount'] as int? ?? 0
          );
      }
      return NotificationResult(
        success: false,
        errorMessage: data['message'] as String? ?? 'Failed to load'
        );
    } on TimeoutException {
      return const NotificationResult(
        success: false,
        errorMessage: 'Connection timed out.'
        );
    } on SocketException {
      return const NotificationResult(
        success: false,
        errorMessage: 'No internet connection.'
        );
    }
    catch (_){
      return const NotificationResult(
        success: false,
        errorMessage: 'Something went wrong.'
        );
    }
  }
  static Future<bool> markOneRead(int id) async{
    try{
      final response = await http.patch(Uri.parse('${Api.notifications}/$id/read'),
      headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['success'] == true;
    }
    catch (_){
      return false;
    }
  }
  static Future<bool> markAllRead() async {
    try{
      final response = await http.patch(Uri.parse('${Api.notifications}/read-all'),
      headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['success'] == true;
    }
    catch (_){
      return false;
    }
  }
  static Future<bool> deleteOne(int id) async{
    try{
      final response = await http.delete(Uri.parse('${Api.notifications}/$id'),
      headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['success'] == true;
    }
    catch (_){
      return false;
    }
  }
  static Future<bool> deleteAll() async {
    try{
      final response = await http.delete(Uri.parse(Api.notifications),
      headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['success'] == true;
    }
    catch (_){
      return false;
    }
  }
}