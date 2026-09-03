import 'package:flutter/material.dart';

import '../consts/styles.dart';

class TopAppBar extends StatelessWidget {
  const TopAppBar({
    super.key,
    this.titulo,
    this.alVolver,
    this.alAccion,
    this.textoAccion,
  });

  final String? titulo;
  final VoidCallback? alVolver;
  final VoidCallback? alAccion;
  final String? textoAccion;

  @override
  Widget build(BuildContext context) {
    final muestraVolver = alVolver != null;
    final muestraAccion = alAccion != null;

    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            if (muestraVolver) ...[
              _AccionCabecera(
                etiquetaSemantica: 'Volver',
                simbolo: '‹',
                tamanoFuente: 32,
                color: const Color(0xFF616161),
                alTocar: alVolver!,
              ),
              const SizedBox(width: 16),
            ],
            if (titulo != null)
              Expanded(
                child: Text(
                  titulo!,
                  style: const TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontFamily: semibold,
                    fontSize: 24,
                    height: 32 / 24,
                  ),
                ),
              )
            else
              const Spacer(),
            if (muestraAccion) ...[
              if (titulo != null || muestraVolver) const SizedBox(width: 16),
              _AccionCabecera(
                etiquetaSemantica: textoAccion ?? 'Agregar',
                simbolo: textoAccion ?? '+',
                tamanoFuente: textoAccion == null ? 28 : 16,
                color: const Color(0xFF2E2E2E),
                ancho: textoAccion == null ? 24 : 60,
                alTocar: alAccion!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccionCabecera extends StatelessWidget {
  const _AccionCabecera({
    required this.etiquetaSemantica,
    required this.simbolo,
    required this.tamanoFuente,
    required this.color,
    this.ancho = 24,
    required this.alTocar,
  });

  final String etiquetaSemantica;
  final String simbolo;
  final double tamanoFuente;
  final Color color;
  final double ancho;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: etiquetaSemantica,
      child: InkWell(
        onTap: alTocar,
        child: SizedBox(
          width: ancho,
          height: 32,
          child: Center(
            child: Text(
              simbolo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontFamily: regular,
                fontSize: tamanoFuente,
                height: 32 / tamanoFuente,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
