import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'home_placeholder_screen.dart';

class TokenVerificationScreen extends StatefulWidget {
  final String correo;

  const TokenVerificationScreen({
    super.key,
    required this.correo,
  });

  @override
  State<TokenVerificationScreen> createState() =>
      _TokenVerificationScreenState();
}

class _TokenVerificationScreenState extends State<TokenVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(VerifyTokenSubmitted(
          correo: widget.correo,
          token: _tokenCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar cuenta')),
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => HomePlaceholderScreen(
                  nombre: state.nombre,
                  correo: state.correo,
                ),
              ),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read_outlined,
                            color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Te enviamos un código a ${widget.correo}',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verificando: ${widget.correo}',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.grisInactivo),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _tokenCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      labelText: 'Código de verificación',
                      prefixIcon: Icon(Icons.pin_outlined),
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length != 6) {
                        return 'El código debe tener exactamente 6 dígitos';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    // RNF-10: mínimo 8 caracteres, una mayúscula, una minúscula y un número
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'Mínimo 8 caracteres';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(v)) {
                        return 'Debe incluir al menos una mayúscula';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(v)) {
                        return 'Debe incluir al menos una minúscula';
                      }
                      if (!RegExp(r'\d').hasMatch(v)) {
                        return 'Debe incluir al menos un número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const SizedBox(
                          height: 50,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.guinda)),
                        );
                      }
                      return ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Crear cuenta',
                            style: TextStyle(fontSize: 16)),
                      );
                    },
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
