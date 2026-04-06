class Api {
  static const String baseUrl='http://localhost:3000';
  static const String login='$baseUrl/api/auth/citizen/login';
  static const String register = '$baseUrl/api/auth/citizen/register';
  static const String me='$baseUrl/api/auth/citizen/me';
  static const String logout='$baseUrl/api/auth/citizen/logout';
  static const String zones    = '$baseUrl/api/auth/zones';
  static const String home = '$baseUrl/api/home';
  static const String requests = '$baseUrl/api/requests';
  static const String notifications = '$baseUrl/api/notifications';
  static const String appointments = '$baseUrl/api/appointments';
  static const String proposals = '$baseUrl/api/proposals';
  static const String issues = '$baseUrl/api/issues';
  static const String chat = '$baseUrl/api/chat';
  static const String profile = '$baseUrl/api/profile';
  static const Duration timeout = Duration(seconds: 15);
}