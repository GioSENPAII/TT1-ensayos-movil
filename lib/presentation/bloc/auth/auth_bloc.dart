import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  static const _soloAlumnos =
      'Esta aplicación es exclusiva para alumnos. Profesores y administradores '
      'deben usar la plataforma web.';

  final AuthRepository _repository;
  late final StreamSubscription<void> _expiredSub;

  AuthBloc(this._repository) : super(AuthChecking()) {
    on<AppStarted>(_onAppStarted);
    on<RegisterSubmitted>(_onRegister);
    on<ResendTokenRequested>(_onResendToken);
    on<VerifyTokenSubmitted>(_onVerifyToken);
    on<LoginSubmitted>(_onLogin);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<ResetPasswordSubmitted>(_onResetPassword);
    on<LogoutRequested>(_onLogout);
    on<SessionExpired>(_onSessionExpired);

    _expiredSub = _repository.onSessionExpired.listen((_) => add(SessionExpired()));
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    final sesion = await _repository.currentSession();
    if (sesion != null && sesion.esAlumno) {
      emit(AuthAuthenticated(nombre: sesion.nombre, correo: sesion.correo));
    } else {
      emit(AuthUnauthenticated());
    }
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

  Future<void> _onResendToken(ResendTokenRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      emit(TokenResent(await _repository.resendToken(event.correo)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyToken(VerifyTokenSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final tokens = await _repository.verifyToken(
        correo: event.correo,
        token: event.token,
        password: event.password,
      );
      await _repository.saveSession(tokens);
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
      await _repository.saveSession(tokens);
      if (tokens.rol != 'ALUMNO') {
        // Tabla 18: profesor y administrador solo usan la web; se cierra la sesión recién abierta
        await _repository.logout();
        emit(AuthError(_soloAlumnos));
        return;
      }
      emit(AuthAuthenticated(nombre: tokens.nombre, correo: tokens.correo));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      emit(PasswordResetCodeSent(await _repository.forgotPassword(event.correo)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(ResetPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      emit(PasswordResetSuccess(await _repository.resetPassword(
        correo: event.correo,
        codigo: event.codigo,
        password: event.password,
      )));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(AuthUnauthenticated());
  }

  void _onSessionExpired(SessionExpired event, Emitter<AuthState> emit) {
    if (state is AuthAuthenticated) {
      emit(AuthUnauthenticated(message: 'Tu sesión expiró. Inicia sesión de nuevo.'));
    }
  }

  @override
  Future<void> close() {
    _expiredSub.cancel();
    return super.close();
  }
}
