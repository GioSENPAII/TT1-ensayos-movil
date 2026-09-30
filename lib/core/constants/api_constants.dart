class ApiConstants {
  // Se elige al compilar, sin editar el código:
  //   local (por defecto):  flutter run
  //   emulador Android:     flutter run --dart-define=API_URL=http://10.0.2.2:8080/api/v1
  //   nube (Cloud Run):     flutter run --dart-define=API_URL=https://<servicio>.run.app/api/v1
  static const String baseUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://127.0.0.1:8080/api/v1');

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

  static const String entregas = '/submissions';
  static const String misEntregas = '/students/me/submissions';
  static String entrega(int id) => '/submissions/$id';
}
