class ApiConstants {
  // Backend local (la cuenta de Google Cloud expiró).
  // iOS simulator: 127.0.0.1 — Android emulator: 10.0.2.2
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';
  static const String register = '$baseUrl/auth/register';
  static const String verifyToken = '$baseUrl/auth/verify-token';
  static const String login = '$baseUrl/auth/login';
}
