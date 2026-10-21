import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/foto_perfil.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/profile/foto_perfil_cubit.dart';
import 'privacy_notice_screen.dart';

/// Perfil del alumno y cierre de sesión (ProfileScreen, CU-AUTH-05).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmarSalida(BuildContext context) async {
    final salir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar tu sesión en este dispositivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.grisInactivo)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión', style: TextStyle(color: AppTheme.guinda)),
          ),
        ],
      ),
    );
    if (salir == true && context.mounted) {
      context.read<AuthBloc>().add(LogoutRequested());
    }
  }

  /// La foto solo se elige de la galería o de Archivos: la app no usa la cámara.
  Future<void> _cambiarFoto(BuildContext context, bool tieneFoto) async {
    final cubit = context.read<FotoPerfilCubit>();
    final opcion = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppTheme.guinda),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(ctx).pop('galeria'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: AppTheme.guinda),
              title: const Text('Elegir de Archivos'),
              subtitle: const Text('JPG o PNG, máximo 5 MB'),
              onTap: () => Navigator.of(ctx).pop('archivos'),
            ),
            if (tieneFoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.rojoDeficiente),
                title: const Text('Quitar foto', style: TextStyle(color: AppTheme.rojoDeficiente)),
                onTap: () => Navigator.of(ctx).pop('quitar'),
              ),
          ],
        ),
      ),
    );

    switch (opcion) {
      case 'galeria':
        // Se reduce y convierte a JPEG en el teléfono (también las fotos HEIC del iPhone)
        final imagen = await ImagePicker().pickImage(
            source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
        if (imagen == null) return;
        await cubit.subir(FotoPerfil(nombre: imagen.name, bytes: await imagen.readAsBytes()));
      case 'archivos':
        final archivo = await FilePicker.pickFile(
            type: FileType.custom, allowedExtensions: FotoPerfil.extensiones);
        if (archivo == null) return;
        await cubit.subir(FotoPerfil(nombre: archivo.name, bytes: await archivo.readAsBytes()));
      case 'quitar':
        await cubit.eliminar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final nombre = state is AuthAuthenticated ? state.nombre : '';
    final correo = state is AuthAuthenticated ? state.correo : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          BlocConsumer<FotoPerfilCubit, FotoPerfilState>(
            listenWhen: (_, actual) => actual.mensaje != null,
            listener: (context, foto) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(foto.mensaje!), backgroundColor: AppTheme.rojoDeficiente),
            ),
            builder: (context, foto) => Center(
              child: _Avatar(
                nombre: nombre,
                foto: foto,
                onTap: foto.status == FotoStatus.lista
                    ? () => _cambiarFoto(context, foto.bytes != null)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.negro)),
          const SizedBox(height: 4),
          const Text('Alumno',
              textAlign: TextAlign.center, style: TextStyle(color: AppTheme.grisInactivo)),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email_outlined, color: AppTheme.guinda),
              title: const Text('Correo institucional'),
              subtitle: Text(correo),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.guinda),
              title: const Text('Aviso de privacidad'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyNoticeScreen()),
              ),
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: () => _confirmarSalida(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

/// Foto de perfil o, si no hay, la inicial del nombre; con un botón para cambiarla.
class _Avatar extends StatelessWidget {
  final String nombre;
  final FotoPerfilState foto;
  final VoidCallback? onTap;
  const _Avatar({required this.nombre, required this.foto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bytes = foto.bytes;
    final ocupado = foto.status == FotoStatus.cargando || foto.status == FotoStatus.guardando;
    return Semantics(
      button: true,
      label: 'Cambiar foto de perfil',
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: AppTheme.guinda,
              backgroundImage: bytes != null ? MemoryImage(bytes) : null,
              child: bytes == null
                  ? Text(
                      nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            if (ocupado)
              const SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(color: AppTheme.guindaClaro, strokeWidth: 3),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.grisClaro, width: 2),
                ),
                child: const Icon(Icons.edit, size: 18, color: AppTheme.guinda),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
