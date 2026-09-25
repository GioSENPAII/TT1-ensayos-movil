import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Revisando si hay sesión guardada (pantalla de carga).
class AuthChecking extends AuthState {}

/// Sin sesión: se muestra el árbol de autenticación. [message] se muestra al llegar al login.
class AuthUnauthenticated extends AuthState {
  final String? message;
  AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthLoading extends AuthState {}

class RegisterTokenSent extends AuthState {}

class TokenResent extends AuthState {
  final String message;
  TokenResent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final String nombre;
  final String correo;
  AuthAuthenticated({required this.nombre, required this.correo});

  @override
  List<Object?> get props => [nombre, correo];
}

class PasswordResetCodeSent extends AuthState {
  final String message;
  PasswordResetCodeSent(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetSuccess extends AuthState {
  final String message;
  PasswordResetSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  // Cada error es un evento distinto aunque el texto se repita (p. ej. dos intentos fallidos)
  @override
  List<Object?> get props => [message, identityHashCode(this)];
}
