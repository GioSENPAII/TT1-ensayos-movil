import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Preguntas frecuentes (Soporte). Mismo contenido que la página soporte.html de la web, sin la sección
/// de profesores y con los nombres de los botones de la app. Se abre desde el inicio de sesión y desde el perfil.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _correosAdministradores = <String>[
    'porraszuniga@gmail.com',
    'joseeduardomayafabela@gmail.com',
    'glongoria.3a.is@gmail.com',
  ];

  // Las **negritas** se marcan como en Markdown
  static const _temas = <_Tema>[
    _Tema('Cuenta y acceso', Icons.person_outline, [
      _Pregunta('¿Con qué correo me registro?',
          'Con tu correo institucional: los alumnos usan **@alumno.ipn.mx**. Para crear la cuenta también '
              'debes aceptar el aviso de privacidad, que después puedes volver a consultar desde tu perfil.'),
      _Pregunta('No me llegó el código de verificación',
          'Revisa tu carpeta de spam o correo no deseado: llega del remitente "Sistema de Calificación de '
              'Ensayos ESCOM". Si no aparece, en la pantalla del código pulsa **"Reenviar código"**; puedes '
              'pedir otro cada 60 segundos. Al pedir un código nuevo, el anterior deja de servir.'),
      _Pregunta('Me dice que el código es incorrecto o que expiró',
          'Cada código tiene 6 dígitos, se usa una sola vez y vence a los 15 minutos. Admite **5 intentos**: '
              'después hay que pedir uno nuevo. Usa siempre el último código que recibiste.'),
      _Pregunta('¿Qué contraseña puedo usar?',
          'Mínimo 8 caracteres, con al menos una **mayúscula**, una **minúscula**, un **número** y un '
              '**carácter especial** (por ejemplo ! # \$ % * .). Con el ícono del ojo puedes ver lo que '
              'escribiste antes de enviarla.'),
      _Pregunta('Olvidé mi contraseña',
          'En la pantalla de inicio de sesión pulsa **"¿Olvidaste tu contraseña?"**, escribe tu correo y usa '
              'el código que te llegue para crear una contraseña nueva. Por seguridad, al cambiarla se cierran '
              'todas tus sesiones abiertas.'),
      _Pregunta('Me dice que mi cuenta está suspendida',
          'Las cuentas las suspende el administrador del sistema. Mientras esté suspendida no podrás entrar; '
              'escribe a los administradores (sus correos están en "¿No encontraste tu respuesta?", al final).'),
      _Pregunta('Me sacó de la sesión sin que la cerrara',
          'La sesión se renueva sola mientras usas la app. Si pasan muchos días sin entrar, si cambiaste tu '
              'contraseña o si se suspendió la cuenta, tendrás que iniciar sesión de nuevo.'),
    ]),
    _Tema('Grupos y tareas', Icons.groups_outlined, [
      _Pregunta('¿Cómo me uno a un grupo?',
          'Pide a tu profesor el **código de acceso de 6 caracteres** y, en Inicio, pulsa **"Unirse a un '
              'grupo"**. Si te dice que el código no es válido, revísalo con tu profesor; si te dice que el '
              'grupo no acepta inscripciones, es que el profesor desactivó el código.'),
      _Pregunta('No veo una tarea que mi profesor dice que ya publicó',
          'Las tareas aparecen a partir de su **fecha de apertura**. Si ya pasó y no la ves, confirma con tu '
              'profesor que la publicó en el grupo en el que estás inscrito.'),
      _Pregunta('Ya pasó la fecha de cierre, ¿puedo entregar?',
          'No: al cerrar, el sistema bloquea las entregas automáticamente. Solo tu profesor puede ampliar la '
              'fecha de cierre.'),
    ]),
    _Tema('Entregar mi ensayo', Icons.upload_file_outlined, [
      _Pregunta('¿Qué archivo debo subir?',
          'Un **PDF de hasta 10 MB** con **texto seleccionable**, es decir, exportado desde Word, Google Docs '
              'u otro editor. Los PDF escaneados (fotos de hojas), dañados o con contraseña no se pueden '
              'calificar. El **nombre del archivo** también se evalúa en el criterio "Formato de Archivo".'),
      _Pregunta('Subí el archivo equivocado, ¿puedo reemplazarlo?',
          'Una vez calificado, el ensayo **ya no se puede reemplazar**; revisa tu archivo antes de enviarlo. '
              'Si el motor de calificación falla, la entrega queda en "Error" y sí puedes volver a subirla '
              'mientras la tarea siga abierta. Para cualquier otro caso, habla con tu profesor.'),
      _Pregunta('Mi entrega dice "En revisión"',
          'La calificación se hace automáticamente después de subir el archivo. Normalmente tarda unos '
              'segundos (hasta medio minuto si el sistema estaba inactivo) y la app muestra el resultado sola. '
              'Puedes salir: el resultado quedará en la pestaña Entregas.'),
    ]),
    _Tema('Calificación', Icons.grading_outlined, [
      _Pregunta('¿Cómo se calcula mi calificación?',
          'Un motor de inteligencia artificial evalúa el ensayo con la rúbrica institucional de 8 criterios '
              '(estructura, formato, ortografía, título, introducción, desarrollo, conclusiones y '
              'referencias), sobre 10 puntos. En el reporte ves el puntaje de cada criterio, su nivel (alto, '
              'medio o bajo) y la descripción de la rúbrica.'),
      _Pregunta('No estoy de acuerdo con mi calificación',
          'Habla con tu profesor: puede revisar tu ensayo y ajustar el puntaje de cualquier criterio. Si lo '
              'hace, en tu reporte verás la marca "Revisado por docente" junto al valor original.'),
      _Pregunta('Mi reporte tiene una "alerta de similitud histórica"',
          'Significa que tu ensayo se parece mucho a uno del histórico del sistema. La alerta **no cambia tu '
              'calificación**: solo avisa a tu profesor para que lo revise.'),
    ]),
    _Tema('App móvil', Icons.phone_android_outlined, [
      _Pregunta('¿En qué teléfonos funciona la app?',
          'La app es para alumnos y solo para **Android**. Como no viene de Play Store, al instalarla Android '
              'te pide permitir aplicaciones de orígenes desconocidos. En iPhone no está disponible; puedes '
              'usar la página web desde el navegador.'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soporte')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Respuestas a las dudas más comunes. Si la tuya no está aquí, al final encontrarás a quién '
                'acudir.',
                style: TextStyle(color: AppTheme.grisInactivo),
              ),
            ),
            for (final tema in _temas) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                child: Row(
                  children: [
                    Icon(tema.icono, color: AppTheme.guinda),
                    const SizedBox(width: 8),
                    Text(tema.titulo,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.negro)),
                  ],
                ),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final (i, p) in tema.preguntas.indexed) ...[
                      if (i > 0) const Divider(height: 1),
                      ExpansionTile(
                        shape: const Border(),
                        iconColor: AppTheme.guinda,
                        title: Text(p.pregunta, style: const TextStyle(fontWeight: FontWeight.w600)),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedAlignment: Alignment.centerLeft,
                        children: [_TextoConNegritas(p.respuesta)],
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              color: AppTheme.grisClaro,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('¿No encontraste tu respuesta?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.negro)),
                    const SizedBox(height: 8),
                    const _TextoConNegritas('Tu primer contacto es **tu profesor**: puede revisar tus entregas, '
                        'ampliar fechas de cierre y ajustar calificaciones.'),
                    const SizedBox(height: 12),
                    const _TextoConNegritas('Para problemas con tu cuenta, como una suspensión, escribe a los '
                        '**administradores del sistema**:'),
                    const SizedBox(height: 8),
                    for (final correo in _correosAdministradores)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SelectableText(correo,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.guinda)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tema {
  final String titulo;
  final IconData icono;
  final List<_Pregunta> preguntas;
  const _Tema(this.titulo, this.icono, this.preguntas);
}

class _Pregunta {
  final String pregunta;
  final String respuesta;
  const _Pregunta(this.pregunta, this.respuesta);
}

/// Texto con tramos **en negritas**.
class _TextoConNegritas extends StatelessWidget {
  final String texto;
  const _TextoConNegritas(this.texto);

  @override
  Widget build(BuildContext context) {
    final partes = texto.split('**');
    return Text.rich(
      TextSpan(
        style: const TextStyle(height: 1.4, color: AppTheme.negro),
        children: [
          for (final (i, parte) in partes.indexed)
            TextSpan(text: parte, style: i.isOdd ? const TextStyle(fontWeight: FontWeight.bold) : null),
        ],
      ),
    );
  }
}
