/// Validadores de formularios compartidos entre pantallas.
class Validators {
  Validators._();

  static String? correo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
      return 'Correo inválido';
    }
    return null;
  }

  static String? correoAlumno(String? v) {
    final base = correo(v);
    if (base != null) return base;
    if (!v!.trim().toLowerCase().endsWith('@alumno.ipn.mx')) {
      return 'Debes usar tu correo @alumno.ipn.mx';
    }
    return null;
  }

  /// RNF-10: mínimo 8 caracteres, una mayúscula, una minúscula, un número y un
  /// carácter especial (cualquier símbolo que no sea letra, número ni espacio).
  static String? password(String? v) {
    if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Debe incluir al menos una mayúscula';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'Debe incluir al menos una minúscula';
    if (!RegExp(r'\d').hasMatch(v)) return 'Debe incluir al menos un número';
    if (!RegExp(r'[^\p{L}\p{N}\s]', unicode: true).hasMatch(v)) {
      return 'Debe incluir al menos un carácter especial (p. ej. ! # \$ % * .)';
    }
    return null;
  }

  static String? codigo6Digitos(String? v) {
    if (v == null || !RegExp(r'^\d{6}$').hasMatch(v.trim())) {
      return 'El código debe tener 6 dígitos';
    }
    return null;
  }

  /// Código de acceso de grupo: 6 caracteres alfanuméricos (RF-ALU-04).
  static String? codigoGrupo(String? v) {
    if (v == null || !RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(v.trim())) {
      return 'El código debe tener 6 letras o números';
    }
    return null;
  }
}
