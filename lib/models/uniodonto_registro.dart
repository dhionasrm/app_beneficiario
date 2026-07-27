/// A single beneficiary record returned by the Uniodonto `usuCatNumero`
/// endpoint (either the titular or one of their dependentes).
class UniodontoRegistro {
  const UniodontoRegistro({
    required this.carteira,
    required this.nome,
    required this.cpf,
    required this.tipoContratacao,
    required this.empregador,
    required this.modalidade,
    required this.registro,
    required this.inclusao,
    required this.cns,
    required this.nascimento,
    required this.abrangencia,
    required this.tipo,
  });

  factory UniodontoRegistro.fromJson(Map<String, dynamic> json) {
    return UniodontoRegistro(
      carteira: json['CARTEIRA']?.toString() ?? '',
      nome: json['NOME']?.toString() ?? '',
      cpf: json['CPF']?.toString() ?? '',
      tipoContratacao: json['TIPO_CONTRATACAO']?.toString() ?? '',
      empregador: json['EMPREGADOR']?.toString() ?? '',
      modalidade: json['MOD']?.toString() ?? '',
      registro: json['REGISTRO']?.toString() ?? '',
      inclusao: json['INCLUSAO']?.toString() ?? '',
      cns: json['CNS']?.toString() ?? '',
      nascimento: json['NASCIMENTO']?.toString() ?? '',
      abrangencia: json['ABRANGENCIA']?.toString() ?? '',
      tipo: json['TIPO']?.toString() ?? '',
    );
  }

  final String carteira;
  final String nome;
  final String cpf;
  final String tipoContratacao;
  final String empregador;
  final String modalidade;
  final String registro;
  final String inclusao;
  final String cns;
  final String nascimento;
  final String abrangencia;
  final String tipo;

  bool get isTitular => tipo.toUpperCase() == 'TITULAR';

  Map<String, dynamic> toJson() => {
        'carteira': carteira,
        'nome': nome,
        'cpf': cpf,
        'tipoContratacao': tipoContratacao,
        'empregador': empregador,
        'modalidade': modalidade,
        'registro': registro,
        'inclusao': inclusao,
        'cns': cns,
        'nascimento': nascimento,
        'abrangencia': abrangencia,
        'tipo': tipo,
      };
}

enum UniodontoConsultaStatus { titular, dependente, naoEncontrado }

/// Result of looking up a CPF against the Uniodonto beneficiary API.
class UniodontoConsultaResult {
  const UniodontoConsultaResult._(this.status, this.registro);

  const UniodontoConsultaResult.titular(UniodontoRegistro registro)
      : this._(UniodontoConsultaStatus.titular, registro);

  const UniodontoConsultaResult.dependente(UniodontoRegistro registro)
      : this._(UniodontoConsultaStatus.dependente, registro);

  const UniodontoConsultaResult.naoEncontrado()
      : this._(UniodontoConsultaStatus.naoEncontrado, null);

  final UniodontoConsultaStatus status;
  final UniodontoRegistro? registro;
}
