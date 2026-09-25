import 'dart:typed_data';

/// PDF elegido por el alumno, listo para enviarse.
class ArchivoPdf {
  static const int maxBytes = 10 * 1024 * 1024; // RN-IA-02

  final String nombre;
  final Uint8List bytes;

  const ArchivoPdf({required this.nombre, required this.bytes});

  int get tamano => bytes.length;
}
