import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class RegisterTokenSent extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String nombre;
  final String correo;
  AuthAuthenticated({required this.nombre, required this.correo});

  @override
  List<Object?> get props => [nombre, correo];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
