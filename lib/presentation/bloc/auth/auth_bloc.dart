import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(AuthInitial()) {
    on<RegisterSubmitted>(_onRegister);
    on<VerifyTokenSubmitted>(_onVerifyToken);
    on<LoginSubmitted>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _repository.register(
        nombre: event.nombre,
        apellidos: event.apellidos,
        correo: event.correo,
      );
      emit(RegisterTokenSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyToken(VerifyTokenSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final tokens = await _repository.verifyToken(
        token: event.token,
        password: event.password,
      );
      await _repository.saveTokens(tokens);
      emit(AuthAuthenticated(nombre: tokens.nombre, correo: tokens.correo));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final tokens = await _repository.login(
        correo: event.correo,
        password: event.password,
      );
      await _repository.saveTokens(tokens);
      emit(AuthAuthenticated(nombre: tokens.nombre, correo: tokens.correo));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.clearTokens();
    emit(AuthInitial());
  }
}
