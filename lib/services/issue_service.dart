import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:frontend/config/api.dart';
import 'package:frontend/models/issue_model.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
class IssueResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  const IssueResult({
    required this.success,
    this.message,
    this.errorMessage
  });
}
class IssueService {
  static Future<Map<String, String>> headers() async{
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
  }
  // GET /api/issues/categories
  static Future<List<Map<String, dynamic>>> getCategories() async{
    try {
      final response = await http.get(
        Uri.parse("${Api.issues}/categories"),
        headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true){
        return List<Map<String, dynamic>>.from(data['categories']);
      }
      return [];
    }
    catch (_) {
      return [];
    }
  }
  //GET my issues
  // GET /api/issue
  static Future<List<Issue>> getMyIssues() async {
    try {
      final response = await http.get(
        Uri.parse(Api.issues),
        headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true){
        final List list = data['issues'];
        return list.map((e) => Issue.fromJson(e)).toList();
      }
      return [];
    }
    catch (_){
      return [];
    }
  }
  // POST submit new issue
  // POST /api/issues
  static Future<IssueResult> submitIssue({
  required int categoryId,
  required String title,
  required String description,
  required IssueSeverity severity,
  required double latitude,
  required double longitude,
  String? adrressText,
  String? photoUrl1,
  String? photoUrl2
}) async {
  try {

    final body = {
      'categoryId': categoryId,
      'title': title.trim(),
      'description': description.trim(),
      'severity': severity.key,
      'latitude': latitude,
      'longitude': longitude,
      'addressText': adrressText,
      'photoUrl1': photoUrl1,
      'photoUrl2': photoUrl2
    };

    final response = await http.post(
      Uri.parse(Api.issues),
      headers: await headers(),
      body: jsonEncode(body)
    ).timeout(Api.timeout);

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true){
      return IssueResult(
        success: true,
        message: data['message']
      );
    }

    return IssueResult(
      success: false,
      errorMessage: data['message'] ?? 'Submission failed.'
    );

  } on TimeoutException {
    return const IssueResult(
      success: false,
      errorMessage: 'Connection timed out.'
    );
  } on SocketException {
    return const IssueResult(
      success: false,
      errorMessage: 'No Internet connection.'
    );
  } catch (e) {
    return const IssueResult(
      success: false,
      errorMessage: 'Something went wrong.'
    );
  }
}
  // DELETE issue
  // DELETE /api/issues/:id
  static Future<IssueResult> deleteIssue(int issueId) async{
    try {
      final response = await http.delete(
        Uri.parse("${Api.issues}/$issueId"),
        headers: await headers()
      ).timeout(Api.timeout);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true){
        return IssueResult(
          success: true,
          message: data['message']
          );
      }
      return IssueResult(
        success: false,
        errorMessage: data['message'] ?? 'Delete failed.' 
        );
    }
    catch (_){
      return const IssueResult(
        success: false,
        errorMessage: 'Something went wrong.' 
        );
    }
  }
}