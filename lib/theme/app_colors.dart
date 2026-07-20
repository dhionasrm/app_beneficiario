import 'package:flutter/material.dart';

/// Official Uniodonto brand palette, transcribed from BrandBook-Uniodonto-v5BG.pdf.
///
/// Sources (page 49/50 — "Diretrizes da marca" and page 53 — "Paleta
/// cromática complementar"):
/// - `vinhoEscuro` is the institution's core identity color. Per the
///   brandbook, the support tones may vary but must always be *combined
///   with* Vinho-Escuro, never replace it — so it stays the seed/primary
///   color in both themes rather than just a decorative option.
/// - The "cores vibrantes" are light, high-luminance accents: safe for
///   large text/icons over them with a dark wine tone, not for small body
///   text or as a filled-button background with white text (contrast <3:1).
class AppColors {
  AppColors._();

  // --- Paleta de apoio (institutional wine tones) ---
  static const Color vinhoEscuro = Color(0xFF810E56); // primary / core identity
  static const Color vinhoMedio = Color(0xFFA60069); // secondary
  static const Color vinhoUltra = Color(0xFF550039); // deepest — dark-mode surfaces
  static const Color vinhoClaro = Color(0xFFBC5688); // soft tint / decorative

  // --- Cores vibrantes (complementary accents) ---
  static const Color roxo = Color(0xFFBF9CFF);
  static const Color pessego = Color(0xFFFF9FAD);
  static const Color ciano = Color(0xFF60EBFF);
  static const Color lima = Color(0xFFE1FF7B);
  static const Color goiaba = Color(0xFFFF637E);

  /// Seed for Material 3's tonal palette generation, which keeps every
  /// derived container/on-color pairing at an accessible contrast ratio
  /// automatically. Semantic colors below are hand-picked because their
  /// meaning must stay stable regardless of theme brightness.
  static const Color seed = vinhoEscuro;

  static const Color success = Color(0xFF1B7F4D);
  static const Color successOnLight = Color(0xFF0F5132);
  static const Color warning = Color(0xFFB25E00);
  static const Color warningOnLight = Color(0xFF7A3E00);
}
