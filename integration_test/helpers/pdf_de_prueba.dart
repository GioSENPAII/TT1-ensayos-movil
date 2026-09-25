import 'dart:convert';
import 'dart:typed_data';

/// Genera un PDF válido con texto seleccionable (el backend rechaza PDFs sin texto, RN-IA-01).
Uint8List pdfConTexto(List<String> lineas) {
  String esc(String s) => s.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
  final contenido = StringBuffer('BT /F1 12 Tf 72 720 Td 16 TL\n');
  for (final l in lineas) {
    contenido.write('(${esc(l)}) Tj T*\n');
  }
  contenido.write('ET');
  final stream = latin1.encode(contenido.toString());

  final objetos = <String>[
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R '
        '/Resources << /Font << /F1 5 0 R >> >> >>',
    '<< /Length ${stream.length} >>\nstream\n${latin1.decode(stream)}\nendstream',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>',
  ];

  final out = BytesBuilder();
  void escribir(String s) => out.add(latin1.encode(s));
  escribir('%PDF-1.4\n');
  final offsets = <int>[];
  for (var i = 0; i < objetos.length; i++) {
    offsets.add(out.length);
    escribir('${i + 1} 0 obj\n${objetos[i]}\nendobj\n');
  }
  final xref = out.length;
  escribir('xref\n0 ${objetos.length + 1}\n0000000000 65535 f \n');
  for (final o in offsets) {
    escribir('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  escribir('trailer\n<< /Size ${objetos.length + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF\n');
  return out.toBytes();
}
