import 'package:flutter/material.dart';
enum NotificationType{
  requestUpdate,
  appointment,
  announcement,
  issueUpdate,
  other
}
extension NotificationTypeExt on NotificationType {
  static NotificationType fromTitle(String s){
    final title = s.toLowerCase();
    if(title.contains('request')){
      return NotificationType.requestUpdate;
    }
    if(title.contains('appointment')){
      return NotificationType.appointment;
    }
    if(title.contains('announcement')){
      return NotificationType.announcement;
    }
    if(title.contains('issue')){
      return NotificationType.issueUpdate;
    }
    return NotificationType.other;
  }
  String get label {
    switch (this){
      case NotificationType.requestUpdate:
      return 'Request Update';
      case NotificationType.appointment:
      return 'Appointment';
      case NotificationType.announcement:
      return 'Announcement';
      case NotificationType.issueUpdate:
      return 'Issue Update';
      case NotificationType.other:
      return 'Notification';
    }
  }
  IconData get icon {
    switch (this){
      case NotificationType.requestUpdate:
      return Icons.description_rounded;
      case NotificationType.appointment:
      return Icons.calendar_month_rounded;
      case NotificationType.announcement:
      return Icons.campaign_rounded;
      case NotificationType.issueUpdate:
      return Icons.report_problem_rounded;
      case NotificationType.other:
      return Icons.notifications_rounded;
    }
  }
  Color get color {
    switch (this){
      case NotificationType.requestUpdate:
      return const Color(0xFF4A90D9);
      case NotificationType.appointment:
      return const Color(0xFFC9AB4C);
      case NotificationType.announcement:
      return const Color(0xFF3DBD71);
      case NotificationType.issueUpdate:
      return const Color(0xFFE05252);
      case NotificationType.other:
      return const Color(0xFF5A7A62);
    }
  }
  Color get bgColor => color;
}
class AppNotification {
  final int id;
  final String title;
  final NotificationType type;
  final String message;
  final bool isRead;
  final String createdAt;
  const AppNotification({
    required this.id,
    required this.title,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt
  });
  factory AppNotification.fromJason(Map<String, dynamic> j){
    final title = j['title'] as String? ?? '';
    return AppNotification(
      id: j['notification_id'] as int,
      title: title, 
      type: NotificationTypeExt.fromTitle(title), 
      message: j['message'] as String? ?? '', 
      isRead: (j['is_read'] as int? ?? 0) == 1 , 
      createdAt: j['created_at'] as String? ?? ''
      );
  }
  String get timeAgo {
    try{
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inSeconds < 60) return 'Just Now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
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
      return '${months[dt.month]} ${dt.day}';
    }
    catch (_){
      return '';
    }
  }
  AppNotification copyWith({bool? isRead}){
    return AppNotification(
      id: id, 
      title: title, 
      type: type, 
      message: message, 
      isRead: isRead ?? this.isRead, 
      createdAt: createdAt
      );
  }
}