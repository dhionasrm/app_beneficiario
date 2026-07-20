import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class _MenuAction {
  const _MenuAction(this.icon, this.label, this.description);

  final IconData icon;
  final String label;
  final String description;
}

const _menuActions = [
  _MenuAction(Icons.badge_outlined, 'Carteirinha Digital',
      'Acesse sua carteirinha sempre que precisar'),
  _MenuAction(Icons.map_outlined, 'Rede Credenciada',
      'Encontre dentistas e clínicas parceiras'),
  _MenuAction(Icons.calendar_month_outlined, 'Agendamentos',
      'Marque e acompanhe suas consultas'),
  _MenuAction(Icons.description_outlined, 'Guias e Documentos',
      'Consulte guias, laudos e comprovantes'),
  _MenuAction(Icons.receipt_long_outlined, 'Financeiro',
      'Boletos e histórico de pagamentos'),
  _MenuAction(Icons.person_outline, 'Meus Dados',
      'Atualize suas informações cadastrais'),
  _MenuAction(Icons.support_agent_outlined, 'Central de Ajuda',
      'Fale com o nosso atendimento'),
];

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza de que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _openAction(BuildContext context, _MenuAction action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${action.label}: funcionalidade em desenvolvimento.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá, Beneficiário'),
        actions: [
          Semantics(
            label: 'Sair da conta',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'O que você precisa hoje?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Color.alphaBlend(
                    colorScheme.primary.withValues(alpha: 0.45),
                    colorScheme.onSurface,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Sizes the grid so every card fits the available space at
              // once — no scrolling needed regardless of screen size.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 14.0;
                    final columns = constraints.maxWidth >= 700
                        ? 4
                        : constraints.maxWidth >= 480
                            ? 3
                            : 2;
                    final rows = (_menuActions.length / columns).ceil();
                    final cardWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                            columns;
                    final cardHeight =
                        (constraints.maxHeight - spacing * (rows - 1)) / rows;
                    final compact = cardHeight < 150;

                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: _menuActions.length,
                      itemBuilder: (context, index) {
                        final action = _menuActions[index];
                        return _MenuCard(
                          action: action,
                          compact: compact,
                          onTap: () => _openAction(context, action),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.action,
    required this.onTap,
    this.compact = false,
  });

  final _MenuAction action;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconSize = compact ? 34.0 : 44.0;

    return Semantics(
      button: true,
      label: '${action.label}. ${action.description}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action.icon,
                    color: colorScheme.onPrimaryContainer,
                    size: compact ? 20 : 24,
                    semanticLabel: '',
                  ),
                ),
                SizedBox(height: compact ? 6 : 12),
                Text(
                  action.label,
                  style: (compact
                          ? theme.textTheme.labelLarge
                          : theme.textTheme.titleSmall)
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!compact) ...[
                  const SizedBox(height: 4),
                  Text(
                    action.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Color.alphaBlend(
                        colorScheme.primary.withValues(alpha: 0.35),
                        colorScheme.onSurface,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
