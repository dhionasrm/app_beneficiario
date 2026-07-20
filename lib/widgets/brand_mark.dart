import 'package:flutter/material.dart';

/// The Uniodonto "U" mark (from `arquivos/IconeJ.jpeg`, cut out with a
/// transparent background). Centralized here so every screen that shows the
/// logo stays in sync if the artwork is ever swapped.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Logo Uniodonto',
      image: true,
      child: Image.asset(
        'assets/icon/icon_foreground.png',
        width: size,
        height: size,
        excludeFromSemantics: true,
      ),
    );
  }
}
