import 'package:ensayos_movil/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('política de contraseñas RNF-10', () {
    expect(Validators.password('corta1A'), isNotNull);
    expect(Validators.password('sinmayuscula1'), isNotNull);
    expect(Validators.password('SINMINUSCULA1'), isNotNull);
    expect(Validators.password('SinNumeroAqui'), isNotNull);
    expect(Validators.password('Prueba123'), isNull);
  });

  test('código de grupo: 6 alfanuméricos', () {
    expect(Validators.codigoGrupo('SO3CM1'), isNull);
    expect(Validators.codigoGrupo('so3cm1'), isNull);
    expect(Validators.codigoGrupo('SO3CM'), isNotNull);
    expect(Validators.codigoGrupo('SO-CM1'), isNotNull);
  });

  test('correo de alumno', () {
    expect(Validators.correoAlumno('ana@alumno.ipn.mx'), isNull);
    expect(Validators.correoAlumno('ana@ipn.mx'), isNotNull);
    expect(Validators.correoAlumno('ana'), isNotNull);
  });
}
