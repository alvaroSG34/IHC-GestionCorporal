import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../consts/styles.dart';

class BotonGuardar extends StatelessWidget {
  const BotonGuardar({
    super.key,
    required this.texto,
    required this.alPresionar,
    this.estaCargando = false,
    this.colorFondo = auxiliar,
    this.colorTexto = const Color(0xFF616161),
  });

  final String texto;
  final VoidCallback? alPresionar;
  final bool estaCargando;
  final Color colorFondo;
  final Color colorTexto;

  @override
  Widget build(BuildContext context) {
    final habilitado = alPresionar != null && !estaCargando;

    return SizedBox(
      width: 138,
      height: 46,
      child: Material(
        color: colorFondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: colorFondo),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: habilitado ? alPresionar : null,
          child: Center(
            child: estaCargando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(texto, style: figmaButton.copyWith(color: colorTexto)),
          ),
        ),
      ),
    );
  }
}
