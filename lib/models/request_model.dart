import 'package:flutter/material.dart';
enum RequestStatus{
  pending,
  inReview,
  approved,
  cancelled,
  inProgress,
  resolved,
  done,
  unknown
}
extension RequestStatusExt on RequestStatus {
  static RequestStatus fromString(String s){
    switch (s.toUpperCase()){
      case 'PENDING':
      return RequestStatus.pending;
      case 'IN_REVIEW':
      return RequestStatus.inReview;
      case 'APPROVED':
      return RequestStatus.approved;
      case 'CANCELLED':
      return RequestStatus.cancelled;
      case 'IN_PROGRESS':
      return RequestStatus.inProgress;
      case 'RESOLVED':
      return RequestStatus.resolved;
      case 'DONE':
      return RequestStatus.done;
      default:
      return RequestStatus.unknown;
    }
  }
  String get label {
    switch (this){
      case RequestStatus.pending:
      return 'PENDING';
      case RequestStatus.inReview:
      return 'In Review';
      case RequestStatus.approved:
      return 'Approved';
      case RequestStatus.cancelled:
      return 'Cancelled';
      case RequestStatus.inProgress:
      return 'In Progress';
      case RequestStatus.resolved:
      return 'Resolved';
      case RequestStatus.done:
      return 'Done';
      default:
      return 'Unknown';
    }
  }
  Color get color {
    switch (this) {
      case RequestStatus.pending:
      return const Color(0xFFC9A84C);
      case RequestStatus.inReview:
      return const Color(0xFF4A90D9);
      case RequestStatus.approved:
      return const Color(0xFF3DBD71);
      case RequestStatus.cancelled:
      return const Color(0xFFE05252);
      case RequestStatus.inProgress:
      return const Color(0xFF4A90D9);
      case RequestStatus.resolved:
      return const Color(0xFF3DBD71);
      case RequestStatus.done:
      return const Color(0xFF3DBD71);
      default:
      return const Color(0xFF5A7A62);
    }
  }
  // ignore: deprecated_member_use
  Color get bgColor => color.withOpacity(0.15);
}
class RequestNote {
  final int id;
  final String text;
  final String staffName;
  final String createdAt;
  const RequestNote({
    required this.id,
    required this.text,
    required this.staffName,
    required this.createdAt
  });
  factory RequestNote.fromJson(Map<String, dynamic> j) => RequestNote(
    id: j['note_id'] as int,
    text: j['note_text'] as String,
    staffName: j['staff_name'] as String? ?? 'Staff',
    createdAt: j['created_at'] as String
    );
    String get formattedDate {
      try{
        final dt = DateTime.parse(createdAt);
        const months = [
          '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
        ];
        return '${months[dt.month]} ${dt.day}, ${dt.year}';
      }
      catch (_){
        return createdAt;
      }
    }
}
class DocumentRequest {
  final int id;
  final String requestCode;
  final String documentType;
  final String? purpose;
  final RequestStatus status;
  final String submittedAt;
  final String? updatedAt;
  final String? assignedToName;
  final List<RequestNote> notes;
  const DocumentRequest({
    required this.id,
    required this.requestCode,
    required this.documentType,
    required this.status,
    required this.submittedAt,
    this.purpose,
    this.updatedAt,
    this.assignedToName,
    this.notes = const []
  });
  factory DocumentRequest.fromJson(
    Map<String, dynamic> j, {
      List <RequestNote> notes = const []
    }) {
      return DocumentRequest(
      id: j['request_id'] as int,
      requestCode: j['request_code'] as String? ?? '',
      documentType: j['document_type'] as String? ?? '',
      purpose: j['purpose'] as String?,
      status: RequestStatusExt.fromString(j['status'] as String? ?? ''),
      submittedAt: j['created_at'] as String,
      updatedAt: j['updated_at'] as String?,
      assignedToName: j['assigned_to_name'] as String?,
      notes: notes
      );
    }
    String get formattedDate {
      try{
        final dt = DateTime.parse(submittedAt);
        const months = [
          '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
        ];
        return '${months[dt.month]} ${dt.day}, ${dt.year}';
      }
      catch (_){
        return submittedAt;
      }
    }
}