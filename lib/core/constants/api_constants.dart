class ApiConstants {
  // Backend local (la cuenta de Google Cloud expiró).
  // iOS simulator: 127.0.0.1 — Android emulator: 10.0.2.2
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';

  // Rutas relativas a baseUrl (Tabla 55)
  static const String register = '/auth/register';
  static const String resendToken = '/auth/resend-token';
  static const String verifyToken = '/auth/verify-token';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  static const String misGrupos = '/students/me/groups';
  static const String unirseGrupo = '/groups/join';
  static String tareasDeGrupo(int groupId) => '/assignments?groupId=$groupId';
}
