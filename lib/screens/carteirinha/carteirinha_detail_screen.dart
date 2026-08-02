import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/beneficiario.dart';
import '../../utils/cpf_mask.dart';
import '../../widgets/primary_button.dart';

class CarteirinhaDetailScreen extends StatelessWidget {
  const CarteirinhaDetailScreen({super.key});

  void _baixarCarteirinha(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download da carteirinha: funcionalidade em desenvolvimento.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final beneficiario =
        ModalRoute.of(context)!.settings.arguments as Beneficiario;

    return Scaffold(
      appBar: AppBar(title: Text(beneficiario.nome)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CartFace(
                asset: 'assets/images/carteirinha/carteirinha_frente.svg',
                label: 'Frente',
                beneficiario: beneficiario,
                showDados: true,
              ),
              const SizedBox(height: 16),
              _CartFace(
                asset: 'assets/images/carteirinha/carteirinha_verso.svg',
                label: 'Verso',
                beneficiario: beneficiario,
                showDados: false,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar'),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Baixar carteirinha',
                icon: Icons.download_outlined,
                onPressed: () => _baixarCarteirinha(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card art (front/back) rendered from the official Uniodonto carteirinha
/// SVGs, with the beneficiário's data overlaid on the front face.
class _CartFace extends StatefulWidget {
  const _CartFace({
    required this.asset,
    required this.label,
    required this.beneficiario,
    required this.showDados,
  });

  final String asset;
  final String label;
  final Beneficiario beneficiario;
  final bool showDados;

  @override
  State<_CartFace> createState() => _CartFaceState();
}

class _CartFaceState extends State<_CartFace> {
  bool _cpfRevealed = false;

  @override
  Widget build(BuildContext context) {
    final beneficiario = widget.beneficiario;
    final displayCpf =
        _cpfRevealed ? beneficiario.cpf : maskCpf(beneficiario.cpf);

    return Semantics(
      label: '${widget.label} da carteirinha de ${beneficiario.nome}',
      image: true,
      child: AspectRatio(
        aspectRatio: 270.933 / 169.333,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SvgPicture.asset(widget.asset, fit: BoxFit.cover),
              if (widget.showDados)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        constraints.maxWidth * 0.06,
                        constraints.maxHeight * 0.42,
                        constraints.maxWidth * 0.06,
                        constraints.maxHeight * 0.08,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            beneficiario.nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Semantics(
                            button: true,
                            label: _cpfRevealed
                                ? 'CPF $displayCpf, toque para ocultar'
                                : 'CPF oculto, toque para exibir',
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _cpfRevealed = !_cpfRevealed),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'CPF $displayCpf',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    _cpfRevealed
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            beneficiario.plano,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
