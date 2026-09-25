import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

/// Recuperar contraseña en dos pasos (ForgotPasswordScreen, CU-AUTH-06):
/// 1) pedir el código con el correo; 2) código + nueva contraseña.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _codigoEnviado = false;
  bool _obscure = true;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _codigoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final correo = _correoCtrl.text.trim().toLowerCase();
    final bloc = context.read<AuthBloc>();
    if (!_codigoEnviado) {
      bloc.add(ForgotPasswordRequested(correo));
    } else {
      bloc.add(ResetPasswordSubmitted(
        correo: correo,
        codigo: _codigoCtrl.text.trim(),
        password: _passwordCtrl.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
          final messenger = ScaffoldMessenger.of(context);
          if (state is PasswordResetCodeSent) {
            setState(() => _codigoEnviado = true);
            messenger.showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is PasswordResetSuccess) {
            messenger.showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.verdeExito,
            ));
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            messenger.showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.rojoDeficiente,
            ));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _codigoEnviado
                        ? 'Ingresa el código que te enviamos y tu nueva contraseña.'
                        : 'Te enviaremos un código de 6 dígitos a tu correo institucional.',
                    style: const TextStyle(color: AppTheme.grisInactivo, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _correoCtrl,
                    enabled: !_codigoEnviado,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo institucional',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.correo,
                  ),
                  if (_codigoEnviado) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codigoCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Código de recuperación',
                        prefixIcon: Icon(Icons.pin_outlined),
                        counterText: '',
                      ),
                      validator: Validators.codigo6Digitos,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        helperText: 'Mínimo 8 caracteres, con mayúscula, minúscula y número',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscure,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contraseña',
                        prefixIcon: Icon(Icons.lock_outlined),
                      ),
                      validator: (v) =>
                          v != _passwordCtrl.text ? 'Las contraseñas no coinciden' : null,
                    ),
                  ],
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const SizedBox(
                          height: 50,
                          child: Center(child: CircularProgressIndicator(color: AppTheme.guinda)),
                        );
                      }
                      return ElevatedButton(
                        onPressed: _submit,
                        child: Text(_codigoEnviado ? 'Cambiar contraseña' : 'Enviar código',
                            style: const TextStyle(fontSize: 16)),
                      );
                    },
                  ),
                  if (_codigoEnviado)
                    TextButton(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(ForgotPasswordRequested(_correoCtrl.text.trim().toLowerCase())),
                      child: const Text('Reenviar código', style: TextStyle(color: AppTheme.guinda)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
