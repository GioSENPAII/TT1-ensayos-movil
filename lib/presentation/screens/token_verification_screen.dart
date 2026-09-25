import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../../core/utils/validators.dart';

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
        // Al crear la cuenta, el AuthGate (main.dart) lleva al alumno a Inicio
        listener: (context, state) {
          // Solo la pantalla visible reacciona (las de abajo en la pila escuchan el mismo bloc)
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
          if (state is TokenResent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppTheme.verdeExito),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.rojoDeficiente,
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
                      color: AppTheme.grisClaro,
                      border: Border.all(color: AppTheme.guindaClaro),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mark_email_read_outlined,
                            color: AppTheme.guinda),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Te enviamos un código a ${widget.correo}',
                            style: TextStyle(
                              color: AppTheme.negro,
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
                    validator: Validators.codigo6Digitos,
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
                    validator: Validators.password,
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
                  const SizedBox(height: 16),
                  // CU-AUTH-01 E3: pedir otro código sin reiniciar el registro
                  Center(
                    child: TextButton(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(ResendTokenRequested(widget.correo)),
                      child: const Text('¿No te llegó? Reenviar código',
                          style: TextStyle(color: AppTheme.guinda)),
                    ),
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
