// lib/services/request_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/config/api.dart';
import 'package:http/http.dart' as http;
import '../models/request_model.dart';
import 'auth_service.dart';

class RequestsResult {
  final bool success;
  final List<DocumentRequest> requests;
  final String? errorMessage;

  const RequestsResult({
    required this.success,
    this.requests = const [],
    this.errorMessage,
  });
}

class SingleRequestResult {
  final bool success;
  final DocumentRequest? request;
  final String? errorMessage;

  const SingleRequestResult({
    required this.success,
    this.request,
    this.errorMessage,
  });
}

class ActionResult {
  final bool success;
  final String? message;
  final DocumentRequest? request;

  const ActionResult({
    required this.success,
    this.message,
    this.request,
  });
}

class DocumentTypeItem {
  final int id;
  final String name;

  const DocumentTypeItem({
    required this.id,
    required this.name,
  });

  factory DocumentTypeItem.fromJson(Map<String, dynamic> j) {
    return DocumentTypeItem(
      id: j['document_type_id'] as int,
      name: j['document_name'] as String,
    );
  }
}

class RequestService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET all my requests ────────────────────────────────────────────────────
  static Future<RequestsResult> getMyRequests() async {
    try {
      final response = await http
          .get(
            Uri.parse(Api.requests),
            headers: await _headers(),
          )
          .timeout(Api.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final list = (data['requests'] as List)
            .map((e) => DocumentRequest.fromJson(e as Map<String, dynamic>))
            .toList();

        return RequestsResult(
          success: true,
          requests: list,
        );
      }

      return RequestsResult(
        success: false,
        errorMessage: data['message'] as String? ?? 'Failed to load requests.',
      );
    } on TimeoutException {
      return const RequestsResult(
        success: false,
        errorMessage: 'Connection timed out.',
      );
    } on SocketException {
      return const RequestsResult(
        success: false,
        errorMessage: 'No internet connection.',
      );
    } catch (_) {
      return const RequestsResult(
        success: false,
        errorMessage: 'Something went wrong.',
      );
    }
  }

  // ── GET single request with notes ─────────────────────────────────────────
  static Future<SingleRequestResult> getRequestById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${Api.requests}/$id'),
            headers: await _headers(),
          )
          .timeout(Api.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final notes = (data['notes'] as List? ?? [])
            .map((n) => RequestNote.fromJson(n as Map<String, dynamic>))
            .toList();

        final req = DocumentRequest.fromJson(
          data['request'] as Map<String, dynamic>,
          notes: notes,
        );

        return SingleRequestResult(
          success: true,
          request: req,
        );
      }

      return SingleRequestResult(
        success: false,
        errorMessage: data['message'] as String? ?? 'Request not found.',
      );
    } on TimeoutException {
      return const SingleRequestResult(
        success: false,
        errorMessage: 'Connection timed out.',
      );
    } on SocketException {
      return const SingleRequestResult(
        success: false,
        errorMessage: 'No internet connection.',
      );
    } catch (_) {
      return const SingleRequestResult(
        success: false,
        errorMessage: 'Something went wrong.',
      );
    }
  }

  // ── GET document types ─────────────────────────────────────────────────────
  static Future<List<DocumentTypeItem>> getDocumentTypes() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Api.requests}/document-types'),
            headers: await _headers(),
          )
          .timeout(Api.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return (data['documentTypes'] as List)
            .map((e) => DocumentTypeItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return const [];
  }

  // ── POST submit new request ────────────────────────────────────────────────
  static Future<ActionResult> createRequest({
    required int documentTypeId,
    String? purpose,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Api.requests),
            headers: await _headers(),
            body: jsonEncode({
              'documentTypeId': documentTypeId,
              'purpose': purpose?.trim(),
            }),
          )
          .timeout(Api.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 && data['success'] == true) {
        final req = DocumentRequest.fromJson(
          data['request'] as Map<String, dynamic>,
        );

        return ActionResult(
          success: true,
          message: data['message'] as String?,
          request: req,
        );
      }

      return ActionResult(
        success: false,
        message: data['message'] as String? ?? 'Failed to submit request.',
      );
    } on TimeoutException {
      return const ActionResult(
        success: false,
        message: 'Connection timed out.',
      );
    } on SocketException {
      return const ActionResult(
        success: false,
        message: 'No internet connection.',
      );
    } catch (_) {
      return const ActionResult(
        success: false,
        message: 'Something went wrong.',
      );
    }
  }

  // ── DELETE cancel request ──────────────────────────────────────────────────
  static Future<ActionResult> cancelRequest(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${Api.requests}/$id'),
            headers: await _headers(),
          )
          .timeout(Api.timeout);

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return ActionResult(
        success: data['success'] as bool? ?? false,
        message: data['message'] as String?,
      );
    } on TimeoutException {
      return const ActionResult(
        success: false,
        message: 'Connection timed out.',
      );
    } on SocketException {
      return const ActionResult(
        success: false,
        message: 'No internet connection.',
      );
    } catch (_) {
      return const ActionResult(
        success: false,
        message: 'Something went wrong.',
      );
    }
  }
}