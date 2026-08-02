import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/prestador.dart';
import 'uniodonto_auth_client.dart';

/// Consults the Uniodonto Porto Alegre operator API for accredited dental
/// providers (rede credenciada).
class RedeCredenciadaService {
  RedeCredenciadaService._();
  static final RedeCredenciadaService instance = RedeCredenciadaService._();

  static const pageSize = 20;

  Future<PrestadorPagina> buscar(PrestadorFiltro filtro, {int page = 1}) async {
    final token = await UniodontoAuthClient.instance.obterToken();

    final queryParameters = <String, String>{
      'page': '$page',
      'limit': '$pageSize',
      if ((filtro.estado ?? '').trim().isNotEmpty)
        'estado': filtro.estado!.trim(),
      if ((filtro.cidade ?? '').trim().isNotEmpty)
        'cidade': filtro.cidade!.trim(),
      if ((filtro.bairro ?? '').trim().isNotEmpty)
        'bairro': filtro.bairro!.trim(),
      if ((filtro.areaAtuacao ?? '').trim().isNotEmpty)
        'area_de_atuacao': filtro.areaAtuacao!.trim(),
      if ((filtro.cro ?? '').trim().isNotEmpty) 'cro': filtro.cro!.trim(),
      if ((filtro.nome ?? '').trim().isNotEmpty) 'nome': filtro.nome!.trim(),
    };

    final uri = Uri.parse('${UniodontoAuthClient.baseUrl}/ListaPrestadorGeral')
        .replace(queryParameters: queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(UniodontoAuthClient.timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Falha ao consultar a rede credenciada (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final prestadores = (decoded['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Prestador.fromJson)
        .toList();
    final pagination =
        decoded['pagination'] as Map<String, dynamic>? ?? const {};

    return PrestadorPagina(
      prestadores: prestadores,
      page: (pagination['page'] as num?)?.toInt() ?? page,
      totalPages: (pagination['total_pages'] as num?)?.toInt() ?? page,
    );
  }
}
