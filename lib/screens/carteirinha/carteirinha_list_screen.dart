import 'package:flutter/material.dart';

import '../../models/beneficiario.dart';
import '../../routes/app_routes.dart';
import '../../services/carteirinha_service.dart';
import '../../utils/cpf_mask.dart';

class CarteirinhaListScreen extends StatefulWidget {
  const CarteirinhaListScreen({super.key});

  @override
  State<CarteirinhaListScreen> createState() => _CarteirinhaListScreenState();
}

class _CarteirinhaListScreenState extends State<CarteirinhaListScreen> {
  late Future<List<Beneficiario>> _future;

  @override
  void initState() {
    super.initState();
    _future = CarteirinhaService.instance.fetchBeneficiarios();
  }

  void _openDetalhe(Beneficiario beneficiario) {
    Navigator.of(context).pushNamed(
      AppRoutes.carteirinhaDetail,
      arguments: beneficiario,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carteirinha Virtual')),
      body: SafeArea(
        child: FutureBuilder<List<Beneficiario>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final beneficiarios = snapshot.data ?? const [];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ListHeader(),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: beneficiarios.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final beneficiario = beneficiarios[index];
                        return _BeneficiarioRow(
                          beneficiario: beneficiario,
                          onTap: () => _openDetalhe(beneficiario),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('NOME', style: style)),
          Expanded(flex: 2, child: Text('CPF', style: style)),
          Expanded(flex: 2, child: Text('PLANO', style: style)),
        ],
      ),
    );
  }
}

class _BeneficiarioRow extends StatelessWidget {
  const _BeneficiarioRow({required this.beneficiario, required this.onTap});

  final Beneficiario beneficiario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label:
          '${beneficiario.nome}, CPF oculto terminado em ${beneficiario.cpf.substring(beneficiario.cpf.length - 2)}, '
          'plano ${beneficiario.plano}. Toque para ver os detalhes.',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  beneficiario.nome,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  maskCpf(beneficiario.cpf),
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  beneficiario.plano,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
