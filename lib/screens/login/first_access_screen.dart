import 'package:flutter/material.dart';

import '../../models/uniodonto_registro.dart';
import '../../services/primeiro_acesso_storage_service.dart';
import '../../services/uniodonto_api_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/cpf_input_formatter.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

/// Collects the registration data needed to activate first-time access:
/// name, surname, birth date and CPF.
///
/// The CPF is checked against the Uniodonto Porto Alegre operator API to
/// confirm it belongs to a titular before the registration is accepted.
/// There is no backend yet to persist the result, so accepted registrations
/// are written to a local JSON file — swap [_salvarCadastro] for a real API
/// call once an endpoint exists to write these records to the operator's
/// SQL database.
class FirstAccessScreen extends StatefulWidget {
  const FirstAccessScreen({super.key});

  @override
  State<FirstAccessScreen> createState() => _FirstAccessScreenState();
}

class _FirstAccessScreenState extends State<FirstAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();

  final _lastNameFocus = FocusNode();
  final _birthDateFocus = FocusNode();
  final _cpfFocus = FocusNode();

  DateTime? _birthDate;
  bool _isSubmitting = false;
  bool _requestSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _lastNameFocus.dispose();
    _birthDateFocus.dispose();
    _cpfFocus.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Data de nascimento',
    );
    if (picked == null) return;

    setState(() {
      _birthDate = picked;
      _birthDateController.text =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final cpfDigits = _cpfController.text.replaceAll(RegExp(r'\D'), '');

    try {
      final resultado = await UniodontoApiService.instance.consultarPorCpf(
        cpfDigits,
      );

      switch (resultado.status) {
        case UniodontoConsultaStatus.titular:
          await _salvarCadastro(cpfDigits, resultado.registro!);
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _requestSent = true;
          });
          break;
        case UniodontoConsultaStatus.dependente:
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Você é dependente do plano.';
          });
          break;
        case UniodontoConsultaStatus.naoEncontrado:
          if (!mounted) return;
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Você não é beneficiário Uniodonto Porto Alegre.';
          });
          break;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'Não foi possível verificar seus dados agora. Verifique sua '
            'conexão e tente novamente.';
      });
    }
  }

  Future<void> _salvarCadastro(
    String cpfDigits,
    UniodontoRegistro registro,
  ) async {
    await PrimeiroAcessoStorageService.instance.salvarCadastro({
      'nome': _firstNameController.text.trim(),
      'sobrenome': _lastNameController.text.trim(),
      'dataNascimento': _birthDateController.text,
      'cpf': cpfDigits,
      'criadoEm': DateTime.now().toIso8601String(),
      'uniodonto': registro.toJson(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Primeiro acesso')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_requestSent) ...[
                Semantics(
                  liveRegion: true,
                  child: _InfoBanner(
                    icon: Icons.check_circle_outline,
                    color: colorScheme.primary,
                    message:
                        'Cadastro recebido! Assim que confirmarmos seus '
                        'dados, enviaremos as instruções de acesso para '
                        'você.',
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Voltar para o login',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                Text(
                  'Complete seu cadastro',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Preencha os dados abaixo para liberar seu primeiro '
                  'acesso ao aplicativo.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null) ...[
                        Semantics(
                          liveRegion: true,
                          child: ErrorBanner(message: _errorMessage!),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        label: 'Nome',
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline,
                        autofillHints: const [AutofillHints.givenName],
                        onFieldSubmitted: (_) =>
                            _lastNameFocus.requestFocus(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu nome.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Sobrenome',
                        controller: _lastNameController,
                        focusNode: _lastNameFocus,
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.person_outline,
                        autofillHints: const [AutofillHints.familyName],
                        onFieldSubmitted: (_) => _pickBirthDate(),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu sobrenome.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Data de nascimento',
                        hint: 'DD/MM/AAAA',
                        controller: _birthDateController,
                        focusNode: _birthDateFocus,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        prefixIcon: Icons.cake_outlined,
                        validator: (_) {
                          if (_birthDate == null) {
                            return 'Informe sua data de nascimento.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'CPF',
                        hint: '000.000.000-00',
                        controller: _cpfController,
                        focusNode: _cpfFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.badge_outlined,
                        inputFormatters: [CpfInputFormatter()],
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          final digits =
                              value?.replaceAll(RegExp(r'\D'), '') ?? '';
                          if (digits.isEmpty) {
                            return 'Informe seu CPF.';
                          }
                          if (digits.length != 11) {
                            return 'CPF inválido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Concluir cadastro',
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
