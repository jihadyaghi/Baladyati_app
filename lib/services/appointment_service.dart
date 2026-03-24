import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/config/api.dart';
import 'package:http/http.dart' as http;
import '../models/appointment_model.dart';
import 'auth_service.dart';
class AppointmentsResult {
  final bool success;
  final List<Appointment> appointments;
  final String? errorMessage;
  const AppointmentsResult({
    required this.success,
    this.appointments = const [],
    this.errorMessage,
  });
}
class SlotsResult {
  final bool success;
  final List<TimeSlot> slots;
  final String? errorMessage;
  const SlotsResult({
    required this.success,
    this.slots = const [],
    this.errorMessage,
  });
}
class BookingResult {
  final bool success;
  final String? message;
  final Appointment? appointment;
  const BookingResult({
    required this.success,
    this.message,
    this.appointment,
  });
}
class AppointmentService {
  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
  static Future<List<Department>> getDepartments() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Api.appointments}/departments'),
            headers: await _headers(),
          )
          .timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['departments'] as List)
            .map((x) => Department.fromJson(x as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
  static Future<List<WorkingDay>> getWorkingDays() async {
    try {
      final response = await http
          .get(
            Uri.parse('${Api.appointments}/working-days'),
            headers: await _headers(),
          )
          .timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['days'] as List)
            .map((x) => WorkingDay.fromJson(x as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
  static Future<SlotsResult> getAvailableSlots({
    required int departmentId,
    required String date,
  }) async {
    try {
      final url = Uri.parse(
        '${Api.appointments}/available-slots?departmentId=$departmentId&date=$date',
      );
      final response = await http
          .get(url, headers: await _headers())
          .timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final slots = (data['slots'] as List)
            .map((s) => TimeSlot.fromJson(s as Map<String, dynamic>))
            .toList();
        return SlotsResult(success: true, slots: slots);
      }
      return SlotsResult(
        success: false,
        errorMessage: data['message'] as String?,
      );
    } on TimeoutException {
      return const SlotsResult(
        success: false,
        errorMessage: 'Connection timed out.',
      );
    } on SocketException {
      return const SlotsResult(
        success: false,
        errorMessage: 'No internet connection.',
      );
    } catch (_) {
      return const SlotsResult(
        success: false,
        errorMessage: 'Could not load slots.',
      );
    }
  }
  static Future<AppointmentsResult> getMyAppointments() async {
    try {
      final response = await http
          .get(
            Uri.parse(Api.appointments),
            headers: await _headers(),
          )
          .timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        final list = (data['appointments'] as List)
            .map((a) => Appointment.fromJson(a as Map<String, dynamic>))
            .toList();
        return AppointmentsResult(
          success: true,
          appointments: list,
        );
      }
      return AppointmentsResult(
        success: false,
        errorMessage: data['message'] as String? ?? 'Failed to load.',
      );
    } on TimeoutException {
      return const AppointmentsResult(
        success: false,
        errorMessage: 'Connection timed out.',
      );
    } on SocketException {
      return const AppointmentsResult(
        success: false,
        errorMessage: 'No internet connection.',
      );
    } catch (_) {
      return const AppointmentsResult(
        success: false,
        errorMessage: 'Something went wrong.',
      );
    }
  }
  static Future<BookingResult> bookAppointment({
    required int departmentId,
    required String date,
    required String timeSlot,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(Api.appointments),
            headers: await _headers(),
            body: jsonEncode({
              'departmentId': departmentId,
              'date': date,
              'timeSlot': timeSlot,
            }),
          )
          .timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201 && data['success'] == true) {
        final appt =
            Appointment.fromJson(data['appointment'] as Map<String, dynamic>);
        return BookingResult(
          success: true,
          message: data['message'] as String?,
          appointment: appt,
        );
      }
      return BookingResult(
        success: false,
        message: data['message'] as String? ?? 'Booking failed.',
      );
    } on TimeoutException {
      return const BookingResult(
        success: false,
        message: 'Connection timed out.',
      );
    } on SocketException {
      return const BookingResult(
        success: false,
        message: 'No internet connection.',
      );
    } catch (_) {
      return const BookingResult(
        success: false,
        message: 'Something went wrong.',
      );
    }
  }
  static Future<BookingResult> cancelAppointment(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${Api.appointments}/$id'),
            headers: await _headers(),
          )
          .timeout(Api.timeout);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return BookingResult(
        success: data['success'] as bool? ?? false,
        message: data['message'] as String?,
      );
    } on TimeoutException {
      return const BookingResult(
        success: false,
        message: 'Connection timed out.',
      );
    } on SocketException {
      return const BookingResult(
        success: false,
        message: 'No internet connection.',
      );
    } catch (_) {
      return const BookingResult(
        success: false,
        message: 'Something went wrong.',
      );
    }
  }
}