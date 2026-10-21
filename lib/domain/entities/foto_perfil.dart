import 'dart:typed_data';

/// Imagen elegida de la galería o de Archivos para la foto de perfil.
class FotoPerfil {
  static const int maxBytes = 5 * 1024 * 1024; // límite del servidor
  static const List<String> extensiones = ['jpg', 'jpeg', 'png'];

  final String nombre;
  final Uint8List bytes;

  const FotoPerfil({required this.nombre, required this.bytes});
}
