import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/config/api.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
class ChatResponse {
  final bool success;
  final String? reply;
  final List<String> suggestions;
  final String? errorMessage;
  const ChatResponse({
    required this.success,
    this.reply,
    this.suggestions = const [],
    this.errorMessage
  });
}
class ChatService {
  static Future<Map<String, String>> headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  // POST /api/chat
  static Future<ChatResponse> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(Api.chat),
        headers: await headers(),
        body: jsonEncode({'message': message.trim()})
      ).timeout(const Duration(seconds: 30));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true){
        final suggestions = (data['suggestions'] as List? ?? []).cast<String>();
        return ChatResponse(
          success: true,
          reply: data['reply'] as String?,
          suggestions: suggestions
          );
      }
      return ChatResponse(
        success: false,
        errorMessage: data['message'] as String? ?? 'The assistant is unavailable. Please try again.'
        );
    } on TimeoutException{
      return const ChatResponse(
        success: false,
        errorMessage: 'The assistant took too long to respond. Try again.'
        );
    } on SocketException{
      return const ChatResponse(
        success: false,
        errorMessage: 'No internet connection.'
        );
    }
    catch (_){
      return const ChatResponse(
        success: false,
        errorMessage: 'Something went wrong. Please try again.'
        );
    }
  }
  // DELETE
  static Future<bool> clearHistory() async {
    try {
      final response = await http.delete(
        Uri.parse('${Api.chat}/history'),
        headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String,dynamic>;
      return data['success'] == true;
    }
    catch (_){
      return false;
    }
  }
}