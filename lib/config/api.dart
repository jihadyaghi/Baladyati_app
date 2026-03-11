class Api {
  static const String baseUrl='http://localhost:3000';
  static const String login='$baseUrl/api/auth/citizen/login';
  static const String register = '$baseUrl/api/auth/citizen/register';
  static const String me='$baseUrl/api/auth/citizen/me';
  static const String logout='$baseUrl/api/auth/citizen/logout';
  static const String zones    = '$baseUrl/api/auth/zones';
  static const String home = '$baseUrl/api/home';
  static const Duration timeout = Duration(seconds: 15);
}