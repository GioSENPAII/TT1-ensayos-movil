import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../../core/utils/validators.dart';
import 'privacy_notice_screen.dart';
import 'token_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  bool _aceptaAviso = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(RegisterSubmitted(
          nombre: _nombreCtrl.text.trim(),
          apellidos: _apellidosCtrl.text.trim(),
          correo: _correoCtrl.text.trim().toLowerCase(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Solo la pantalla visible reacciona (las de abajo en la pila escuchan el mismo bloc)
          if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
          if (state is RegisterTokenSent) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TokenVerificationScreen(
                  correo: _correoCtrl.text.trim().toLowerCase(),
                ),
              ),
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
                  const Text(
                    'Datos de registro',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.guinda),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Usa tu correo @alumno.ipn.mx',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.grisInactivo),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nombreCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre(s)',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _apellidosCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa tus apellidos' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo institucional',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: 'usuario@alumno.ipn.mx',
                    ),
                    validator: Validators.correoAlumno,
                  ),
                  const SizedBox(height: 16),
                  _CasillaAviso(
                    valor: _aceptaAviso,
                    onChanged: (v) => setState(() => _aceptaAviso = v),
                  ),
                  const SizedBox(height: 24),
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
                        child: const Text('Continuar',
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

/// Aceptación obligatoria del aviso de privacidad antes de enviar los datos personales.
class _CasillaAviso extends StatelessWidget {
  final bool valor;
  final ValueChanged<bool> onChanged;
  const _CasillaAviso({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: valor,
      validator: (v) => v == true ? null : 'Debes aceptar el aviso de privacidad para continuar',
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: valor,
                activeColor: AppTheme.guinda,
                onChanged: (v) {
                  onChanged(v ?? false);
                  field.didChange(v);
                  if (field.hasError) field.validate(); // quita el error al marcarla
                },
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('He leído y acepto el ', style: TextStyle(fontSize: 14)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrivacyNoticeScreen()),
                      ),
                      child: const Text(
                        'aviso de privacidad',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.guinda,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.guinda,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(field.errorText!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.rojoDeficiente)),
            ),
        ],
      ),
    );
  }
}
