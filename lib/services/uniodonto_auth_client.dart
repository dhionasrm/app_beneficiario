import 'dart:convert';

import 'package:http/http.dart' as http;

/// Shared authentication for the Uniodonto Porto Alegre operator API.
///
/// The credentials below authenticate against the operator's internal API
/// and are only embedded in the app to unblock these flows before a
/// dedicated backend endpoint exists. They must move server-side once that
/// endpoint is built — shipping them in the client lets anyone who
/// decompiles the app query any beneficiário's or prestador's data.
class UniodontoAuthClient {
  UniodontoAuthClient._();
  static final UniodontoAuthClient instance = UniodontoAuthClient._();

  static const baseUrl = 'https://cliente-src.uniodontopoa.com.br:2096';
  static const timeout = Duration(seconds: 15);

  static const _username = 'ti';
  static const _password = 'h#k2947ToP';

  Future<String> obterToken() async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': _username, 'password': _password}),
        )
        .timeout(timeout);

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
}
