import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:ensayos_movil/core/errors/app_exceptions.dart';
import 'package:ensayos_movil/domain/entities/archivo_pdf.dart';
import 'package:ensayos_movil/domain/entities/entrega.dart';
import 'package:ensayos_movil/domain/entities/tarea.dart';
import 'package:ensayos_movil/domain/repositories/submission_repository.dart';
import 'package:ensayos_movil/presentation/bloc/submission/submission_bloc.dart';
import 'package:ensayos_movil/presentation/bloc/submission/submission_event.dart';
import 'package:ensayos_movil/presentation/bloc/submission/submission_state.dart';
import 'package:flutter_test/flutter_test.dart';

class RepoFalso implements SubmissionRepository {
  Object? error;
  int envios = 0;
  int lecturas = 0;

  @override
  Future<Entrega> enviar({required int tareaId, required ArchivoPdf archivo}) async {
    envios++;
    if (error != null) throw error!;
    return Entrega(
      id: 1, nombreArchivo: archivo.nombre, tamanoBytes: archivo.tamano, fechaEntrega: DateTime(2026),
      tareaId: tareaId, tarea: 'T', grupoId: 1, grupo: 'G', estado: EstadoEntrega.calificado,
      calificacionFinal: 8.5, modificadoPorDocente: false, mensaje: null, reporte: null,
    );
  }

  @override
  Future<List<Entrega>> historial() async => [];
  @override
  Future<Entrega> detalle(int id) => throw UnimplementedError();
}

void main() {
  late RepoFalso repo;
  setUp(() => repo = RepoFalso());

  ArchivoSeleccionado archivo(String nombre, int tamano) => ArchivoSeleccionado(
        nombre: nombre,
        tamano: tamano,
        leer: () async {
          repo.lecturas++;
          return Uint8List(tamano);
        },
      );

  blocTest<SubmissionBloc, SubmissionState>(
    'rechaza un archivo que no es PDF sin contactar al servidor (CU-ALU-02 E1)',
    build: () => SubmissionBloc(repo),
    act: (b) => b.add(archivo('ensayo.docx', 1000)),
    expect: () => [isA<ArchivoInvalido>().having((s) => s.mensaje, 'mensaje', 'Solo se permiten archivos PDF')],
    verify: (_) => expect(repo.envios, 0),
  );

  blocTest<SubmissionBloc, SubmissionState>(
    'rechaza más de 10 MB sin leer el archivo (CU-ALU-02 E2)',
    build: () => SubmissionBloc(repo),
    act: (b) => b.add(archivo('ensayo.pdf', ArchivoPdf.maxBytes + 1)),
    expect: () => [isA<ArchivoInvalido>().having((s) => s.mensaje, 'mensaje', contains('10 MB'))],
    verify: (_) => expect(repo.lecturas, 0),
  );

  blocTest<SubmissionBloc, SubmissionState>(
    'archivo válido → confirmación → enviando → terminado',
    build: () => SubmissionBloc(repo),
    act: (b) async {
      b.add(archivo('Ensayo.PDF', 2048));
      await Future<void>.delayed(Duration.zero);
      b.add(EnvioConfirmado(7));
    },
    expect: () => [isA<ArchivoListo>(), isA<Enviando>(), isA<EnvioTerminado>()],
  );

  blocTest<SubmissionBloc, SubmissionState>(
    'sin red permite reintentar con el mismo archivo (CU-ALU-02 E3)',
    build: () => SubmissionBloc(repo),
    act: (b) async {
      repo.error = const NetworkException();
      b.add(archivo('ensayo.pdf', 2048));
      await Future<void>.delayed(Duration.zero);
      b.add(EnvioConfirmado(7));
      await Future<void>.delayed(Duration.zero);
      repo.error = null;
      b.add(EnvioConfirmado(7));
    },
    expect: () => [
      isA<ArchivoListo>(),
      isA<Enviando>(),
      isA<EnvioFallido>().having((s) => s.esDeRed, 'esDeRed', isTrue),
      isA<Enviando>(),
      isA<EnvioTerminado>(),
    ],
    verify: (_) => expect(repo.envios, 2),
  );
}
