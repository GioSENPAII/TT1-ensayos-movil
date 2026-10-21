import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/aviso_privacidad.dart';
import '../../domain/repositories/profile_repository.dart';

/// Aviso de privacidad integral. El texto lo publica el servidor, así la app y la web muestran
/// siempre la misma versión.
class PrivacyNoticeScreen extends StatefulWidget {
  const PrivacyNoticeScreen({super.key});

  @override
  State<PrivacyNoticeScreen> createState() => _PrivacyNoticeScreenState();
}

class _PrivacyNoticeScreenState extends State<PrivacyNoticeScreen> {
  late Future<AvisoPrivacidad> _aviso;

  @override
  void initState() {
    super.initState();
    _aviso = sl<ProfileRepository>().avisoPrivacidad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aviso de privacidad')),
      backgroundColor: Colors.white,
      body: FutureBuilder<AvisoPrivacidad>(
        future: _aviso,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.guinda));
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snap.error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => setState(
                          () => _aviso = sl<ProfileRepository>().avisoPrivacidad()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }
          final aviso = snap.data!;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                ..._MarkdownSimple.bloques(aviso.contenido),
                const SizedBox(height: 24),
                Text('Versión ${aviso.version} · Actualizado el ${aviso.fechaActualizacion}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.grisInactivo)),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Lo poco de Markdown que usa el aviso: títulos (#, ##), listas (-, 1.) y **negritas**.
class _MarkdownSimple {
  static List<Widget> bloques(String texto) {
    final widgets = <Widget>[];
    for (final linea in texto.split('\n')) {
      final l = linea.trimRight();
      if (l.isEmpty) continue;
      if (l.startsWith('# ')) {
        widgets.add(_padding(Text(l.substring(2),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.guinda)),
            top: 0));
      } else if (l.startsWith('## ')) {
        widgets.add(_padding(Text(l.substring(3),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.negro)),
            top: 16));
      } else {
        final lista = RegExp(r'^(- |\d+\. )').firstMatch(l);
        if (lista != null) {
          final vineta = lista.group(1)!.trim() == '-' ? '•' : lista.group(1)!.trim();
          widgets.add(_padding(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 22, child: Text(vineta, style: _cuerpo)),
                Expanded(child: _enLinea(l.substring(lista.end))),
              ],
            ),
            top: 4,
          ));
        } else {
          widgets.add(_padding(_enLinea(l), top: 8));
        }
      }
    }
    return widgets;
  }

  static const _cuerpo = TextStyle(fontSize: 14, height: 1.45, color: AppTheme.negro);

  static Widget _enLinea(String texto) {
    final partes = texto.split('**');
    return Text.rich(TextSpan(
      style: _cuerpo,
      children: [
        for (var i = 0; i < partes.length; i++)
          TextSpan(
            text: partes[i],
            style: i.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
      ],
    ));
  }

  static Widget _padding(Widget child, {required double top}) =>
      Padding(padding: EdgeInsets.only(top: top), child: child);
}
