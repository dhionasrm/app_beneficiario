import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persists first-access registration data to a local JSON file.
///
/// There is no backend yet, so completed registrations are stored on-device.
/// Swap [salvarCadastro] for a real API call once an endpoint exists to
/// write these records to the operator's SQL database.
class PrimeiroAcessoStorageService {
  PrimeiroAcessoStorageService._();
  static final PrimeiroAcessoStorageService instance =
      PrimeiroAcessoStorageService._();

  static const _fileName = 'primeiro_acesso_cadastros.json';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> salvarCadastro(Map<String, dynamic> cadastro) async {
    final file = await _getFile();

    var cadastros = <dynamic>[];
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.trim().isNotEmpty) {
        cadastros = jsonDecode(content) as List<dynamic>;
      }
    }

    cadastros.add(cadastro);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(cadastros),
    );
  }
}
