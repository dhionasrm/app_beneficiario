class Beneficiario {
  const Beneficiario({
    required this.nome,
    required this.cpf,
    required this.plano,
    required this.titular,
  });

  final String nome;
  final String cpf;
  final String plano;
  final bool titular;
}
