import '../models/beneficiario.dart';

/// Placeholder carteirinha data source.
///
/// There is no backend wired up yet, so this returns a fixed titular +
/// dependente pair so the list/detail screens can be built and tested.
/// Swap [fetchBeneficiarios] for a real API call when the operator's
/// backend is available — the return type and public signature can stay
/// the same.
class CarteirinhaService {
  CarteirinhaService._();
  static final CarteirinhaService instance = CarteirinhaService._();

  Future<List<Beneficiario>> fetchBeneficiarios() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return const [
      Beneficiario(
        nome: 'Teste Silva Santos',
        cpf: '000.000.001-00',
        plano: 'Uniodonto Total',
        titular: true,
      ),
      Beneficiario(
        nome: 'Dep Silva Santos',
        cpf: '000.000.002-00',
        plano: 'Uniodonto Total',
        titular: false,
      ),
    ];
  }
}
