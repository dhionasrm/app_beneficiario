import 'package:flutter/material.dart';

import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

/// Lets the user request a password reset by e-mail.
///
/// There is no backend yet, so submitting just simulates the round trip and
/// shows a confirmation message — swap [_submit] for a real API call once
/// the password-reset endpoint exists.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _requestSent = false;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Placeholder: no backend wired up yet.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _requestSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Esqueci minha senha')),
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
                        'Se o e-mail informado estiver cadastrado, você '
                        'receberá as instruções para redefinir sua senha em '
                        'instantes.',
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Voltar para o login',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                Text(
                  'Redefinir senha',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Informe o e-mail utilizado no seu cadastro. Enviaremos '
                  'as instruções para você criar uma nova senha.',
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
                      AppTextField(
                        label: 'E-mail cadastrado',
                        hint: 'nome@exemplo.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.mail_outline,
                        autofillHints: const [AutofillHints.email],
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) {
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.isEmpty) {
                            return 'Informe seu e-mail.';
                          }
                          if (!_emailRegex.hasMatch(trimmed)) {
                            return 'Informe um e-mail válido.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Enviar instruções',
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
