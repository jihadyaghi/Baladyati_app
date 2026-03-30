import 'package:flutter/material.dart';
enum IssueCategory{
  road,
  lighting,
  waste,
  water,
  electricity,
  other
}
extension IssueCategoryExt on IssueCategory {
  String get key {
    switch (this){
      case IssueCategory.road: return 'road';
      case IssueCategory.lighting: return 'lighting';
      case IssueCategory.waste: return 'waste';
      case IssueCategory.water: return 'water';
      case IssueCategory.electricity: return 'electricity';
      case IssueCategory.other: return 'other';
    }
  }
  String get label {
    switch (this){
      case IssueCategory.road: return 'Road Damage';
      case IssueCategory.lighting: return 'Lighting';
      case IssueCategory.waste: return 'Waste';
      case IssueCategory.water: return 'Water';
      case IssueCategory.electricity: return 'Electricity';
      case IssueCategory.other: return 'Other';
    }
  }
  IconData get icon {
    switch (this) {
      case IssueCategory.road:
      return Icons.construction_rounded;
      case IssueCategory.lighting:
      return Icons.lightbulb_rounded;
      case IssueCategory.waste:
      return Icons.delete_outline_rounded;
      case IssueCategory.water:
      return Icons.water_drop_rounded;
      case IssueCategory.electricity:
      return Icons.bolt_rounded;
      case IssueCategory.other:
      return Icons.report_problem_rounded;
    }
  }
  Color get color {
    switch (this) {
      case IssueCategory.road:
      return const Color(0xFFC9A84C);
      case IssueCategory.lighting:
      return const Color(0xFFFFD166);
      case IssueCategory.waste:
      return const Color(0xFF3DBD71);
      case IssueCategory.water:
      return const Color(0xFF4A90D9);
      case IssueCategory.electricity:
      return const Color(0xFFFF9F1C);
      case IssueCategory.other:
      return const Color(0xFF9B8EA8);
    }
  }
}
enum IssueSeverity { low, medium, high }
extension IssueSeverityExt on IssueSeverity {
  String get key {
    switch (this) {
      case IssueSeverity.low:
      return 'low';
      case IssueSeverity.medium:
      return 'medium';
      case IssueSeverity.high:
      return 'high';
    }
  }
  String get label {
    switch (this) {
      case IssueSeverity.low:
      return 'Low';
      case IssueSeverity.medium:
      return 'Meduim';
      case IssueSeverity.high:
      return 'High';
    }
  }
  IconData get icon {
    switch (this) {
      case IssueSeverity.low:
      return Icons.arrow_downward_rounded;
      case IssueSeverity.medium:
      return Icons.remove_rounded;
      case IssueSeverity.high:
      return Icons.priority_high_rounded;
    }
  }
  Color get color {
    switch (this) {
      case IssueSeverity.low:
      return const Color(0xFF3DBD71);
      case IssueSeverity.medium:
      return const Color(0xFFC9A84C);
      case IssueSeverity.high:
      return const Color(0xFFE05252);
    }
  }
  Color get bgColor => color;
  static IssueSeverity fromString(String? value) {
    switch ((value ?? '').toLowerCase()){
      case 'low':
      return IssueSeverity.low;
      case 'medium':
      return IssueSeverity.medium;
      case 'high':
      return IssueSeverity.high;
      default:
      return IssueSeverity.medium;
    }
  }
}
class Issue{
  final int issueReportId;
  final int citizenId;
  final int categoryId;
  final String categoryName;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String? addressText;
  final String? photoUrl1;
  final String? photoUrl2;
  final String severity;
  final String status;
  final String submittedAt;
  final String? resolvedAt;
  const Issue({
    required this.issueReportId,
    required this.citizenId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.addressText,
    this.photoUrl1,
    this.photoUrl2,
    required this.severity,
    required this.status,
    required this.submittedAt,
    this.resolvedAt
  });
  factory Issue.fromJson(Map<String, dynamic> j){
    return Issue(
      issueReportId: (j['issue_report_id'] as num).toInt(), 
      citizenId: (j['citizen_id'] as num).toInt(), 
      categoryId: (j['category_id'] as num).toInt(), 
      categoryName: (j['category_name'] ?? '').toString(), 
      title: (j['title'] ?? '').toString(), 
      description: (j['description'] ?? '').toString(), 
      latitude: double.parse(j['latitude'].toString()), 
      longitude: double.parse(j['longitude'].toString()),
      addressText: j['address_text']?.toString(),
      photoUrl1: j['photo_url_1']?.toString(),
      photoUrl2: j['photo_url_2']?.toString(), 
      severity: (j['severity'] ?? 'medium').toString(), 
      status: (j['status'] ?? 'open').toString(), 
      submittedAt: (j['submitted_at'] ?? '').toString(),
      resolvedAt: j['resolved_at']?.toString(),
      );
  }
  IssueSeverity get severityEnum => IssueSeverityExt.fromString(severity);
  String get formattedDate {
    try {
      final dt = DateTime.parse(submittedAt).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    }
    catch (_){
      return submittedAt;
    }
  }
}