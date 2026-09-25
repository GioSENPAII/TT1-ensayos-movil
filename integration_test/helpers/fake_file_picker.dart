import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';

/// Archivo "elegido" en memoria.
final class ArchivoFalso extends PlatformFile {
  @override
  final String name;
  final Uint8List bytes;
  ArchivoFalso(this.name, this.bytes);

  @override
  Uri get uri => Uri.parse('memory:///$name');
  @override
  XFile get xFile => XFile.fromData(bytes, name: name);
  @override
  int? lengthSync() => bytes.length;
  @override
  Future<int?> length() async => bytes.length;
  @override
  Future<Uint8List> readAsBytes() async => bytes;
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

/// Sustituye al selector nativo (que una prueba no puede tocar): devuelve los archivos de la cola
/// en orden y registra los filtros que pidió la app.
class FilePickerFalso extends FilePickerPlatform {
  final List<PlatformFile> cola;
  final List<List<String>?> extensionesPedidas = [];
  FilePickerFalso(this.cola);

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    extensionesPedidas.add(allowedExtensions);
    return cola.isEmpty ? null : cola.removeAt(0);
  }
}
