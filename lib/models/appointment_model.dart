import 'package:flutter/material.dart';

enum AppointmentStatus {
  pending,
  served,
  cancelled,
  unknown,
}

extension AppointmentStatusExt on AppointmentStatus {
  static AppointmentStatus fromString(String? s) {
    final value = (s ?? '').trim().toLowerCase();

    switch (value) {
      case 'pending':
      case 'upcoming':
        return AppointmentStatus.pending;
      case 'served':
      case 'completed':
        return AppointmentStatus.served;
      case 'cancelled':
      case 'canceled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Upcoming';
      case AppointmentStatus.served:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentStatus.pending:
        return const Color(0xFF3DBD71);
      case AppointmentStatus.served:
        return const Color(0xFF4A90D9);
      case AppointmentStatus.cancelled:
        return const Color(0xFFE05252);
      default:
        return const Color(0xFF5A7A62);
    }
  }

  Color get bgColor => color;

  IconData get icon {
    switch (this) {
      case AppointmentStatus.pending:
        return Icons.schedule_rounded;
      case AppointmentStatus.served:
        return Icons.check_circle_rounded;
      case AppointmentStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

class Department {
  final int id;
  final String name;
  final String? description;

  const Department({
    required this.id,
    required this.name,
    this.description,
  });

  factory Department.fromJson(Map<String, dynamic> j) {
    return Department(
      id: j['department_id'] as int,
      name: (j['department_name'] ?? j['name'] ?? '').toString(),
      description: j['description']?.toString(),
    );
  }

  IconData get icon {
    final n = name.toLowerCase();

    if (n.contains('civil')) return Icons.badge_rounded;
    if (n.contains('permit')) return Icons.description_rounded;
    if (n.contains('finance')) return Icons.account_balance_wallet_rounded;
    if (n.contains('health')) return Icons.local_hospital_rounded;
    if (n.contains('plan')) return Icons.map_rounded;
    if (n.contains('social')) return Icons.groups_rounded;
    if (n.contains('building')) return Icons.apartment_rounded;
    if (n.contains('engineering')) return Icons.engineering_rounded;
    if (n.contains('water')) return Icons.water_drop_rounded;
    if (n.contains('electric')) return Icons.electrical_services_rounded;

    return Icons.account_balance_rounded;
  }
}

class WorkingDay {
  final String date;
  final String label;

  const WorkingDay({
    required this.date,
    required this.label,
  });

  factory WorkingDay.fromJson(Map<String, dynamic> j) {
    return WorkingDay(
      date: j['date'].toString(),
      label: j['label'].toString(),
    );
  }

  String get shortDay {
    try {
      return label.split(',').first.trim();
    } catch (_) {
      return label;
    }
  }

  String get dayNum {
    try {
      return label.split(' ').last.trim();
    } catch (_) {
      return '';
    }
  }

  String get monthShort {
    try {
      return label.split(' ')[1].replaceAll(',', '').trim();
    } catch (_) {
      return '';
    }
  }
}

class TimeSlot {
  final String time;
  final bool available;
  final int booked;
  final int capacity;

  const TimeSlot({
    required this.time,
    required this.available,
    required this.booked,
    required this.capacity,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> j) {
    return TimeSlot(
      time: j['time'].toString(),
      available: j['available'] as bool,
      booked: (j['booked'] as num).toInt(),
      capacity: (j['capacity'] as num).toInt(),
    );
  }

  String get displayTime {
    try {
      final parts = time.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final ampm = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $ampm';
    } catch (_) {
      return time;
    }
  }

  bool get isFull => booked >= capacity;
}

class Appointment {
  final int id;
  final int? requestId;
  final int? departmentId;
  final String departmentName;
  final String? departmentDescription;
  final String? requestCode;
  final String? requestTitle;
  final String date;
  final String timeSlot;
  final int queueNumber;
  final AppointmentStatus status;
  final String createdAt;

  const Appointment({
    required this.id,
    required this.departmentName,
    required this.date,
    required this.timeSlot,
    required this.queueNumber,
    required this.status,
    required this.createdAt,
    this.requestId,
    this.departmentId,
    this.departmentDescription,
    this.requestCode,
    this.requestTitle,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) {
    final rawStatus = j['status']?.toString();

    debugPrint('APPOINTMENT JSON = $j');
    debugPrint('RAW STATUS = $rawStatus');

    return Appointment(
      id: (j['appointment_id'] as num).toInt(),
      requestId: j['request_id'] == null ? null : (j['request_id'] as num).toInt(),
      departmentId: j['department_id'] == null ? null : (j['department_id'] as num).toInt(),
      departmentName: (j['department_name'] ?? '').toString(),
      departmentDescription: j['department_description']?.toString(),
      requestCode: j['request_code']?.toString(),
      requestTitle: j['request_title']?.toString(),
      date: (j['appointment_date'] ?? '').toString(),
      timeSlot: (j['time_slot'] ?? '').toString(),
      queueNumber: (j['queue_number'] as num).toInt(),
      status: AppointmentStatusExt.fromString(rawStatus),
      createdAt: (j['created_at'] ?? '').toString(),
    );
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(date);
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
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
      return '${days[dt.weekday % 7]}, ${months[dt.month]} ${dt.day}';
    } catch (_) {
      return date;
    }
  }

  String get displayTime {
    try {
      final parts = timeSlot.split(':');
      int h = int.parse(parts[0]);
      final m = parts[1];
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:$m $ap';
    } catch (_) {
      return timeSlot;
    }
  }
  bool get isUpcoming => status == AppointmentStatus.pending;
  bool get isCompleted => status == AppointmentStatus.served;
  bool get isCancelled => status == AppointmentStatus.cancelled;
}