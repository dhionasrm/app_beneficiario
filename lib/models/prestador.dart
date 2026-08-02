/// A dental provider (dentista/clínica) returned by the Uniodonto
/// `ListaPrestadorGeral` endpoint.
class Prestador {
  const Prestador({
    required this.nome,
    required this.endereco,
    required this.estado,
    required this.cidade,
    required this.bairro,
    required this.contatos,
    required this.celulares,
    required this.cro,
    required this.areasAtuacao,
  });

  factory Prestador.fromJson(Map<String, dynamic> json) {
    return Prestador(
      nome: (json['Nome']?.toString() ?? '').trim(),
      endereco: json['Endereco']?.toString() ?? '',
      estado: json['Estado']?.toString() ?? '',
      cidade: json['Cidade']?.toString() ?? '',
      bairro: json['Bairro']?.toString() ?? '',
      contatos: json['Contatos']?.toString() ?? '',
      celulares: json['Celulares']?.toString() ?? '',
      cro: json['CRO']?.toString() ?? '',
      areasAtuacao: json['Areas_de_Atuacao']?.toString() ?? '',
    );
  }

  final String nome;
  final String endereco;
  final String estado;
  final String cidade;
  final String bairro;
  final String contatos;
  final String celulares;
  final String cro;
  final String areasAtuacao;

  String get localizacao =>
      [bairro, cidade, estado].where((v) => v.trim().isNotEmpty).join(' - ');

  String get telefones => [
        contatos,
        celulares,
      ].where((v) => v.trim().isNotEmpty).join(' · ');
}

/// One page of a `ListaPrestadorGeral` search.
class PrestadorPagina {
  const PrestadorPagina({
    required this.prestadores,
    required this.page,
    required this.totalPages,
  });

  final List<Prestador> prestadores;
  final int page;
  final int totalPages;

  bool get temMaisPaginas => page < totalPages;
}

/// Search filters accepted by [RedeCredenciadaService].
///
/// `cidade` is only honoured by the API when [estado] is set, and `bairro`
/// only when both [estado] and [cidade] are set.
class PrestadorFiltro {
  const PrestadorFiltro({
    this.estado,
    this.cidade,
    this.bairro,
    this.areaAtuacao,
    this.cro,
    this.nome,
  });

  final String? estado;
  final String? cidade;
  final String? bairro;
  final String? areaAtuacao;
  final String? cro;
  final String? nome;

  bool get isEmpty => [estado, cidade, bairro, areaAtuacao, cro, nome]
      .every((value) => value == null || value.trim().isEmpty);

  List<String> get resumo => [
        if ((estado ?? '').trim().isNotEmpty) 'Estado: $estado',
        if ((cidade ?? '').trim().isNotEmpty) 'Cidade: $cidade',
        if ((bairro ?? '').trim().isNotEmpty) 'Bairro: $bairro',
        if ((areaAtuacao ?? '').trim().isNotEmpty)
          'Área de atuação: $areaAtuacao',
        if ((cro ?? '').trim().isNotEmpty) 'CRO: $cro',
        if ((nome ?? '').trim().isNotEmpty) 'Nome: $nome',
      ];
}
