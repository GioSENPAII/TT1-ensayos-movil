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

Entrega entregaCon(EstadoEntrega estado) => Entrega(
      id: 1, nombreArchivo: 'ensayo.pdf', tamanoBytes: 2048, fechaEntrega: DateTime(2026),
      tareaId: 7, tarea: 'T', grupoId: 1, grupo: 'G', estado: estado,
      calificacionFinal: estado == EstadoEntrega.calificado ? 8.5 : null,
      modificadoPorDocente: false, mensaje: null, reporte: null,
    );

class RepoFalso implements SubmissionRepository {
  Object? error;
  int envios = 0;
  int lecturas = 0;

  /// Estado que devuelve el servidor al recibir el archivo (202).
  EstadoEntrega alEnviar = EstadoEntrega.calificado;

  /// Respuestas sucesivas de GET /submissions/{id}; un Exception simula falla de red.
  final List<Object> consultas = [];

  @override
  Future<Entrega> enviar({required int tareaId, required ArchivoPdf archivo}) async {
    envios++;
    if (error != null) throw error!;
    return entregaCon(alEnviar);
  }

  @override
  Future<List<Entrega>> historial() async => [];

  @override
  Future<Entrega> detalle(int id) async {
    final r = consultas.removeAt(0);
    if (r is Exception) throw r;
    return entregaCon(r as EstadoEntrega);
  }
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
    build: () => SubmissionBloc(repo, intervaloConsulta: Duration.zero),
    act: (b) => b.add(archivo('ensayo.docx', 1000)),
    expect: () => [isA<ArchivoInvalido>().having((s) => s.mensaje, 'mensaje', 'Solo se permiten archivos PDF')],
    verify: (_) => expect(repo.envios, 0),
  );

  blocTest<SubmissionBloc, SubmissionState>(
    'rechaza más de 10 MB sin leer el archivo (CU-ALU-02 E2)',
    build: () => SubmissionBloc(repo, intervaloConsulta: Duration.zero),
    act: (b) => b.add(archivo('ensayo.pdf', ArchivoPdf.maxBytes + 1)),
    expect: () => [isA<ArchivoInvalido>().having((s) => s.mensaje, 'mensaje', contains('10 MB'))],
    verify: (_) => expect(repo.lecturas, 0),
  );

  blocTest<SubmissionBloc, SubmissionState>(
    'archivo válido → confirmación → enviando → terminado',
    build: () => SubmissionBloc(repo, intervaloConsulta: Duration.zero),
    act: (b) async {
      b.add(archivo('Ensayo.PDF', 2048));
      await Future<void>.delayed(Duration.zero);
      b.add(EnvioConfirmado(7));
    },
    expect: () => [isA<ArchivoListo>(), isA<Enviando>(), isA<EnvioTerminado>()],
  );

  blocTest<SubmissionBloc, SubmissionState>(
    'sin red permite reintentar con el mismo archivo (CU-ALU-02 E3)',
    build: () => SubmissionBloc(repo, intervaloConsulta: Duration.zero),
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

  blocTest<SubmissionBloc, SubmissionState>(
    'C6: el servidor responde EN_REVISION y la app consulta hasta tener la calificación',
    build: () => SubmissionBloc(repo, intervaloConsulta: Duration.zero),
    act: (b) async {
      repo.alEnviar = EstadoEntrega.enRevision;
      repo.consultas.addAll([EstadoEntrega.enRevision, const NetworkException(), EstadoEntrega.calificado]);
      b.add(archivo('ensayo.pdf', 2048));
      await Future<void>.delayed(Duration.zero);
      b.add(EnvioConfirmado(7));
    },
    wait: const Duration(milliseconds: 50),
    expect: () => [
      isA<ArchivoListo>(),
      isA<Enviando>(),
      isA<Procesando>().having((s) => s.sinConexion, 'sinConexion', isFalse),
      // sin red a mitad de la espera: se avisa y se sigue consultando
      isA<Procesando>().having((s) => s.sinConexion, 'sinConexion', isTrue),
      isA<EnvioTerminado>().having((s) => s.entrega.estado, 'estado', EstadoEntrega.calificado),
    ],
    verify: (_) => expect(repo.consultas, isEmpty),
  );
}
