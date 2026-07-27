import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/uniodonto_registro.dart';

/// Consults the Uniodonto Porto Alegre operator API to check whether a CPF
/// belongs to a beneficiary (titular or dependente).
///
/// The credentials below authenticate against the operator's internal API
/// and are only embedded in the app to unblock the first-access flow before
/// a dedicated backend endpoint exists. They must move server-side once that
/// endpoint is built — shipping them in the client lets anyone who
/// decompiles the app query any beneficiary's data.
class UniodontoApiService {
  UniodontoApiService._();
  static final UniodontoApiService instance = UniodontoApiService._();

  static const _baseUrl = 'https://cliente-src.uniodontopoa.com.br:2096';
  static const _username = 'ti';
  static const _password = 'h#k2947ToP';
  static const _timeout = Duration(seconds: 15);

  Future<String> _obterToken() async {
    final response = await http
        .post(
          Uri.parse('$_baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': _username, 'password': _password}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao autenticar na API Uniodonto (${response.statusCode}).',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token de acesso não retornado pela API Uniodonto.');
    }
    return token;
  }

  Future<UniodontoConsultaResult> consultarPorCpf(String cpf) async {
    final token = await _obterToken();

    final uri = Uri.parse(
      '$_baseUrl/usuCatNumero',
    ).replace(queryParameters: {'cpf': cpf});

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 404) {
      return const UniodontoConsultaResult.naoEncontrado();
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao consultar CPF na API Uniodonto (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) {
      return const UniodontoConsultaResult.naoEncontrado();
    }

    final registros = decoded
        .whereType<Map<String, dynamic>>()
        .map(UniodontoRegistro.fromJson)
        .toList();

    if (registros.isEmpty) {
      return const UniodontoConsultaResult.naoEncontrado();
    }

    final registro = registros.firstWhere(
      (r) => r.cpf == cpf,
      orElse: () => registros.first,
    );

    return registro.isTitular
        ? UniodontoConsultaResult.titular(registro)
        : UniodontoConsultaResult.dependente(registro);
  }
}
