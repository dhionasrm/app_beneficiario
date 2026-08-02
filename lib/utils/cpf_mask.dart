/// Masks a CPF for display, revealing only the last block and verifier
/// digits (e.g. `000.000.001-00` -> `***.***.001-00`) to limit exposure of
/// the full document number in glanceable or shareable views.
String maskCpf(String cpf) {
  final digits = cpf.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 11) return cpf;
  return '***.***.${digits.substring(6, 9)}-${digits.substring(9)}';
}
