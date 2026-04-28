import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

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

class VerifyTokenSubmitted extends AuthEvent {
  final String token;
  final String password;

  VerifyTokenSubmitted({required this.token, required this.password});

  @override
  List<Object?> get props => [token, password];
}

class LoginSubmitted extends AuthEvent {
  final String correo;
  final String password;

  LoginSubmitted({required this.correo, required this.password});

  @override
  List<Object?> get props => [correo, password];
}

class LogoutRequested extends AuthEvent {}
