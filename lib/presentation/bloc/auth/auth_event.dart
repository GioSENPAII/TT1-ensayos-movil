import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Al abrir la app: revisa si hay una sesión guardada.
class AppStarted extends AuthEvent {}

class RegisterSubmitted extends AuthEvent {
  final String nombre;
  final String apellidos;
  final String correo;

  RegisterSubmitted({
    required this.nombre,
    required this.apellidos,
    required this.correo,
  });

  @override
  List<Object?> get props => [nombre, apellidos, correo];
}

class ResendTokenRequested extends AuthEvent {
  final String correo;
  ResendTokenRequested(this.correo);

  @override
  List<Object?> get props => [correo];
}

class VerifyTokenSubmitted extends AuthEvent {
  final String correo;
  final String token;
  final String password;

  VerifyTokenSubmitted({
    required this.correo,
    required this.token,
    required this.password,
  });

  @override
  List<Object?> get props => [correo, token, password];
}

class LoginSubmitted extends AuthEvent {
  final String correo;
  final String password;

  LoginSubmitted({required this.correo, required this.password});

  @override
  List<Object?> get props => [correo, password];
}

class ForgotPasswordRequested extends AuthEvent {
  final String correo;
  ForgotPasswordRequested(this.correo);

  @override
  List<Object?> get props => [correo];
}

class ResetPasswordSubmitted extends AuthEvent {
  final String correo;
  final String codigo;
  final String password;

  ResetPasswordSubmitted({
    required this.correo,
    required this.codigo,
    required this.password,
  });

  @override
  List<Object?> get props => [correo, codigo, password];
}

class LogoutRequested extends AuthEvent {}

/// Interno: el ApiClient no pudo renovar la sesión.
class SessionExpired extends AuthEvent {}
