import 'package:flutter/material.dart';

/// Full-width primary action button with a built-in busy state.
///
/// Wrapped in [Semantics] with `liveRegion: true` so screen readers announce
/// the "carregando" state change instead of silently swallowing it — button
/// text alone doesn't change, so without this an assistive user gets no
/// feedback that their tap registered.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      liveRegion: isLoading,
      label: isLoading ? '$label, carregando' : label,
      child: ExcludeSemantics(
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
