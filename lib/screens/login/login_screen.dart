import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_mark.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _rememberMe = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _cardController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await AuthService.instance.login(
      cardNumber: _cardController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.menu);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = result.errorMessage;
    });
  }

  void _goToForgotPassword() {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }

  void _goToFirstAccess() {
    Navigator.of(context).pushNamed(AppRoutes.firstAccess);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const BrandMark(size: 52),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Uniodonto Porto Alegre Beneficiários',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Bem-vindo de volta',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Entre com os dados da sua carteirinha para acessar '
                        'seus benefícios odontológicos.',
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
                              label: 'Número da carteirinha',
                              hint: 'Somente números',
                              controller: _cardController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icons.badge_outlined,
                              autofillHints: const [AutofillHints.username],
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(20),
                              ],
                              onFieldSubmitted: (_) =>
                                  _passwordFocus.requestFocus(),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe o número da sua carteirinha.';
                                }
                                if (value.trim().length < 6) {
                                  return 'Número da carteirinha inválido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Senha',
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icons.lock_outline,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Informe sua senha.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Semantics(
                                    label: 'Lembrar-me neste dispositivo',
                                    child: CheckboxListTile(
                                      value: _rememberMe,
                                      onChanged: (value) => setState(
                                        () => _rememberMe = value ?? false,
                                      ),
                                      title: const Text('Lembrar-me'),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _goToForgotPassword,
                                  child: const Text('Esqueci minha senha'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                              label: 'Entrar',
                              isLoading: _isSubmitting,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: _goToFirstAccess,
                                child: const Text('Primeiro acesso'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      _DemoCredentialsHint(colorScheme: colorScheme),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Visible only until a real backend is wired up — lets the app be tested
/// end-to-end on a physical device without needing live credentials.
class _DemoCredentialsHint extends StatelessWidget {
  const _DemoCredentialsHint({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modo de teste (remover ao integrar com o backend real): '
              'carteirinha 0000000000, senha unipoa123.',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
