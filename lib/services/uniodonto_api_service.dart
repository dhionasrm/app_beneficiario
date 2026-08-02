import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/uniodonto_registro.dart';
import 'uniodonto_auth_client.dart';

/// Consults the Uniodonto Porto Alegre operator API to check whether a CPF
/// belongs to a beneficiary (titular or dependente).
class UniodontoApiService {
  UniodontoApiService._();
  static final UniodontoApiService instance = UniodontoApiService._();

  Future<UniodontoConsultaResult> consultarPorCpf(String cpf) async {
    final token = await UniodontoAuthClient.instance.obterToken();

    final uri = Uri.parse(
      '${UniodontoAuthClient.baseUrl}/usuCatNumero',
    ).replace(queryParameters: {'cpf': cpf});

    final response = await http
        .get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(UniodontoAuthClient.timeout);

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
