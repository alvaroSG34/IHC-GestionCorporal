import 'package:flutter/material.dart';

import '../consts/colors.dart';
import '../consts/styles.dart';

class BotonGuardar extends StatelessWidget {
  const BotonGuardar({
    super.key,
    required this.texto,
    required this.alPresionar,
    this.estaCargando = false,
    this.anchoCompleto = false,
    this.colorFondo = auxiliar,
    this.colorTexto = textoSecundario,
    this.alto = 46,
    this.radio = 10,
    this.conSombra = false,
  });

  final String texto;
  final VoidCallback? alPresionar;
  final bool estaCargando;
  final bool anchoCompleto;
  final Color colorFondo;
  final Color colorTexto;
  final double alto;
  final double radio;
  final bool conSombra;

  @override
  Widget build(BuildContext context) {
    final habilitado = alPresionar != null && !estaCargando;

    return SizedBox(
      width: anchoCompleto ? double.infinity : 138,
      height: alto,
      child: Material(
        color: colorFondo,
        elevation: conSombra ? 3 : 0,
        shadowColor: const Color.fromRGBO(36, 43, 20, 0.18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: BorderSide(color: colorFondo),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radio),
          onTap: habilitado ? alPresionar : null,
          child: Center(
            child: estaCargando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    texto,
                    style: figmaButton.copyWith(
                      color: colorTexto,
                      fontSize: alto == 54 ? 19 : null,
                      height: alto == 54 ? 24 / 19 : null,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
