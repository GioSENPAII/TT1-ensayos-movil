import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/group/group_state.dart';

/// Unirse a un grupo con el código del profesor (JoinGroupScreen, CU-ALU-01 pasos 3-7).
class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoCtrl = TextEditingController();

  @override
  void dispose() {
    _codigoCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<GroupBloc>().add(JoinGroupSubmitted(_codigoCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupBloc, GroupState>(
      listenWhen: (a, b) => a.joinStatus != b.joinStatus,
      listener: (context, state) {
        if (state.joinStatus == JoinStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.joinMessage ?? 'Te uniste al grupo'),
            backgroundColor: AppTheme.verdeExito,
          ));
          context.read<GroupBloc>().add(JoinGroupReset());
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final enviando = state.joinStatus == JoinStatus.submitting;
        final error = state.joinStatus == JoinStatus.failure ? state.joinMessage : null;
        return PopScope(
          onPopInvokedWithResult: (didPop, _) {
            if (didPop && state.joinStatus == JoinStatus.failure) {
              context.read<GroupBloc>().add(JoinGroupReset());
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('Unirse a un grupo')),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.vpn_key_outlined, size: 56, color: AppTheme.guinda),
                      const SizedBox(height: 16),
                      const Text(
                        'Ingresa el código de acceso de 6 caracteres que te proporcionó tu profesor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.grisInactivo, fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _codigoCtrl,
                        readOnly: enviando, // readOnly conserva el foco (disabled lo pierde)
                        autofocus: true,
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          TextInputFormatter.withFunction(
                              (_, v) => v.copyWith(text: v.text.toUpperCase())),
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          letterSpacing: 8,
                          fontFamily: AppTheme.fuenteMono,
                          color: AppTheme.guinda,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(hintText: 'ABC123', counterText: ''),
                        validator: Validators.codigoGrupo,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.rojoDeficiente.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.rojoDeficiente),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(error,
                                    style: const TextStyle(color: AppTheme.rojoDeficiente)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      enviando
                          ? const SizedBox(
                              height: 50,
                              child: Center(child: CircularProgressIndicator(color: AppTheme.guinda)),
                            )
                          : ElevatedButton(
                              onPressed: _submit,
                              child: const Text('Unirme', style: TextStyle(fontSize: 16)),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
