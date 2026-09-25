/// Jerarquía de errores de la app (sección 4.6.5 de TT2).
/// `toString()` devuelve el mensaje listo para mostrarse al alumno.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Sin conexión o tiempo de espera agotado (RNF-01).
class NetworkException extends AppException {
  const NetworkException(
      [super.message = 'Se requiere conexión a internet para continuar']);
}

/// Error 5xx del servidor.
class ServerException extends AppException {
  const ServerException(
      [super.message =
          'El servidor no está disponible. Intenta de nuevo en unos minutos.']);
}

/// Error 4xx con el mensaje `detail` del ProblemDetail (RFC 9457).
class ClientException extends AppException {
  final int statusCode;
  const ClientException(this.statusCode, super.message);
}

/// La sesión expiró y no se pudo renovar con el refresh token.
class SessionExpiredException extends AppException {
  const SessionExpiredException(
      [super.message = 'Tu sesión expiró. Inicia sesión de nuevo.']);
}
