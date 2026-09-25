import 'dart:convert';
import 'dart:io';

import 'package:ensayos_movil/core/errors/app_exceptions.dart';
import 'package:ensayos_movil/core/network/api_client.dart';
import 'package:ensayos_movil/core/storage/session_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response json(int code, Object? body) => http.Response(
      body == null ? '' : jsonEncode(body),
      code,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  late SessionStorage session;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    session = SessionStorage(const FlutterSecureStorage());
    await session.save(accessToken: 'viejo', refreshToken: 'r1', nombre: 'Ana', correo: 'a@alumno.ipn.mx', rol: 'ALUMNO');
  });

  test('ante 401 renueva la sesión, guarda los tokens nuevos y repite la petición', () async {
    final vistos = <String>[];
    final client = MockClient((req) async {
      if (req.url.path.endsWith('/auth/refresh-token')) {
        expect(jsonDecode(req.body), {'refreshToken': 'r1'});
        return json(200, {'accessToken': 'nuevo', 'refreshToken': 'r2', 'nombre': 'Ana', 'correo': 'a', 'rol': 'ALUMNO'});
      }
      vistos.add(req.headers['Authorization']!);
      return req.headers['Authorization'] == 'Bearer nuevo' ? json(200, [1, 2]) : json(401, {'detail': 'x'});
    });
    final api = ApiClient(session, client);

    expect(await api.get('/students/me/groups'), [1, 2]);
    expect(vistos, ['Bearer viejo', 'Bearer nuevo']);
    expect(await session.accessToken, 'nuevo');
    expect(await session.refreshToken, 'r2');
  });

  test('si la renovación falla borra la sesión, avisa y lanza SessionExpiredException', () async {
    final client = MockClient((req) async => json(401, {'detail': 'Sesión inválida'}));
    final api = ApiClient(session, client);
    final avisos = <void>[];
    api.onSessionExpired.listen(avisos.add);

    await expectLater(api.get('/students/me/groups'), throwsA(isA<SessionExpiredException>()));
    await Future<void>.delayed(Duration.zero);
    expect(avisos, hasLength(1));
    expect(await session.refreshToken, isNull);
  });

  test('peticiones concurrentes con 401 comparten una sola renovación', () async {
    var renovaciones = 0;
    final client = MockClient((req) async {
      if (req.url.path.endsWith('/auth/refresh-token')) {
        renovaciones++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return json(200, {'accessToken': 'nuevo', 'refreshToken': 'r2', 'nombre': 'Ana', 'correo': 'a', 'rol': 'ALUMNO'});
      }
      return req.headers['Authorization'] == 'Bearer nuevo' ? json(200, {'ok': true}) : json(401, null);
    });
    final api = ApiClient(session, client);

    final r = await Future.wait([api.get('/a'), api.get('/b'), api.get('/c')]);
    expect(r, everyElement({'ok': true}));
    expect(renovaciones, 1);
  });

  test('un 4xx se convierte en ClientException con el detail del ProblemDetail', () async {
    final client = MockClient((req) async =>
        json(409, {'status': 409, 'detail': 'Ya eres parte de este grupo', 'error': 'Ya eres parte de este grupo'}));
    final api = ApiClient(session, client);

    await expectLater(
      api.post('/groups/join', {'codigo': 'SO3CM1'}),
      throwsA(isA<ClientException>()
          .having((e) => e.statusCode, 'statusCode', 409)
          .having((e) => e.message, 'message', 'Ya eres parte de este grupo')),
    );
  });

  test('un 5xx es ServerException y sin red es NetworkException', () async {
    final api5xx = ApiClient(session, MockClient((_) async => json(503, {'detail': 'Correo caído'})));
    await expectLater(api5xx.get('/x'), throwsA(isA<ServerException>()));

    final sinRed = ApiClient(session, MockClient((_) async => throw const SocketException('sin red')));
    await expectLater(sinRed.get('/x'), throwsA(isA<NetworkException>()));
  });

  test('las peticiones públicas no mandan Authorization ni intentan renovar', () async {
    final client = MockClient((req) async {
      expect(req.headers.containsKey('Authorization'), isFalse);
      return json(401, {'detail': 'Correo o contraseña incorrectos'});
    });
    final api = ApiClient(session, client);

    await expectLater(
      api.post('/auth/login', {'correo': 'a', 'password': 'b'}, false),
      throwsA(isA<ClientException>().having((e) => e.message, 'message', 'Correo o contraseña incorrectos')),
    );
    expect(await session.refreshToken, 'r1'); // la sesión no se toca
  });
}
